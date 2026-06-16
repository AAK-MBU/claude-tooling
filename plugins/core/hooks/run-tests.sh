#!/usr/bin/env bash
# Run the relevant test suite after Claude edits a file.
# On failure: print output to stderr and exit 2 so Claude sees it and fixes it.

set -uo pipefail

# --- config: adjust to your repo layout ---
BACKEND_DIR="backend"     # FastAPI app + pytest tests live here
FRONTEND_DIR="frontend"   # package.json + vitest live here
# -------------------------------------------

input=$(cat)
# Extract tool_input.file_path. Prefer jq; fall back to python3 when jq is
# absent (otherwise the field comes back empty and the hook silently no-ops).
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
else
  path=$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin)["tool_input"].get("file_path","") or "")
except Exception:
    pass')
fi
[[ -z "$path" ]] && exit 0

# normalise to a repo-relative path
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
rel="${path#"$root"/}"

run() {
  echo "Running: $1" >&2
  # shellcheck disable=SC2086
  output=$(eval "$1" 2>&1)
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "Tests failed. Fix the failures below before continuing:" >&2
    echo "$output" >&2
    exit 2          # PostToolUse: stderr is fed back to Claude
  fi
  exit 0
}

case "$rel" in
  # --- backend (Python / FastAPI) ---
  "$BACKEND_DIR"/*.py)
    # if a test file was edited, run just it; otherwise run the backend suite
    if [[ "$rel" == *"/test_"* || "$rel" == *_test.py ]]; then
      run "cd $root/$BACKEND_DIR && python -m pytest \"${rel#$BACKEND_DIR/}\" -q"
    else
      run "cd $root/$BACKEND_DIR && python -m pytest -q"
    fi
    ;;

  # --- frontend (vitest 'related' runs only affected tests) ---
  "$FRONTEND_DIR"/*.ts|"$FRONTEND_DIR"/*.tsx|"$FRONTEND_DIR"/*.js|"$FRONTEND_DIR"/*.svelte)
    run "cd $root/$FRONTEND_DIR && npx vitest related \"${rel#$FRONTEND_DIR/}\" --run"
    ;;

  *)
    exit 0   # not a tested file type — do nothing
    ;;
esac