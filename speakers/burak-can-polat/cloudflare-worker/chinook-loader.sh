#!/usr/bin/env bash
set -euo pipefail

# chinook-loader.sh — one-shot setup for the Chinook D1 + Worker stack.
# Re-runnable: skips creation if database already exists.
#
# Usage:
#   cd speakers/burak-can-polat/cloudflare-worker
#   bash chinook-loader.sh
#
# Prereqs: `wrangler login` already done; `wrangler whoami` returns your email.

DB_NAME="chinook-workshop"
CHINOOK_SQL_URL="https://raw.githubusercontent.com/lerocha/chinook-database/master/ChinookDatabase/DataSources/Chinook_Sqlite.sql"
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

echo "==> Checking wrangler auth"
wrangler whoami

# 1. Create the D1 database (or reuse existing).
echo "==> Ensuring D1 database '$DB_NAME' exists"
# UUID shape — robust across wrangler 3.x (TOML output) and 4.x (JSON output).
UUID_RE='[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
if wrangler d1 list 2>/dev/null | grep -q "$DB_NAME"; then
  echo "    Database already exists. Reusing."
  DB_ID=$(wrangler d1 info "$DB_NAME" 2>/dev/null | grep -oE "$UUID_RE" | head -1)
else
  echo "    Creating database..."
  CREATE_OUTPUT=$(wrangler d1 create "$DB_NAME")
  echo "$CREATE_OUTPUT"
  DB_ID=$(echo "$CREATE_OUTPUT" | grep -oE "$UUID_RE" | head -1)
fi
if [ -z "${DB_ID:-}" ]; then
  echo "ERROR: failed to determine database_id. Edit wrangler.toml manually." >&2
  exit 1
fi
echo "    Database ID: $DB_ID"

# 2. Write wrangler.toml from the example.
echo "==> Writing wrangler.toml"
sed "s/REPLACE_WITH_ID_FROM_WRANGLER_D1_CREATE/$DB_ID/" wrangler.toml.example > wrangler.toml
echo "    wrangler.toml ready."

# 3. Fetch Chinook SQL (~1.5 MB).
if [ ! -f chinook.sql ]; then
  echo "==> Downloading Chinook SQL"
  curl -fsSL -o chinook.sql "$CHINOOK_SQL_URL"
fi
echo "    Chinook SQL size: $(wc -c < chinook.sql) bytes"

# 4. Strip statements D1 doesn't accept.
echo "==> Cleaning chinook.sql for D1 compatibility"
sed -E '/^(PRAGMA|BEGIN|COMMIT)/Id' chinook.sql > chinook.cleaned.sql
mv chinook.cleaned.sql chinook.sql
echo "    Cleaned."

# 5. Load schema + data into D1 (remote, not local dev).
echo "==> Loading Chinook into D1 (remote)"
wrangler d1 execute "$DB_NAME" --remote --file=chinook.sql

# 6. Verify expected row count.
echo "==> Verifying load"
TRACK_COUNT=$(wrangler d1 execute "$DB_NAME" --remote --command="SELECT COUNT(*) AS c FROM Track" --json | grep -oE '"c":[0-9]+' | head -1 | cut -d: -f2)
echo "    Track row count: $TRACK_COUNT (expected: 3503)"
if [ "$TRACK_COUNT" != "3503" ]; then
  echo "WARNING: Track count differs from expected 3503. Investigate before deploying." >&2
fi

# 7. Deploy the Worker.
echo "==> Deploying Worker"
wrangler deploy

# 8. Smoke test.
WORKER_URL=$(wrangler deployments list 2>/dev/null | grep -oE 'https://[^ ]*workers\.dev' | head -1)
if [ -z "$WORKER_URL" ]; then
  echo "==> Note: could not auto-detect Worker URL. Check 'wrangler deploy' output."
else
  echo "==> Smoke testing $WORKER_URL"
  curl -fsS -X POST "$WORKER_URL/test" \
    -H 'Content-Type: application/json' \
    -d '{"sql":"SELECT Name FROM Artist LIMIT 3"}' | head -c 400
  echo
fi

echo "==> Done. Worker URL: $WORKER_URL"
