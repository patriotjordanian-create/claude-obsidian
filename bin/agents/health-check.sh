#!/usr/bin/env bash
# Vault health check (mechanical half).
# Verifies the machinery a healthy vault depends on: manifest JSON validity,
# lock directory state, address counter sanity, git cleanliness, and the
# plugin test suite if make is available. Exit nonzero on hard failures.
# The judgment half (orphans, stale claims, dead links) is /wiki-lint in a
# Claude session; this script catches breakage between sessions.
# Usage: bash bin/agents/health-check.sh [--dry-run]
#   --dry-run: report only; skip the one side effect (clearing stale locks)

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$VAULT"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

FAIL=0
say() { printf '%s %s\n' "$1" "$2"; }

echo "== health check: $(date -u +%FT%TZ) =="

if python3 -c "import json; json.load(open('.raw/.manifest.json'))" 2>/dev/null; then
  say OK "ingest manifest is valid JSON"
else
  say FAIL "ingest manifest missing or corrupt (.raw/.manifest.json)"; FAIL=1
fi

LOCKS=$(find .vault-meta/locks -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$LOCKS" -eq 0 ]; then
  say OK "no lingering wiki-locks"
else
  if [ "$DRY_RUN" -eq 1 ]; then
    say WARN "$LOCKS lock file(s) present; would clear stale ones (dry run)"
  else
    say WARN "$LOCKS lock file(s) present; clearing stale ones"
    bash scripts/wiki-lock.sh clear-stale >/dev/null 2>&1 || true
  fi
fi

if [ -x scripts/allocate-address.sh ]; then
  PEEK=$(bash scripts/allocate-address.sh --peek 2>/dev/null || echo "")
  if [ -n "$PEEK" ]; then
    say OK "address counter peek: $PEEK"
  else
    say FAIL "address counter unreadable"; FAIL=1
  fi
fi

DIRTY=$(git status --porcelain wiki .raw | wc -l | tr -d ' ')
if [ "$DIRTY" -eq 0 ]; then
  say OK "wiki/.raw clean in git"
else
  say WARN "$DIRTY uncommitted wiki/.raw change(s); nightly.sh will commit them"
fi

if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
  if make test >/dev/null 2>&1; then
    say OK "make test green"
  else
    say FAIL "make test failing; run 'make test' for details"; FAIL=1
  fi
fi

echo "== health check done (exit $FAIL) =="
exit "$FAIL"
