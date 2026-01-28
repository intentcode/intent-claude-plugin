# Intent Plugin - Development Guide

## Quick Start (Development)

```bash
# Load plugin locally
claude --plugin-dir /path/to/intent-claude-plugin

# Or resume a session with the plugin
claude --plugin-dir /path/to/intent-claude-plugin --resume
```

## Project Structure

```
intent-claude-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── hooks/
│   ├── hooks.json               # Hook configuration
│   └── session-start.sh         # Injects context at startup
├── skills/
│   ├── generating-intents/
│   │   ├── SKILL.md             # Main skill: generate intents
│   │   └── anchor-reference.md  # Semantic anchors reference
│   └── reviewing-with-intents/
│       └── SKILL.md             # PR review skill
└── README.md
```

## Skills

### `/intent:generating-intents`

Creates `.intent.md` files from git diff. Workflow:

1. Ask for languages (default: en + fr)
2. Analyze `git diff --staged`
3. Detect functions/classes changed
4. Prompt for decisions/rationale
5. Generate multilingual intent file
6. Update manifest

**Trigger:** Before committing significant code changes.

### `/intent:reviewing-with-intents`

Adds intent documentation during PR review for unclear code.

**Trigger:** When reviewing code that lacks explanation.

## Intent File Format

```markdown
---
id: "001"
from: {commit-sha}
author: claude
date: YYYY-MM-DD
status: active
files:
  - src/file.ts
---

# English Title
# fr: Titre français

## Summary
en: English summary.
fr: Résumé français.

## Chunks

### @function:name | English title
### fr: Titre français
en: Description.
fr: Description.

> Decision: English rationale
> fr: Justification française
```

## Semantic Anchors

| Type | Syntax | Example |
|------|--------|---------|
| Function | `@function:name` | `@function:authenticate` |
| Class | `@class:Name` | `@class:AuthService` |
| Method | `@method:Class.method` | `@method:Auth.login` |
| Pattern | `@pattern:text` | `@pattern:if __name__` |
| Chunk | `@chunk:id` | `@chunk:overview` |

## Testing the Plugin

```bash
# 1. Load plugin
claude --plugin-dir .

# 2. Make changes to code
# 3. Stage changes
git add -A

# 4. Generate intent
# Say: "generate an intent for my changes"
# Or: /intent:generating-intents

# 5. Commit both code and intent
git add .intent/
git commit -m "feat: description"
```

## Hooks

### SessionStart

Injects intent documentation context at session start. Reminds about:
- When to generate intents
- How to use `/intent:generating-intents`
- Intent file format basics

## Links

- [Intent Web Viewer](https://intent-code.vercel.app)
- [Intent Format Spec](https://github.com/intentcode/intent)
- [Plugin Repo](https://github.com/intentcode/intent-claude-plugin)
