#!/usr/bin/env bash
set -euo pipefail

# inject-credentials.sh — take the placeholder workflow JSON and produce a
# *-with-creds.json file that has the real Worker URL and system prompt
# inlined. The output is gitignored (per .gitignore *-with-creds.json).
#
# Usage:
#   cd speakers/burak-can-polat/workflows
#   WORKER_URL=https://chinook-workshop.x.workers.dev \
#     bash inject-credentials.sh text-to-sql-agent-finished.json en

if [ $# -lt 2 ]; then
  echo "Usage: WORKER_URL=<url> bash inject-credentials.sh <workflow.json> <en|tr>" >&2
  exit 1
fi

INPUT="$1"
LANG="$2"
HERE="$(cd "$(dirname "$0")" && pwd)"
PROMPT_FILE="$HERE/../prompts/system-prompt-${LANG}.md"
OUTPUT="${INPUT%.json}-with-creds.json"

if [ -z "${WORKER_URL:-}" ]; then
  echo "ERROR: WORKER_URL env var not set." >&2
  exit 1
fi
if [ ! -f "$INPUT" ]; then
  echo "ERROR: input file '$INPUT' not found." >&2
  exit 1
fi
if [ ! -f "$PROMPT_FILE" ]; then
  echo "ERROR: prompt file '$PROMPT_FILE' not found." >&2
  exit 1
fi

# Read prompt into JSON-safe string (escape backslashes, quotes, newlines).
PROMPT_JSON_ESCAPED=$(python3 -c "import json,sys; print(json.dumps(open(sys.argv[1]).read()))" "$PROMPT_FILE")
# Strip the surrounding quotes so we can inline into the JSON value.
PROMPT_JSON_ESCAPED="${PROMPT_JSON_ESCAPED:1:-1}"

sed -e "s|WORKER_URL_HERE|$WORKER_URL|g" \
    -e "s|PASTE_SYSTEM_PROMPT_FROM_prompts/system-prompt-en.md_HERE|$PROMPT_JSON_ESCAPED|g" \
    "$INPUT" > "$OUTPUT"

echo "Wrote $OUTPUT"
echo "Import URL flow: open n8n -> ⋯ -> Import from File -> select this file."
