#!/bin/bash
# show_file.sh - Show actual file contents

cd ~/meshtastic-supercon-build/meshtastic-firmware

FACTORY=$(find .pio/libdeps/supercon_2025 -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

echo "════════════════════════════════════════════════════════════"
echo "FILE: $FACTORY"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Lines 40-60:"
echo "────────────────────────────────────────────────────────────"
sed -n '40,60p' "$FACTORY" | nl -ba -v 40
echo "────────────────────────────────────────────────────────────"
echo ""
echo "Searching for SUPERCON_2025:"
grep -n "SUPERCON_2025" "$FACTORY" || echo "NOT FOUND"
echo ""
echo "Searching for LGFX:"
grep -n "LGFX" "$FACTORY" | head -20
echo "════════════════════════════════════════════════════════════"
