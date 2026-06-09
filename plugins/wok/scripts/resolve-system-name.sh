#!/bin/bash
# resolve-system-name.sh - Resolve shorthand system-name to full directory name
#
# Usage: resolve-system-name.sh <input> [phase]
#   input  Full name, shorthand, partial string, or phase-only (p1, p2-name)
#   phase  Phase identifier: p1, 1, p1-name, substring, or --phases to list
#
# Output (stdout):
#   Single match (flat)        → system-name (exit 0)
#   Single match (phased)      → system-name/phase-dir (exit 0)
#   Phase selection needed     → PHASES:\n<phase1>\n<phase2> (exit 0)
#   AMBIGUOUS:\n<name1>\n...   (exit 0)
#   AMBIGUOUS_PHASE:\n<p1>\n... (exit 0)
#   NOT_FOUND: <input>         (exit 1)
#   No input                   → list all .wok-plans/ directories (exit 0)
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

# ── Helper: check if a system has roadmap ──
has_roadmap() {
    local sys_name="$1"
    [ -f "$PLANS_DIR/$sys_name/_roadmap.md" ]
}

# ── Helper: list phases for a roadmap system ──
list_phases() {
    local sys_name="$1"
    for dir in "$PLANS_DIR/$sys_name"/p[0-9]*/; do
        [ -d "$dir" ] || continue
        basename "$dir"
    done
}

# ── Helper: resolve phase input to phase dir name ──
# Args: system-name, phase-input
# Output: phase dir name (e.g. p1-core-device)
resolve_phase() {
    local sys_name="$1"
    local phase_input="$2"
    local phases
    phases="$(list_phases "$sys_name")"

    if [ -z "$phases" ]; then
        return 1
    fi

    # Exact match
    if [ -d "$PLANS_DIR/$sys_name/$phase_input" ]; then
        echo "$phase_input"
        return 0
    fi

    # Phase number match: "p1" or "1" → p1-*
    local phase_num=""
    case "$phase_input" in
        p[0-9]*) phase_num="${phase_input#p}" ;;
        [0-9]*)  phase_num="$phase_input" ;;
    esac

    if [ -n "$phase_num" ]; then
        for dir in "$PLANS_DIR/$sys_name"/p${phase_num}*/; do
            [ -d "$dir" ] || continue
            basename "$dir"
            return 0
        done
    fi

    # Fuzzy match on phase name substring
    local match=""
    local count=0
    while IFS= read -r pname; do
        [ -z "$pname" ] && continue
        if [[ "$pname" == *"$phase_input"* ]]; then
            match="$pname"
            count=$((count + 1))
        fi
    done <<< "$phases"

    if [ "$count" -eq 1 ]; then
        echo "$match"
        return 0
    elif [ "$count" -gt 1 ]; then
        echo "AMBIGUOUS_PHASE:"
        while IFS= read -r pname; do
            [ -z "$pname" ] && continue
            if [[ "$pname" == *"$phase_input"* ]]; then
                echo "$pname"
            fi
        done <<< "$phases"
        return 0
    fi

    echo "NOT_FOUND: phase $phase_input in $sys_name"
    return 1
}

# ── Helper: resolve a system to its final output ──
# If system has roadmap, apply phase resolution.
# Args: system-name, phase-hint (may be empty or --phases)
resolve_system_to_output() {
    local sys_name="$1"
    local phase_hint="$2"

    if ! has_roadmap "$sys_name"; then
        # Flat system: output as-is
        echo "$sys_name"
        return 0
    fi

    # Multi-phase system
    local phases
    phases="$(list_phases "$sys_name")"
    local phase_count
    phase_count="$(echo "$phases" | grep -c . || true)"

    if [ "$phase_count" -eq 0 ]; then
        # Roadmap exists but no phase dirs yet
        echo "$sys_name"
        return 0
    fi

    # --phases: list phases for caller
    if [ "$phase_hint" = "--phases" ]; then
        echo "PHASES:"
        echo "$phases"
        return 0
    fi

    # Phase hint provided: resolve it
    if [ -n "$phase_hint" ]; then
        local phase_res
        phase_res="$(resolve_phase "$sys_name" "$phase_hint")" || {
            echo "$phase_res"
            return 1
        }
        if [[ "$phase_res" == AMBIGUOUS_PHASE:* ]]; then
            echo "$phase_res"
            return 0
        fi
        echo "$sys_name/$phase_res"
        return 0
    fi

    # No phase hint: auto-select if single phase, otherwise list
    if [ "$phase_count" -eq 1 ]; then
        local single_phase
        single_phase="$(echo "$phases" | head -1)"
        echo "$sys_name/$single_phase"
        return 0
    fi

    echo "PHASES:"
    echo "$phases"
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
PHASE_HINT="${2:-}"

if [ ! -d "$PLANS_DIR" ]; then
    echo "NOT_FOUND: .wok-plans/ directory not found"
    exit 1
fi

# ── Phase-only input: "p1", "p2-automation" etc. ──
# Only when $1 looks like a phase and no $2
if [[ "$INPUT" =~ ^p[0-9] ]] && [ -z "$PHASE_HINT" ]; then
    cross_matches=""
    for sys_dir in "$PLANS_DIR"/*/; do
        [ -d "$sys_dir" ] || continue
        sys_name="$(basename "$sys_dir")"
        has_roadmap "$sys_name" || continue
        phase_res="$(resolve_phase "$sys_name" "$INPUT")" || continue
        if [[ "$phase_res" != AMBIGUOUS_* ]] && [[ "$phase_res" != NOT_FOUND:* ]]; then
            cross_matches="$sys_name/$phase_res"$'\n'"$cross_matches"
        fi
    done

    if [ -n "$cross_matches" ]; then
        print_matches "$cross_matches"
        exit 0
    fi
fi

# ── 1. Exact match ──
if [ -d "$PLANS_DIR/$INPUT" ]; then
    resolve_system_to_output "$INPUT" "$PHASE_HINT"
    exit $?
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
    raw="$(echo "$shorthand_matches" | sed '/^$/d' | sort -u)"
    count="$(echo "$raw" | grep -c . || true)"
    if [ "$count" -eq 1 ]; then
        resolve_system_to_output "$(echo "$raw" | head -1)" "$PHASE_HINT"
        exit $?
    fi
    echo "AMBIGUOUS:"
    echo "$raw"
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
    raw="$(echo "$fuzzy_matches" | sed '/^$/d' | sort -u)"
    count="$(echo "$raw" | grep -c . || true)"
    if [ "$count" -eq 1 ]; then
        resolve_system_to_output "$(echo "$raw" | head -1)" "$PHASE_HINT"
        exit $?
    fi
    echo "AMBIGUOUS:"
    echo "$raw"
    exit 0
fi

# ── 4. No match ──
echo "NOT_FOUND: $INPUT"
exit 1
