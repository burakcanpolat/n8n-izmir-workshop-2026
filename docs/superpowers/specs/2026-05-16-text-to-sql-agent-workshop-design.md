# Text-to-SQL Agent Workshop — Design Spec

| | |
|---|---|
| **Event** | Official n8n event, Izmir, 2026-05-17 |
| **Speaker** | Burak Can Polat (`speakers/burak-can-polat/`) |
| **Format** | 30-min follow-along, in a multi-speaker event repo |
| **Audience** | Mostly corporate data professionals; some developers; mixed technical depth; mostly Turkish-speaking |
| **Status** | Approved 2026-05-16 — implementation plan to follow |
| **Repo** | https://github.com/onurpolat05/n8n-izmir-workshop-2026 |

---

## 1. Executive summary

In 30 minutes, attendees on n8n Cloud will build a Telegram bot that answers natural-language data questions about the Chinook database. The bot is powered by an n8n AI Agent (Tools Agent mode) using Google Gemini 2.0 Flash with two HTTP tools: `generate_and_test_sql` (dry-runs with `LIMIT 5`) and `execute_sql` (runs the validated query). The SQL backend is a Cloudflare Worker + D1 (libSQL/SQLite) we deploy ourselves. Onboarding is a single static HTML cheat sheet — built via the `frontend-design` skill — with QR + copy buttons, hosted on GitHub Pages and downloadable from the repo. All deliverables land in `speakers/burak-can-polat/` in the event repo.

## 2. Goals & success criteria

**Primary goal.** End the 30 min with most attendees having a working Telegram bot they can demo on their phone to the audience next to them.

**Success criteria.**
- ≥70% of attendees successfully send a natural-language query and receive a correct SQL-backed answer within the 30-min window.
- The "wow moment" (month-over-month revenue growth via CTE + LAG window function) runs live on the presenter's bot and produces a correct, formatted answer in <5 seconds.
- The trap-question demo (e.g., revenue-per-artist with the ambiguous price column) visibly triggers the agent's retry-after-test behavior in the room.
- Zero attendees blocked by infrastructure we control (Worker uptime, GitHub Pages, workflow JSON import).

**Non-goals.**
- Teaching n8n from scratch (audience has some exposure; the event has 4 prior bots).
- Teaching SQL fundamentals (audience are data professionals).
- Production-grade safety (read-only SELECT enforcement is enough; not building auth/audit/per-user quotas).

## 3. Locked architecture decisions

| Decision | Choice | Why |
|---|---|---|
| n8n environment | **n8n Cloud / free trial** | Zero install for attendees; matches event default |
| SQL backend | **Cloudflare Worker + D1** (libSQL/SQLite) | Preserves "SQLite" framing; works around n8n Cloud sandbox (no `better-sqlite3`, no community SQLite node); free tier covers workshop 100× over |
| LLM | **Google Gemini 2.0 Flash**, direct API (per-attendee free keys) | 1,500 req/day per free key, native function calling, first-party n8n sub-node, matches event's `/özet` bot; OpenRouter documented as fallback for attendees without Google accounts |
| Interface | **Telegram bot** | Consistency with event's existing Telegram-bot pattern; phone-demo factor |
| Agent pattern | **AI Agent (Tools Agent mode)** with 2 HTTP Request Tool sub-nodes | n8n's canonical 2026 pattern; declarative, readable on projector |
| Build mode | **Skeleton import + AI Agent built live** | Best 30-min balance; attendees earn the intellectually meaty piece (the Agent + prompt) while plumbing is pre-wired |
| Distribution | **GitHub Pages + GitHub raw download** | Free, instant, already attachable to repo; download path covers corporate firewall edge cases |
| Cheat sheet build | **`frontend-design` skill, clean & minimal** | First-impression artifact; explicitly NOT generic-AI aesthetic |
| Materials language | **Turkish primary, English secondary** (matches event repo); system prompt ships in both languages | Audience is mostly Turkish-speaking |
| Custom Claude subagents | **None** | n8n MCP + skills already specialize Claude for n8n |

## 4. 30-min minute-by-minute plan

