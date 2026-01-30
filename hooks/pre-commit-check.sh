#!/bin/bash
#
# Pre-commit check hook for intent plugin
# Checks if staged files are covered by an intent and suggests creating/updating one
#

set -uo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || command=""

# Only process git commit commands
[[ ! "$command" =~ ^git\ commit ]] && exit 0

# Not in a git repo?
git rev-parse --git-dir > /dev/null 2>&1 || exit 0

# Get staged files
staged_files=$(git diff --cached --name-only 2>/dev/null)
[[ -z "$staged_files" ]] && exit 0

# Filter to code files only (exclude .intent/, docs, configs)
code_files=$(echo "$staged_files" | grep -vE '^\.(intent|git)|\.md$|\.json$|\.yaml$|\.yml$|\.txt$|LICENSE|README' || true)
code_count=$(echo "$code_files" | grep -c . 2>/dev/null || echo "0")

# Less than 2 code files = no reminder
[[ "$code_count" -lt 2 ]] && exit 0

# Find an existing intent that covers these files
matching_intent=""
if [[ -d ".intent/intents" ]]; then
    for file in $code_files; do
        found=$(grep -l "- $file" .intent/intents/*.intent.md 2>/dev/null | head -1)
        if [[ -n "$found" ]]; then
            matching_intent="$found"
            break
        fi
    done
fi

# Detect new functions/classes in the diff
new_structures=$(git diff --cached | grep -E '^\+.*(def [a-zA-Z_]+|function [a-zA-Z_]+|class [a-zA-Z_]+|export (function|class) [a-zA-Z_]+)' | head -10)
new_names=$(echo "$new_structures" | grep -oE '(def|function|class) [a-zA-Z_]+' | awk '{print $2}' | sort -u)

if [[ -z "$matching_intent" ]]; then
    # No intent for these files → suggest creation
    structures_list=""
    if [[ -n "$new_names" ]]; then
        structures_list=$(echo "$new_names" | sed 's/^/- /' | tr '\n' ' ' | sed 's/ $//')
    fi

    context="## Intent Documentation

**${code_count} code files** staged without intent coverage.
$(if [[ -n "$structures_list" ]]; then echo -e "\nStructures: ${structures_list}"; fi)

Options:
1. Create intent: \`/intent:generating-intents\`
2. Continue without intent
3. Create new intent if distinct work"

else
    # Intent exists → check completeness
    existing_anchors=$(grep -oE '@(function|class|method):[a-zA-Z0-9_]+' "$matching_intent" 2>/dev/null | sed 's/.*://' | sort -u)

    uncovered=""
    for name in $new_names; do
        if [[ -n "$name" ]] && ! echo "$existing_anchors" | grep -q "^${name}$"; then
            uncovered="${uncovered}- ${name}\n"
        fi
    done

    if [[ -z "$uncovered" ]]; then
        # Intent is complete → silent
        exit 0
    fi

    intent_name=$(basename "$matching_intent")
    context="## Intent Update Suggested

\`${intent_name}\` covers these files but not:
$(echo -e "$uncovered")
Options:
1. Add chunks for these structures
2. Continue without update
3. Create new intent if distinct work"
fi

# Output JSON
escaped=$(echo -e "$context" | jq -Rs '.')
echo "{\"hookSpecificOutput\": {\"additionalContext\": ${escaped}}}"
exit 0
