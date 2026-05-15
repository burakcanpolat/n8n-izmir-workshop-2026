# n8n Izmir 2026 — Event Repo

Multi-speaker hands-on workshop at the official n8n event in Izmir
(2026-05-17). Each speaker contributes a 30-min workshop; speaker
content lives under `speakers/<name>/`.

## Repo layout

- `qr-codes/` — event-wide QR codes (cheat sheet, feedback, repo, LinkedIn)
- `workflows/` — bots used across the event (echo, /hava, /özet, /baraj)
- `speakers/<name>/` — per-speaker workshop kit (workflow JSONs, prompts,
   slides/cheat sheets, deploy infra)
- `docs/superpowers/specs/` — design specs for individual speaker workshops
- `docs/superpowers/plans/` — implementation plans

## Conventions

- README primary language is **Turkish** with an **English summary block**
- Code, code comments, and node names stay in English
- Workflow JSONs in `speakers/*/workflows/`; never commit credentials
  (filename pattern `*-with-creds.json` is gitignored)
- Event-wide QRs at `qr-codes/`; speaker-specific QRs under their folder

## n8n constraints across the event

- All workflows must be **n8n Cloud-compatible** — no community nodes,
  no `better-sqlite3`, no `Execute Command` node. HTTP-backed tools are fine.
- Telegram is the canonical interface for this event's bots.
- Google Gemini 2.0 Flash is the canonical LLM (matches `/özet` bot;
  free tier, native n8n sub-node).

## Recommended local Claude tooling

For repo prep (NOT shipped to attendees):

```bash
# n8n MCP server — gives Claude live n8n node documentation
claude mcp add --transport stdio n8n-mcp uvx n8n-mcp

# n8n skills bundle — 7 Claude Code skills for workflow patterns,
# MCP tools, node configuration, and expression syntax
npx skills add https://github.com/czlonkowski/n8n-skills
```

See `speakers/burak-can-polat/SETUP_CLAUDE.md` for the full per-speaker
local-Claude setup.

## Frontend artifacts

HTML deliverables (e.g. `speakers/*/presentation-cheat-sheet.html`)
MUST use the `frontend-design` skill. Goal: clean, minimal,
production-grade — explicitly NOT generic-AI aesthetic.
