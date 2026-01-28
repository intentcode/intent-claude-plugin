---
name: reviewing-with-intents
description: Use when reviewing a PR and encountering unclear code, or when asked to add documentation to existing code sections that lack explanation
---

# Reviewing Code with Intents

## Overview

Add intent documentation to existing code during PR review or code exploration. Unlike `generating-intents` (for your own changes), this skill documents code written by others or legacy code.

## When to Use

- Reviewing a PR and finding unclear code
- Onboarding to a codebase and documenting discoveries
- Adding documentation to legacy code
- Asked to explain existing code with intents

## The Process

### Step 0: Choose Languages

**Ask first:**
```
Which languages for the intent?
- English + French (default)
- English only
- Other
```

### Step 1: Identify Unclear Code

Read the PR diff or specified code. Look for:
- Complex logic without comments
- Non-obvious design decisions
- Code that made you ask "why?"

### Step 2: Formulate Questions or Infer

**Option A: Ask the author**
```
Questions for the author:
- Why was X chosen over Y?
- What's the purpose of this pattern?
- What edge cases does this handle?
```

**Option B: Infer from context**
If you can understand the rationale, document it directly.

### Step 3: Generate Intent

Create intent with `status: pending-review`:

```markdown
---
id: "NNN"
from: HEAD
author: reviewer
date: {YYYY-MM-DD}
status: pending-review
risk: medium
tags: [review, documentation]
files:
  - {file-path}
---

# Code Documentation: {Area}
# fr: Documentation du code : {Zone}

## Summary
en: Documents the {feature/logic} in {file}.
fr: Documente {la fonctionnalité/logique} dans {fichier}.

## Motivation
en: This code lacked documentation explaining its purpose and design decisions.
fr: Ce code manquait de documentation expliquant son but et ses décisions de conception.

## Chunks

### @function:complexFunction | {Title}
### fr: {Titre français}
en: {Explanation of what this does and likely why}
fr: {Explication en français}

> Decision: {Inferred or confirmed rationale}
> fr: {Justification inférée ou confirmée}
```

### Step 4: Request Validation

If author is available:
```
Please review this intent documentation:
- Is the explanation accurate?
- Any decisions I missed?
- Should status change to 'active'?
```

## Differences from generating-intents

| Aspect | generating-intents | reviewing-with-intents |
|--------|-------------------|------------------------|
| Author | Developer (self) | Reviewer |
| Knowledge | First-hand | Inferred |
| Status | `active` | `pending-review` |
| Decisions | Known | May need confirmation |

## Multilingual Requirements

Same as `generating-intents`:
- ALL titles in ALL languages
- ALL descriptions in ALL languages
- ALL decisions in ALL languages

## Status Values

- `pending-review`: Needs author validation
- `active`: Confirmed accurate
- `draft`: Work in progress
