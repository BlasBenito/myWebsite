---
title: "R Code Optimization III: Hardware Utilization and Performance"
author: ""
date: '2025-12-20'
slug: R-code-optimization-hardware-performance
categories: []
tags:
- Rstats
- Data Science
- Tutorial
- Code Optimization
subtitle: ''
summary: "The third post in a four-part series on code optimization, covering vectorization, parallelization, and memory management techniques to maximize computational efficiency."
authors: [admin]
lastmod: '2025-03-21T07:28:01+01:00'
featured: no
draft: false
image:
  caption: ''
  focal_point: Smart
  margin: auto
projects: []
toc: true
---

<style>
.alert-warning {
  background-color: #f4f4f4;
  color: #333333;
  border-color: #333333;
}
</style>



Welcome to the third post in this series! In the [first article](/2025/12/18/r-code-optimization-foundations-principles/) we covered key concepts, in the [second](/2025/12/19/r-code-optimization-design-readability/) we explored language choices and algorithm design. Now we'll talk a bit about where the real performance gains happen: vectorization, parallelization, and memory management.

## Hardware Utilization

Hardware utilization refers to how code leverages computational resources. For example, vectorization and parallelization help us squeeze every last drop of juice from our CPUs, while in-place modification, object size pre-allocation, and on-demand data access are useful to manage memory usage.

## Vectorization

Vectorization refers to the application of an operation to multiple elements simultaneously.

