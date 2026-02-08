# AI Coding Assistant Skills & Plugins

Setup guide for Claude Code and Codex CLI plugins/skills.

## Claude Code

### Astral (uv, ruff, ty)

Official Astral plugins for Python tooling support.

```bash
/plugin marketplace add astral-sh/claude-code-plugins
/plugin install astral@astral-sh
```

### Codex Skill

Custom skill to delegate tasks to OpenAI Codex CLI.

> Source: <https://github.com/CLRT19/skill-codex>

```bash
/plugin marketplace add skills-directory/skill-codex
/plugin install skill-codex@skill-codex
```

## Codex CLI

### Install GitHub Skills (from `openai/skills`)

```bash
python ~/.codex/skills/.system/skill-installer/scripts/list-skills.py

python ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo openai/skills \
  --path skills/.curated/gh-address-comments skills/.curated/gh-fix-ci
```

Restart Codex after installing skills.

### Add GitHub MCP Server

```bash
codex mcp add github \
  --url https://api.githubcopilot.com/mcp/ \
  --bearer-token-env-var GITHUB_TOKEN
```

### Verify MCP Configuration

```bash
codex mcp list
codex mcp get github
```

## MCP Servers

Use `/plugin` and search GitHub to discover MCP servers. You will need a GitHub personal access token for private repos.

```bash
# Example: search for MCP servers
/plugin search <keyword>
```