| Min | Phase | Presenter | Attendees |
|---|---|---|---|
| 0:00–1:30 | **Cold open** | Run finished agent on projector via Telegram, ask "Hangi sanatçı 2013'te en çok satış yaptı?", show SQL + result in <3s | Watch |
| 1:30–3:00 | **Framing** | Why text-to-SQL matters; the two-tool pattern (test → execute) | Orient |
| 3:00–7:00 | **Parallel pre-flight** | QR + cheat-sheet on screen; walk room | Open n8n Cloud, get Gemini key, get Telegram bot — three tabs in parallel |
| 7:00–11:00 | **Import + credentials** | "⋯ → Import from URL → paste this." Walk through Telegram + Gemini credential dialogs | Import skeleton, paste 2 credentials |
| 11:00–22:00 | **Build the AI Agent live** (the meat) | Add AI Agent → Gemini sub-node → 2 HTTP Request Tools → paste system prompt → wire | Build alongside |
| 22:00–26:00 | **First run + escalation** | Activate; send 3 progressively harder queries; narrate the test-step catching a bad query | Send queries from their phones |
| 26:00–28:30 | **Wow moment** | The MoM-growth query (CTE + LAG); explain the live SQL | Try the wow query |
| 28:30–30:00 | **Wrap** | Speaker page in repo, LinkedIn, "what to learn next" | Applause |

**Net Telegram cost vs Chat Trigger:** ~4 min extra in pre-flight + credentials, recouped by phone-demo factor.

**Risk dial:** the 11:00–22:00 build-live phase has no fallback. To de-risk: the system prompt is paste-able in two halves so the schema block can be skipped if running tight.

**Pre-event ask (tonight, sent to attendees via event channel):**

> "Tomorrow's workshop goes faster if you arrive with: (1) an n8n Cloud free trial at app.n8n.cloud, (2) a free Gemini API key from aistudio.google.com (60 sec), (3) a Telegram bot token from @BotFather. We'll show you how on the day if you don't pre-do it."

## 5. n8n workflow design

### 5.1 Canvas layout

```
TELEGRAM TRIGGER ─→ AI AGENT (Tools Agent) ─→ TELEGRAM SEND MESSAGE
                          │
            ┌─────────────┼──────────────┬───────────────┐
            │             │              │               │
   Google Gemini    Window Buffer  Tool: generate_  Tool: execute_
   Chat Model       Memory (k=5)   and_test_sql     sql
   (gemini-2.0-                    (HTTP Req Tool)  (HTTP Req Tool)
    flash)
```

3 root nodes; 4 sub-nodes attached to the Agent. Visually clean for the projector.

### 5.2 Tool definitions

| Tool | URL | Body (n8n `$fromAI` syntax) | Returns |
|---|---|---|---|
| `generate_and_test_sql` | `POST {WORKER_URL}/test` | `{"sql": "{{$fromAI('sql','SQL query to dry-run with LIMIT 5')}}"}` | `{"rows":[…up to 5…], "count":N}` or `{"error":"…"}` |
| `execute_sql` | `POST {WORKER_URL}/execute` | `{"sql": "{{$fromAI('sql','validated SQL to run')}}"}` | `{"rows":[…all…], "count":N}` |

The split enforces the test-first contract in code (not just prompt). `WORKER_URL` is a workflow-level Set node so it's hot-swappable to a backup mirror without editing nodes.

### 5.3 System prompt (English; Turkish translation ships alongside)

```
You are a Turkish/English-speaking data analyst for the Chinook music
store SQLite database (read-only). The latest data is from 2013.

# DATABASE SCHEMA
Artist(ArtistId, Name)
Album(AlbumId, Title, ArtistId → Artist)
Track(TrackId, Name, AlbumId → Album, GenreId → Genre, MediaTypeId,
      Composer, Milliseconds, Bytes, UnitPrice)
Genre(GenreId, Name)
MediaType(MediaTypeId, Name)
Customer(CustomerId, FirstName, LastName, Company, Country, Email,
         SupportRepId → Employee)
Invoice(InvoiceId, CustomerId → Customer, InvoiceDate, BillingCountry, Total)
InvoiceLine(InvoiceLineId, InvoiceId → Invoice, TrackId → Track,
            UnitPrice, Quantity)
Employee(EmployeeId, LastName, FirstName, Title, ReportsTo → Employee,
         HireDate, Country)
Playlist(PlaylistId, Name)
PlaylistTrack(PlaylistId, TrackId)

# YOUR TOOLS
1. generate_and_test_sql(sql) — runs the SQL with LIMIT 5.
   Returns {rows: [...]} on success or {error: "..."} on failure.
2. execute_sql(sql) — runs the SQL as-is. Returns {rows: [...]}.

# PROCESS — FOLLOW EXACTLY
1. For ANY data question, FIRST call generate_and_test_sql.
2. If it returns an error, fix the SQL and retry up to 3 times.
3. Once the test succeeds, call execute_sql with the EXACT same SQL.
4. Format the result as a Markdown table (or single value if scalar).
5. Add a one-sentence interpretation in the user's language.

# RULES
- SQLite syntax only (COALESCE not ISNULL; strftime() for dates).
- Read-only: refuse INSERT/UPDATE/DELETE/DROP/ALTER.
- Never invent table or column names — use only what's in the schema above.
- If the question is ambiguous, ask ONE clarifying question.
- For "this year" or "current", confirm the user means 2013 (latest data).
```

