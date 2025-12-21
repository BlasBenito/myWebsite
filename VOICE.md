# VOICE.md

This file documents the writing style and voice used in blog posts on this website. Use this as a guide when writing new content "in my voice."

## Overall Tone and Personality

**Conversational yet Technical**: Writing is approachable and friendly while maintaining technical rigor. The voice is that of a knowledgeable colleague explaining complex topics over coffee, not a formal textbook.

**Strategic Humor**: Uses GIFs, memes, XKCD comics, and self-deprecating comments to lighten technical content. Humor serves a purpose—it breaks tension, illustrates points, and keeps readers engaged.

**Direct and Personal**:
- Address the reader as "you" and include yourself with "we"
- Use first-person when sharing experience: "I believe", "I find", "I cannot confirm nor deny"
- Not afraid to be opinionated: "whatever rocks your boat", "tacky or whatever"
- Admits uncertainty or mistakes openly

**Emphatic but Measured**:
- Use **bold** for key concepts or critical points
- Use *italics* for emphasis or Latin terms
- Use ALL CAPS sparingly for effect ("MORE!", "VERY IMPORTANT")
- Strikethrough for humorous effect: "~~junk~~ code"

## Structure and Organization

### Post Architecture

1. **Front Matter**: Always include YAML metadata (title, date, tags, summary, toc)
2. **Opening Alert Box** (when appropriate): Set expectations with `{{% alert note %}}` blocks
3. **Summary Section**: Brief overview of what the post covers, often bulleted
4. **Resources/R Packages**: List requirements early, including installation code
5. **Main Content**: Hierarchical structure with clear headers
6. **Appendix** (when appropriate): Extra examples, edge cases, related topics
7. **Friendly Sign-off**: "That's all for now folks", "Happy parallelization!", or just "Blas"

### Content Flow

- **Build from Concepts to Practice**: Start with "what" and "why", then move to "how"
- **Code First, Explanation Second**: Show working code before lengthy explanations
- **Use Transitions**: "Now that we have...", "Let's see...", "So far so good!", "Here goes..."
- **Break Complex Topics**: Use step-by-step breakdowns with numbered or bulleted lists

## Language Patterns

### Sentence Structure

- **Start with Conjunctions** (deliberately): "But...", "So...", "And...", "Now..."
- **Conversational Fragments**: "Great!", "Yep", "Duh!", "So now we have..."
- **Rhetorical Questions**: "But what the heck is...?", "What option is more efficient then?"
- **Parenthetical Asides**: Frequent use of parentheses for side comments, clarifications, or humor

### Vocabulary Choices

- **Mix Formal and Informal**:
  - Formal: "ameliorate", "nonetheless", "hereafter"
  - Informal: "pitiful", "cumbersome", "buzz kill", "junk"
- **Colloquialisms**: "a.k.a", "the likes", "folks", "the meat in this post"
- **Technical Precision**: Define jargon, explain acronyms, break down etymology when useful
- **Analogies**: "similar to letting a river find its path down a valley", "loops in a trenchcoat"

### Common Phrases

- "Let me go ahead and..."
- "At this point..."
- "In any case..."
- "That said..."
- "For example..."
- "Notice that..."
- "Keep in mind..."
- "Here's the thing..."

## Technical Communication Style

### Explaining Concepts

**Etymology and Etymology**: Break down complex terms by their origins (e.g., multicollinearity from Latin roots)

**Historical Context**: Provide background when relevant, cite original papers, trace development

**Multiple Levels of Explanation**:
- Conceptual first: What it is, why it matters
- Technical next: How it works mathematically or algorithmically
- Practical last: How to implement it

**Acknowledge Complexity**: "This is a deep rabbit hole", "well beyond the scope of this post", "I'll revisit this topic later"

### Code Presentation

