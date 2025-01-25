#Making math work

To make latex math work as `$$ equation here $$` I added the code below, from https://yihui.org/en/2018/07/latex-math-markdown/, to `themes/hugo-academic/layouts/partials/page_footer.html

<script src="//yihui.org/js/math-code.js"></script>

<script async
src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

Also, as note, be aware of https://www.stderr.nl/Blog/Blog/MathJaxInMarkdown.html

#Code highlighting

Add this to config.toml

  [markup.highlight]
    codeFences = true
    hl_Lines = ""
    lineNoStart = 1
    lineNos = false
    lineNumbersInTable = true
    noClasses = true
#styles here https://xyproto.github.io/splash/docs/all.html, but not all work
    style = "github" #style name
    tabWidth = 4

<script>
  document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('pre code').forEach((block) => {
      hljs.highlightBlock(block);
    });
  });
</script>


#Copy Button (could not make it work though)
https://github.com/jmooring/hugo-testing/tree/hugo-forum-topic-49633

#Table of Contents
https://github.com/HugoBlox/hugo-blox-builder/issues/1520#issuecomment-601982609
http://ericfong.ca/post/floatingtoc/