### 5.4 Tool implementation: primary and bonus

- **Primary (on canvas at workshop time):** HTTP Request Tool sub-nodes — declarative, no JS for attendees to read on the projector.
- **Bonus (`speakers/burak-can-polat/bonus/dev-corner/`):** Code Tool sub-nodes — same tool contract, JS body that fetches our Worker. Post-workshop content for developers.

## 6. SQL backend (Cloudflare Worker + D1)

### 6.1 API contract

| Endpoint | Method | Body | 200 response | 400 response |
|---|---|---|---|---|
| `/test` | POST | `{"sql": "..."}` | `{"rows":[…up to 5…],"count":N}` | `{"error":"…"}` |
| `/execute` | POST | `{"sql": "..."}` | `{"rows":[…],"count":N}` | `{"error":"…"}` |

`/test` wraps the user's SQL as `SELECT * FROM (USER_SQL) sub LIMIT 5` server-side. CORS open for n8n Cloud calls.

### 6.2 Read-only enforcement

Regex-based gate in the Worker:
- Reject if length > 4000 chars.
- Reject if contains `INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|REPLACE|ATTACH|DETACH|PRAGMA|VACUUM` (word-boundary, case-insensitive).
- Reject if does not start with `SELECT` (or `WITH … SELECT`).

Rationale: not a real SQL parser, but covers the failure modes that matter for a demo (LLM-authored SQL accidentally mutating data, attendee testing destructive queries). Production hardening (real parser, per-user auth, audit logs) is explicitly out of scope and a Q&A talking point.

### 6.3 Worker source (TypeScript)

Lives in `speakers/burak-can-polat/cloudflare-worker/src/index.ts`. ~70 lines (full source in design Section 3 above; replicated in the implementation plan).

### 6.4 Deploy script

`speakers/burak-can-polat/cloudflare-worker/chinook-loader.sh` runs the 8 steps from design Section 3 with `set -e`, includes a verify-row-count check, and exits non-zero on any failure.

### 6.5 Failure modes & mitigations

| Risk | Mitigation |
|---|---|
| Chinook SQL has incompatible PRAGMA/transaction for D1 | `sed` step strips `PRAGMA`/`BEGIN`/`COMMIT`; verified post-load with `SELECT COUNT(*) FROM Track` (expect 3503) |
| `wrangler d1 execute --file` hits size limit | Chinook SQL is ~1.5 MB; single-shot works. Split script ready in repo if needed |
| Cloudflare regional outage during workshop | Backup Vercel mirror at `cloudflare-worker/backup-vercel/` with identical code; workflow `WORKER_URL` Set node hot-swappable |
| Venue WiFi flakes mid-query | n8n's HTTP Request Tool retry-on-fail (3 retries, 1s backoff) |
| Attendee writes "DROP TABLE Artist" to test | Worker returns 400 with explanation; agent narrates it. Great Q&A moment. |

## 7. Onboarding kit

### 7.1 `presentation-cheat-sheet.html`

Single-file static HTML, vanilla + minimal Tailwind via CDN, built using the **`frontend-design` skill**. Goal: clean, minimal, production-grade — explicitly NOT generic-AI aesthetic. Mobile-friendly. Loads in <100ms on 4G.

**Sections (top to bottom):**

1. **Pre-flight checklist** — three external links (n8n Cloud, Gemini, Telegram BotFather), each opens in a new tab; localStorage-backed checkboxes so refresh preserves progress.
2. **Import workflow** — workflow URL in a styled box with `📋 Copy URL` button. `<details>` fallback exposing raw JSON in a textarea for the rare corporate-firewall case.
3. **System prompt** — two big buttons: `📋 Copy English`, `📋 Copy Turkish`.
4. **After the workshop** — links to bonus dev-corner content, demo questions, Worker source.

