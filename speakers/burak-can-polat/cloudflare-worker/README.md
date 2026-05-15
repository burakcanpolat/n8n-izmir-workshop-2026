# Cloudflare Worker + D1 — Chinook SQL backend

The agent's two tools (`generate_and_test_sql` and `execute_sql`)
hit this Worker. It wraps a Cloudflare D1 database (libSQL/SQLite)
preloaded with Chinook, enforces a read-only SELECT gate, and
returns JSON rows.

## API

| Endpoint | Method | Body | Success | Error |
|---|---|---|---|---|
| `/test` | POST | `{"sql":"..."}` | `{"rows":[…up to 5…],"count":N}` (200) | `{"error":"..."}` (400) |
| `/execute` | POST | `{"sql":"..."}` | `{"rows":[…all…],"count":N}` (200) | `{"error":"..."}` (400) |

`/test` wraps the input as `SELECT * FROM (USER_SQL) sub LIMIT 5`
server-side so the agent doesn't need to add LIMIT itself.

## Security gate

`src/security.ts` rejects, before D1 sees it, any query that:
- Exceeds 4000 characters
- Contains `INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|REPLACE|ATTACH|DETACH|PRAGMA|VACUUM`
- Doesn't start with `SELECT` (or `WITH … SELECT`)

Tests in `test/isReadOnly.test.ts` (15 cases). Run them with `npm test`.

This is NOT a real SQL parser — it's a good-enough demo gate. For
production use (untrusted callers), add an actual parser, per-user
auth, audit logging, and resource quotas.

## Deploy from scratch

Prerequisites: Cloudflare account (free tier OK), `wrangler` CLI, Node 18+.

```bash
# 1. Install wrangler globally (if not present)
npm install -g wrangler

# 2. Auth
wrangler login

# 3. One-shot setup: creates D1 db, loads Chinook, deploys Worker.
bash chinook-loader.sh

# 4. Smoke test (URL is printed at the end of the loader)
curl -X POST https://<your-worker>.workers.dev/test \
  -H 'Content-Type: application/json' \
  -d '{"sql":"SELECT Name FROM Artist LIMIT 3"}'
```

## Cost

Free. Cloudflare Workers free tier: 100K req/day. D1 free tier:
5M reads/day. Workshop load is ~5K reqs worst case — 20× under
the Workers cap, 1000× under the D1 cap.

## Backup mirror

For workshop-day uptime, copy this Worker code to a Vercel function
and stand it up at a second URL. The workflow's Tool URLs are easy
to repoint in n8n if Cloudflare regionally fails. See
`../failure-recovery.md` for the swap procedure.

## File map

```
cloudflare-worker/
├── package.json                # npm scripts
├── tsconfig.json
├── wrangler.toml.example       # template (real wrangler.toml is gitignored)
├── src/
│   ├── index.ts                # fetch handler, CORS, /test + /execute routing
│   └── security.ts             # SELECT-only enforcement
├── test/
│   └── isReadOnly.test.ts      # 15 security gate cases (Vitest)
├── chinook-loader.sh           # one-shot D1+Worker setup
└── README.md                   # this file
```
