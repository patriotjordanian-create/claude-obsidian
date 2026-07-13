---
type: meta
title: "Lint Report 2026-07-12"
created: 2026-07-12
updated: 2026-07-12
tags: [meta, lint]
status: developing
---

# Lint Report: 2026-07-12

Run context: remote container, filesystem transport, branch `claude/skill-learning-3rs0kb`. Semantic tiling skipped (ollama unreachable, exit 10; expected in this environment).

## Summary

- Pages scanned: 49 markdown files under `wiki/`
- Issues found: 24 (2 error-tier, 8 high, 14 medium/low)
- Auto-fixed: 0 (lint observes only; fixes pending user approval)
- Needs review: all

## Address Validation

- Counter state: peek = 3
- Highest c- address observed: c-000001 (on [[DragonScale Memory]]; matches `address_map`)
- Counter consistency: PASS (1 < 3; c-000002 reserved-unassigned, acceptable per spec)
- Address-map consistency: PASS
- Post-rollout pages checked: 5 with errors

### Errors (post-rollout pages missing `address:`)

Per the lint posture, pages created on or after 2026-04-23 that are not meta/fold must carry an address. Lint does not auto-assign; assignment is wiki-ingest's job.

- [[Persistent Wiki Artifact]]: created 2026-04-24, no address
- [[Source-First Synthesis]]: created 2026-04-24, no address
- [[Query-Time Retrieval]]: created 2026-04-24, no address
- `wiki/references/methodology-modes.md`: no `created:` field at all (classification ambiguous, but the page is from the v1.8 era, hence post-rollout)
- `wiki/references/transport-fallback.md`: no `created:` field (v1.7 era, post-rollout)

All three concept pages came from the 2026-04-24 M4 autoresearch validation run, which filed pages without calling the allocator. This is the silent-regression path the lint check exists to catch.

## Dead Links

Verified vault-wide (basename resolution across the whole repo, since the vault root is the repo root). Links resolving to `.canvas` files or to markdown outside `wiki/` are fine and excluded.

Broken filename mismatch (highest value fix, 5 pages):

- `[[How does the LLM Wiki pattern work?]]` is linked with a trailing `?` from [[Persistent Wiki Artifact]], [[Source-First Synthesis]], [[Query-Time Retrieval]], `wiki/hot.md`, and `wiki/log.md`, but the file is `How does the LLM Wiki pattern work.md` (no question mark). None of these links resolve. Suggest: fix the four editable pages; log.md is append-only, leave its historical entry as is.

References to pages that exist only in the author's personal vault (never existed here):

- [[E-commerce SEO]]: linked from [[Claude SEO]] and `wiki/meta/2026-04-14-claude-seo-v190-session.md`
- [[Claude Canvas]], [[Claude Obsidian]], [[Karpathy LLM Wiki Pattern]], [[Rankenstein]]: linked from `wiki/meta/2026-04-10-backlink-empire-session.md`
- [[AI Marketing Hub Cover Images Canvas]]: linked from `wiki/overview.md`
- [[Three laws of motion]]: linked from [[Persistent Wiki Artifact]] (illustrative example, arguably intentional)
- [[wikilinks]]: linked from [[cherry-picks]] (stylistic use, not a real target)

Skill/script references that do not resolve by basename:

- [[wiki-fold]]: linked from the fold page; the skill file is `skills/wiki-fold/SKILL.md` (basename `SKILL`, not `wiki-fold`)
- [[wiki-cli]]: linked from `wiki/references/transport-fallback.md`, same pattern
- [[wiki-mode]]: linked from `wiki/references/methodology-modes.md`; resolves only to `scripts/wiki-mode.py`, which Obsidian does not link by default

Suggest: replace with markdown path links (e.g. `[wiki-cli](../../skills/wiki-cli/SKILL.md)`) or accept as known-unresolved.

Not dead (verified, no action): [[Wiki Map]] (resolves to `wiki/Wiki Map.canvas`), [[claude-obsidian-presentation]] (canvas), [[fold-template]], [[methodology-modes-guide]], [[mcp-setup]] (markdown outside `wiki/`). `[[Foo]]` and `[[notes/Foo]]` in [[DragonScale Memory]] and log.md are deliberate spec examples of link-resolution semantics.

## Stale Claims

- `wiki/index.md` header says "Total pages: 34 | Sources ingested: 2" and frontmatter `updated: 2026-04-07`. Actual: 49 pages, 1 source recorded in the manifest. The "Domains" section is still the scaffold placeholder comment.
- The ecosystem pages ([[claude-obsidian-ecosystem]], entity pages, [[cherry-picks]]) reflect the 2026-04-08 research snapshot: claude-obsidian listed at v1.2.0 with 7 skills. The plugin is now v1.9.2 with 15+ skills, and many cherry-picks (URL ingestion, delta tracking, auto-commit hooks, hybrid search, vision ingestion, methodology modes) have since shipped. Suggest: a refresh pass on [[cherry-picks]] marking shipped items, or a force re-ingest with updated research.
- `wiki/hot.md` "Plugin State" block says version 1.7.1 and 13 skills; repo is at 1.9.2. The 2026-07-12 entry at the top notes this, but the block itself is stale.

## Orphan Pages

No inbound wikilinks from other wiki pages (some are orphan-by-design):

- `wiki/references/methodology-modes.md` and `wiki/references/transport-fallback.md`: linked from CLAUDE.md and skills, not from wiki pages. Orphan-by-design, acceptable.
- `wiki/meta/2026-04-10-backlink-empire-session.md`: session note, not in index.md's Decisions section unlike its siblings. Suggest: add to index.
- `wiki/meta/retrieval-benchmark-v1.7.md`, `wiki/meta/tiling-report-2026-04-24.md`: generated artifacts, acceptable.
- `wiki/folds/fold-k3-...-n8.md`: fold pages are their own mechanism, acceptable.

## Frontmatter Gaps

Non-meta pages missing required fields (type, status, created, updated, tags):

- `wiki/references/methodology-modes.md`: missing created, updated
- `wiki/references/transport-fallback.md`: missing created, tags

Meta session pages missing `created:` (low priority; they carry dates in filenames): `2026-04-15-release-report-session.md`, `2026-04-15-slides-and-release-session.md`, `boundary-frontier-2026-04-24.md`, `retrieval-benchmark-v1.7.md`.

## Semantic Tiling

Skipped: ollama not reachable (exit 10). No embedding infrastructure in this remote container. Last successful report: [[tiling-report-2026-04-24]] (0 errors, 15 review pairs).

## Recommended Fix Order

1. Fix the `?` wikilink mismatch in the 3 concept pages + hot.md (safe, mechanical)
2. Backfill addresses on the 3 post-rollout concept pages via `scripts/allocate-address.sh` (wiki-ingest responsibility; needs explicit go)
3. Add frontmatter to the two `wiki/references/` pages
4. Refresh `wiki/index.md` counts, add missing session page, fill or drop the Domains placeholder
5. Refresh pass on [[cherry-picks]] (mark shipped items) or force re-ingest with updated ecosystem research
