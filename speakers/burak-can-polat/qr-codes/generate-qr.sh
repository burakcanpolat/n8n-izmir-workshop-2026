#!/usr/bin/env bash
set -euo pipefail

# generate-qr.sh — Generate the cheat sheet QR code PNG.
# Run AFTER GitHub Pages is enabled and the cheat sheet URL is reachable.
#
# Prereq: qrencode installed.
#   sudo apt-get install -y qrencode       # Debian/Ubuntu/WSL
#   brew install qrencode                   # macOS
#
# Usage:
#   bash generate-qr.sh

HERE="$(cd "$(dirname "$0")" && pwd)"
URL="https://onurpolat05.github.io/n8n-izmir-workshop-2026/speakers/burak-can-polat/presentation-cheat-sheet.html"
OUT="$HERE/presentation-cheat-sheet.png"

if ! command -v qrencode >/dev/null 2>&1; then
  echo "ERROR: qrencode not installed." >&2
  echo "Install: sudo apt-get install -y qrencode  (or brew install qrencode)" >&2
  exit 1
fi

# -s 14 = pixels per QR module (large, projector-friendly)
# -m 2  = quiet zone modules around the code
# --foreground=1a1714 --background=f7f4ec keeps the QR on-palette with the cheat sheet.
qrencode -s 14 -m 2 \
  --foreground=1a1714 --background=f7f4ec \
  -o "$OUT" \
  "$URL"

echo "Wrote $OUT"
echo "Test: scan from a phone — should open the cheat sheet."
