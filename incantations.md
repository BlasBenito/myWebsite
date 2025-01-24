#Making math work

To make latex math work as `$$ equation here $$` I added the code below, from https://yihui.org/en/2018/07/latex-math-markdown/, to `themes/hugo-academic/layouts/partials/page_footer.html

<script src="//yihui.org/js/math-code.js"></script>

<script async
src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

Also, as note, be aware of https://www.stderr.nl/Blog/Blog/MathJaxInMarkdown.html

#Code highlighting
Downloaded highlightjs from https://highlightjs.org/download, and unpacked in /static.

Added this code to themes/hugo-academic/layouts/partials/page_footer.html:

<!-- Add highlight.js CSS -->
<link rel="stylesheet" href="/static/highlight/styles/agate.css">
<!-- Add highlight.js JS -->
<script src="/static/highlight/highlight.min.js"></script>
<!-- Initialize highlight.js -->
<script>
  document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('pre code').forEach((block) => {
      hljs.highlightBlock(block);
    });
  });
</script>
