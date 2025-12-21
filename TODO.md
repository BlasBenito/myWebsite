# Website Infrastructure TODO

This file documents issues found during the blogdown/Hugo infrastructure wellness check on 2025-12-21.

## 🚨 CRITICAL ISSUES

### 1. Git Repository Corruption from Dropbox Conflict

**Issue**: Git has broken refs from Dropbox file conflicts:
```
warning: ignoring ref with broken name refs/heads/master (rocinante's conflicted copy 2025-01-23)
warning: ignoring ref with broken name refs/remotes/origin/master (rocinante's conflicted copy 2025-01-23)
```

**Impact**: This could cause git operations to fail or behave unpredictably. May prevent proper pushes/pulls.

**Solution**: Clean up broken git refs:
```bash
cd .git/refs/heads
rm -f "master (rocinante's conflicted copy 2025-01-23)"
cd ../remotes/origin
rm -f "master (rocinante's conflicted copy 2025-01-23)"
git gc --prune=now
```

**Prevention**: Consider using Git outside of Dropbox sync folder, or use `.gitignore` patterns to exclude `.git/` from Dropbox sync.

---

### 2. Hugo Academic Theme is Deprecated

**Issue**: The Hugo Academic theme was deprecated/rebranded around 2020. It became Hugo Blox (formerly Wowchemy) and the old `sourcethemes.com/academic` URLs no longer work.

**Impact**:
- No security updates or bug fixes
- Documentation links are broken
- May have compatibility issues with newer Hugo versions
- Missing modern features and improvements

**Current version**: Using Hugo Academic from ~2020 (commit aef9810d, Dec 2024)
**Theme min Hugo version**: 0.73
**Your Hugo version**: 0.74.3

**Solution Options**:
1. **Freeze current setup** (RECOMMENDED):
   - Pin Hugo version to 0.74.3 (already done)
   - Accept no updates - this is fine for static sites
   - Site is stable, deployed, and working
   - No security risk (unlike dynamic CMSes)
   - Document the technical debt
   - **This is the pragmatic choice** - time better spent on content than infrastructure

2. **Migrate to Hugo Blox** (NOT RECOMMENDED):
   - Current "successor": https://github.com/HugoBlox/hugo-blox-builder
   - **PROBLEMS**: Poor documentation (circular links), sub-optimal implementation
   - Users report frustration: https://github.com/HugoBlox/hugo-blox-builder/discussions/1994
   - Technical issues: https://www.usecue.com/blog/why-hugoblox-is-a-great-idea/
   - "Great idea, bad execution"

3. **Switch to different platform entirely** (nuclear option):
   - Quarto (modern, R-friendly, well-documented): https://quarto.org/
   - Distill for R Markdown (simpler, fewer dependencies)
   - Different Hugo academic themes (Academia, Professors, Gofolium)
   - Requires complete site rebuild (weeks of work)

**Recommendation**: Option 1 (freeze and stay). Your site works, migration options are problematic, time better spent on content.

---

### 3. Very Old Hugo Version (0.74.3 from July 2020)

**Issue**: Using Hugo 0.74.3, which is ~5.5 years old. Current version is 0.140+ (as of Dec 2024).

**Impact**:
- Missing 5+ years of features, performance improvements, and bug fixes
- Security vulnerabilities (if any discovered in old versions)
- Limited community support for old versions
- Can't use modern Hugo features (modules, etc.)

**Why you're stuck**: Hugo Academic theme requires specific Hugo version ranges. Updating Hugo would break compatibility with your theme.

