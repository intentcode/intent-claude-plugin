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

## Installation

### Option 1: Local plugin

```bash
# Clone to plugins directory
git clone https://github.com/intentcode/intent-claude-plugin ~/.claude/plugins/intent

# Enable in settings
# Add to ~/.claude/settings.json:
{
  "enabledPlugins": {
    "intent": true
  }
}
```

### Option 2: Symlink from dev

```bash
# If developing locally
ln -s /path/to/intent-claude-plugin ~/.claude/plugins/intent
```

## Usage

### Generate Intent (Development)

When ready to commit code changes:

```
Generate an intent for my changes
```

or

```
/intent
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
| `intent:generating-intents` | Create intents from your code changes |
| `intent:reviewing-with-intents` | Add intents during PR review |

## Links

- [Intent Web Viewer](https://intent-code.vercel.app) - View intents alongside diffs
- [Intent Format Spec](https://github.com/intentcode/intent) - Full specification
- [Report Issues](https://github.com/intentcode/intent-claude-plugin/issues)

## License

MIT
