#!/bin/bash
# resolve-system-name.sh - Resolve shorthand system-name to full directory name
#
# Usage: resolve-system-name.sh [input]
#   input  Full name, shorthand, or partial string
#
# Output (stdout):
#   Single match   → full system-name (exit 0)
#   Multiple match → AMBIGUOUS:\n<name1>\n<name2>  (exit 0)
#   No match       → NOT_FOUND: <input>             (exit 1)
#   No input       → list all .wok-plans/ directories (exit 0)
#
# Shorthand rules:
#   ft-abc   → feat-<a>...-<b>...-<c>...   (first letter of each word)
#   fts-abc  → feat-s-<a>...-<b>...-<c>...
#   fx-abc   → fix-<a>...-<b>...-<c>...
#   ex-abc   → exp-<a>...-<b>...-<c>...
#   cr-abc   → cr-<a>...-<b>...-<c>...

set -e

WOK_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLANS_DIR="$WOK_ROOT/.wok-plans"

# ── Helper: generate shorthand for a full directory name ──
generate_shorthand() {
    local name="$1"
    local prefix="" rest=""

    case "$name" in
        feat-s-*) prefix="fts"; rest="${name#feat-s-}" ;;
        feat-*)   prefix="ft";  rest="${name#feat-}"   ;;
        fix-*)    prefix="fx";  rest="${name#fix-}"    ;;
        exp-*)    prefix="ex";  rest="${name#exp-}"    ;;
        cr-*)     prefix="cr";  rest="${name#cr-}"     ;;
        *)        echo "$name"; return                  ;;
    esac

    local suffix=""
    IFS='-' read -ra words <<< "$rest"
    for word in "${words[@]}"; do
        suffix+="${word:0:1}"
    done
    echo "${prefix}-${suffix}"
}

# ── Helper: print matches ──
print_matches() {
    local raw="$1"
    local trimmed
    trimmed="$(echo "$raw" | sed '/^$/d' | sort -u)"
    local count
    count="$(echo "$trimmed" | grep -c . || true)"

    if [ "$count" -eq 1 ]; then
        echo "$trimmed"
        return 0
    fi
    echo "AMBIGUOUS:"
    echo "$trimmed"
    return 0
}

# ── No input: list all ──
if [ -z "${1:-}" ]; then
    if [ -d "$PLANS_DIR" ]; then
        ls -1 "$PLANS_DIR" 2>/dev/null
    fi
    exit 0
fi

INPUT="$1"

if [ ! -d "$PLANS_DIR" ]; then
    echo "NOT_FOUND: .wok-plans/ directory not found"
    exit 1
fi

# ── 1. Exact match ──
if [ -d "$PLANS_DIR/$INPUT" ]; then
    echo "$INPUT"
    exit 0
fi

# ── 2. Shorthand match ──
shorthand_matches=""
for dir in "$PLANS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    short="$(generate_shorthand "$name")"
    if [ "$short" = "$INPUT" ]; then
        shorthand_matches="$name"$'\n'"$shorthand_matches"
    fi
done

if [ -n "$shorthand_matches" ]; then
    print_matches "$shorthand_matches"
    exit 0
fi

# ── 3. Fuzzy match (substring) ──
fuzzy_matches=""
for dir in "$PLANS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    if [[ "$name" == *"$INPUT"* ]]; then
        fuzzy_matches="$name"$'\n'"$fuzzy_matches"
    fi
done

if [ -n "$fuzzy_matches" ]; then
    print_matches "$fuzzy_matches"
    exit 0
fi

# ── 4. No match ──
echo "NOT_FOUND: $INPUT"
exit 1
