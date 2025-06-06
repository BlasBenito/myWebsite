---
title: "R Code Optimization I: A Few Principles"
author: ""
date: '2025-03-07'
slug: R-code-optimization-principles
categories: []
tags:
- Rstats
- Data Science
- Tutorial
- Code Optimization
subtitle: ''
summary: "This post presents a code optimization framework."
authors: [admin]
lastmod: '2025-03-07T07:28:01+01:00'
featured: no
draft: true
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



## A Trilogy of Posts on Code Optimization

This is the first post of a trilogy focused on code optimization.

I'll draw from my experience developing scientific software in both academia and industry to share a practical techniques and tools that can help you streamline your R workflows without sacrificing clarity. By the end, you’ll have a solid understanding of the foundational principles of code optimization and when to approach it—without overcomplicating things.

I hope the principles presented here will help you write code that’s not just faster but also sustainable and practical to maintain.

Let’s dig in!

## A Fine Balance

Whether you're playing with large data, designing spatial pipelines, or developing scientific packages, at some point everyone writes a regrettably sluggish piece of ~~junk~~ code.

The simplest way to make it run is simple enough: throw more money at your cloud provider, or upgrade your rig, and get **MORE**!

![Kylo Ren says MORE!](more.gif)
More cores, more RAM, more POWER! Because who doesn't love bragging about that shit? I surely do!

<blockquote class="mastodon-embed" data-embed-url="https://fosstodon.org/@blasbenito/110305047179219534/embed" style="background: #FCF8FF; border-radius: 8px; border: 1px solid #C9C4DA; margin: 0; max-width: 800; min-width: 270px; overflow: hidden; padding: 0;"> <a href="https://fosstodon.org/@blasbenito/110305047179219534" target="_blank" style="align-items: center; color: #1C1A25; display: flex; flex-direction: column; font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Oxygen, Ubuntu, Cantarell, 'Fira Sans', 'Droid Sans', 'Helvetica Neue', Roboto, sans-serif; font-size: 14px; justify-content: center; letter-spacing: 0.25px; line-height: 20px; padding: 24px; text-decoration: none;"> <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="32" height="32" viewBox="0 0 79 75"><path d="M74.7135 16.6043C73.6199 8.54587 66.5351 2.19527 58.1366 0.964691C56.7196 0.756754 51.351 0 38.9148 0H38.822C26.3824 0 23.7135 0.756754 22.2966 0.964691C14.1319 2.16118 6.67571 7.86752 4.86669 16.0214C3.99657 20.0369 3.90371 24.4888 4.06535 28.5726C4.29578 34.4289 4.34049 40.275 4.877 46.1075C5.24791 49.9817 5.89495 53.8251 6.81328 57.6088C8.53288 64.5968 15.4938 70.4122 22.3138 72.7848C29.6155 75.259 37.468 75.6697 44.9919 73.971C45.8196 73.7801 46.6381 73.5586 47.4475 73.3063C49.2737 72.7302 51.4164 72.086 52.9915 70.9542C53.0131 70.9384 53.0308 70.9178 53.0433 70.8942C53.0558 70.8706 53.0628 70.8445 53.0637 70.8179V65.1661C53.0634 65.1412 53.0574 65.1167 53.0462 65.0944C53.035 65.0721 53.0189 65.0525 52.9992 65.0371C52.9794 65.0218 52.9564 65.011 52.9318 65.0056C52.9073 65.0002 52.8819 65.0003 52.8574 65.0059C48.0369 66.1472 43.0971 66.7193 38.141 66.7103C29.6118 66.7103 27.3178 62.6981 26.6609 61.0278C26.1329 59.5842 25.7976 58.0784 25.6636 56.5486C25.6622 56.5229 25.667 56.4973 25.6775 56.4738C25.688 56.4502 25.7039 56.4295 25.724 56.4132C25.7441 56.397 25.7678 56.3856 25.7931 56.3801C25.8185 56.3746 25.8448 56.3751 25.8699 56.3816C30.6101 57.5151 35.4693 58.0873 40.3455 58.086C41.5183 58.086 42.6876 58.086 43.8604 58.0553C48.7647 57.919 53.9339 57.6701 58.7591 56.7361C58.8794 56.7123 58.9998 56.6918 59.103 56.6611C66.7139 55.2124 73.9569 50.665 74.6929 39.1501C74.7204 38.6967 74.7892 34.4016 74.7892 33.9312C74.7926 32.3325 75.3085 22.5901 74.7135 16.6043ZM62.9996 45.3371H54.9966V25.9069C54.9966 21.8163 53.277 19.7302 49.7793 19.7302C45.9343 19.7302 44.0083 22.1981 44.0083 27.0727V37.7082H36.0534V27.0727C36.0534 22.1981 34.124 19.7302 30.279 19.7302C26.8019 19.7302 25.0651 21.8163 25.0617 25.9069V45.3371H17.0656V25.3172C17.0656 21.2266 18.1191 17.9769 20.2262 15.568C22.3998 13.1648 25.2509 11.9308 28.7898 11.9308C32.8859 11.9308 35.9812 13.492 38.0447 16.6111L40.036 19.9245L42.0308 16.6111C44.0943 13.492 47.1896 11.9308 51.2788 11.9308C54.8143 11.9308 57.6654 13.1648 59.8459 15.568C61.9529 17.9746 63.0065 21.2243 63.0065 25.3172L62.9996 45.3371Z" fill="currentColor"/></svg> <div style="color: #787588; margin-top: 16px;">Post by @blasbenito@fosstodon.org</div> <div style="font-weight: 500;">View on Mastodon</div> </a> </blockquote> <script data-allowed-prefixes="https://fosstodon.org/" async src="https://fosstodon.org/embed.js"></script>

