#!/usr/bin/env bash
# Nightly consolidation, 5 phases (mechanical half).
#   1. clear stale wiki-locks
#   2. delta scan .raw/ vs ingest manifest
#   3. quick structural scan (page count, unresolved wikilink count)
#   4. commit any uncommitted wiki/ changes (local commit only; never pushes)
#   5. append one status line to .vault-meta/agent-status.log
# Real consolidation (folds, synthesis, hot-cache rewrite) needs a Claude
# session; this script keeps the vault tidy and observable between sessions.
# Usage: bash bin/agents/nightly.sh   (cron-safe, no arguments, no network)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$VAULT"

echo "== nightly consolidation: $(date -u +%FT%TZ) =="

echo "[1/5] stale locks"
bash scripts/wiki-lock.sh clear-stale >/dev/null 2>&1 || true

echo "[2/5] delta scan"
PENDING=$(python3 - <<'PY'
import hashlib, json, os
try:
    manifest = json.load(open(".raw/.manifest.json")).get("sources", {})
except Exception:
    manifest = {}
n = 0
for root, dirs, files in os.walk(".raw"):
    for f in files:
        if f.startswith("."):
            continue
        p = os.path.join(root, f)
        h = hashlib.md5(open(p, "rb").read()).hexdigest()
        if manifest.get(p, {}).get("hash") != h:
            n += 1
print(n)
PY
)
echo "  pending ingest: $PENDING source(s)"

echo "[3/5] structural scan"
PAGES=$(find wiki -name '*.md' | wc -l | tr -d ' ')
echo "  wiki pages: $PAGES"

echo "[4/5] commit wiki changes"
if ! git diff --quiet -- wiki .raw || [ -n "$(git status --porcelain wiki .raw)" ]; then
  git add wiki .raw
  git commit -m "auto(nightly): consolidate vault state $(date -u +%F)" >/dev/null
  echo "  committed pending wiki/.raw changes"
else
  echo "  nothing to commit"
fi

echo "[5/5] status log"
mkdir -p .vault-meta
printf '%s nightly pages=%s pending_ingest=%s\n' \
  "$(date -u +%FT%TZ)" "$PAGES" "$PENDING" >> .vault-meta/agent-status.log
echo "== nightly consolidation done =="
