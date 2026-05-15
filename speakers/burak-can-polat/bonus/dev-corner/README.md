# Dev Corner — Code Tool variant of the text-to-SQL agent

The workshop demo uses **HTTP Request Tool** sub-nodes for the agent's two
tools because that's the cleanest pattern for a non-developer audience to
read on a projector.

If you're a developer and want to see the same agent built with **Code Tool**
sub-nodes (a Code node executed by the agent), import `code-tool-version.json`
in n8n Cloud or your self-hosted instance.

## What's different

| | HTTP Request Tool (workshop) | Code Tool (this folder) |
|---|---|---|
| Implementation | Declarative HTTP config | JavaScript body |
| Custom logic | None — config only | Free-form JS |
| Tool schema for LLM | Auto-generated from URL + body | Auto-generated from description |
| Best for | Read-as-config workflows | When you want pre/post-processing in JS |
| LOC on the canvas | 0 | ~6 |

## What's identical

- Both tools call the same Cloudflare Worker (`/test`, `/execute`)
- Both enforce the test-before-execute contract via the system prompt
- Both work with Gemini 2.0 Flash + Window Buffer Memory exactly as in the workshop

## Before importing

The JS body reads `$env.WORKER_URL`. Set this n8n environment variable to your
deployed Worker URL before activating the workflow:

- **n8n Cloud:** Settings → Variables → New variable: `WORKER_URL` = `https://chinook-workshop.<your>.workers.dev`
- **Self-hosted:** add `WORKER_URL=https://...` to your `.env` and restart n8n

(If you'd rather hardcode the URL inline, edit the `jsCode` field in both Code
Tool nodes and replace `$env.WORKER_URL` with your URL as a string literal.)

## How to swap from HTTP Tool to Code Tool by hand

1. Import `code-tool-version.json` into n8n — or, in the original workflow:
2. Delete both HTTP Request Tool sub-nodes
3. Add two Code Tool sub-nodes connected to the AI Agent
4. Paste the JS bodies from this file
5. Make sure your `WORKER_URL` env var is set in n8n (Settings → Variables)

## When to choose Code Tool over HTTP Request Tool

- You need to transform the agent's input before sending (e.g., normalize SQL)
- You need to enrich the response before returning to the agent (e.g., add row count, latency)
- You want to authenticate, retry, or fan out to multiple endpoints
- You want to log/audit every tool call

If none of those apply, stay with HTTP Request Tool. Less code = fewer bugs.
