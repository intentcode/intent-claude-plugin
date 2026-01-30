# Intent Plugin for Claude Code

Generate structured documentation that captures the **"why"** behind code changes.

## What is Intent?

Intent creates `.intent.md` files that explain design decisions, not just what the code does. Using **semantic anchors**, documentation stays linked to code even when it's refactored.

**Example:**
```markdown
### @function:authenticate | Authentication Logic
### fr: Logique d'authentification
en: Validates credentials and generates JWT tokens.
fr: Valide les identifiants et génère des tokens JWT.

> Decision: Chose JWT over sessions for horizontal scaling
> fr: Choisi JWT plutôt que les sessions pour le scaling horizontal
```

## Features

- **Multilingual by default** - Generate intents in English + French (or more)
- **Semantic anchors** - Link docs to `@function`, `@class`, `@method`, `@pattern`
- **Decision capture** - Document the "why", not just the "what"
- **PR review mode** - Add intents to unclear code during review
- **Smart pre-commit check** - Reminds you to document new code before committing

## Installation

### Option 1: Full Plugin (Recommended)

Use the `--plugin-dir` flag to load the complete plugin with hooks and skills:

```bash
# Clone the repository
git clone https://github.com/intentcode/intent-claude-plugin

# Start Claude Code with the plugin loaded
claude --plugin-dir ./intent-claude-plugin

# Or from inside the plugin directory
cd intent-claude-plugin
claude --plugin-dir .

# Resume an existing session with the plugin
claude --plugin-dir ./intent-claude-plugin --resume
```

**What you get:**
- Skills: `/intent:generating-intents` and `/intent:reviewing-with-intents`
- SessionStart hook: Injects intent context at startup
- Pre-commit hook: Checks if your code changes have intent coverage
- Full plugin experience

**Note:** The `--plugin-dir` flag must be used every time you start Claude Code to load the plugin. There is no persistent installation yet.

### Option 2: Skills Only (No Hooks)

Copy just the skills to your Claude skills directory:

```bash
# Clone and copy skills
git clone https://github.com/intentcode/intent-claude-plugin
cp -r intent-claude-plugin/skills/* ~/.claude/skills/
```

**What you get:**
- Skills: `/generating-intents` and `/reviewing-with-intents` (no namespace prefix)
- No hooks (no automatic context injection at startup)
- Persistent installation (skills available in all sessions)

### Option 3: Marketplace (Coming Soon)

```bash
claude
> /plugin install intent
```

### Which Option Should I Choose?

| Need | Recommended Option |
|------|-------------------|
| Full experience with hooks | Option 1: `--plugin-dir` |
| Persistent installation | Option 2: Skills only |
| Contributing/developing | Option 1: `--plugin-dir` |
| Just trying it out | Option 1: `--plugin-dir` |

## Usage

### Generate Intent (Development)

When ready to commit code changes:

```
Generate an intent for my changes
```

or use the skill directly:

```
/intent:generating-intents
```

The skill will:
1. Ask which languages (default: en + fr)
2. Analyze your git diff
3. Identify functions/classes changed
4. Ask about your decisions
5. Generate the `.intent.md` file
6. Update the manifest

### Review with Intent (PR Review)

When reviewing unclear code:

```
Add an intent to explain this function
```

## Intent File Format

```markdown
---
id: "001"
from: abc123
author: claude
date: 2024-01-15
status: active
risk: medium
tags: [feature, auth]
files:
  - src/auth.ts
---

# User Authentication
# fr: Authentification utilisateur

## Summary
en: Added JWT-based authentication with refresh tokens.
fr: Ajout de l'authentification JWT avec tokens de rafraîchissement.

## Motivation
en: The app needed secure sessions without server-side state.
fr: L'app avait besoin de sessions sécurisées sans état côté serveur.

## Chunks

### @function:authenticate | Token Generation
### fr: Génération de token
en: Generates JWT access and refresh tokens.
fr: Génère les tokens JWT d'accès et de rafraîchissement.

> Decision: 15-minute expiry for access tokens balances security and UX
> fr: Expiration de 15 minutes pour les tokens d'accès équilibre sécurité et UX
```

## Semantic Anchors

| Type | Syntax | Use Case |
|------|--------|----------|
| `@function:name` | `@function:authenticate` | Functions/methods |
| `@class:Name` | `@class:AuthService` | Classes |
| `@method:Class.method` | `@method:Auth.login` | Specific methods |
| `@pattern:text` | `@pattern:if __name__` | Code patterns |
| `@chunk:id` | `@chunk:overview` | Conceptual, no code |

## Project Structure

```
your-project/
└── .intent/
    ├── manifest.yaml
    └── intents/
        ├── 001-auth.intent.md
        └── 002-api.intent.md
```

## Skills

| Skill | Purpose |
|-------|---------|
| `/intent:generating-intents` | Create intents from your code changes |
| `/intent:reviewing-with-intents` | Add intents during PR review |

## Hooks

The plugin includes automatic hooks that run in the background:

| Hook | Trigger | Purpose |
|------|---------|---------|
| SessionStart | New/resumed session | Injects intent context and reminders |
| Pre-commit check | `git commit` | Checks if staged files have intent coverage |

### Pre-commit Check Behavior

When you run `git commit` with 2+ code files staged, the hook:

1. **No intent exists** for these files → Suggests creating one
2. **Intent exists** but new functions/classes aren't documented → Suggests adding chunks
3. **Intent is complete** → Silent (no interruption)

The hook never blocks commits - it only suggests documentation.

## Development

See [CLAUDE.md](./CLAUDE.md) for development documentation.

## Links

- [Intent Web Viewer](https://intent-code.vercel.app) - View intents alongside diffs
- [Intent Format Spec](https://github.com/intentcode/intent) - Full specification
- [Report Issues](https://github.com/intentcode/intent-claude-plugin/issues)

## License

MIT
