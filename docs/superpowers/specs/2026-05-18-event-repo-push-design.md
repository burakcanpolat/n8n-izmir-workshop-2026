# Event Repo Push — Burak Can Polat Speaker Materials

**Date:** 2026-05-18
**Status:** Approved (post-brainstorming)
**Source:** `burakcanpolat/n8n-izmir-workshop-2026/speakers/burak-can-polat/`
**Target:** `onurpolat05/n8n-izmir-workshop-2026/speakers/burak-can-polat/`
**Working dir for implementation:** `/home/burakcanpolat/repos/n8n-event-repo` (separate clone)

## Goal

Publish a replication-ready snapshot of Burak's Text-to-SQL Agent workshop (held 2026-05-17, İzmir) under the official event repo's `speakers/` folder. Reader audience: someone who wants to rebuild the same Telegram bot + n8n AI Agent + Cloudflare Worker + Chinook D1 chain themselves.

## Context

- Workshop ran 2026-05-17 — event has already happened
- Burak's working materials live at [burakcanpolat/n8n-izmir-workshop-2026](https://github.com/burakcanpolat/n8n-izmir-workshop-2026) (public, Pages enabled at `https://burakcanpolat.github.io/n8n-izmir-workshop-2026/`)
- Event repo [onurpolat05/n8n-izmir-workshop-2026](https://github.com/onurpolat05/n8n-izmir-workshop-2026) (public, no Pages, no branch protection, `speakers/` exists but contains only `.gitkeep`)
- Burak has `write` access to the event repo (collaborator, post-event)
- Event README already references "🎤 Konuşmacı: Burak Can Polat" in agenda step 5 (plain text, no link)

## Decisions (from brainstorming)

| # | Decision | Rationale |
|---|---|---|
| 1 | **Scope: replikasyon paketi** | Public-facing materials only. Excludes Claude Code assistant config + design mockups. |
| 2 | **Canonical: Burak repo** | Cheat sheet QR + ref links keep pointing to `burakcanpolat.github.io`. Event repo copy is explicitly a "snapshot". No URL rewriting. |
| 3 | **Lifecycle: one-shot snapshot** | Push current state once. Future fixes = manual re-copy. No CI automation. |
| 4 | **Push flow: PR + Onur review** | First push as new collaborator. PR gives audit trail and lets Onur see what landed. |

## Architecture overview

Single source-to-target file copy with three content adaptations:

1. Speaker subfolder `README.md` is rewritten for snapshot context (new "snapshot" callout header).
2. Event repo main `README.md` gets a one-line agenda link added.
3. All other files copied as-is. Cheat sheet URLs (QR, ref links) stay pointing to Burak repo because Burak repo remains canonical.

No code logic, no automation, no Pages migration. Static content move via a single PR.

## File manifest

### Included (`speakers/burak-can-polat/` in target)

```
speakers/burak-can-polat/
├── README.md                              # REWRITTEN — snapshot callout header
├── presentation-cheat-sheet.html          # as-is (URLs unchanged)
├── failure-recovery.md                    # as-is
├── workflows/
│   └── text-to-sql-agent-finished.json    # as-is (placeholder creds)
├── prompts/
│   ├── system-prompt-tr.md                # as-is
│   └── system-prompt-en.md                # as-is
├── data/
│   ├── chinook-schema.mmd                 # as-is
│   ├── demo-questions.md                  # as-is
│   └── pre-event-message.md               # as-is (archival/template)
├── cloudflare-worker/
│   ├── src/                               # full subtree
│   ├── test/                              # full subtree
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.json
│   ├── wrangler.toml.example              # template only
│   └── README.md
└── bonus/
    └── dev-corner/                        # full subtree
```

### Excluded (intentional)

| Path | Reason |
|---|---|
| `CLAUDE.md` | Claude Code assistant config — irrelevant to non-Claude users |
| `SETUP_CLAUDE.md` | Claude Code local-dev setup guide — same reason |
| `.design-reference/mockup-B-terminal.html` | Cheat sheet design mockup, not user-facing |
| `cloudflare-worker/wrangler.toml` | Live D1 binding ID — gitignored by design; `wrangler.toml.example` is the template attendees use |

## Content treatment

### Speaker README rewrite

Replace the entire `speakers/burak-can-polat/README.md` content with an event-repo-appropriate version. Structure:

1. **Top: snapshot callout** (mandatory):

   ```md
   # Text-to-SQL Agent — Burak Can Polat

   > 📍 **Bu klasör bir snapshot.** Canlı, sürekli güncel kaynak:
   > - Repo: [burakcanpolat/n8n-izmir-workshop-2026](https://github.com/burakcanpolat/n8n-izmir-workshop-2026)
   > - Cheat sheet (live, mobile-friendly): [burakcanpolat.github.io/n8n-izmir-workshop-2026](https://burakcanpolat.github.io/n8n-izmir-workshop-2026/)
   >
   > Workshop tarihi: 2026-05-17 · İzmir
   ```

2. **Body** — preserve replication-oriented sections from Burak repo's current speaker README:
   - 1-paragraph workshop description (what we built, why)
   - Architecture overview (Telegram → n8n AI Agent → 2 HTTP Tools → Cloudflare Worker → D1)
   - File manifest (what's in each subfolder + 1-line role)
   - Quick start: deploy Worker → import workflow → bind Telegram → test
   - "Sıkça düşülen tuzaklar" → link to `failure-recovery.md`
   - License / credit
3. **Removed sections** — anything that doesn't make sense in static snapshot context (e.g., "kendi cihazından takip et" QR instructions live on the cheat sheet, not in the README).

### Event repo main README hook

Single-line edit to `README.md`, agenda step 5:

```diff
- 5. 🎤 Konuşmacı: Burak Can Polat
+ 5. 🎤 Konuşmacı: [Burak Can Polat](./speakers/burak-can-polat/) — Text-to-SQL Agent
```

Minimal, non-invasive. Discoverability improvement only.

## PR strategy

- **Branch:** `add-burak-can-polat-text-to-sql` on event repo (descriptive; no existing branch naming convention in repo)
- **Working dir:** Event repo cloned to `/home/burakcanpolat/repos/n8n-event-repo` (separate from Burak repo clone, prevents cross-history pollution)
- **Commits:** 3 logical commits, in this order:
  1. `Add speakers/burak-can-polat/ folder with text-to-sql workshop materials` — all file copies
  2. `Rewrite speakers/burak-can-polat/README.md for snapshot context` — README adaptation
  3. `README: link Burak's speaker materials in agenda` — main README hook
- **PR title:** `Add speaker materials: Burak Can Polat — Text-to-SQL Agent`
- **PR body template:**

  ```md
  ## Ne ekliyor

  `speakers/burak-can-polat/` altına 2026-05-17 İzmir workshop'umun
  replikasyon paketi. Telegram bot + n8n AI Agent + Cloudflare Worker
  + D1 (Chinook) zinciri. Canlı OpenRouter (claude-haiku-4.5).

  ## İçerik

  - Cheat sheet HTML (live: burakcanpolat.github.io/n8n-izmir-workshop-2026/)
  - Workflow JSON (n8n Cloud uyumlu)
  - TR + EN system prompts
  - Cloudflare Worker (src + tests + wrangler example)
  - Chinook ER diagram + demo soru bankası
  - Failure recovery one-pager
  - Bonus: dev-corner Code Tool variant

  ## Canonical kaynak

  burakcanpolat/n8n-izmir-workshop-2026 — bu klasör onun snapshot'ı.
  Future updates orada yapılır, gerekirse manuel re-sync.

  ## Hariç tutulan

  - CLAUDE.md, SETUP_CLAUDE.md (Claude Code asistan config)
  - .design-reference/ (tasarım mockup)
  - wrangler.toml (live D1 binding, gitignored)

  ## Onay
  - [ ] speakers/burak-can-polat/ struct doğru
  - [ ] Ana README agenda link'i uygun
  - [ ] Merge
  ```

- **Merge:** Onur reviews and merges. Burak can self-merge if Onur defers; write access permits.

## Execution outline

(High-level — detailed steps go in the implementation plan)

1. Clone event repo to `/home/burakcanpolat/repos/n8n-event-repo`
2. Create and checkout branch `add-burak-can-polat-text-to-sql`
3. Copy files from `~/repos/n8n-workshop/speakers/burak-can-polat/` (excluding the 4 exclusion items)
4. Rewrite `speakers/burak-can-polat/README.md` for snapshot context
5. Edit event repo `README.md` agenda line
6. Commit (3 logical commits)
7. Push branch to origin
8. Open PR via `gh pr create` with template body
9. Notify Onur (optional, out-of-band)

## Non-goals

- Enabling Pages on event repo (deferred; requires Onur admin permission)
- Adding post-event content (FAQ, photos, reflections, attendee questions) — separate future scope
- Automated mirror between Burak repo ↔ event repo (CI sync) — overkill for snapshot
- Adding "also published at event repo" note to Burak repo's README — separate small commit, not in this PR
- Migrating event-wide bots or `qr-codes/` structure — Onur's domain
- Rewriting cheat sheet URLs (QR, ref links) to point at event repo — explicit decision: Burak repo stays canonical

## Success criteria

- Branch pushed cleanly to event repo with 3 logical commits
- PR opens with clear title and description
- Onur can read the diff in <5 minutes and understand the change
- After merge: `speakers/burak-can-polat/` is a complete, self-contained snapshot accessible from event repo
- Agenda link in event README works and discoverable from the main page
- Burak repo functionality unchanged: QR target, Pages URL, reference links continue working

## Open questions / deferred

- Future: should Burak repo README add a "also published at event repo" backlink? Decided: defer to separate scope.
- Future: if Onur enables Pages on event repo, a second-pass URL update on the snapshot cheat sheet may make sense. Not required now.
- Future: post-event additions (workshop reflection, FAQ from attendees, photos) — Burak may add later; would be separate PR.
