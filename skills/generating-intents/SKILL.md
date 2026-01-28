---
name: generating-intents
description: Use when committing code, finishing a feature, or asked to document changes - analyzes git diff and creates multilingual .intent.md files with semantic anchors explaining the 'why' behind code changes
---

# Generating Intent Documentation

## Overview

Intent files capture **why** code changes were made, not just what changed. They use semantic anchors to link documentation to specific code locations that survive refactoring.

**Core principle:** Document decisions at commit time, when context is fresh.

## The Process

### Step 0: Choose Languages (FIRST STEP)

**Always ask before starting:**

```
Which languages should the intent be generated in?
- English + French (default)
- English only
- English + French + Spanish
- Other combination
```

**Default:** English (en) + French (fr)

**Supported languages:** en, fr, es, de

**CRITICAL:** Every title, summary, motivation, chunk description, and decision MUST be written in ALL selected languages.

### Step 1: Analyze Changes

```bash
git diff --staged    # What's being committed
git status           # Files involved
```

Identify:
- New/modified functions and classes
- Files with significant changes
- Patterns that need explanation

### Step 2: Detect Code Structures

For each significant change, determine the appropriate anchor:

| Code Pattern | Anchor Type |
|-------------|-------------|
| `def func_name(` / `function name(` | `@function:func_name` |
| `class ClassName` | `@class:ClassName` |
| Method inside class | `@method:Class.method` |
| Specific pattern | `@pattern:the_pattern` |
| Conceptual (no code) | `@chunk:concept-name` |

### Step 3: Capture Decisions (Interactive)

For each chunk, ask the developer:

1. "What problem does this code solve?" → Summary
2. "Why this approach over alternatives?" → Decision
3. "What's the risk level?" → low/medium/high

### Step 4: Generate Multilingual Intent File

**IMPORTANT:** All content sections must include ALL selected languages.

```markdown
---
id: "NNN"
from: {base-commit-sha}
author: claude
date: {YYYY-MM-DD}
status: active
risk: {low|medium|high}
tags: [{detected-tags}]
files:
  - {changed-files}
---

# {English Title}
# fr: {French Title}

## Summary
en: {English summary of what this change accomplishes}
fr: {French summary - Résumé de ce que ce changement accomplit}

## Motivation
en: {English motivation - why this change was needed}
fr: {French motivation - pourquoi ce changement était nécessaire}

## Chunks

### @function:name | {English chunk title}
### fr: {French chunk title}
en: {English description of what this code does and why}
fr: {French description - description de ce que ce code fait et pourquoi}

> Decision: {English rationale for this approach}
> fr: {French rationale - justification de cette approche}

### @class:AnotherClass | {English title}
### fr: {French title}
en: {English description}
fr: {French description}

> Decision: {English decision}
> fr: {French decision}
```

### Step 5: Update Manifest

Add entry to `.intent/manifest.yaml`:

```yaml
- id: "NNN"
  file: NNN-slug.intent.md
  status: active
```

## Multilingual Format Rules

### Title
```markdown
# Main Title (English by default)
# fr: Titre en français
# es: Título en español
```

### Sections (Summary, Motivation)
```markdown
## Summary
en: English content here.
fr: Contenu français ici.
es: Contenido en español aquí.
```

### Chunk Titles
```markdown
### @function:myFunc | English Title
### fr: Titre français
### es: Título español
```

### Chunk Descriptions
```markdown
en: English description that explains what this code does.
Multiple lines are supported.

fr: Description française qui explique ce que fait ce code.
Plusieurs lignes sont supportées.
```

### Decisions
```markdown
> Decision: English rationale explaining why this approach was chosen
> fr: Justification française expliquant pourquoi cette approche a été choisie
> es: Justificación en español
```

## Completeness Check

**Before finalizing, verify:**

- [ ] Title has ALL languages
- [ ] Summary has ALL languages
- [ ] Motivation has ALL languages
- [ ] EVERY chunk title has ALL languages
- [ ] EVERY chunk description has ALL languages
- [ ] EVERY decision has ALL languages

**If any translation is missing, the intent is INCOMPLETE.**

## Semantic Anchors Reference

| Type | Syntax | When to Use |
|------|--------|-------------|
| `@function:name` | Function/method definition | Most common |
| `@class:Name` | Class definition | For class-level docs |
| `@method:Class.method` | Specific method in class | When class has many methods |
| `@pattern:text` | First line containing text | For patterns, configs |
| `@chunk:id` | Virtual, no code location | Architecture, concepts |

## Decision Format

Decisions explain **why**, not what:

```markdown
> Decision: Chose JWT over sessions for horizontal scaling - sessions require sticky load balancing
> fr: Choisi JWT plutôt que les sessions pour le scaling horizontal - les sessions nécessitent un load balancing sticky
```

Not:
```markdown
> Decision: Used JWT tokens  ← Just restates the code
```

## When to Generate Intents

| Situation | Generate Intent? |
|-----------|-----------------|
| New feature | Yes - explain architecture decisions |
| Complex bug fix | Yes - explain root cause and solution |
| Refactoring | Yes - explain why new structure is better |
| Typo/formatting | No - self-explanatory |
| Dependency update | No - usually no decisions |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing translations | Check ALL sections have ALL languages |
| Documenting WHAT not WHY | Ask "why this approach?" |
| Inconsistent language coverage | Same content in all languages |
| Generic descriptions | Be specific to this change |
