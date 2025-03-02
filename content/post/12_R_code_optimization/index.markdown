---
title: "Optimizing R Code"
author: ""
date: '2025-02-21'
slug: R-code-optimization
categories: []
tags:
- Rstats
- Data Science
- Tutorial
subtitle: ''
summary: "Post focused on fundamental concepts on code optimization, with a practical showcase of optimization techniques for R code."
authors: [admin]
lastmod: '2025-02-21T07:28:01+01:00'
featured: no
draft: true
image:
  caption: ''
  focal_point: Smart
  margin: auto
projects: []
toc: true
---

<script src="{{< blogdown/postref >}}index_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index_files/jquery/jquery.min.js"></script>
<script src="{{< blogdown/postref >}}index_files/d3/d3.min.js"></script>
<link href="{{< blogdown/postref >}}index_files/profvis/profvis.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/profvis/profvis.js"></script>
<script src="{{< blogdown/postref >}}index_files/profvis/scroll.js"></script>
<link href="{{< blogdown/postref >}}index_files/highlight/textmate.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index_files/highlight/highlight.js"></script>
<script src="{{< blogdown/postref >}}index_files/profvis-binding/profvis.js"></script>
<style>
.alert-warning {
  background-color: #f4f4f4;
  color: #333333;
  border-color: #333333;
}
</style>

# Resources

