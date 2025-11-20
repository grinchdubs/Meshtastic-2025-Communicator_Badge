#!/bin/bash
# fix_patch.sh - Fix the incorrectly placed SUPERCON_2025 includes

cd ~/meshtastic-supercon-build/meshtastic-firmware

FACTORY=$(find .pio/libdeps/supercon_2025 -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

echo "Fixing $FACTORY"
echo ""

# Remove the incorrectly placed SUPERCON blocks and add them in the right place
awk '
# Skip the incorrectly placed SUPERCON blocks inside UNPHONE
/^#ifdef SUPERCON_2025$/ && inside_unphone { skip_block=1; next }
skip_block && /^#endif$/ { skip_block=0; next }
skip_block { next }

# Track when we are inside UNPHONE block
/^#ifdef UNPHONE$/ { inside_unphone=1 }

# When we hit the UNPHONE endif, insert SUPERCON block AFTER it
/^#endif$/ && inside_unphone {
    print
    print "#ifdef SUPERCON_2025"
    print "#include \"graphics/LGFX/LGFX_SUPERCON_2025.h\""
    print "#endif"
    inside_unphone=0
    next
}

# Print all other lines
{ print }
' "$FACTORY" > "$FACTORY.fixed"

mv "$FACTORY.fixed" "$FACTORY"

echo "Fixed! New lines 45-62:"
sed -n '45,62p' "$FACTORY" | nl -ba -v 45

echo ""
echo "Cleaning build cache and rebuilding..."
rm -rf .pio/build/supercon_2025
pio run -e supercon_2025 -j $(nproc)
