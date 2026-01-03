#!/bin/bash
# ios/Runner/Scripts/link_native_sources.sh
#
# This script creates symbolic links to the centralized native sources
# instead of duplicating them. Run this BEFORE building in Xcode.
#
# Usage:
#   bash ios/Runner/Scripts/link_native_sources.sh
#   Or add as a Build Phase in Xcode

set -e

# Get the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="${SCRIPT_DIR}/../../.."
NATIVE_SRC="${PROJECT_ROOT}/native/cpp"
IOS_NATIVE="${SCRIPT_DIR}/../Native"

echo "Linking native sources from: $NATIVE_SRC"
echo "To: $IOS_NATIVE"

# Create Native directory if it doesn't exist
mkdir -p "$IOS_NATIVE"

# Create symbolic links (not copies) to avoid duplication
ln -sf "$NATIVE_SRC/math_lib.h" "$IOS_NATIVE/math_lib.h"
ln -sf "$NATIVE_SRC/math_lib.c" "$IOS_NATIVE/math_lib.c"
ln -sf "$NATIVE_SRC/calculator.hpp" "$IOS_NATIVE/calculator.hpp"
ln -sf "$NATIVE_SRC/calculator.cpp" "$IOS_NATIVE/calculator.cpp"
ln -sf "$NATIVE_SRC/calculator_c_api.h" "$IOS_NATIVE/calculator_c_api.h"
ln -sf "$NATIVE_SRC/calculator_c_api.cpp" "$IOS_NATIVE/calculator_c_api.cpp"

echo "✓ Native sources linked successfully"
echo ""
echo "Linked files:"
ls -la "$IOS_NATIVE"
