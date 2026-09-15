#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-/root/autodl-tmp/Habitat/projects/SG-Nav-original}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EXPECTED_SGNAV="902ea13508c74c1323dfc5f198148819e9e757bdc50bf38345f5987f6a953284"
EXPECTED_SCENEGRAPH="ae63a505361905f72871994b065c585fd58c87fe2c8fde3c41f18124823d8c2e"

check_hash() {
    local file="$1"
    local expected="$2"
    local actual
    actual="$(sha256sum "$file" | awk '{print $1}')"
    if [[ "$actual" != "$expected" ]]; then
        echo "Refusing to install: unexpected hash for $file" >&2
        echo "Expected: $expected" >&2
        echo "Actual:   $actual" >&2
        exit 1
    fi
}

check_hash "$PROJECT_ROOT/SG_Nav.py" "$EXPECTED_SGNAV"
check_hash "$PROJECT_ROOT/scenegraph.py" "$EXPECTED_SCENEGRAPH"

stamp="$(date +%Y%m%d_%H%M%S)"
backup_dir="$PROJECT_ROOT/patches/original_visual_runtime_$stamp"
mkdir -p "$backup_dir"

for name in SG_Nav_original_visual.py scenegraph_original_visual.py; do
    if [[ -f "$PROJECT_ROOT/$name" ]]; then
        cp -a "$PROJECT_ROOT/$name" "$backup_dir/$name"
    fi
    install -m 0644 "$SCRIPT_DIR/$name" "$PROJECT_ROOT/$name"
done

python -m py_compile \
    "$PROJECT_ROOT/SG_Nav_original_visual.py" \
    "$PROJECT_ROOT/scenegraph_original_visual.py"

echo "Lightweight original-visual entry point installed successfully."
echo "Original SG_Nav.py and scenegraph.py were not modified."
echo "Backup directory: $backup_dir"

