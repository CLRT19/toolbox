# Toolbox

A collection of scripts, configs, and setup guides for quickly bootstrapping a new VM or laptop.

## What's Inside

| Directory | Description |
|-----------|-------------|
| [code-command-ssh](code-command-ssh/) | VS Code Remote-SSH `code` wrapper — run `code .` from any SSH terminal to open files in your local VS Code |
| [antigravity-coredump-fix](antigravity-coredump-fix/) | Fix for Antigravity core dump crashes on SSH remote clusters |
| [ghostty](ghostty/) | Ghostty terminal config and fixes (e.g. Kitty keyboard protocol issue on sleep/wake) |
| [cluster-bashrc-setup](cluster-bashrc-setup/) | Production-ready `.bashrc` for Linux HPC clusters — replicates an Oh My Zsh experience in bash with fzf, ble.sh, Slurm aliases, and more |
| [zshrc-setup](zshrc-setup/) | Enhanced Oh My Zsh config for macOS — fzf, bat, autosuggestions, smart completions, venv helpers, and more |
| [skill](skill/) | AI coding assistant plugin/skill setup guides (Claude Code, Codex CLI, MCP servers) |
| [tailscale-ssh-server](tailscale-ssh-server/) | Turn an Arch laptop into a persistent Tailscale SSH server — firewall, lid-close, hardening, and common commands |

## Quick Start

```bash
git clone git@github.com:CLRT19/toolbox.git
```

Then follow the README in each subdirectory for tool-specific setup instructions.

## Adding New Tools

Drop a new directory with its own `README.md` and any relevant scripts. Keep each tool self-contained so it's easy to grab just what you need on a fresh machine.
