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

Whether you're playing with large data, designing spatial pipelines, or developing scientific packages, at some point you will become the creator of a regrettably sluggish piece of ~~junk~~ code. That's not the end of the world though, there are options ahead!

One of these options is quite *simple*: throw some money at AWS and just get **MORE**.

![Kylo Ren says MORE!](more.gif)

Of course I mean **more computational power**. Who doesn't love that? I definitely do!

However, the MORE strategy is rarely ever enough for *bona fide* nerds, masochists, and anyone in between. Why? Because such folks (maybe you, maybe me) love their craft and can't run anything short of perfect in their machines. Such folks, for better or worse, **optimize their code**!

But what does it really mean to optimize code, and how far should we go?

Optimizing code isn't just about speed; it's about writing *efficient* code. Efficient for the developers and users, and efficient for the machines running it. For us, pitiful carbon-based blobs, **readable** code is easier to wield, *ergo* efficient. On the other hand, for a machine, whether we're talking about a tiny Raspberry Pi or a magnificent supercomputer, efficient code **runs fast** and has a **small memory footprint**. 

Optimizing code to improve efficiency across the board means balancing the needs of both humans and machines. And there's an inherent tension there: maximizing computational performance often comes at the cost of readability, while clean, readable code can sometimes slow things down.

That's why optimization isn’t just about squeezing out more speed, it’s about making strategic choices. Before diving headfirst into refactoring, it's crucial to **understand what efficiency really means** and **when optimization is actually worth it**.

## Understanding Code Efficiency

*Code efficiency* is an abstract concept involving a complex web of causes and effects. I don't have the intention of unveiling the whole thing bare here, but I do believe that understanding some of the foundations helps articulate successful code optimization strategies. These foundations are simplified in the diagram below, which represents the most relevant causes and consequences of code efficiency.

![](diagram.png)
On the left, the causes comprise several major *code features* that we can tweak to improve (or worsen!) the efficiency of our code. Changes in these features are bound to shape the *efficiency landscape* of our code in often divergent ways.

### The Causes

#### Programming Language

