# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based academic/personal website built with the Hugo Academic theme and R's blogdown package. The site is deployed on Netlify and serves as a portfolio for publications, projects, and blog posts.

## Development Workflow

### Building and Serving the Site

```r
# Install Hugo (first time only)
blogdown::install_hugo()

# Build the entire site
blogdown::build_site()

# Start local development server
blogdown::serve_site()

# Stop development server
blogdown::stop_server()
```

### Creating New Posts

```r
# Create new blog post
blogdown::new_post(title = "post_title", ext = '.Rmarkdown', subdir = "post")
```

Posts should use `.Rmarkdown` extension as configured in `.Rprofile`:
```r
options(blogdown.method = 'markdown')
options(blogdown.hugo.version = "0.74.3")
```

### Hugo Commands

```bash
# Build site (used by Netlify)
hugo

# Build with future-dated content (for previews)
hugo --buildFuture

# Specify base URL
hugo -b <URL> --buildFuture
```

## Site Architecture

### Directory Structure

- `content/` - All content organized by type:
  - `post/` - Blog posts (numbered directories: `01_`, `02_`, etc.)
  - `publication/` - Academic publications
  - `project/` - Project descriptions
  - `authors/` - Author profiles (main profile in `authors/admin/`)
  - `home/` - Homepage widgets/sections
  - `talk/`, `slides/`, `courses/` - Additional content types

- `themes/hugo-academic/` - Hugo Academic theme (do not modify directly)

- `layouts/` - Custom layout overrides that take precedence over theme layouts:
  - `layouts/partials/` - Partial template overrides
  - `layouts/_default/` - Page template overrides
  - `layouts/shortcodes/` - Custom Hugo shortcodes

- `static/` - Static files served as-is:
  - `static/media/` - Images, icons, PDFs
  - `static/files/` - Downloadable files (CVs, resumes)
  - `static/rmarkdown-libs/` - Generated R Markdown support files

- `config.toml` - Main Hugo configuration
- `config/_default/` - Additional configuration files (params, menus, etc.)
- `public/` - Generated site output (not version controlled, except currently it is)
- `resources/` - Hugo's processing cache

### Key Configuration Files

- **config.toml**: Site title, baseURL, theme selection, markdown rendering, taxonomies
- **config/_default/params.toml**: Theme settings, fonts, social links, contact info
- **.Rprofile**: blogdown settings (Hugo version, rendering method)
- **netlify.toml**: Netlify deployment configuration (Hugo version: 0.74.3)

### Content Organization

Blog posts follow a numbered naming scheme:
- `01_home_cluster/`
- `02_parallelizing_loops_with_r/`
- `05_multicollinearity_model_interpretability/`
- etc.

Each post directory contains:
- `index.Rmarkdown` or `index.md` - Main content file
- Supporting images, data files
- Generated `index.markdown` (from .Rmarkdown files)

### Custom Modifications

**Math Support**: LaTeX math rendering configured in `themes/hugo-academic/layouts/partials/page_footer.html`:
```html
<script src="//yihui.org/js/math-code.js"></script>
<script async src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML"></script>
```

**Code Highlighting**: Configured in `config.toml`:
```toml
[markup.highlight]
  codeFences = true
  style = "github"
  lineNumbersInTable = true
```

## Important Notes

### Hugo Academic Theme

This site uses the Hugo Academic theme from `themes/hugo-academic/`. Do not modify theme files directly. Instead:
- Override layouts by creating corresponding files in `layouts/`
- Customize parameters in `config.toml` and `config/_default/params.toml`

### File Ignoring

Hugo ignores certain files (configured in `config.toml`):
```toml
ignoreFiles = ["\\.ipynb$", ".ipynb_checkpoints$", "\\.Rmd$", "\\.Rmarkdown$", "_cache$"]
```

### Deployment

- Hosted on Netlify
- Hugo version locked to 0.74.3 (in netlify.toml and .Rprofile)
- Build command: `hugo`
- Publish directory: `public/`

### Working with R Markdown

When editing `.Rmarkdown` files:
1. blogdown will automatically render to `.markdown` files
2. Hugo processes `.markdown` files to generate HTML
3. Use `blogdown::serve_site()` to preview changes in real-time

## Writing Style Guide

See `VOICE.md` for detailed guidance on writing blog posts that match the site's established voice and style. This file documents:
- Tone and personality (conversational yet technical)
- Structure and organization patterns
- Language patterns and vocabulary choices
- Technical communication style
- Code presentation preferences
- Educational approach and engagement tactics

Use VOICE.md whenever writing new content to maintain consistency with existing posts.

## Reference Documentation

See `incantations.md` for additional configuration notes on:
- Math rendering setup
- Code highlighting styles
- Table of contents configuration