**Solution**: Tied to theme migration (Issue #2). For now, keep pinned to 0.74.3.

---

## ⚠️ HIGH PRIORITY

### 4. Theme Not Managed as Git Submodule

**Issue**: The `themes/hugo-academic` directory is committed directly into your repository (vendor-locked) rather than managed as a git submodule.

**Impact**:
- Can't easily update theme
- Can't track theme version
- Harder to maintain custom modifications vs. upstream changes
- Repository bloat (theme files add ~8MB)

**Current state**: Theme last updated Dec 10, 2024 (recent commit to theme files)

**Solution**: If you ever migrate themes, use git submodules or Hugo modules:
```bash
# For git submodules (old way)
git submodule add <theme-repo-url> themes/<theme-name>

# For Hugo modules (new way, requires Hugo 0.110+)
hugo mod init github.com/username/myWebsite
hugo mod get github.com/HugoBlox/hugo-blox-builder/modules/blox
```

**Action**: Document current theme state, accept vendor-locking for now.

---

### 5. Hardcoded Copyright Year

**Issue**: `config.toml` line 17:
```toml
copyright = "© 2023 Blas M. Benito. All Rights Reserved."
```

**Impact**: Copyright year is outdated (currently 2025).

**Solution**: Use Hugo's dynamic year:
```toml
copyright = "© {year} Blas M. Benito. All Rights Reserved."
```

**Action**: Update config.toml with dynamic year placeholder.

---

### 6. Deprecated Documentation URLs

**Issue**: Config files reference deprecated `sourcethemes.com/academic` URLs:
- `config.toml` line 2: Guide URL
- `config/_default/params.toml` lines 2, 13, 22, 58

**Impact**: Documentation links are broken, making it harder to troubleshoot issues.

**Solution**:
1. Update URLs to Hugo Blox equivalents where possible
2. Or comment them out as deprecated
3. Use Internet Archive for historical reference

**Action**: Document that these URLs are deprecated, use web.archive.org if needed.

---

### 7. Incorrect Country Code in Address

**Issue**: `config/_default/params.toml` line 96 has country code set to "US" instead of "ES" (Spain):
```toml
address = {street = "...", city = "San Vicente del Raspeig", ..., country = "Spain", country_code = "US"}
```

**Impact**: Incorrect structured data for search engines, inconsistent location metadata.

**Solution**: Change `country_code = "US"` to `country_code = "ES"`

**Action**: Update params.toml with correct country code.

---

## 📋 MEDIUM PRIORITY

### 8. .Rhistory Tracked in Git

**Issue**: The file `.Rhistory` is tracked by git and shows as modified:
```
Changes not staged for commit:
  modified:   .Rhistory
```

**Impact**: Clutters git commits with R command history, may expose sensitive commands.

**Current state**: `.Rhistory` is in `.gitignore` but was committed before the ignore rule was added.

**Solution**: Remove from git tracking:
```bash
git rm --cached .Rhistory
git commit -m "Stop tracking .Rhistory"
```

**Action**: Clean up git tracking of .Rhistory file.

---

### 9. No Regular Blogdown Health Checks

**Issue**: No evidence of running `blogdown::check_site()` or similar health checks.

**Impact**: May have latent issues with site configuration or content that go undetected.

**Solution**: Add to workflow:
```r
# Run periodically
blogdown::check_site()
blogdown::check_content()
```

**Action**: Run health check and document any findings. Add to maintenance routine.

---

### 10. Hugo Not Installed Locally

**Issue**: Hugo is not in system PATH, relying entirely on blogdown's bundled Hugo.

**Impact**:
- Can't run `hugo` commands directly
- Can't test builds outside of R
- Harder to troubleshoot build issues

**Current approach**: Relying on `blogdown::install_hugo()` is acceptable but limits flexibility.

**Solution**: Optional - install Hugo locally:
```bash
# Ubuntu/Debian
sudo apt install hugo

# Or use blogdown's Hugo
# R: blogdown::install_hugo(version = "0.74.3", force = TRUE)
```

**Action**: Document that this is intentional (blogdown-managed Hugo only).

---

### 11. Edit Page Config Points to Wrong Repo

**Issue**: `config/_default/params.toml` line 78:
```toml
edit_page = {repo_url = "https://github.com/gcushen/hugo-academic", ...}
```

**Impact**: "Edit this page" links would point to theme author's repo, not your repo.

**Solution**: Either:
1. Update to your repo URL if you want edit links
2. Disable edit links: `edit_page = {repo_url = "", ...}`

**Action**: Decide if you want edit functionality, update or disable accordingly.

---

### 12. R Markdown Generated Files in Content Directory

**Issue**: Found `*_files/` and `*_cache/` directories in `content/post/`:
```
content/post/13_code_optimization_2/index_files
content/post/project_distantia_time_delay/index_cache
...
```

**Impact**: These generated files add bloat to git repo (though currently ignored by `ignoreFiles` in config.toml).

**Current state**: Properly ignored by Hugo via `ignoreFiles = [... "_cache$"]` in config.toml.

**Solution**: Already handled correctly. These files are necessary for R Markdown rendering.

**Action**: No action needed. Document that this is expected behavior.

---

### 13. HTML Files in Post Directories

**Issue**: Found `.html` files in some post directories:
```
content/post/13_code_optimization_2/profiling.html
content/post/12_code_optimization_1/article_1_foundations.html
...
```

**Impact**: May be included by Hugo or cause confusion about source of truth.

**Investigation needed**: Determine if these are:
- Intentional embeds/iframes
- Orphaned build artifacts
- Custom HTML widgets

**Action**: Review each HTML file, determine purpose, document or clean up.

---

## ℹ️ LOW PRIORITY / INFORMATIONAL

### 14. No Hugo Modules Support

**Issue**: Not using Hugo modules (requires Hugo 0.110+), still using traditional themes/ directory.

**Impact**: Missing benefits of Hugo modules (version control, easier updates, etc.)

**Note**: This is fine for current frozen setup. Only relevant if migrating to newer Hugo.

**Action**: No action needed. Document for future reference.

---

### 15. Public Directory Size

**Issue**: Unknown if `public/` directory is tracked in git (shouldn't be).

**Verification**: Ran `git ls-files public/` - returned empty (good!)

**Current state**: `public/` is correctly in `.gitignore` and not tracked.

**Action**: No action needed. This is correct.

---

### 16. Resources Directory

**Issue**: `resources/` directory exists (Hugo's processing cache).

**Current state**: Correctly in `.gitignore` and not tracked.

**Action**: No action needed. This is correct.

---

## 📝 SUMMARY & RECOMMENDATIONS

### Immediate Actions (Can do now)
- [ ] Fix git broken refs from Dropbox conflict (Issue #1)
- [ ] Update copyright year to `{year}` (Issue #5)
- [ ] Fix country code from US to ES (Issue #7)
- [ ] Stop tracking .Rhistory (Issue #8)
- [ ] Update or disable edit_page repo URL (Issue #11)

### Documentation Tasks
- [ ] Document decision to freeze on Hugo 0.74.3 + Academic theme
- [ ] Comment deprecated URLs in config files
- [ ] Run and document `blogdown::check_site()` results
- [ ] Review and document purpose of HTML files in posts

### Future Considerations (Technical Debt)
- [ ] **Accept the freeze** - Hugo 0.74.3 + Academic theme works, no migration needed
- [ ] If ever rebuilding from scratch: Consider Quarto or Distill for R Markdown
- [ ] Consider moving git repo outside Dropbox to avoid conflicts (or configure Dropbox to ignore .git/)
- [ ] Evaluate if edit functionality is desired

### Working Well (No Changes Needed) ✅
- Public/ and resources/ correctly ignored
- R Markdown cache properly handled
- Netlify deployment configuration looks correct
- Content organization is clean
- .gitignore is mostly correct

---

## 🔧 TESTING CHECKLIST

Before making any changes, verify:
- [ ] Site builds locally: `blogdown::serve_site()`
- [ ] Site builds on Netlify: Check deploy logs
- [ ] All internal links work
- [ ] R Markdown posts render correctly
- [ ] Images and static assets load

After making changes:
- [ ] Re-test all of the above
- [ ] Check git status is clean
- [ ] Verify Netlify preview deploy works
- [ ] Test on multiple browsers if changing theme/config