At the hardware level, vectorization is enabled by an architectural feature known as [Single Instruction Multiple Data (SIMD)](https://johnnysswlab.com/crash-course-introduction-to-parallelism-simd-parallelism/). SIMD operations can, for example, sum 16 pairs of vector elements simultaneously within a single core, offering substantial speed-ups. However, only compiled languages (C, C++, Fortran, etc) can leverage SIMD instructions via specific [compiler optimizations](https://blog.minhazav.dev/guide-compiler-to-auto-vectorise/).

At the software level, many languages implement **vectorized semantics**. Think of adding two vectors `b` and `c` with the expression `a = b + c`. This abstraction makes code concise, and can also unlock performance gains in different ways. In compiled languages like Fortran, such expressions are typically optimized for SIMD vectorization. In interpreted languages like R, many vectorized functions are backed by compiled code. For instance, primitives like `+` are implemented as fast C loops, that may or may not be optimized for SIMD by the compiler (see the section *R side: how can R possibly use SIMD?* in [this excellent StackOverflow answer](https://stackoverflow.com/a/37214261) for details). In contrast, matrix operations rely on [blazing-fast matrix algebra backends](https://medium.com/@shiansu/calling-blas-in-r-the-hard-way-da90e0206d99) such as [BLAS](https://brettklamer.com/diversions/statistical/faster-blas-in-r/) and [LAPACK](https://www.netlib.org/lapack/), which explicitly exploit SIMD vectorization (and parallelization!).

However, it's not uncommon to find vectorized semantics without performance gains. This is the case with R functions like `apply()`, `lapply()`, `purrr::map()`, and the likes, which are essentially loops in a trenchcoat.

By combining SIMD vectorization for raw performance with semantics-level vectorization for expressiveness, we maximize hardware utilization while keeping our code clean and efficient.

## Parallelization

[**Parallelization**](http://computing.stat.berkeley.edu/tutorial-parallelization/parallel-R.html) accelerates execution by spreading independent tasks across multiple cores. At the software level, parallelization can be achieved by spawning multiple processes, each with its own memory space, or by a [process spawning several threads](https://www.geeksforgeeks.org/difference-between-process-and-thread/), all them sharing the same memory space.

### Explicit vs Implicit Parallelization

Parallelization can be **explicit** and **implicit**.

**Explicit parallelization** requires the user to define how and where parallel tasks are executed. This approach offers fine control over execution but also demands more setup and understanding of parallel workflows. In R, [parallelized loops](https://www.blasbenito.com/post/parallelized-loops-r/) written with the packages [`doParallel`](https://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf) and [`foreach`](https://cran.r-project.org/package=foreach) require defining a parallelization backend (a.k.a "cluster"), selecting a number of cores, and a specific syntax (`y <- foreach(...) %dopar% {...}`). That's pretty explicit if you ask me! Modern alternatives like [`future`](https://future.futureverse.org/) and [`future.apply`](https://future.apply.futureverse.org/) achieve the same results with a less involved code.

On the other hand, **implicit parallelization** happens without user intervention or even knowledge. For example, the packages [`arrow`](https://cran.r-project.org/package=arrow), [`data.table`](https://rdatatable.gitlab.io/data.table/), or [`ranger`](https://imbs-hl.github.io/ranger/) apply multithreading to parallelize many data operations. This is also the case of matrix operations in R (i.e. GAM fitting with `mgcv::gam()`), which are multithreaded by the matrix algebra libraries [BLAS](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms) and [Intel MKL](https://en.wikipedia.org/wiki/Math_Kernel_Library).

The [CRAN Task View: High-Performance and Parallel Computing with R](https://cran.r-project.org/web/views/HighPerformanceComputing.html) offers a more complete overview of the different parallelization options available in R.

### Requirements for Effective Parallelization

In any case, parallelization has several requirements:

- The task must be easy to split into independent sub-tasks (a.k.a [*embarrassingly parallel*](https://en.wikipedia.org/wiki/Embarrassingly_parallel)).
- The computation time of a task must be longer than the time required to move its input and output data between memory or disk to the CPU and back, or otherwise the communication overhead will cause a [parallel slowdown](https://en.wikipedia.org/wiki/Parallel_slowdown). Parallelizing very fast tasks is rarely worth it!
- The memory required by a parallel task times the number of parallel processes **must not exceed the available system memory**. I wrote this one in bold so you can remember it whenever your code crashes for this very reason!

Even under ideal conditions, parallelization has well-known diminishing returns formulated in [Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl%27s_law). That just means that beyond some point we cannot simply throw more processors at our code and expect immediate efficiency gains.

## Memory Management

Let's jump into what's IMHO the most interesting topic of this article!

Computers have a [short-term memory](https://en.wikipedia.org/wiki/Computer_memory) directly connected to the processor named *main memory*, *system memory*, or *RAM*. Any code and data required by a program *lives* (and sometimes *dies*) there during run time. 

For example, when we start an R session, the operating system assigns it a section of the system memory, and all functions of the packages `base`, `stats`, `graphics`, and a few others are read from disk and loaded there. So does the code of any package you load using `library()`, or the data your program reads from disk, or any results it generates via models or other computations.

Main memory is FAST, but FINITE! If a program requires more memory than available, the operating system may start moving parts of the main memory to the hard disk (see [memory paging](https://en.wikipedia.org/wiki/Memory_paging) and [swap file](https://www.linux.com/news/all-about-linux-swap-space/)), slowing things down. In extreme cases, a program can [run out of memory](https://en.wikipedia.org/wiki/Out_of_memory) and crash.

![Computer Crash](parks-and-rec-rage.gif)

Also, a program repeatedly allocating and deallocating memory chunks of varying sizes usually accumulates non-contiguous free gaps between used memory blocks that are hard to re-allocate. This issue, known as [memory fragmentation](https://en.wikipedia.org/wiki/Fragmentation_%28computing%29), leads to performance slowdowns and a higher memory usage that can end with a crash.

If your code tries to use more RAM than your system has available, things slow down dramatically or crash altogether.

![Easy Memory Management](more_ram.jpeg)

Efficient memory management can help avoid these issues by ensuring that our code uses the system's memory in a *sensible* manner.

Being *memory aware* is a first step in the right direction. And this is a silly concept, really, but keeping a memory monitor like [htop](https://htop.dev/) and the likes open during code development and testing helps build an intuition on how our program uses memory. There are more precise methods I'll talk about in a coming article, but really, that's a good start.

Other good techniques we can apply to consistently improve memory management in R are in-place modification, pre-allocating object size, and on-demand data access.

### In-place Modification

Also known as *modification by reference*, it refers to object modification without duplication (see [*copy-on-modify in R*](https://stackoverflow.com/questions/15759117/what-exactly-is-copy-on-modify-semantics-in-r-and-where-is-the-canonical-source)). This is probably the most consistent strategy we can apply to manage memory in R! The [section 2.5 of the book **Advanced R**](https://adv-r.hadley.nz/names-values.html#modify-in-place) covers the technical details, and offers great advice: *We can reduce the number of copies by using a list instead of a data frame. Modifying a list uses internal C code, so ... no copy is made*. If data frames are your jam, then the package [`data.table`](https://rdatatable.gitlab.io/data.table/) may come as a life-saver, as it has an [innate ability to modify large data frames in place](https://rdatatable.gitlab.io/data.table/articles/datatable-reference-semantics.html), making it fast and efficient.

### Object Size Pre-allocation

[Growing data frames, vectors, or matrices in a loop](https://library.virginia.edu/data/articles/why-preallocate-memory-r-loops) triggers the *copy-on-modify* behavior of R and [makes things very slow](https://privefl.github.io/blog/why-loops-are-slow-in-r/). This happens because [R has to reallocate memory](https://insightr.wordpress.com/2018/08/23/growing-objects-and-loop-memory-pre-allocation/) on each iteration for the object's copy, which takes time and increases memory usage. But if growing *something* is unavoidable, either **pre-allocate the object size**, or better, [grow a list](https://stackoverflow.com/questions/68701726/r4-0-performance-dataframes-vs-lists-loops-vs-vectorized-example-with-consta), as lists are dynamically allocated (rather than pre-allocated) and don't require their elements to be stored in contiguous memory regions. In any case, when in doubt, apply [benchmarking to identify the most efficient method](https://www.mm218.dev/posts/2023-08-29-allocations/).

### On-demand Data Access

**On-demand data access** refers to several data handling strategies to work with data larger than memory.

**Memory-mapped files** are representations of large on-disk data in the [virtual memory of the operating system](https://en.wikipedia.org/wiki/Virtual_memory). The operating system handles directly the on-demand reading and caching of specific portions of these files, which reduces memory overhead at the expense of increased disk reads (having an efficient SSD is a game changer here!) and computation time. In R, the packages [mmap](https://cran.r-project.org/package=mmap) and [ff](https://cran.r-project.org/package=ff) (see brief tutorial [here](https://bookdown.org/josephine_lukito/bookdown-demo/ff.html#ff-1)) offer low-level memory-mapping implementations, while the [bigmemory](https://cran.r-project.org/package=bigmemory) package [focuses on large matrices](http://www.stat.yale.edu/~mjk56/temp/bigmemory-vignette.pdf).

**Chunk-wise processing** involves explicitly dividing large data into smaller and more manageable pieces, making it a flexible solution for handling large-scale computations efficiently. For example, the package [terra](https://rspatial.github.io/terra/index.html) combines this technique with [lazy evaluation](https://colinfay.me/lazyeval/) when working with large raster files to control memory usage.

**Modern data solutions** like [Apache Arrow](https://arrow.apache.org/) and [DuckDB](https://duckdb.org/) provide efficient columnar storage and query capabilities. The `arrow` package enables efficient on-demand access and streaming reads with `arrow::open_dataset()`, while DuckDB brings SQL-powered processing to R with support for lazy evaluation and filtering only relevant data subsets.

The package [targets](https://docs.ropensci.org/targets/) combines chunk-wise processing, parallelization, and multisession execution seamlessly via [*dynamic branching*](https://books.ropensci.org/targets/dynamic.html).

### Memory Management Resources

Memory management in R is a deep rabbit hole, but there are several great resources out there that may help you find your footing on this topic:

- [Best Coding Practices for R](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/): The chapters [10](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/types.html), [11](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/reference.html) and [12](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/releasememory.html) of this regrettably unfinished on-line book offers plenty of tips and tricks to improve memory management in R.
- Chapter 14 of [The Art of R Programming](https://archive.org/details/Norman_Matloff___The_Art_of_R_Programming/mode/2up) (pdf available [here](https://diytranscriptomics.com/Reading/files/The%20Art%20of%20R%20Programming.pdf)): might seem dated, but goes deep on the trade-off between computational speed and memory usage through many enlightening examples.
- [Advanced R](https://adv-r.hadley.nz/index.html): the first edition of this essential book has the chapter [Memory](http://adv-r.had.co.nz/memory.html#gc), which explains in detail how *modification in place* and *garbage collection* work in R. Chapter 24 in the latest version, titled [Improving Performance](https://adv-r.hadley.nz/perf-improve.html#perf-improve) is full of tips to improve general performance in R code.

## Wrapping Up

And that's it! We've covered the three major pillars of hardware utilization: vectorization, parallelization, and memory management. These techniques can deliver dramatic performance gains when applied appropriately.

The [final post](/2025/12/21/r-code-optimization-toolbox/) focuses on practical tools for code optimization: profiling to identify bottlenecks, benchmarking to validate improvements, and the iterative optimization workflow that ties all these concepts into a systematic process.