<br> 

On the other hand, money is expensive (duh!), and [computing has a serious environmental footprint](https://thereader.mitpress.mit.edu/the-staggering-ecological-impacts-of-computation-and-the-cloud/). With this in mind, it's also good to remember that [we went to the Moon and back on less than 4kb of RAM](https://en.wikipedia.org/wiki/Apollo_Guidance_Computer), so there must be a way to make our ~~junk~~ code run in a more sustainable manner.

This is where **code optimization** comes into play! 

Optimizing code is not about making it faster, it is about about making it **efficient** for developers, users, and machines alike.  For us, pitiful carbon-based blobs, **readable** code is easier to wield, *ergo* efficient. For a machine, efficient code **runs fast** and has a **small memory footprint**. And there is an inherent tension there! Optimizing for computational performance alone often comes at the cost of readability, while clean, readable code can sometimes slow things down. That's why optimization requires making some strategic choices. Before diving headfirst into code optimization, it's crucial to understand **the dimensions of code efficiency** and **when** code optimization is actually worth it.

## The Dimensions Code Efficiency

*Code efficiency* is an abstract concept involving a complex web of causes and effects. Unveiling the whole thing bare here is beyond the scope of this post, but I believe that understanding some of the foundations may help articulate successful code optimization strategies. 

Let's take a look at the diagram below.

![Pillars of Code Efficiency](diagram.png)
On the left, there are several major *code features* that we can tweak to improve (or worsen!) the efficiency of our code. Changes in these features are bound to shape the *efficiency landscape* of our code in often divergent ways.

### Code Features

#### Programming Language

The choice between a compiled and a interpreted language (see [here](https://medium.com/basecs/a-deeper-inspection-into-compilation-and-interpretation-d98952ebc842) and [here](https://thevaluable.dev/difference-between-compiler-interpreter/)) shapes key aspects of code efficiency. 

In languages like C, C++, or Fortran, the code we write is translated into binary code by a [compiler](https://medium.com/@fivemoreminix/understanding-compilers-for-humans-ba970e045877) before execution. Compilers optimize the binary code for the given hardware, resulting in a **very fast execution and a low memory overhead**. These are the hallmarks of efficient code for a machine! But on the other hand, compiled languages lack interactive execution, which makes them harder to debug.

In contrast, languages like R and Python, much easier to write and read, are translated and executed line-by-line by an [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)). Interpreters enable interactive execution and facilitate debugging at the expense of speed and a higher memory usage. Here goes [a rabbit-hole on the R interpreter](https://www.codeproject.com/Articles/5338916/Introducing-Rsharp-Language) for the brave!

The boundary between compiled and interpreted languages isn't rigid though: many built-in functions in interpreted languages rely on compiled code for speed. Tools like [Rcpp](https://www.rcpp.org/) (C++ in R) or [Cython ](https://cython.org/) (C in Python) can [boost performance](https://github.com/deanbodenham/benchmarks_rpycpp) by orders of magnitude, albeit with added code complexity.

#### Simplicity and Readability

Software exists for us, developers and users, and our time is far more valuable than CPU time! That's why the most straightforward way to improve efficiency is writing **clean code**. Clean code is readable, modular (but not [excessively modular!](https://softengbook.org/articles/deep-modules)), easy to use, and easy to maintain. 

The key here is reducing the cognitive load required to maintain AND use the code. That is exactly the focus of the best book I've read on this topic: [A Philosophy of Software Design](https://milkov.tech/assets/psd.pdf). It changed the way I code! For example, the book presents the concept of **deep modules**, which are classes or functions with very simple interfaces (think of a well-named function with one or two arguments) hiding a complex functionality or long sequences of processing steps. Before reading it you might want to check this [review](https://blog.pragmaticengineer.com/a-philosophy-of-software-design-review/) and this interesting [podcast with the author](https://www.youtube.com/watch?v=lz451zUlF-k), or even this [talk by John Ousterhout himself](https://www.youtube.com/watch?v=bmSAYlu0NcY).

In the end, it is important to strike a good balance between code readability and computational efficiency, as excessive simplicity may leave other efficiency gains off the table.

#### Algorithm Design and Data Structures

There is no efficient code without a well-designed [**algorithm**](https://www.geeksforgeeks.org/fundamentals-of-algorithms/?ref=lbp). Good algorithms have a clear purpose, avoid redundant steps, and scale well with data size.

Choosing the right **data structure** for the job can make a huge difference in speed, readability, and memory usage. For instance, in R, vectors and matrices are more memory-efficient and faster than data frames for numerical operations, but in certain contexts, [reference semantics](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reference-semantics.html) applied to a [`data.table`](https://rdatatable.gitlab.io/data.table/) (extension of R's data frames) can be orders of magnitude faster, at the expense of readability (the [syntax can get weird](http://brooksandrew.github.io/simpleblog/articles/advanced-data-table/)).

A complete overview on the role of algorithm design and data structures in code optimization is well beyond the scope of this post. However, if you wish to go further, I strongly recommend the classic book [The Algorithm Design Manual](https://mimoza.marmara.edu.tr/~msakalli/cse706_12/SkienaTheAlgorithmDesignManual.pdf), which bridges theory and practice with elegance.

#### Hardaware Utilization

Hardware utilization refers to how code leverages computational resources. For example, vectorization and parallelization help us squeeze every last drop of juice in our CPUS, while in-place modification, object size pre-allocation, and on-demand data access are useful to manage memory usage.

**Vectorization**

Vectorization refers to the application of an operation to multiple elements simultaneously.

At the hardware level, vectorization is enabled by an architectural feature known as [Single Instruction Multiple Data (SIMD)](https://johnnysswlab.com/crash-course-introduction-to-parallelism-simd-parallelism/). SIMD operations can, for example, sum 16 pairs of vector elements simultaneously within a single core, offering substantial speed-ups. However, only compiled languages (C, C++, Fortran, etc) can leverage SIMD instructions via specific [compiler optimizations](https://blog.minhazav.dev/guide-compiler-to-auto-vectorise/).

At the software level, many languages implement **vectorized semantics**. Think of adding two vectors `b` and `c` with the expression `a = b + c`. This abstraction makes code concise, and can also unlock performance gains in different ways. In compiled languages like Fortran, such expressions are typically optimized for SIMD vectorization. In interpreted languages like R, many vectorized functions are backed by compiled code. For instance, primitives like `+` are implemented as fast C loops, that may or may not be optimized for SIMD by the compiler (see the section *R side: how can R possibly use SIMD?* in [this excellent StackOverflow answer](https://stackoverflow.com/a/37214261) for details). In contrast, matrix operations rely on [blazing-fast matrix algebra backends](https://medium.com/@shiansu/calling-blas-in-r-the-hard-way-da90e0206d99) such as [BLAS](https://brettklamer.com/diversions/statistical/faster-blas-in-r/) and [LAPACK](https://www.netlib.org/lapack/), which explicitly exploit SIMD vectorization (and parallelization!). 

Some functions offer vectorized semantics without performance gains. This is the case with R functions like apply(), lapply(), purrr::map(), and the likes, which are essentially loops in a trenchcoat.

By combining SIMD vectorization for raw performance with semantics-level vectorization for expressiveness, we maximize hardware utilization while keeping our code clean and efficient.

**Parallelization**

[**Parallelization**](http://computing.stat.berkeley.edu/tutorial-parallelization/parallel-R.html) accelerates execution by spreading independent tasks across multiple CPU cores. 

Parallelization can be **explicit** and **implicit**. 

Explicit parallelization requires the user to define how and where parallel tasks are executed. In R, this is the case of [parallelized loops](https://www.blasbenito.com/post/parallelized-loops-r/) written with the packages [doParallel](https://cran.r-project.org/web/packages/doParallel/vignettes/gettingstartedParallel.pdf)  and [`foreach`](https://cran.r-project.org/package=foreach). These require the user to define a parallelization backend (a.k.a "cluster"), select the number of cores to use, and a specific syntax (`y <- foreach(...) %dopar% \{...\})

require the user to define a cluster, a number of workers


This approach offers fine control over execution but also demands more setup and understanding of parallel workflows. On the other hand, 


On the other hand, the latter happens under the hood. For example, the package [`data.table`]()


when fitting a GAM model with `mgcv::gam()`, matrix operations are run in parallel BLAS library runs in parallel during matrix operations, provided a multithreaded implementation like OpenBLAS or MKL is installed.

In any case, parallelization has several requirements:

  - The task must be easy to split into independent sub-tasks (a.k.a [*embarrasingly parallel*](https://en.wikipedia.org/wiki/Embarrassingly_parallel)).
  - The computation time of a task must be longer than the time required to move its input and output data between memory or disk to the CPU and back, or otherwise the communication overhead will cause a [parallel slowdown](https://en.wikipedia.org/wiki/Parallel_slowdown). Parallelizing very fast tasks is rarely worth it!
  - The memory required by a parallel task times the number of parallel processes **must not exceed the available system memory**. I wrote this one in bold so you can remember it whenever your code crashes for this very reason!
  
Even under ideal conditions, parallelization has well-known diminishing returns formulated in [Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl%27s_law). That just means that beyond some point we cannot simply throw more processors at our code and expect immediate efficiency gains.



Even though the R interpreter is single-threaded, the availability and usability of parallelization backends has improved dramatically over time.

Let's jump into what's IMHO the most interesting topic of this section...

**Memory Management!**

Computers have a [short-term memory](https://en.wikipedia.org/wiki/Computer_memory) directly connected to the processor named *main memory*, *system memory*, or *RAM*. Any code and data required by a program *lives* (and sometimes *dies*) there during run time. For example, when you start an R session, the operating system assigns it a section of the system memory, and all functions of the packages `base`, `stats`, `graphics`, and a few others are read from disk loaded there. So does the code of any package you load using `library()`, or the data your program reads from disk, or any results it generates via models or other computations. 

Main memory is FAST, but FINITE! If a program requires more memory than available, the operating system may start moving parts of the main memory to the hard disk (see [memory paging](https://en.wikipedia.org/wiki/Memory_paging) and [swap file](https://www.linux.com/news/all-about-linux-swap-space/)), slowing things down. In extreme cases, a program can [run out of memory](https://en.wikipedia.org/wiki/Out_of_memory) and crash.

![Computer Crash](parks-and-rec-rage.gif)

Also, a program repeatedly allocating and deallocating memory chunks of varying sizes usually accumulate non-contiguous free gaps between used memory blocks that are hard to re-allocate. This issue, known as [memory fragmentation](https://en.wikipedia.org/wiki/Fragmentation_%28computing%29), leads to performance slowdowns and a higher memory usage that can end with a crash. 





If your code tries to use more RAM than your system has available, things slow down dramatically or crash altogether.


![Easy Memory Mangement](more_ram.jpeg)



Efficient memory management can help avoid these issues by ensuring that our code uses the system's memory in a *sensible* manner. 

Being *memory aware* is a first step in the right direction. And this is a silly concept, really, but keeping a memory monitor like [htop](https://htop.dev/) and the likes open during code development and testing helps build an intuition on how our program uses memory. 

Other good techniques we can apply to consistently improve memory management in R are in-place modification, pre-allocating object size, and on-demand data access.

**In-place modification**

Also known as *modification by reference*, it refers to object modification without duplication (see [*copy-on-modify in R*](https://stackoverflow.com/questions/15759117/what-exactly-is-copy-on-modify-semantics-in-r-and-where-is-the-canonical-source)). This is probably the most consistent strategy we can apply to manage memory in R! The [section 2.5 of the book **Advanced R**](https://adv-r.hadley.nz/names-values.html#modify-in-place) covers the technical details, and offers great advice: *We can reduce the number of copies by using a list instead of a data frame. Modifying a list uses internal C code, so ... no copy is made*. If data frames are your jam, then the package [`data.table`](https://rdatatable.gitlab.io/data.table/) may come as a life-saver, as it has an [innate ability to modify large data frames in place](https://rdatatable.gitlab.io/data.table/articles/datatable-reference-semantics.html), making it fast and efficient. 

**Object size pre-allocation**

[Growing data frames, vectors, or matrices in a loop](https://library.virginia.edu/data/articles/why-preallocate-memory-r-loops) triggers the *copy-on-modify* behavior of R and [makes things very slow](https://privefl.github.io/blog/why-loops-are-slow-in-r/). This happens because [R has to to reallocate memory](https://insightr.wordpress.com/2018/08/23/growing-objects-and-loop-memory-pre-allocation/) on each iteration for the object's copy, which takes time and increases memory usage. But if growing *something* is unavoidable, either **pre-allocate the object size**, or better, [grow a list](https://stackoverflow.com/questions/68701726/r4-0-performance-dataframes-vs-lists-loops-vs-vectorized-example-with-consta), as lists are dynamically allocated (rather than pre-allocated) and don't require their elements to be stored in contiguous memory regions. In any case, when in doubt, apply [benchmarking to identify the most efficient method](https://www.mm218.dev/posts/2023-08-29-allocations/).

**On-demand data access** 

Refers to several data handling strategies to work with data larger than memory.

*[Memory-mapped files](https://en.wikipedia.org/wiki/Mmap)* are representations of large on-disk data in the [virtual memory of the operating system](https://en.wikipedia.org/wiki/Virtual_memory). The operating system handles directly the on-demand reading and caching of specific portions of these files, which reduces memory overhead at the expense of increased disk reads (having an efficient SSD is a game changer here!) and computation time. In R, the packages [mmap](https://cran.r-project.org/package=mmap) and [ff](https://cran.r-project.org/package=ff) (see brief tutorial [here](https://bookdown.org/josephine_lukito/bookdown-demo/ff.html#ff-1)) offer low-level memory-mapping implementations, while the [bigmemory](https://cran.r-project.org/package=bigmemory) package [focuses on large matrices](http://www.stat.yale.edu/~mjk56/temp/bigmemory-vignette.pdf).

*Chunk-wise processing* involves explicitly dividing large data into smaller and more manageable pieces, making it a flexible solution for handling large-scale computations efficiently. For example, the package [terra](https://rspatial.github.io/terra/index.html) combines this technique with [lazy evaluation](https://colinfay.me/lazyeval/) when working with large raster files to control memory usage. 



Out-of-process execution

The package [targets](https://docs.ropensci.org/targets/) combines chunk-wise processing, parallelization, and multisession execution seamlessly via [*dynamic branching*](https://books.ropensci.org/targets/dynamic.html).



combines chunk-wise processing with parallelization via dynamic branching.
    
    - **Chunk-wise processing**: this method allows reading and analyzing data in manageable pieces rather than loading everything at once. Here, the multi-platform library [Apache Arrow](https://arrow.apache.org/) allows efficient storage of data and retrieval  [feather](https://arrow.apache.org/docs/python/feather.html) and [parquet](https://parquet.apache.org/docs/overview/)

    arrow and duckdb: More recent solutions that integrate well with modern data workflows. arrow enables efficient columnar storage and lazy-loading via Apache Arrow and Parquet files, while duckdb is an embedded analytical database that can query large datasets on disk with SQL-like operations, often outperforming traditional chunk-wise approaches.
    
    
    Apache Arrow: The arrow package provides a columnar, memory-efficient format that supports on-demand access and streaming reads. With arrow::open_dataset(), you can process large datasets incrementally, loading only the necessary chunks without keeping everything in RAM.

DuckDB: This in-process database system brings SQL-powered chunk-wise processing to R. It supports querying large Parquet, CSV, or Arrow datasets efficiently, allowing lazy evaluation and pushdown filtering (i.e., reading only relevant data subsets).
    

    
    broom, arrow, disk.frame, fst, duckdb
  
  - **Multisession**:

Memory management in R is a deep rabbit hole, but there are several great resources out there that may help you find your footing on this topic:

  - [Best Coding Practices for R](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/): The chapters [10](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/types.html), [11](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/reference.html) and [12](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/releasememory.html) of this regrettably unfinished on-line book offers plenty of tips and tricks to improve memory management in R. 
  - Chapter 14 of [The Art of R Programming](https://archive.org/details/Norman_Matloff___The_Art_of_R_Programming/mode/2up) (pdf available [here](https://diytranscriptomics.com/Reading/files/The%20Art%20of%20R%20Programming.pdf)): might seem dated, but goes deep on the trade-off between computational speed and memory usage through many enlightening examples.
  - [Advanced R](https://adv-r.hadley.nz/index.html): the first edition of this essential book has the chapter [Memory](http://adv-r.had.co.nz/memory.html#gc), which explains in detail how *modification in place* and *garbage collection* work in R. Chapter 24 in the latest version, titled [Improving Performance](https://adv-r.hadley.nz/perf-improve.html#perf-improve) is full of tips to improve general performance in R code.

### The Effects

These foundational choices impact three key performance dimensions:

  - **Execution Speed** (Time Complexity): The time required to run the code.
  - **Memory Usage** (Space Complexity): Peak memory usage during run time.
  - **Input/Output Efficiency**: How well the code handles file access, network usage, and database queries.

At a higher level, two emergent properties arise:

  - **Scalability**: How well the code adapts to increasing workloads and larger infrastructures.
  
https://cran.r-project.org/web/packages/usl/vignettes/usl.pdf
https://en.wikipedia.org/wiki/Neil_J._Gunther#Universal_Scalability_Law
https://tangowhisky37.github.io/PracticalPerformanceAnalyst/pages/spe_fundamentals/what_is_universal_scalability_law/
  
  - **Energy Efficiency**: The trade-off between computational cost and energy consumption.

Code optimization is a multidimensional trade-off. Improving one aspect often affects others. For example, speeding up execution might increase memory usage, parallelization can create I/O bottlenecks. There's rarely a single "best" solution, only trade-offs based on context and constraints.

## To Optimize Or Not To Optimize

If for some reason you find yourself in the conundrum expressed in the title of this section, then you might find solace in the *First Commandment of Code Optimization*.

> "Thou shall not optimize thy code."  

Also known in some circles as the *[YOLO](https://dictionary.cambridge.org/dictionary/english/yolo) Principle*, this commandment reveals the righteous path! If your code **is reasonably simple and works as expected**, you can call it a day and move on, because there is no reason whatsoever to attempt any optimization. This idea aligns well with a principle enunciated long ago:

> "Premature optimization is the root of all evil."  
> — [Donald Knuth](https://en.wikipedia.org/wiki/Donald_Knuth) - [*The Art of Computer Programming*](https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming)

*Premature optimization* happens when we let performance considerations get in the way of our code design. Designing code is a taxing task already, and designing code while trying to make it efficient at once is even harder! Having a non-trivial fraction of our mental bandwidth focused on optimization results in code more complex than it should be, and increases the chance of introducing bugs.

![https://xkcd.com/1691/](https://imgs.xkcd.com/comics/optimization.png)

That said, there are legitimate reasons to break the first commandment. Maybe you are bold enough to publish your code in a paper (Reviewer #2 says *hi*), releasing it as package for the community, or simply sharing it with your data team. In these cases, the *Second Commandment* comes into play.

> "Thou shall make thy code simple."  

Optimizing code for simplicity isn't just about aesthetics; it's about making it readable, maintainable, and easy to use and debug. In essence, this commandment ensures that we optimize the time required to interact with the code. Any code that saves the time of users and maintainers is efficient enough already! 

This post is not focused on code simplicity, but here are a few key principles that might be helpful:

  - **Use a consistent style**: Stick to a recognizable style guide, such as the [tidyverse style guide](https://style.tidyverse.org/) or [Google’s R style guide](https://google.github.io/styleguide/Rguide.html).
  
  - **Avoid deep nesting**: Excessive nesting makes code harder to read and debug. This wonderful video makes the point quite clear: [Why You Shouldn't Nest Your Code](https://www.youtube.com/watch?v=CFRhGnuXG-4).
  
  - **Use meaningful names**: Clear names for functions, arguments, and variables make the code self-explanatory! Avoid cryptic abbreviations or single-letter names and do not hesitate to use long and descriptive names. The video [Naming Things in Code](https://www.youtube.com/watch?v=-J3wNP6u5YU) is a great resource on this topic.
  
  - **Limit number of function arguments**: According to [Uncle Bob Martin](https://en.wikipedia.org/wiki/Robert_C._Martin), author of the book ["Clean Code"](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), *the ideal number of arguments for a function is zero*. There's no need to be that extreme, but it is important to acknowledge that the user's cognitive load increases with the number of arguments. If a function has more than five args you can either rethink your approach or let the user pay the check.
  
Beyond these tips, I highly recommend the book [A Philosophy of Software Design](https://www.amazon.com/dp/173210221X), by [John Ousterhout](https://en.wikipedia.org/wiki/John_Ousterhout). It helped me find new ways to write better code!

At this point we have a clean and elegant code that runs once and gets the job done, great! But what if it must run thousands of times in production? Or worse, what if a single execution takes hours or even days? In these cases, optimization shifts from a nice-to-have to a requirement. Yep, there's a commandment for this too.

> "Thou shall optimize wisely." 

At this point you might be at the ready, fingers on the keyboard, about to deface your pretty code for the sake of sheer performance. Just don't. This is a great point to stop, go back to the whiteboard, and think *carefully* about what you ~~want~~ need to do. You gotta be smart about your next steps! 

Here there are a couple of ideas that might help you *get smart* about optimization.

First, keep the [Pareto Principle](https://en.wikipedia.org/wiki/Pareto_principle) in mind! It says that, roughly, 80% of the consequences result from 20% of the causes. When applied to code optimization, this principle translates into a simple fact: *most performance issues are produced by a small fraction of the code*. From here, the best course of action requires identifying these critical code blocks (more about this later) and focusing our optimization efforts on them. Once you've identified the real bottlenecks, the next step is making sure your optimizations don't introduce unnecessary complexity.

Second, **beware of over-optimization**. Taking code optimization too far can do more harm than good! Over-optimization happens when we keep pushing for marginal performance gains at the expense of clarity. It often results in convoluted one-liners and obscure tricks to save milliseconds that will confuse future you while making your code harder to maintain. Worse yet, excessive tweaking can introduce subtle bugs. In short, optimizing wisely means knowing when to stop. A clear, maintainable solution that runs fast enough is often better than a convoluted one that chases marginal gains.

![https://xkcd.com/1739](https://imgs.xkcd.com/comics/fixing_problems.png)

Beyond these important points, there is no golden rule to follow here. Optimize when necessary, but never at the cost of clarity!



