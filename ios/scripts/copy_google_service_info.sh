#!/bin/bash
# Copies the per-flavor GoogleService-Info.plist into the bundle before Firebase reads it.
# Setup:
#   1. In Xcode: Build Phases → + → New Run Script Phase
#   2. Drag the new phase above "Compile Sources"
#   3. Paste: "${SRCROOT}/scripts/copy_google_service_info.sh"
#   4. Uncheck "Based on dependency analysis"
#
# Real GoogleService-Info.plist files are git-ignored — store as CI secrets.
# Place them at:
#   ios/config/dev/GoogleService-Info.plist   (nibbles-dev project)
#   ios/config/prod/GoogleService-Info.plist  (nibbles-prod project)
# after running: flutterfire configure --project nibbles-<flavor>

set -euo pipefail

if [[ "${CONFIGURATION}" == *"-dev"* || "${CONFIGURATION}" == "Debug" ]]; then
  FLAVOR="dev"
else
  FLAVOR="prod"
fi

SRC="${PROJECT_DIR}/config/${FLAVOR}/GoogleService-Info.plist"
DST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [[ ! -f "${SRC}" ]]; then
  echo "warning: GoogleService-Info.plist not found at ${SRC}. Run: flutterfire configure --project nibbles-${FLAVOR}"
  exit 0
fi

cp "${SRC}" "${DST}"
echo "Copied ${SRC} → ${DST}"