**Code Style**:
- Comment generously with `#`
- Use clear, descriptive variable names
- Show both command and output
- Format code blocks with language specification: ```{r}

**Code Examples**:
- Start simple, build complexity
- Show wrong approaches before correct ones when instructive
- Include installation instructions for required packages
- Use realistic examples (e.g., penguins data, toy datasets)

**Inline Code**: Use inline R code for dynamic values: "The result is `r variable_name`"

### Mathematical Notation

- Use LaTeX for equations: `$$\beta_{sor} = \frac{2a}{2a + b + c}$$`
- Explain symbols immediately after presenting formula
- Provide intuitive interpretation alongside math

## Educational Approach

### Reader Awareness

**State Target Audience Explicitly**:
- "This is written for beginner to intermediate R users"
- "If you are an advanced R user, this post will likely waste your time"

**Provide Context**:
- Explain why the topic matters
- Show real-world applications
- Link to related posts and external resources generously

**Progressive Disclosure**:
- Don't overwhelm with everything at once
- Use "I'll talk more about it later" when introducing concepts
- Circle back to connect ideas

### Engagement Tactics

**Anticipate Questions**: Address potential confusion proactively: "You might be wondering...", "If I lost you there..."

**Acknowledge Different Paths**: "There are several options...", "This works best when...", "In either case..."

**Credit Others**: "gif kindly suggested by Andreas Angourakis", reference papers properly, link to Stack Overflow answers

**Meta-Commentary**: Comment on the writing itself: "I hope you'll enjoy it!", "probably you have read somewhere", "This is CUMBERSOME"

## Visual Elements

### Figures and Graphics

- Custom plots with clear labels
- Include figure captions crediting source
- Use color strategically (e.g., "red4", "forestgreen" for contrast)
- Reference figures in text: "The figure below shows..."

### Multimedia

- Embed GIFs for humor and illustration
- Link YouTube videos for complex explanations
- Include XKCD comics when they perfectly illustrate a point
- Social media embeds (Mastodon posts) when relevant

### Alert Boxes

Use Hugo shortcodes for emphasis:
```
{{% alert note %}}
Important information here
{{% /alert %}}

{{% alert warning %}}
Cautionary information here
{{% /alert %}}
```

## Specific Quirks and Patterns

### Opening Lines

- Often start with broad context before narrowing
- May use a hook: humor, surprising fact, or provocative statement
- State the post's purpose clearly and early

### Section Breaks

- Use `&nbsp;` for spacing between major sections
- Use horizontal rules sparingly
- Often end sections with transition: "Let's move on to...", "Now that..."

### Lists

- Heavily favor bulleted lists for clarity
- Use nested bullets for sub-points
- Include code examples within list items
- Format lists with proper spacing and punctuation

### Links

- Link generously to related posts, papers, documentation
- Use descriptive link text, not "click here"
- Provide both general and specific resources
- Link to both academic sources and blog posts

### Caveats and Warnings

- Be upfront about limitations: "this is simplified", "there's more to it"
- Use bold for critical warnings: "**must not exceed the available system memory**"
- Acknowledge when something is controversial or debated

## Technical Preferences

### R-Specific

- Prefer base R unless tidyverse improves clarity
- Show both approaches when relevant
- Use `|>` pipe operator in modern code
- Package names with backticks: `` `collinear` ``
- Function references with parentheses: `vif_select()`

### Code Blocks vs. Inline

- Use code blocks for examples to run
- Use inline code for: package names, function names, arguments, variable references
- Format file paths as inline code: `` `path/to/file` ``

### References and Citations

- Link to papers with DOI when possible
- Cite books with author and title
- Reference Stack Overflow answers with links
- Credit ideas to specific people by name

## What to Avoid

**Don't**:
- Use corporate jargon or buzzwords without irony
- Write in passive voice unnecessarily
- Include excessive formality in introductions/conclusions
- Over-explain basic R concepts to stated audience
- Use emoji (except in rare, strategic cases)
- Create walls of text without breaks
- Make assumptions about reader's background without stating them

**Do**:
- Keep paragraphs short (3-5 sentences typically)
- Use active voice whenever possible
- Show, don't just tell
- Test code before publishing
- Provide working examples
- Link to sources

## Example Opening Patterns

**Pattern 1 - Problem Statement**:
> "Whether you're playing with large data, designing spatial pipelines, or developing scientific packages, at some point everyone writes a regrettably sluggish piece of ~~junk~~ code."

**Pattern 2 - Contextual Hook**:
> "This cute word comes from the amalgamation of these three Latin terms..."

**Pattern 3 - Direct Introduction**:
> "This post focuses on Variance Inflation Factors (VIF) and their crucial role in identifying multicollinearity within linear models."

## Example Transition Patterns

**Pattern 1 - Building Momentum**:
> "So far so good! From here we build the functions..."

**Pattern 2 - Shifting Gears**:
> "That said, there are legitimate reasons to break the first commandment."

**Pattern 3 - Moving Forward**:
> "Now that we have a valley, let's go create a river!"

## Example Closing Patterns

**Pattern 1 - Encouraging**:
> "I hope you found this post helpful. Have a great time!"

**Pattern 2 - Casual**:
> "And that's all for now, folks, I hope you found this post useful!"

**Pattern 3 - Thematic**:
> "That's all for now folks, happy parallelization!"

---

**Remember**: The goal is to educate and engage simultaneously. Technical precision with human warmth. Clear structure with conversational flow. This is how you teach complex R programming to people who are smart but busy.
