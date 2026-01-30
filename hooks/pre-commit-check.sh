#!/bin/bash
#
# Pre-commit check hook for intent plugin
# Checks if staged files are covered by an intent and suggests creating/updating one
#

# CRITICAL: This hook must NEVER fail - wrap everything in error handling
# If anything goes wrong, just exit 0 silently

main() {
    input=$(cat 2>/dev/null) || return 0
    command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || return 0

    # Only process git commit commands
    [[ -z "$command" ]] && return 0
    [[ ! "$command" =~ ^git\ commit ]] && return 0

    # Not in a git repo?
    git rev-parse --git-dir > /dev/null 2>&1 || return 0

    # Get staged files
    staged_files=$(git diff --cached --name-only 2>/dev/null) || return 0
    [[ -z "$staged_files" ]] && return 0

    # Filter to code files only (exclude .intent/, docs, configs)
    code_files=$(echo "$staged_files" | grep -vE '^\.(intent|git)|\.md$|\.json$|\.yaml$|\.yml$|\.txt$|LICENSE|README' 2>/dev/null) || code_files=""
    code_count=$(echo "$code_files" | grep -c . 2>/dev/null) || code_count=0

    # Less than 2 code files = no reminder
    [[ "$code_count" -lt 2 ]] && return 0

    # Find an existing intent that covers these files
    matching_intent=""
    if [[ -d ".intent/intents" ]]; then
        for file in $code_files; do
            found=$(grep -l "- $file" .intent/intents/*.intent.md 2>/dev/null | head -1) || true
            if [[ -n "$found" ]]; then
                matching_intent="$found"
                break
            fi
        done
    fi

    # Detect new functions/classes in the diff
    new_structures=$(git diff --cached 2>/dev/null | grep -E '^\+.*(def [a-zA-Z_]+|function [a-zA-Z_]+|class [a-zA-Z_]+|export (function|class) [a-zA-Z_]+)' | head -10) || new_structures=""
    new_names=$(echo "$new_structures" | grep -oE '(def|function|class) [a-zA-Z_]+' 2>/dev/null | awk '{print $2}' | sort -u) || new_names=""

    if [[ -z "$matching_intent" ]]; then
        # No intent for these files → suggest creation
        structures_list=""
        if [[ -n "$new_names" ]]; then
            structures_list=$(echo "$new_names" | sed 's/^/- /' | tr '\n' ' ' | sed 's/ $//') || true
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
        existing_anchors=$(grep -oE '@(function|class|method):[a-zA-Z0-9_]+' "$matching_intent" 2>/dev/null | sed 's/.*://' | sort -u) || existing_anchors=""

        uncovered=""
        for name in $new_names; do
            if [[ -n "$name" ]] && ! echo "$existing_anchors" | grep -q "^${name}$" 2>/dev/null; then
                uncovered="${uncovered}- ${name}\n"
            fi
        done

        if [[ -z "$uncovered" ]]; then
            # Intent is complete → silent
            return 0
        fi

        intent_name=$(basename "$matching_intent") || intent_name="unknown"
        context="## Intent Update Suggested

\`${intent_name}\` covers these files but not:
$(echo -e "$uncovered")
Options:
1. Add chunks for these structures
2. Continue without update
3. Create new intent if distinct work"
    fi

    # Output JSON
    escaped=$(echo -e "$context" | jq -Rs '.' 2>/dev/null) || return 0
    echo "{\"hookSpecificOutput\": {\"additionalContext\": ${escaped}}}"
}

# Run main, catch any errors, always exit 0
main "$@" 2>/dev/null || true
exit 0
