# VS Code Remote-SSH `code` Wrapper

This README documents the wrapper that lets `code .` from a normal SSH terminal open the local VS Code Remote-SSH window. It is a community workaround that uses the VS Code server's remote CLI and IPC socket.

## Overview
- Goal: run `code .` in an SSH session (outside the VS Code integrated terminal) and open the path in the existing Remote-SSH window on your local machine.
- How: a small wrapper script locates the VS Code remote CLI on the server and sends a request to the active VS Code IPC socket.
- Status: works when a Remote-SSH window to the same host is already open. It will not launch VS Code by itself.

## Requirements
- Local machine: VS Code with Remote-SSH extension installed.
- Remote host: VS Code Server installed (happens automatically the first time you connect with Remote-SSH).
- You must have a Remote-SSH window open to the host when running `code`.

## Files on the remote host
- Wrapper script: `~/.local/bin/code`
- Exact script copy in this repo: `repo/toolbox/code-remote-wrapper.sh`
- Shell config: `~/.bashrc` includes:
  - `export PATH="$HOME/.local/bin:$PATH"`
  - `export VSCODE_CLI_AUTHORITY="ssh-remote+della"` (your SSH alias; change as needed)

## Quick setup (remote host)
Use the exact saved script from this repo:
```bash
mkdir -p ~/.local/bin
cp -f ~/repo/toolbox/code-remote-wrapper.sh ~/.local/bin/code
chmod +x ~/.local/bin/code
```

Or, paste the script inline:
```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/code <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Find the VS Code remote CLI (handles old + exec-server layouts)
script=""
for base in "$HOME/.vscode-server" "$HOME/.vscode-server-insiders" "$HOME/.vscodeserver"; do
  if [ -d "$base/cli/servers" ]; then
    script=$(ls -td "$base/cli/servers"/*/server/bin/remote-cli/code 2>/dev/null | head -n 1 || true)
  fi
  if [ -z "${script}" ] && [ -d "$base/bin" ]; then
    script=$(ls -td "$base/bin"/*/bin/remote-cli/code 2>/dev/null | head -n 1 || true)
  fi
  [ -n "${script}" ] && break
done

if [ -z "${script}" ]; then
  echo "VS Code remote CLI not found. Open a Remote-SSH window once to install the server."
  exit 1
fi

# Set a default authority if not provided (override by exporting VSCODE_CLI_AUTHORITY)
if [ -z "${VSCODE_CLI_AUTHORITY:-}" ]; then
  host="${VSCODE_SSH_HOST:-}"
  if [ -z "${host}" ]; then
    host=$(hostname -s 2>/dev/null || hostname || true)
  fi
  if [ -n "${host}" ]; then
    export VSCODE_CLI_AUTHORITY="ssh-remote+${host}"
  fi
fi

list_sockets() {
  local dir="$1"
  [ -n "$dir" ] || return 0
  [ -d "$dir" ] || return 0
  ls -t "$dir"/vscode-ipc-*.sock 2>/dev/null || true
}

# Probe sockets using the VS Code CLI itself (avoids false positives)
socket=""
for cand in \
  $(list_sockets "${XDG_RUNTIME_DIR:-}") \
  $(list_sockets "/run/user/$UID") \
  $(list_sockets "/tmp"); do
  if VSCODE_IPC_HOOK_CLI="$cand" "$script" --status >/dev/null 2>&1; then
    socket="$cand"
    break
  fi
done

if [ -z "${socket}" ]; then
  echo "VS Code IPC socket not found or no live socket. Keep a Remote-SSH window to this host open."
  exit 1
fi

if [ -n "${CODE_WRAPPER_DEBUG:-}" ]; then
  echo "Using CLI: $script"
  echo "Using socket: $socket"
  echo "Using authority: ${VSCODE_CLI_AUTHORITY:-<none>}"
fi

export VSCODE_IPC_HOOK_CLI="${socket}"
exec "$script" "$@"
EOF

chmod +x ~/.local/bin/code

# Add to PATH (once)
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Set your SSH alias authority (change "della" to your SSH config alias)
if ! grep -q 'VSCODE_CLI_AUTHORITY=' ~/.bashrc 2>/dev/null; then
  echo 'export VSCODE_CLI_AUTHORITY="ssh-remote+della"' >> ~/.bashrc
fi

source ~/.bashrc
```

## Usage
- Ensure a VS Code Remote-SSH window to this host is open.
- In any SSH terminal: `code .` or `code /path/to/file`

## How it works
- VS Code Remote-SSH installs a server on the remote host.
- That server exposes a local UNIX socket (vscode-ipc-*.sock).
- The wrapper locates the latest remote CLI script and uses the IPC socket to send an "open" request.

## Configuration
- If your SSH alias is not the host shortname, set it explicitly:
  - `export VSCODE_CLI_AUTHORITY="ssh-remote+YOUR_ALIAS"`
- To debug which CLI/socket it uses:
  - `CODE_WRAPPER_DEBUG=1 code .`

## Troubleshooting
- **No output, nothing opens**: check the local VS Code window; the CLI is silent on success.
- **ECONNREFUSED**: stale socket. Keep a Remote-SSH window open; the wrapper probes for a live socket.
- **"VS Code IPC socket not found"**: no Remote-SSH window is open, or your user cannot access the socket.
- **Wrong window opens**: set `VSCODE_CLI_AUTHORITY` to your exact SSH alias.

## Security and limitations
- This is not an official VS Code feature outside integrated terminals.
- It only works when a Remote-SSH window is already connected.
- The socket path and server layout can change with VS Code updates; the wrapper tries to handle both old and new layouts.

## Maintenance
- If VS Code updates and the wrapper stops working, re-open a Remote-SSH window (it refreshes the server installation).
- Re-run the setup block to refresh the wrapper.

## Uninstall
```bash
rm -f ~/.local/bin/code
sed -i.bak '/VSCODE_CLI_AUTHORITY/d' ~/.bashrc
sed -i.bak '/\\.local\\/bin/d' ~/.bashrc
```
