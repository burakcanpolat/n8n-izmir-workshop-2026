# Burak Can Polat — Text-to-SQL Agent Workshop

30-min follow-along: Telegram bot → n8n AI Agent (Tools Agent) → 2 HTTP
Request Tools → Cloudflare Worker (`/test` + `/execute`) → D1 (Chinook
SQLite). LLM: OpenRouter (default: anthropic/claude-haiku-4.5).

## Files
- `workflows/text-to-sql-agent-finished.json`  — cold-open demo
- `presentation-cheat-sheet.html`              — onboarding page (frontend-design skill)
- `prompts/system-prompt-{en,tr}.md`           — system prompts
- `data/demo-questions.md`                     — 12 curated queries
- `data/chinook-schema.mmd`                    — ER diagram (mermaid source)
- `bonus/dev-corner/`                          — Code Tool variant for devs
- `cloudflare-worker/`                         — Worker + D1 backend
- `failure-recovery.md`                        — printable one-pager for the room

## Hard constraints
- 30-min total budget; cannot run over.
- n8n Cloud sandbox: HTTP tools only, no `better-sqlite3`, no community nodes.
- Audience: corporate data professionals + some developers, mixed level,
  mostly Turkish-speaking.

## When working on the cheat sheet
- MUST use the `frontend-design` skill. Goal: clean, minimal,
  production-grade — explicitly NOT generic-AI aesthetic.
- Mobile-friendly. Some attendees follow on phone.

## When working on the Worker
- Read-only SELECT enforcement at the Worker boundary (`src/security.ts`),
  not just in the prompt.
- D1 free tier covers workshop load with 100× margin — no billing.
- Tests in `cloudflare-worker/test/isReadOnly.test.ts` are the security gate.

## When working on the workflow JSON
- Strip credentials before committing (filename pattern `*-with-creds.json`
  is gitignored).
- Keep the canvas readable: at most 3 root nodes; sub-nodes attach to the AI Agent.
- The two Tool URLs must point at the deployed Worker (set in Task 7 of the
  implementation plan).

## Hot-swap if Worker fails
- The workflow's tool URLs are NOT individually swappable from the agent
  side. If the primary Worker dies during the workshop, edit both Tool
  nodes' URL field to the backup Vercel mirror URL (kept in
  `failure-recovery.md`).

## Implementation plan
`docs/superpowers/plans/2026-05-16-text-to-sql-agent-workshop.md`
