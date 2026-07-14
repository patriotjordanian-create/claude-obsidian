#!/usr/bin/env bash
# Morning context refresh (mechanical half).
# Refreshes transport detection, clears stale locks, and reports what changed
# in .raw/ since the last ingest so the first Claude session of the day starts
# with a clean, current picture. The LLM half (rewriting hot.md) belongs to a
# Claude session; this script only prepares and reports.
# Usage: bash bin/agents/morning.sh   (cron-safe, no arguments, no network)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(dirname "$(dirname "$SCRIPT_DIR")")"
cd "$VAULT"

echo "== morning refresh: $(date -u +%FT%TZ) =="

bash scripts/detect-transport.sh >/dev/null 2>&1 || true
echo "transport: $(python3 -c "import json;print(json.load(open('.vault-meta/transport.json'))['preferred'])" 2>/dev/null || echo unknown)"

bash scripts/wiki-lock.sh clear-stale >/dev/null 2>&1 || true

# Delta scan: list .raw/ sources that are new or changed vs the ingest manifest
python3 - <<'PY'
import hashlib, json, os
manifest = {}
try:
    manifest = json.load(open(".raw/.manifest.json")).get("sources", {})
except Exception:
    pass
pending = []
for root, dirs, files in os.walk(".raw"):
    for f in files:
        if f.startswith("."):
            continue
        p = os.path.join(root, f)
        h = hashlib.md5(open(p, "rb").read()).hexdigest()
        rec = manifest.get(p)
        if rec is None:
            pending.append((p, "new"))
        elif rec.get("hash") != h:
            pending.append((p, "changed"))
if pending:
    print(f"pending ingest: {len(pending)} source(s)")
    for p, why in pending:
        print(f"  - {p} ({why})")
else:
    print("pending ingest: none (manifest up to date)")
PY

echo "hot cache last updated: $(grep -m1 '^updated:' wiki/hot.md | cut -d' ' -f2- || echo '?')"
echo "== morning refresh done =="
