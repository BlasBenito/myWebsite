# Blog Post Directory Cleanup Guide

This guide explains the file mess in your `content/post/` directories and provides safe cleanup instructions.

## Understanding the Blogdown Workflow

Your `.Rprofile` setting:
```r
options(blogdown.method = 'markdown')
```

**File workflow:**
- `.Rmarkdown` files (SOURCE) → blogdown renders to → `.markdown` files (OUTPUT for Hugo)
- `.Rmd` files (SOURCE) → blogdown renders to → `.md` files (OUTPUT for Hugo)
- Hugo ignores: `.Rmd`, `.Rmarkdown`, and `_cache` directories (via `config.toml`)
- Hugo processes: `.markdown` and `.md` files to create final HTML

**Reference:** [blogdown documentation on output formats](https://bookdown.org/yihui/blogdown/output-format.html)

---

## The Mess Explained

### Post 02_parallelizing_loops_with_r (Typical Example)

**Timeline:**
1. **Dec 2020**: Created `parallelized_loops.Rmd` (original source, minimal YAML)
2. **Jan 2025**: Migrated to `index.Rmarkdown` (current source, full YAML)
   - **WHY**: Code highlighting wasn't working properly with `.Rmd` → `.md` workflow
   - **FIX**: `.Rmarkdown` → `.markdown` uses Hugo's Chroma highlighter correctly
3. **Result**: Both source files + their generated outputs coexist

**Current files:**
```
parallelized_loops.Rmd      25K  Dec 30 2020   ← OLD source (obsolete)
parallelized_loops.md       29K  Jan 23 2025   ← Generated from OLD source
index.Rmarkdown             27K  Jan 25 2025   ← CURRENT source ✓
index.markdown              31K  Jan 25 2025   ← Generated from CURRENT source ✓
index.md                    31K  Jan 23 2025   ← Duplicate/unknown origin
```

**Files Hugo actually uses:**
- `index.markdown` (generated from `index.Rmarkdown`) ✓
- Hugo IGNORES all `.Rmd` and `.Rmarkdown` files

**What happened with index.md:**
- Generated from old `.Rmd` workflow (before you switched to `.Rmarkdown`)
- Has problems: incomplete YAML frontmatter, R output mixed into content
- Differs from `index.markdown`: worse code highlighting, messier output
- **Definitely obsolete** - the `.Rmarkdown` → `.markdown` workflow fixed these issues

---

## Safe Cleanup Procedure

### Prerequisites

1. **Fix git corruption first** (see TODO.md Issue #1)
2. **Backup** your entire website directory:
   ```bash
   cd /home/blas/Dropbox/blas/GITHUB/
   tar -czf myWebsite-backup-$(date +%Y%m%d).tar.gz myWebsite/
   ```

3. **Test local build** before cleanup:
   ```r
   blogdown::serve_site()
   # Verify site looks correct in browser
   blogdown::stop_server()
   ```

---

### Step 1: Identify Your Source Files

For each post directory, determine the **current source**:

**Pattern 1: Standard posts (MOST posts)**
- Source: `index.Rmarkdown`
- Keep: `index.Rmarkdown` (source) + `index.markdown` (generated)
- Delete: Any other `.Rmd` or `.md` files

**Pattern 2: Posts with multiple articles (post 12)**
- Source: `article_1_foundations.Rmarkdown`, etc.
- Keep: Each `.Rmarkdown` + corresponding `.markdown`
- Delete: None (unless duplicates exist)

**Pattern 3: Posts with old source files (post 02)**
- Current source: `index.Rmarkdown`
- Old source: `parallelized_loops.Rmd`
- Keep: `index.Rmarkdown` + `index.markdown`
- Delete: `parallelized_loops.Rmd`, `parallelized_loops.md`, `index.md`

---

### Step 2: Create Cleanup Script

Save this as `cleanup_posts.sh`:

```bash
#!/bin/bash

# Navigate to website root
cd /home/blas/Dropbox/blas/GITHUB/myWebsite

# Create trash directory for review
mkdir -p .cleanup_trash/$(date +%Y%m%d)
TRASH=".cleanup_trash/$(date +%Y%m%d)"

# Post 02: Remove old parallelized_loops files and duplicate index.md
echo "Cleaning post 02..."
mv content/post/02_parallelizing_loops_with_r/parallelized_loops.Rmd "$TRASH/"
mv content/post/02_parallelizing_loops_with_r/parallelized_loops.md "$TRASH/"
mv content/post/02_parallelizing_loops_with_r/index.md "$TRASH/"

# Add other posts if needed following same pattern
# mv content/post/XX_name/oldfile.Rmd "$TRASH/"

echo "Files moved to: $TRASH"
echo "Review before deleting permanently"
```

---

### Step 3: Execute Cleanup

```bash
# Make script executable
chmod +x cleanup_posts.sh

# Run cleanup
./cleanup_posts.sh

# Test the site
R --no-save << 'EOF'
blogdown::serve_site()
# Check in browser, then:
blogdown::stop_server()
EOF

# If everything works, verify netlify deploy preview
git add -A
git commit -m "Clean up obsolete post source files"
git push
# Check Netlify deploy preview

# If all good, delete trash
rm -rf .cleanup_trash/

# If problems, restore from trash
# cp .cleanup_trash/YYYYMMDD/* content/post/02_parallelizing_loops_with_r/
```

---

### Step 4: Prevent Future Mess

**Add to .gitignore:**
```
# Blogdown generated files (optional - keep if you want to track them)
# *.markdown
# *.md
```

**Note:** Most people DO track `.markdown` and `.md` files in git because:
- They're the actual content Hugo uses
- Easier to see content changes in git diffs
- Faster Netlify builds (no R rendering needed)

**Your current approach (tracking generated files) is fine.**

---

## Cleanup Checklist for All Posts

Run this to identify which posts have extra files:

```bash
cd /home/blas/Dropbox/blas/GITHUB/myWebsite/content/post

for dir in */; do
    # Count files
    rmd_count=$(find "$dir" -maxdepth 1 -name "*.Rmd" 2>/dev/null | wc -l)
    rmarkdown_count=$(find "$dir" -maxdepth 1 -name "*.Rmarkdown" 2>/dev/null | wc -l)
    md_count=$(find "$dir" -maxdepth 1 -name "*.md" -not -name "_*" 2>/dev/null | wc -l)
    markdown_count=$(find "$dir" -maxdepth 1 -name "*.markdown" 2>/dev/null | wc -l)

    total=$((rmd_count + rmarkdown_count + md_count + markdown_count))

    # Flag if more than 2 files (1 source + 1 generated is normal)
    if [ $total -gt 2 ]; then
        echo "CHECK: $dir ($total files)"
        ls -1 "$dir"/*.{Rmd,Rmarkdown,md,markdown} 2>/dev/null | xargs -n1 basename
        echo
    fi
done
```

---

## Expected State After Cleanup

**Each standard post should have:**
```
post_name/
├── index.Rmarkdown    ← YOUR source file
├── index.markdown     ← Generated by blogdown (Hugo uses this)
├── featured.png       ← Optional featured image
├── figure1.png        ← Optional figures
└── index_files/       ← Optional R-generated assets
```

**What Hugo actually uses:**
- `index.markdown` (or `.md`) for content
- Images and assets
- **Hugo IGNORES**: `.Rmarkdown`, `.Rmd`, `_cache/`

**What you edit:**
- `index.Rmarkdown` (blogdown regenerates `.markdown` automatically)

---

## Quick Reference: File Types

| Extension | Type | Purpose | Track in Git? |
|-----------|------|---------|---------------|
| `.Rmarkdown` | Source | You edit this | ✓ Yes |
| `.Rmd` | Source (old) | Legacy format | ✓ Yes |
| `.markdown` | Generated | Hugo renders this | ✓ Yes (typical) |
| `.md` | Generated | Hugo renders this | ✓ Yes (typical) |
| `_files/` | Generated | R plot outputs | ✗ No (ignored) |
| `_cache/` | Generated | Knitr cache | ✗ No (ignored) |

---

## When in Doubt

**Golden Rule:**
- Keep the **newest** `.Rmarkdown` or `.Rmd` file (your source)
- Keep the **corresponding** `.markdown` or `.md` file (generated output)
- Delete everything else

**Test often:**
```r
blogdown::serve_site()  # Check locally
git push                # Check on Netlify
```

**Can't decide? Keep everything.** The mess won't break your site, just makes directories cluttered.

---

## Why Post 02 is Special

This post has extra files because:
1. You migrated workflows to fix code highlighting (`parallelized_loops.Rmd` → `index.Rmarkdown`)
2. Blogdown generated output from BOTH sources
3. You never cleaned up the old files

**Why the migration happened:**
- `.Rmd` → `.md`: Code highlighting was broken (needed client-side highlight.js)
- `.Rmarkdown` → `.markdown`: Uses Hugo's Chroma (server-side), works correctly
- **This was the RIGHT decision** for your use case

**Reference:** [rOpenSci Code Highlighting Guide](https://ropensci.org/blog/2020/04/30/code-highlighting/)

**This is common during workflow transitions.** Once cleaned, future posts will be cleaner.

---

## Summary

**Problem:** Mix of old/new source files + their generated outputs
**Cause:** Workflow evolution (Rmd → Rmarkdown) + generated file accumulation
**Solution:** Keep current source + its output, trash the rest
**Prevention:** Stick to one workflow (`index.Rmarkdown` → `index.markdown`)

**Cleanup impact:** Zero. Hugo only uses `.markdown`/`.md` files.
**Safety:** Backup first, use trash directory, test before committing.
