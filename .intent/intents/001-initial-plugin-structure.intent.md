---
id: "001"
from: c67d1d3543a50084dce4e3581a531fb03a513cdc
author: claude
date: 2026-01-28
status: active
risk: low
tags: [plugin, initial, structure, documentation]
files:
  - .claude-plugin/plugin.json
  - hooks/hooks.json
  - hooks/session-start.sh
  - skills/generating-intents/SKILL.md
  - skills/generating-intents/anchor-reference.md
  - skills/reviewing-with-intents/SKILL.md
  - README.md
---

# Intent Plugin for Claude Code - Initial Structure
# fr: Plugin Intent pour Claude Code - Structure initiale

## Summary
en: Created the initial plugin structure for generating intent documentation in Claude Code. The plugin provides two skills for documenting code changes and a session hook for context injection.
fr: Création de la structure initiale du plugin pour générer de la documentation d'intent dans Claude Code. Le plugin fournit deux skills pour documenter les changements de code et un hook de session pour l'injection de contexte.

## Motivation
en: Developers often commit code without documenting the reasoning behind their decisions. This plugin integrates intent documentation directly into the Claude Code workflow, making it easy to capture the "why" at commit time when context is fresh.
fr: Les développeurs commitent souvent du code sans documenter le raisonnement derrière leurs décisions. Ce plugin intègre la documentation d'intent directement dans le workflow Claude Code, facilitant la capture du "pourquoi" au moment du commit quand le contexte est frais.

## Chunks

### @chunk:plugin-architecture | Plugin Architecture
### fr: Architecture du plugin
en: The plugin follows Claude Code's plugin structure with three main components: skills for user interactions, hooks for automatic context injection, and metadata for plugin registration.
fr: Le plugin suit la structure de plugin de Claude Code avec trois composants principaux : les skills pour les interactions utilisateur, les hooks pour l'injection automatique de contexte, et les métadonnées pour l'enregistrement du plugin.

> Decision: Chose a plugin structure over standalone skills to enable hooks and provide a cohesive distribution package.
> fr: Choisi une structure de plugin plutôt que des skills standalone pour permettre les hooks et fournir un package de distribution cohérent.

### @pattern:generating-intents | Main Skill - Generate Intents
### fr: Skill principal - Génération d'intents
en: The core skill that analyzes git diff, detects code structures (functions, classes), prompts for decisions, and generates multilingual .intent.md files with semantic anchors.
fr: Le skill principal qui analyse le git diff, détecte les structures de code (fonctions, classes), demande les décisions, et génère des fichiers .intent.md multilingues avec des ancres sémantiques.

> Decision: Made multilingual support mandatory (en + fr default) because Intent targets international teams where documentation in multiple languages improves accessibility.
> fr: Rendu le support multilingue obligatoire (en + fr par défaut) car Intent cible des équipes internationales où la documentation en plusieurs langues améliore l'accessibilité.

### @pattern:reviewing-with-intents | PR Review Skill
### fr: Skill de revue de PR
en: A lighter skill for adding intent documentation during PR review when encountering unclear code written by others.
fr: Un skill plus léger pour ajouter de la documentation d'intent pendant la revue de PR quand on rencontre du code peu clair écrit par d'autres.

> Decision: Created a separate skill for review mode because the context is different (documenting others' code vs own code) and the default status should be "pending-review" instead of "active".
> fr: Créé un skill séparé pour le mode revue car le contexte est différent (documenter le code des autres vs son propre code) et le statut par défaut devrait être "pending-review" au lieu de "active".

### @pattern:session-start-hook | Session Start Hook
### fr: Hook de démarrage de session
en: Injects intent documentation context at session start, reminding developers about the intent workflow and how to use the skills.
fr: Injecte le contexte de documentation d'intent au démarrage de session, rappelant aux développeurs le workflow d'intent et comment utiliser les skills.

> Decision: Used SessionStart hook with "startup|resume" matcher to ensure context is available in both new and resumed sessions.
> fr: Utilisé le hook SessionStart avec le matcher "startup|resume" pour s'assurer que le contexte est disponible dans les sessions nouvelles et reprises.

### @chunk:semantic-anchors | Semantic Anchors System
### fr: Système d'ancres sémantiques
en: Intent files use semantic anchors (@function, @class, @method, @pattern, @chunk) to link documentation to code locations that survive refactoring.
fr: Les fichiers intent utilisent des ancres sémantiques (@function, @class, @method, @pattern, @chunk) pour lier la documentation à des emplacements de code qui survivent au refactoring.

> Decision: Reused the anchor system from the Intent web viewer project for consistency and compatibility with the existing intent ecosystem.
> fr: Réutilisé le système d'ancres du projet Intent web viewer pour la cohérence et la compatibilité avec l'écosystème intent existant.
