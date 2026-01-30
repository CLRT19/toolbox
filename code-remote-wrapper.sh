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