- [Premature Optimization: Why It’s the “Root of All Evil” and How to Avoid It](https://effectiviology.com/premature-optimization/#%E2%80%9CPremature_optimization_is_the_root_of_all_evil%E2%80%9D)
- [Why Premature Optimization is the Root of All Evil?](https://www.geeksforgeeks.org/premature-optimization/)
- [Time Complexity and Space Complexity](https://www.geeksforgeeks.org/time-complexity-and-space-complexity/)
- [Time and Space Complexity](https://itsgg.com/2025/01/15/time-and-space-complexity.html)

## Summary

Optimizing code isn’t just about speed, it’s about writing *efficient* code. Efficient for the developer (you, maybe?), and efficient for the machine running it.

Drawing from my experience handling large, complex datasets and pipelines in academia and industry, here I share practical techniques and tools that can help you streamline your R workflows without sacrificing clarity. Whether you’re optimizing for speed, memory efficiency, or reproducibility, this guide should provide a solid foundation for improving your code in ways that are both effective and sustainable.

If you’re looking to make your R code both faster and more maintainable, this guide is for you.

## Understanding Code Efficiency

When working with large datasets or complex machine learning models, performance bottlenecks can drain both time and money. That’s where **code optimization** steps in to either save the day or make things worse.

For data scientists and researchers, optimization isn’t just about raw speed; it’s about making workflows more efficient, whatever that means for you.

The diagram below illustrates the hierarchy of elements defining code efficiency. The orange boxes highlight modifiable code components, while the green boxes indicate measurable performance dimensions and emergent performance properties.

![](diagram.png)

Software exists for us developers and users, and our time is far more valuable than CPU time! That’s why **code simplicity** sits at the top of the hierarchy of elements defining code efficiency. The best way to improve efficiency? **Make your code simple!** Simplicity means writing readable, modular, and easy-to-use code. However, striking a balance between readability and optimization is key: over-optimization can make code unreadable, while excessive simplicity might leave major performance gains on the table.

Beneath simplicity, **algorithm design** and **data structures** form the core of code efficiency. Well-designed algorithms and appropriate data structures contribute the most to performance in most cases. However, the **programming language** also plays a crucial role. An efficient algorithm implemented in C++ may vastly outperform the same algorithm written in R due to differences in compilation, memory management, and execution models.

Next, **hardware utilization** determines how well algorithms and data structures leverage computational resources. Techniques like *vectorization*, *parallelization*, *GPU acceleration*, and *memory management* can dramatically increase performance and improve efficiency.

These foundational choices impact three key performance dimensions:

- **Execution Speed** (Time Complexity): The time required to run the code.
- **Memory Usage** (Space Complexity): Peak RAM consumption during execution.
- **Input/Output Efficiency**: How well the code handles file access, network usage, and database queries.

At a higher level, two emergent properties arise:

- **Scalability**: How well the code adapts to increasing workloads and larger infrastructures.
- **Energy Efficiency**: The trade-off between computational cost and energy consumption.

Code optimization is a multidimensional trade-off. Improving one aspect often affects others. For example, speeding up execution might increase memory usage, parallelization can create I/O bottlenecks, and refactoring for performance may reduce readability. There’s rarely a single “best” solution, only trade-offs based on context and constraints.

## To Optimize Or Not To Optimize, That Is The Question

If for some reason you find yourself in the conundrum expressed in the title of this section, then you might find solace in the *First Commandment of Code Optimization*.

> “Thou shall not optimize thy code.”

Also known in some circles as the *[YOLO](https://dictionary.cambridge.org/dictionary/english/yolo) Principle*, this commandment reveals the righteous path! If your code **is reasonably simple and works as expected**, you can call it a day and move on, because there is no reason whatsoever to attempt any optimization. This idea aligns well with a principle enunciated long ago:

> “Premature optimization is the root of all evil.”  
> — [Donald Knuth](https://en.wikipedia.org/wiki/Donald_Knuth) - [*The Art of Computer Programming*](https://en.wikipedia.org/wiki/The_Art_of_Computer_Programming)

*Premature optimization* happens when we let performance considerations get in the way of our code design. Designing code is a taxing task already, and designing code while trying to make it efficient at once is even harder! Having a non-trivial fraction of our mental bandwidth focused on optimization results in code more complex than it should be, and increases the chance of introducing bugs.

<figure>
<img src="https://imgs.xkcd.com/comics/optimization.png" alt="https://xkcd.com/1691/" />
<figcaption aria-hidden="true">https://xkcd.com/1691/</figcaption>
</figure>

That said, there are legitimate reasons to break the first commandment. Maybe you are bold enough to publish your code in a paper (Reviewer \#2 says *hi*), releasing it as package for the community, or simply sharing it with your data team. In these cases, the *Second Commandment* comes into play.

> “Thou shall make thy code simple.”

Optimizing code for simplicity isn’t just about aesthetics; it’s about making it readable, maintainable, and easy to use and debug. In essence, this commandment ensures that we optimize the time required to interact with the code. Any code that saves the time of users and maintainers is efficient enough already!

This post is not focused on code simplicity, but here are a few key principles that might be helpful:

- **Use a consistent style**: Stick to a recognizable style guide, such as the [tidyverse style guide](https://style.tidyverse.org/) or [Google’s R style guide](https://google.github.io/styleguide/Rguide.html).

- **Avoid deep nesting**: Excessive nesting makes code harder to read and debug. This wonderful video makes the point quite clear: [Why You Shouldn’t Nest Your Code](https://www.youtube.com/watch?v=CFRhGnuXG-4).

- **Use meaningful names**: Clear names for functions, arguments, and variables make the code self-explanatory! Avoid cryptic abbreviations or single-letter names and do not hesitate to use long and descriptive names. The video [Naming Things in Code](https://www.youtube.com/watch?v=-J3wNP6u5YU) is a great resource on this topic.

- **Limit number of function arguments**: According to [Uncle Bob Martin](https://en.wikipedia.org/wiki/Robert_C._Martin), author of the book [“Clean Code”](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), *the ideal number of arguments for a function is zero*. There’s no need to be that extreme, but it is important to acknowledge that the user’s cognitive load increases with the number of arguments. If a function has more than five args you can either rethink your approach or let the user pay the check.

Beyond these tips, I highly recommend the book [A Philosophy of Software Design](https://www.amazon.com/dp/173210221X), by [John Ousterhout](https://en.wikipedia.org/wiki/John_Ousterhout). It helped me find new ways to write better code!

At this point we have a clean and elegant code that runs once and gets the job done, great! But what if it must run thousands of times in production? Or worse, what if a single execution takes hours or even days? In these cases, optimization shifts from a nice-to-have to a requirement. Yep, there’s a commandment for this too.

> “Thou shall optimize wisely.”

At this point you might be at the ready, fingers on the keyboard, about to deface your pretty code for the sake of sheer performance. Just don’t. This is a great point to stop, go back to the whiteboard, and think *carefully* about what you ~~want~~ need to do. You gotta be smart about your next steps!

Here there are a couple of ideas that might help you *get smart* about optimization.

First, keep the [Pareto Principle](https://en.wikipedia.org/wiki/Pareto_principle) in mind! It says that, roughly, 80% of the consequences result from 20% of the causes. When applied to code optimization, this principle translates into a simple fact: *most performance issues are produced by a small fraction of the code*. From here, the best course of action requires identifying these critical code blocks (more about this later) and focusing our optimization efforts on them. Once you’ve identified the real bottlenecks, the next step is making sure your optimizations don’t introduce unnecessary complexity.

Second, **beware of over-optimization**. Taking code optimization too far can do more harm than good! Over-optimization happens when we keep pushing for marginal performance gains at the expense of clarity. It often results in convoluted one-liners and obscure tricks to save milliseconds that will confuse future you while making your code harder to maintain. Worse yet, excessive tweaking can introduce subtle bugs. In short, optimizing wisely means knowing when to stop. A clear, maintainable solution that runs fast enough is often better than a convoluted one that chases marginal gains.

<figure>
<img src="https://imgs.xkcd.com/comics/fixing_problems.png" alt="https://xkcd.com/1739" />
<figcaption aria-hidden="true">https://xkcd.com/1739</figcaption>
</figure>

Beyond these important points, there is no golden rule to follow here. Optimize when necessary, but never at the cost of clarity!

## Profiling and Benchmarking

Profiling and benchmarking are methods to measure your code’s performance and help guide optimization decisions. The former helps identify low-performance hot-spots in your code, while the latter helps make informed choices between alternative implementations.

### Profiling

Profiling helps analyze your code to understand where the execution time and RAM memory are spent, and will help you answer the question: *Where should I start optimizing?* Profilers break down code execution into function calls, highlighting potential bottlenecks

In R, the function `utils::Rprof()` is the default profiling tool. You can find a great explanation on this tool in the chapter [Profiling R Code](https://bookdown.org/rdpeng/rprogdatascience/profiling-r-code.html#profiling-r-code) of the book *R Programming for Data Science*, by [Roger D. Peng](https://rdpeng.org/).

The function [`profvis::profvis()`](https://profvis.r-lib.org/reference/profvis.html) is a modern alternative that still uses `Rprof()` underneath, but generates a neat HTML widget to facilitate the visualization and interpretation of profiling data.

The code block below shows the silly function `f()`, which computes a correlation test between two large vectors generated randomly from a normal and a uniform distribution.

``` r
f <- function(n = 1e7){
  stats::cor.test(
    x = stats::rnorm(n = n), 
    y = stats::runif(n = n)
  )
}
```

Let’s profile it with `profvis()`:

``` r
profvis::profvis(
  expr = f(), 
  rerun = TRUE
  )
```

<style>
  .profvis .dataTable td, .profvis .dataTable th {
    min-width: 150px;
    white-space: normal;
  }
</style>
<style>
table.display td { white-space: nowrap; }
</style>
<div id="htmlwidget-1" style="width:100%;height:400px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"message":{"prof":{"time":[1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,30,30,31,31,32,32,33,33,34,34,35,35,36,36,37,37,38,38,39,39,40,40,41,41,42,42,43,43,44,44,45,45,46,46,47,47,48,48,49,49,50,50,51,51,52,52,53,53,54,54,55,55,56,56,57,57,58,58,59,59,60,60,61,61,62,62,63,63,64,64,65,65,66,66,67,67,68,68,69,69,70,70,71,71,72,72,73,73,74,74,75,75,76,76,77,77,78,78,79,79,80,80,81,81,82,82,83,83,84,84,85,85,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,94,94,95,95,96,96,97,97,98,98,99,99,100,100,101,101,102,102,103,103,104,104,105,105,106,106,107,107,108,108,109,109,110,110,111,111,112,112,113,113,114,114,115,115,116,116,117,117,118,118,119,119,120,120,121,121,122,122,123,123,124,124,125,125,126,126,127,127,128,128,129,129,130,130,131,131,132,132,132,133,133,133,134,134,134,135,135,135,136,136,136,137,137,137,138,138,138,139,139,139,140,140,140,141,141,141,142,142,142,143,143,143,144,144,144,145,145,145,146,146,146,147,147,147,148,148,149,149,150,150,151,151,152,152,153,153,153,154,154,154,155,155,155,156,156,156,157,157,157,158,158,158,159,159,160,160,161,161,162,162,163,163,164,164,165,165,166,166,167,167,168,168,168,169,169,169,170,170,170,171,171,171,172,172,172,173,173,173,174,174,174,175,175,176,176,177,177,178,178,179,179,180,180,180,181,181,181,182,182,182,183,183,183,184,184,184,185,185,185,186,186,186,187,187,187,188,188,188,189,189,189],"depth":[3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1],"label":["<GC>","stats::rnorm","f","<GC>","stats::rnorm","f","<GC>","stats::rnorm","f","<GC>","stats::rnorm","f","<GC>","stats::rnorm","f","<GC>","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","stats::rnorm","f","<GC>","stats::runif","f","<GC>","stats::runif","f","<GC>","stats::runif","f","<GC>","stats::runif","f","<GC>","stats::runif","f","<GC>","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","stats::runif","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","complete.cases","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","<GC>","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f","cor","cor.test.default","f"],"filenum":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"linenum":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"memalloc":[9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167732238769531,9.167610168457031,9.167610168457031,9.167610168457031,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.46155548095703,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49605560302734,85.49596405029297,85.49596405029297,85.49596405029297,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,161.789909362793,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9394760131836,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,199.9371871948242,238.0841674804688,238.0841674804688,238.0841674804688,238.0841674804688,238.0841674804688,238.0841674804688,276.2311401367188,276.2311401367188,276.2311401367188,276.2311401367188,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,238.0841598510742,314.3781051635742,314.3781051635742,314.3781051635742,314.3781051635742,314.3781051635742,314.3781051635742,314.3781051635742,314.3781051635742,352.5250854492188,352.5250854492188,352.5250854492188,352.5250854492188,390.6720581054688,390.6720581054688,390.6720581054688,390.6720581054688,390.6720581054688,390.6720581054688,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,352.5250778198242,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.6720504760742,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727,390.7656631469727],"meminc":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.0001220703125,0,0,76.2939453125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0345001220703125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-9.1552734375e-05,0,0,76.2939453125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,38.14956665039062,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.002288818359375,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,38.14698028564453,0,0,0,0,0,38.14697265625,0,0,0,-38.14698028564453,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,76.2939453125,0,0,0,0,0,0,0,38.14698028564453,0,0,0,38.14697265625,0,0,0,0,0,-38.14698028564453,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,38.14697265625,0,0,0,0,0,0,0,0,0,0.0936126708984375,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"filename":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"interval":10,"files":[],"prof_output":"/tmp/RtmpUyxykc/file2eb33cef847b.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script>

The Data view in the result of `profvis()` highlights the computational hotspots in our code in a very intuitive way. As such, it is a very useful tool to guide software optimization. However, there are some limitations to be aware of. The column `Memory (MB)` can be unreliable due to R’s lazy memory management and garbage collection ()

However, it is important to be aware of its limitations

The mem column in profvis is often unreliable, with many values missing or inaccurate. This is due to R’s lazy memory management and garbage collection, which can obscure real-time allocations. Copy-on-modify behavior further complicates tracking, especially for large objects. On some systems, like Windows, memory profiling may not work at all. For better insights, consider pryr::mem_change(), bench::mark(), or Rprofmem().

show that `stats::rnorm()` is the most obvious time sink in `f()`, while there no obvious memory bottlenecks

, while showing that there are no memory usage differences with `stats::runif()`.

If you wish to learn more, there are several `profvis` examples available in this [vignette](https://profvis.r-lib.org/articles/examples.html).

Another alternative leveraging `Rprof()` is the package [`proftools`](https://cran.r-project.org/package=proftools). It does not produce a neat html widget, but has [extended plotting functionalities](https://cran.r-project.org/web/packages/proftools/vignettes/proftools.pdf).

### Benchmarking

benchmarking is the process of running alternative versions (original *vs.* optimized) of a piece of code to compare their performance. It’s purpose is helping make data-driven decisions during code optimization.

![https://xkcd.com/1445](https://imgs.xkcd.com/comics/efficiency.png)
The R package [`microbenchmark`](https://cran.r-project.org/package=microbenchmark)

``` r
library(microbenchmark)

df <- data.frame(
  x = stats::runif(n = 1e7)
)

microbenchmark::microbenchmark(
  df$x,
  df[["x"]],
  df[, "x"],
  dplyr::pull(df, x),
  times = 100
)
```

    ## Unit: nanoseconds
    ##                expr    min       lq       mean   median       uq       max
    ##                df$x    697   1417.5    2134.62   1864.0   2204.0     22250
    ##           df[["x"]]   7839   8548.5    9684.44   9317.0  10059.5     28639
    ##           df[, "x"]  11656  12670.5   14742.47  13644.5  16391.5     26519
    ##  dplyr::pull(df, x) 214985 217744.5 2880768.28 220234.5 227871.0 265628320
    ##  neval
    ##    100
    ##    100
    ##    100
    ##    100

The R package [`bench`](https://bench.r-lib.org/) provides a

``` r
library(bench)

benchmark <- bench::mark(
  df$x,
  df[["x"]],
  df[, "x"],
  dplyr::pull(df, x),
  iterations = 100,
  check = FALSE
)
```

        Test real-world data: Benchmarks should reflect the actual data and usage patterns in your application.
        Use repeated trials: Small variations in timing can occur between trials, so repeat your benchmark several times and look for consistent results.

Putting It Together

    Profile your code first to identify the parts that need optimization.
    Implement optimizations carefully and gradually.
    Benchmark the old and new versions of your code to ensure that changes actually improve performance.

Remember: performance tuning should be a process of continuous improvement, not an all-at-once overhaul. Focus on high-impact changes that significantly improve execution time or memory usage.

Advanced R, by Hadley Whickham, has a [great section in code optimization]().

## The Optimization Loop

Optimizing R code isn’t a one-time task, it’s an iterative process that starts with

![](flowchart.png)

2.  Measure Performance (Profile Your Code!)

Instead of guessing where bottlenecks might be, use profiling tools to identify the actual slow parts of your code:

    Use profvis::profvis() or Rprof() for detailed profiling.
    For quick benchmarking, use bench::mark() or microbenchmark::microbenchmark().
    Log memory usage with lobstr::mem_used() if memory is a concern.

This step helps you find real inefficiencies, so you don’t waste time optimizing parts of the code that aren’t problematic.

3.  Optimize the Low-Hanging Fruit

Once you know where the real slowdowns are, optimize only the parts that provide significant gains without compromising clarity. Some common low-hanging fruit:

    Eliminate unnecessary computations (e.g., avoid redundant loops, reuse calculations).
    Refactor bottleneck functions (e.g., replace slow operations with built-in vectorized alternatives).
    Simplify data handling (e.g., use appropriate data types, avoid excessive copies of large objects).

Avoid over-optimizing too early—focus only on fixes that are clear, easy to implement, and make a measurable difference.

4.  Iterate Until Satisfied

After each round of optimization, re-profile your code and check if further improvements are needed. If performance is now acceptable, stop optimizing. If not, repeat the process:

    Profile again.
    Identify new bottlenecks.
    Optimize only where necessary.
    Repeat until additional optimization no longer justifies the cost in complexity.

The Golden Rule: Stop When It’s “Good Enough”

Optimization should be goal-driven, not an endless pursuit of perfection. If your code is fast enough for its intended use case, further optimization is unnecessary, especially if it would reduce readability or maintainability.

By following this loop, you ensure that your R code remains clean, efficient, and easy to maintain while optimizing only when it truly matters.