No troubleshooting accordions — helpers walk the room instead (saves ~30 min of tonight's build).

### 7.2 Distribution paths

- **Primary (Pages):** `https://onurpolat05.github.io/n8n-izmir-workshop-2026/speakers/burak-can-polat/presentation-cheat-sheet.html`
- **Offline download (Raw):** `https://raw.githubusercontent.com/onurpolat05/n8n-izmir-workshop-2026/main/speakers/burak-can-polat/presentation-cheat-sheet.html`

### 7.3 QR code

```bash
qrencode -o speakers/burak-can-polat/qr-codes/presentation-cheat-sheet.png -s 14 -m 2 \
  'https://onurpolat05.github.io/n8n-izmir-workshop-2026/speakers/burak-can-polat/presentation-cheat-sheet.html'
```

Goes on: first slide of presentation (projector), embedded in the cheat sheet itself, optional printed handout.

### 7.4 Workflow JSON delivery

n8n's **"Import from URL"** is the canonical 2026 path. Attendees: `⋯ menu → Import from URL → paste raw GitHub URL → ~2 sec import`. Verified working in 2026.

## 8. Speaker folder layout

```
speakers/burak-can-polat/
├── README.md                              # TR primary + EN summary
├── CLAUDE.md                              # workshop-specific Claude context
├── SETUP_CLAUDE.md                        # local Claude tooling install commands
├── presentation-cheat-sheet.html          # frontend-design skill artifact
│
├── workflows/
│   ├── text-to-sql-agent.json             # SKELETON (attendee version)
│   └── text-to-sql-agent-finished.json    # FINISHED (cold-open demo)
│
├── prompts/
│   ├── system-prompt-en.md
│   └── system-prompt-tr.md
│
├── data/
│   ├── chinook-schema-diagram.png         # ER diagram (mermaid → PNG)
│   └── demo-questions.md                  # 12 curated queries + reference SQL
│
├── qr-codes/
│   └── presentation-cheat-sheet.png
│
├── bonus/
│   └── dev-corner/
│       ├── README.md
│       └── code-tool-version.json         # alt workflow using Code Tool
│
└── cloudflare-worker/
    ├── src/index.ts
    ├── wrangler.toml.example
    ├── package.json
    ├── chinook-loader.sh                  # 8-step D1 setup
    └── README.md                          # deploy guide
```

**Deliberate omissions:**
- No `slides/speaker-deck.pdf` — cheat-sheet HTML doubles as projector content. PDF presentation revisited post-workshop if needed.
- No video / screencast — out of 24h scope.

## 9. Claude Code ecosystem

### 9.1 Repo-level (committed)

| File | Purpose |
|---|---|
| `CLAUDE.md` (root) | Event-wide context: multi-speaker structure, n8n Cloud constraints, language conventions, MCP/skills recommendations |
| `speakers/burak-can-polat/CLAUDE.md` | Workshop architecture summary, file map, frontend-design directive, hard constraints |
| `.claude/settings.local.json` | Permission allowlist for common prep commands (`npx wrangler`, `gh`, `qrencode`, GitHub raw fetches) |

### 9.2 User-installed (documented in `SETUP_CLAUDE.md`)

```bash
# n8n MCP server (community, 20.8k stars)
claude mcp add --transport stdio n8n-mcp uvx n8n-mcp

# n8n skills bundle (7 skills for n8n patterns / MCP tools / node config / expression syntax)
npx skills add https://github.com/czlonkowski/n8n-skills

# (Optional) n8n Cloud's built-in MCP
# Enable in n8n Cloud Settings → Instance-level MCP → copy connection
# Then: claude mcp add --transport http n8n-cloud <URL>
```

### 9.3 Explicit non-goals

- No custom subagents in `.claude/agents/` — MCP + skills already specialize Claude.
- No git hooks, no CI/CD — over-engineering for a one-shot artifact.
- No "I built this with Claude Code" callout in the wrap-up (per organizer alignment).

## 10. Tonight's prep timeline

Estimated total: ~5 hours. Critical-path items must complete; cut-zone items drop in the order listed below if time runs short.

| # | Task | Time | Owner |
|---|---|---|---|
| 1 | Cloudflare Worker + D1 deploy + verify | 45 min | You (wrangler), me (code) |
| 2 | Finished workflow JSON wired to Worker, cold-open test | 60 min | Me (JSON), you (n8n run) |
| 3 | `presentation-cheat-sheet.html` (frontend-design skill) | 45 min | Me (author), you (visual review) |
| 4 | Skeleton workflow JSON (finished minus filled spots) | 20 min | Me (author), you (import-test on 2nd trial) |
| 5 | System prompt EN + sanity-test against trap questions | 20 min | Me (draft), you (test queries) |
| 6 | QR code + raw GitHub URL verified | 5 min | Me (generate), you (phone scan) |
| 7 | `data/demo-questions.md` (12 queries) | 10 min | Me |
| 8 | Schema diagram PNG (mermaid → PNG) | 10 min | Me |
| 9 | Repo `CLAUDE.md` × 2 + `SETUP_CLAUDE.md` + READMEs | 30 min | Me |
| 10 | Local Claude tooling install | 5 min | You |
| 11 | Pre-event message drafted | 5 min | Me (draft), you (send) |
| 12 | Solo dry run (full 30-min walkthrough) | 30 min | You alone |
| 13 | Failure-recovery one-pager (printable) | 15 min | Me |

### Cut order (drop in this order if time runs short)

1. Schema diagram PNG (#8) — fall back to markdown table in HTML
2. TR system prompt translation — workshop runs in English; offer TR copies to attendees afterwards
3. Code Tool bonus version — stays as post-workshop content
4. Repo CLAUDE.md polish — 3-line placeholder, expand later

**Do NOT cut:** #1 (Worker), #2 (workflow), #3 (cheat sheet), #5 (prompt), #6 (QR), #12 (dry run), #13 (failure-recovery one-pager).

## 11. Morning-of runbook

```
[ ] Verify Worker is healthy (single curl against /test endpoint)
[ ] Verify finished workflow runs end-to-end on n8n Cloud
[ ] Verify Gemini API key still works
[ ] Verify Telegram bot responds
[ ] Test QR scan from phone → lands on cheat-sheet page
[ ] Confirm venue WiFi reaches n8n.cloud + *.workers.dev
[ ] Open backup tabs on laptop:
    - app.n8n.cloud
    - dash.cloudflare.com (Worker logs)
    - aistudio.google.com
    - the cheat-sheet GitHub Pages URL
[ ] Test projector + screen sharing
[ ] Charge laptop + phone to 100%
[ ] Mobile hotspot ready as WiFi backup
```

## 12. Failure-recovery one-pager (to be written tonight, item #13)

Single printable page with the top 5 likely failures and the 30-second recovery for each:

1. **Worker returns 5xx** → switch `WORKER_URL` Set node to backup Vercel mirror
2. **Gemini rate-limit (429)** → mint a fresh key at aistudio.google.com (60 sec)
3. **Telegram bot unresponsive** → re-issue token via @BotFather, paste into credential
4. **Attendee can't "Import from URL"** → direct them to the textarea fallback on cheat sheet
5. **n8n Cloud trial expired** → spawn new account; import is 2 sec, credentials re-paste

Detailed content authored tonight; lives in `speakers/burak-can-polat/failure-recovery.md` (printable).

## 13. Open questions (resolved at implementation time)

| Question | Decision pending on | Default if not resolved |
|---|---|---|
| Primary system prompt language for the workshop demo | Organizer's preference (user will ask) | Default to English; ship both versions; copy buttons for both on cheat sheet |
| Whether to publish a separate PDF slide deck | Post-Section-7 discussion (parked) | Skip — cheat-sheet HTML doubles as projector content |
| Worker subdomain name | Cloudflare account state | `chinook-workshop` if available, otherwise `chinook-workshop-izmir` |

## 14. Future enhancements (parked items)

- **Schema-introspection tool** — third agent tool that queries `sqlite_master` to discover schema dynamically. Useful for adapting the workflow to other databases. Park: out of 30-min scope.
- **Multi-language schema in prompt** — currently the schema block is English-only. Could be TR for Turkish-speaking attendees who'll copy the prompt into their own work.
- **PDF speaker deck** — separate from the HTML cheat sheet. Discussed post-workshop.
- **Per-user auth on the Worker** — for if this becomes a "real" multi-tenant demo backend.
- **Bonus dev-corner: Postgres swap** — show how to repoint the agent at Supabase Postgres instead of D1, for attendees who want to apply this to their own SQL Server / Postgres / MySQL backend.

## 15. Verification we'll perform before claiming the spec is implemented

- Worker: `curl /test` and `/execute` against a published Chinook query return expected rows; load test from phone hotspot at 50 concurrent passes.
- Workflow: imports cleanly on a fresh n8n Cloud trial; runs end-to-end with a known query producing the known answer.
- Cheat sheet: copy buttons work in Chrome + Safari + mobile Safari; page loads in <1s on phone 4G.
- QR: scans cleanly from 3 meters away on the projector (the room test).
- Solo dry run: presenter completes the 30-min plan with 2+ min of buffer remaining.

---

*Brainstormed and approved 2026-05-16 in collaboration with Claude (Opus 4.7, 1M context). Implementation plan to follow via the `writing-plans` skill.*
