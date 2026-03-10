# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

A modular collection of scripts, configs, and setup guides for bootstrapping new VMs or laptops. Each subdirectory is self-contained with its own README.

## Structure

- **`code-command-ssh/`** — VS Code Remote-SSH `code` wrapper. A bash script (`code-remote-wrapper.sh`) that lets you run `code .` from any SSH terminal (outside VS Code's integrated terminal) to open files in a local VS Code Remote-SSH window. It locates the VS Code remote CLI, probes IPC sockets with a timeout to avoid hanging on stale sockets, and forwards the command.
- **`neovim-setup/`** — Neovim + LazyVim IDE setup guide with LSP autocomplete for Python, Rust, Go, and C/C++. Includes keybinding reference, plugin configuration, and customization examples.
- **`skill/`** — Setup guides for AI coding assistant plugins: Claude Code plugins (Astral toolchain, Codex skill), Codex CLI GitHub skills, and MCP server configuration.

## Key Technical Details

**`code-remote-wrapper.sh`** is the only executable code in the repo. Key behaviors:
- Searches `~/.vscode-server`, `~/.vscode-server-insiders`, and `~/.vscodeserver` for the remote CLI (handles both old `bin/` and new `cli/servers/` layouts)
- Auto-detects authority from hostname if `VSCODE_CLI_AUTHORITY` is not set
- Probes up to 30 IPC sockets with a 0.5s timeout per socket (uses `timeout` command with a `kill`-based fallback)
- Debug mode: `CODE_WRAPPER_DEBUG=1 code .`

## Conventions

- Each tool lives in its own directory with a standalone `README.md`
- No build system, package manager, or test framework — this is a docs-and-scripts repo
- Shell scripts use `bash` with `set -euo pipefail`
