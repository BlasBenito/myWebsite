---
title: "R Code Optimization I: A Few Principles"
author: ""
date: '2025-03-06'
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
lastmod: '2025-03-06T07:28:01+01:00'
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



## Summary

This is the first post of a trilogy focused on code optimization.

## Code Optimization: Who Dis?

Whether you're playing with large data, designing spatial pipelines, or developing scientific packages, at some point you will find yourself as the creator of a regrettably sluggish piece of ~~junk~~ code.

. No worries, it happens. A lot.

The easiest solution is usually having **more**.

![Kylo Ren says MORE!](more.gif)

You know, more cores, more RAM, whatever makes AWS happy!

too slow for your deadline, 

or requiring *just a bit more memory* (AWS is gonna cash it!)

And at that point you might start reading about **code optimization** because why not, we are nerds, and nerds do these kind of things.

But what does it really mean to optimize code, and how far should we go?

Optimizing code isn't just about speed; it's about writing *efficient* code. Efficient for the developer (you, maybe?), and efficient for the machine running it. However, code efficiency is in the eye of the beholder! For us, pitiful flesh blobs, **readable** code makes things easier, *ergo* efficient. On the other hand, for a machine, no matter whether we are talking about a tiny Raspberry Pi or a magnificent supercomputer, code that **runs fast** and has a **small memory footprint** makes things faster and cheaper.


In this post, I'll draw from my experience developing scientific software in both academia and industry to share a practical techniques and tools that can help you streamline your R workflows without sacrificing clarity. By the end, you’ll have a solid understanding of the foundational principles of code optimization and when to approach it—without overcomplicating things.

Whether you're optimizing for speed, memory efficiency, or reproducibility, the conceptual framework presented here provides general principles to improve your code in ways that are both effective and sustainable. 

Let’s dig in!

## Understanding Code Efficiency

When working with large datasets or complex machine learning models, performance bottlenecks can drain both time and money. That’s where **code optimization** steps in to either save the day or make things worse.

For data scientists and researchers, optimization isn’t just about raw speed; it’s about making workflows more efficient, whatever that means for you. 

The diagram below illustrates the hierarchy of elements defining code efficiency. The orange boxes highlight modifiable code components, while the green boxes indicate measurable performance dimensions and emergent performance properties.

![](diagram.png)

Software exists for us developers and users, and our time is far more valuable than CPU time! That's why **code simplicity** sits at the top of the hierarchy of elements defining code efficiency. The best way to improve efficiency? **Make your code simple!** Simplicity means writing readable, modular, and easy-to-use code. However, striking a balance between readability and optimization is key: over-optimization can make code unreadable, while excessive simplicity might leave major performance gains on the table.

Beneath simplicity, **algorithm design** and **data structures** form the core of code efficiency. Well-designed algorithms and appropriate data structures contribute the most to performance in most cases. However, the **programming language** also plays a crucial role. An efficient algorithm implemented in C++ may vastly outperform the same algorithm written in R due to differences in compilation, memory management, and execution models.

Next, **hardware utilization** determines how well algorithms and data structures leverage computational resources. Techniques like *vectorization*, *parallelization*, *GPU acceleration*, and *memory management* can dramatically increase performance and improve efficiency.

These foundational choices impact three key performance dimensions:

  - **Execution Speed** (Time Complexity): The time required to run the code.
  - **Memory Usage** (Space Complexity): Peak RAM consumption during execution.
  - **Input/Output Efficiency**: How well the code handles file access, network usage, and database queries.

At a higher level, two emergent properties arise:

  - **Scalability**: How well the code adapts to increasing workloads and larger infrastructures.
  - **Energy Efficiency**: The trade-off between computational cost and energy consumption.

Code optimization is a multidimensional trade-off. Improving one aspect often affects others. For example, speeding up execution might increase memory usage, parallelization can create I/O bottlenecks, and refactoring for performance may reduce readability. There’s rarely a single "best" solution, only trade-offs based on context and constraints.

## To Optimize Or Not To Optimize, That Is The Question

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






