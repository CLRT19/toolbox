#!/usr/bin/env bash
# Patches all installed antigravity-server versions to disable core dump generation.
# Safe to re-run: skips files already patched.

set -euo pipefail

MARKER="ulimit -c 0"
PATCH_BLOCK='# Disable core dumps for antigravity (workaround for crash on large non-code files)\nulimit -c 0\n'

patched=0
skipped=0

for script in "$HOME"/.antigravity-server/bin/*/bin/antigravity-server; do
    [ -f "$script" ] || continue

    if grep -qF "$MARKER" "$script"; then
        echo "Already patched: $script"
        skipped=$((skipped + 1))
        continue
    fi

    # Insert ulimit line before the ROOT= assignment
    sed -i "/^ROOT=\"\$(dirname/i\\${PATCH_BLOCK}" "$script"
    echo "Patched: $script"
    patched=$((patched + 1))
done

if [ $patched -eq 0 ] && [ $skipped -eq 0 ]; then
    echo "No antigravity-server scripts found in ~/.antigravity-server/bin/"
    exit 1
fi

echo "Done. Patched: $patched, Already patched: $skipped"
echo "Restart your antigravity remote connection for the fix to take effect."