The selection of an [interpreted versus a compiled language](https://thevaluable.dev/difference-between-compiler-interpreter/) defines major code features and efficiency consequences. Interpreted languages like R and Python offer a high-level syntax that helps write clear and concise code. They are also easier to debug, but are slow and memory-hungry. On the other hand, compiled languages such as C++ or Rust run fast with little memory overheads, but are harder to write and debug. In practice, a good sweet spot emerges from leveraging the best of both worlds. Tools like [Rcpp (runs C++ code within R)](https://www.rcpp.org/) or [Cython (runs C code within Python)](https://cython.org/) allow combining both kinds of languages to increase performance without sacrificing as much readability at the expense of higher code complexity.

#### Simplicity and Readability

Software exists for us developers and users, and our time is far more valuable than CPU time! That's why the most straightforward way to to improve efficiency is **making your code clean!** Clean code is readable, modular (but not [excessively modular!](https://softengbook.org/articles/deep-modules)), easy to use, and easy to maintain. However, striking a good balance between readability and computational efficiency is key here: excessive simplicity may leave other gains off the table!

#### Algorithm Design and Data Structures

[**Algorithms**](https://www.geeksforgeeks.org/fundamentals-of-algorithms/?ref=lbp) are the hearts of our code! They move bits around tirelessly until their purpose is achieved or an exception is raise. A well designed algorithm is the hallmark of efficient code. A good algorithm has a clear scope, relies on memory-efficient **data structures**, scales efficiently with data size, and avoids redundant steps. At this stage, understanding the trade-offs between algorithm design and readability allows for better optimization decisions. For example, algorithms involving data frames in R are easy to read, but using a more optimized albeit less readable structure such as [data.table](https://rdatatable.gitlab.io/data.table/) in performance-critical sections can yield significant improvements.

#### Hardaware Utilization

There are many techniques to help improve how algorithms and data structures leverage our machine's resources. For example, many functions in R rely on [**vectorization**](https://www.noamross.net/archives/2014-04-16-vectorization-in-r-why/) to processes entire vectors simultaneously in the CPU, vastly outperforming explicit loops. 

[**Parallelization**](http://computing.stat.berkeley.edu/tutorial-parallelization/parallel-R.html) accelerates execution by spreading tasks across multiple processors. There are several requirements to improve code efficiency via parallelization:

  - The code must be easy to split into independent tasks (a.k.a [*embarrasingly parallel*](https://en.wikipedia.org/wiki/Embarrassingly_parallel)).
  - The computation time of a task must be longer than the time required to move its input and output data between memory or disk to the CPU and back, or otherwise the communication overhead will cause a [parallel slowdown](https://en.wikipedia.org/wiki/Parallel_slowdown). Parallelizing very short tasks is not worth it!
  - The total memory required by all tasks running simultaneously must not exceed the available system memory. 
  - *The total memory required by all tasks running simultaneously must not exceed the available system memory*. 
  - **The total memory required by all tasks running simultaneously must not exceed the available system memory**. 
  
Still, even under ideal conditions, parallelization has well-known diminishing returns formulated in [Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl%27s_law). Beyond some point, we cannot simply throw more processors at our code and expect efficiency gains!

But what about more memory?

Bad **memory management** will kick your ass sooner or later.

A program repeatedly allocating and freeing chunks of memory of varying sizes accumulates non-contiguous free gaps between used memory blocks that are hard to re-allocate. This issue is known as [memory fragmentation](https://en.wikipedia.org/wiki/Fragmentation_%28computing%29), and leads to a higher memory usage, performance slowdowns. 

Efficient **memory management** ensures that our code uses the system's memory in a *sensible* manner. But what seems *sensible* in a beefy development laptop might end crashing a production machine, so there are levels to what efficient memory management actually means.

Being *memory aware* is a first step in the right direction. And this is a silly concept, really, but keeping a memory monitor like [htop](https://htop.dev/) and the likes open during code development and testing helps build an intuition on the memory usage pattern of our program. 

What strategies are used to manage memory in R depend a lot on the context, but there are a few good practices we can apply to consistently improve memory management:

  - **In-place modification** (also known as *modification by reference*): modifying objects without duplicating them is probably the most efficient strategy we can apply to manage memory in R. [Section 2.5 of the book **Advanced R**](https://adv-r.hadley.nz/names-values.html#modify-in-place) covers the nitty-gritty details. If you usually work with data frames, then the package [`data.table`](https://rdatatable.gitlab.io/data.table/) may come as a life-saver, as it has an [innate ability to modify large data frames in place](https://rdatatable.gitlab.io/data.table/articles/datatable-reference-semantics.html). 

  - **Pre-allocating object size**: Growing objects in a loop (think of adding new rows to a data frame) [isn't great](https://library.virginia.edu/data/articles/why-preallocate-memory-r-loops) in terms of memory management and [makes things slow](https://privefl.github.io/blog/why-loops-are-slow-in-r/). This happens because [R has to to reallocate memory](https://insightr.wordpress.com/2018/08/23/growing-objects-and-loop-memory-pre-allocation/) on each iteration, and that takes time and increases memory usage. But if growing *something* is unavoidable, either [grow a list](https://stackoverflow.com/questions/68701726/r4-0-performance-dataframes-vs-lists-loops-vs-vectorized-example-with-consta), as lists are dynamically allocated (rather than pre-allocated) and don't require their elements to be stored in contiguous memory regions, or apply [benchmarking to identify the most efficient method](https://www.mm218.dev/posts/2023-08-29-allocations/)).

Memory management in R is a deep rabbit hole, but there are several great resources out there that may help you find your footing on this topic:

  - [Best Coding Practices for R](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/): The chapters [10](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/types.html), [11](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/reference.html) and [12](https://bookdown.org/content/d1e53ac9-28ce-472f-bc2c-f499f18264a3/releasememory.html) of this regrettably unfinished on-line book offers plenty of tips and tricks to improve memory management in R. 
  - Chapter 14 of [The Art of R Programming](https://archive.org/details/Norman_Matloff___The_Art_of_R_Programming/mode/2up) (pdf available [here](https://diytranscriptomics.com/Reading/files/The%20Art%20of%20R%20Programming.pdf)): might seem dated, but goes deep on the trade-off between computational speed and memory usage through many enlightening examples.
  - [Advanced R](http://adv-r.had.co.nz/): the first edition of this essential book has the chapter [Memory](http://adv-r.had.co.nz/memory.html#gc), which explains in detail how *modification in place* and *garbage collection* work in R.

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



