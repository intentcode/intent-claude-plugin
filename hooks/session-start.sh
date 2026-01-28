#!/usr/bin/env bash
# SessionStart hook for intent plugin
# Injects intent documentation context at session start

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read the generating-intents skill content
skill_content=$(cat "${PLUGIN_ROOT}/skills/generating-intents/SKILL.md" 2>/dev/null || echo "")

# Escape for JSON
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

# Build context message
context="## Intent Documentation Available

This project can use Intent files to document the 'why' behind code changes.

**When to generate intents:**
- Before committing significant code changes
- When adding new features or fixing complex bugs
- When making architecture decisions

**How to use:**
- Say 'generate an intent' or '/intent' to create documentation
- Use 'intent:generating-intents' skill for the full workflow

**Intent files:**
- Location: \`.intent/intents/NNN-name.intent.md\`
- Use semantic anchors: @function:name, @class:Name, @method:Class.method
- Explain WHY, not just WHAT"

escaped_context=$(escape_for_json "$context")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${escaped_context}"
  }
}
EOF

exit 0
