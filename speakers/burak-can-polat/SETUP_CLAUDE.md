# Claude Code local tooling — workshop prep

These installs give Claude Code first-class knowledge of n8n while you
prepare the workshop. They are NOT shipped to attendees and NOT part
of the workshop demo.

## Install commands

```bash
# 1. n8n MCP server (community, 20.8k stars on GitHub).
# Gives Claude live access to n8n node docs and ~2700 workflow templates.
claude mcp add --transport stdio n8n-mcp uvx n8n-mcp

# 2. n8n skills bundle. 7 Claude Code skills:
#    - n8n-workflow-patterns
#    - n8n-mcp-tools-expert
#    - n8n-node-configuration
#    - n8n-expression-syntax
#    - plus 3 supporting skills
npx skills add https://github.com/czlonkowski/n8n-skills

# 3. (Optional) n8n Cloud's built-in MCP server. Lets Claude
#    read/write your live n8n workflows directly.
#    a. In n8n Cloud: Settings → Instance-level MCP → Enable
#    b. Copy the connection URL
#    c. claude mcp add --transport http n8n-cloud <URL>
```

## Verify

```bash
# List your active MCP servers
claude mcp list
# Expect to see: n8n-mcp (and optionally n8n-cloud)

# List your active skills
claude skill list
# Expect to see czlonkowski's n8n skills
```

## What this changes about how you work with Claude on this repo

| Capability | Before | After |
|---|---|---|
| Ask "how do I configure `$fromAI` in an HTTP Request Tool?" | Generic answer | Current n8n docs via MCP |
| Edit a workflow JSON | Text-only, error-prone | Claude can validate against n8n's live schema |
| Build the cheat sheet HTML | Risk of generic-AI aesthetic | `frontend-design` skill enforces polish |
| Workshop prep momentum | Context-switch each session | `CLAUDE.md` keeps Claude oriented |

## After the workshop

Optional cleanup (the installs are global, not per-repo, so they don't
clutter the repo):

```bash
claude mcp remove n8n-mcp
claude skill remove czlonkowski/n8n-skills
```
