---
id: "002"
from: 157aae2f73c7d300d7ed8c4d9cd254b0dfdfb2f6
author: claude
date: 2026-01-30
status: active
risk: low
tags: [hook, pre-commit, automation, documentation-reminder]
files:
  - hooks/hooks.json
  - hooks/pre-commit-check.sh
  - README.md
---

# Intelligent Pre-Commit Check Hook
# fr: Hook de vérification pre-commit intelligent

## Summary
en: Added a PreToolUse hook that triggers on `git commit` commands to check if staged files are covered by an intent. If not, it suggests creating one or adding chunks to an existing intent.
fr: Ajout d'un hook PreToolUse qui se déclenche sur les commandes `git commit` pour vérifier si les fichiers staged sont couverts par un intent. Si non, il suggère d'en créer un ou d'ajouter des chunks à un intent existant.

## Motivation
en: Developers often forget to document their code changes. By adding a reminder at commit time, we increase the chances that intent documentation stays up-to-date with the codebase. The hook is non-blocking to avoid frustrating developers.
fr: Les développeurs oublient souvent de documenter leurs changements de code. En ajoutant un rappel au moment du commit, on augmente les chances que la documentation d'intent reste à jour avec le codebase. Le hook est non-bloquant pour éviter de frustrer les développeurs.

## Chunks

### @chunk:hook-logic | Decision Flow Logic
### fr: Logique de flux de décision
en: The hook follows a specific decision tree: (1) Only triggers on `git commit` commands, (2) Counts staged code files excluding docs/configs, (3) If less than 2 code files, stays silent, (4) Searches for an existing intent covering any staged file, (5) If no intent found, suggests creating one, (6) If intent found, checks if new functions/classes are covered by existing anchors, (7) If uncovered structures exist, suggests adding chunks, (8) If everything is covered, stays silent.
fr: Le hook suit un arbre de décision spécifique : (1) Se déclenche uniquement sur les commandes `git commit`, (2) Compte les fichiers code staged en excluant docs/configs, (3) Si moins de 2 fichiers code, reste silencieux, (4) Cherche un intent existant couvrant un des fichiers staged, (5) Si pas d'intent trouvé, suggère d'en créer un, (6) Si intent trouvé, vérifie si les nouvelles fonctions/classes sont couvertes par les anchors existants, (7) Si des structures non couvertes existent, suggère d'ajouter des chunks, (8) Si tout est couvert, reste silencieux.

> Decision: Chose file-based intent matching instead of branch-based because intents document code changes, not branches. A file can be documented by an intent regardless of which branch it was modified on.
> fr: Choisi le matching d'intent basé sur les fichiers plutôt que sur les branches car les intents documentent les changements de code, pas les branches. Un fichier peut être documenté par un intent quelle que soit la branche sur laquelle il a été modifié.

### @chunk:threshold-2-files | Minimum Files Threshold
### fr: Seuil minimum de fichiers
en: The hook only triggers when 2 or more code files are staged. Single-file commits are typically small fixes that don't warrant intent documentation.
fr: Le hook ne se déclenche que lorsque 2 fichiers code ou plus sont staged. Les commits d'un seul fichier sont typiquement de petits correctifs qui ne justifient pas de documentation d'intent.

> Decision: Set threshold at 2 files to reduce noise while still catching most meaningful changes. This can be adjusted based on user feedback.
> fr: Seuil fixé à 2 fichiers pour réduire le bruit tout en capturant la plupart des changements significatifs. Ceci peut être ajusté selon les retours utilisateurs.

### @chunk:structure-detection | Function/Class Detection
### fr: Détection des fonctions/classes
en: The hook parses the git diff to find newly added function and class definitions using regex patterns. It supports Python (`def`), JavaScript/TypeScript (`function`, `class`, `export function`, `export class`), and similar languages.
fr: Le hook parse le git diff pour trouver les définitions de fonctions et classes nouvellement ajoutées en utilisant des patterns regex. Il supporte Python (`def`), JavaScript/TypeScript (`function`, `class`, `export function`, `export class`), et les langages similaires.

> Decision: Used simple regex patterns instead of AST parsing for portability - the hook runs in bash and must work without language-specific dependencies.
> fr: Utilisé des patterns regex simples au lieu du parsing AST pour la portabilité - le hook s'exécute en bash et doit fonctionner sans dépendances spécifiques au langage.

### @chunk:non-blocking | Non-Blocking Behavior
### fr: Comportement non-bloquant
en: The hook outputs suggestions via `hookSpecificOutput.additionalContext` but never blocks the commit. It always exits with code 0 and never uses `blockToolCall`. This respects developer autonomy while providing helpful reminders.
fr: Le hook affiche des suggestions via `hookSpecificOutput.additionalContext` mais ne bloque jamais le commit. Il sort toujours avec le code 0 et n'utilise jamais `blockToolCall`. Cela respecte l'autonomie du développeur tout en fournissant des rappels utiles.

> Decision: Made the hook advisory-only because blocking commits would frustrate developers and lead to them disabling the hook entirely. Gentle reminders are more effective than enforcement.
> fr: Rendu le hook purement consultatif car bloquer les commits frustrerait les développeurs et les amènerait à désactiver complètement le hook. Les rappels doux sont plus efficaces que l'enforcement.
