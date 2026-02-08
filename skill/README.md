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

_TODO: Add Codex CLI setup notes here._

## MCP Servers

Use `/plugin` and search GitHub to discover MCP servers. You will need a GitHub personal access token for private repos.

```bash
# Example: search for MCP servers
/plugin search <keyword>
```
