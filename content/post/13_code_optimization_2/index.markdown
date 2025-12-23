---
title: "R Code Optimization II: Language, Design, and Readability"
author: ""
date: '2025-12-19'
slug: R-code-optimization-design-readability
categories: []
tags:
- Rstats
- Data Science
- Tutorial
- Code Optimization
subtitle: ''
summary: "The second post in a series on code optimization, exploring how programming languages, clean code principles, and how algorithm design shapes code efficiency."
authors: [admin]
lastmod: '2025-12-22T07:28:01+01:00'
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



In the [first article](/2025/12/18/r-code-optimization-foundations-principles/) I covered the dimensions of code efficiency, and the three commandments of code optimization. This (very brief) article focuses on the actual code features that shape efficiency: programming languages, code design, and algorithms.

## Programming Language

The choice between a compiled and an interpreted language (see [here](https://medium.com/basecs/a-deeper-inspection-into-compilation-and-interpretation-d98952ebc842) and [here](https://thevaluable.dev/difference-between-compiler-interpreter/)) shapes key aspects of code efficiency.

![It's always C++](interpreted_vs_compiled.jpeg)

In languages like C, C++, or Fortran, the code we write is translated into binary code by a [compiler](https://medium.com/@fivemoreminix/understanding-compilers-for-humans-ba970e045877) before execution. Compilers optimize the binary code for the given hardware, resulting in **very fast execution and a low memory overhead**. These are the hallmarks of efficient code for a machine! But on the other hand, compiled languages lack interactive execution, which makes them harder to debug.

![Is it?](love_c++.jpeg)

In contrast, languages like R and Python, much easier to write and read, are translated and executed line-by-line by an [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)). Interpreters enable interactive execution and facilitate debugging at the expense of speed and a higher memory usage. Here goes [a rabbit-hole on the R interpreter](https://www.codeproject.com/Articles/5338916/Introducing-Rsharp-Language) for the brave!

The boundary between compiled and interpreted languages isn't rigid though: many built-in functions in interpreted languages rely on compiled code for speed. Tools like [Rcpp](https://www.rcpp.org/) (C++ in R) or [Cython](https://cython.org/) (C in Python) can [boost performance](https://github.com/deanbodenham/benchmarks_rpycpp) by orders of magnitude, albeit with added code complexity.

## Simplicity and Readability

Software exists for us, developers and users, and our time is far more valuable than CPU time! That's why the most straightforward way to improve efficiency is writing **clean code**. Clean code is readable, modular (but not [excessively modular!](https://softengbook.org/articles/deep-modules)), easy to use, and easy to maintain.

The key here is reducing the cognitive load required to maintain AND use the code. That is exactly the focus of the best book I've read on this topic: [A Philosophy of Software Design](https://milkov.tech/assets/psd.pdf). It changed the way I code! 

For example, the book presents the concept of **deep modules**, which are classes or functions with very simple interfaces (think of a well-named function with one or two arguments) hiding a complex functionality or long sequences of processing steps. Before reading it you might want to check this [review](https://blog.pragmaticengineer.com/a-philosophy-of-software-design-review/) and this interesting [podcast with the author](https://www.youtube.com/watch?v=lz451zUlF-k), or even this [talk by John Ousterhout himself](https://www.youtube.com/watch?v=bmSAYlu0NcY).

In the end, it is important to strike a good balance between code readability and computational efficiency, as excessive simplicity may leave other efficiency gains off the table.

### Key Principles for Clean Code

Here are some fundamental principles to keep your code readable and maintainable:

- **Use a consistent style**: Stick to a recognizable style guide, such as the [tidyverse style guide](https://style.tidyverse.org/) or [Google's R style guide](https://google.github.io/styleguide/Rguide.html).

- **Avoid deep nesting**: Excessive nesting makes code harder to read and debug. This wonderful video makes the point quite clear: [Why You Shouldn't Nest Your Code](https://www.youtube.com/watch?v=CFRhGnuXG-4).

- **Use meaningful names**: Clear names for functions, arguments, and variables make the code self-explanatory! Avoid cryptic abbreviations or single-letter names and do not hesitate to use long and descriptive names. The video [Naming Things in Code](https://www.youtube.com/watch?v=-J3wNP6u5YU) is a great resource on this topic.

- **Limit number of function arguments**: According to [Uncle Bob Martin](https://en.wikipedia.org/wiki/Robert_C._Martin), author of the book ["Clean Code"](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), *the ideal number of arguments for a function is zero*. There's no need to be that extreme, but it is important to acknowledge that the user's cognitive load increases with the number of arguments. If a function has more than five args you can either rethink your approach or let the user pay the check.

## Algorithm Design and Data Structures

There is no efficient code without a well-designed [**algorithm**](https://www.geeksforgeeks.org/fundamentals-of-algorithms/?ref=lbp). Good algorithms have a clear purpose, avoid redundant steps, and scale well with data size.

Choosing the right **data structure** for the job can make a huge difference in speed, readability, and memory usage. For instance, in R, vectors and matrices are more memory-efficient and faster than data frames for numerical operations, but in certain contexts, [reference semantics](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-reference-semantics.html) applied to a [`data.table`](https://rdatatable.gitlab.io/data.table/) (extension of R's data frames) can be orders of magnitude faster, at the expense of readability (the [syntax can get weird](http://brooksandrew.github.io/simpleblog/articles/advanced-data-table/)).

A complete overview on the role of algorithm design and data structures in code optimization is well beyond the scope of this post. However, if you wish to go further, I strongly recommend the classic book [The Algorithm Design Manual](https://mimoza.marmara.edu.tr/~msakalli/cse706_12/SkienaTheAlgorithmDesignManual.pdf), which bridges theory and practice with elegance.

In the [next article](/2025/12/20/r-code-optimization-hardware-performance/) I will tackle some juicy stuff about how our code uses computational resources: vectorization, parallelization, and memory management. 
