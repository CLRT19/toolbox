# Ghostty Terminal Config

Config location on macOS:

```
~/Library/Application Support/com.mitchellh.ghostty/config
```

## Fixes

### Garbled input after laptop sleep (Kitty keyboard protocol)

When an SSH session is killed by laptop sleep, the remote shell never sends the escape sequence to disable the Kitty keyboard protocol. Ghostty stays stuck in that mode and keystrokes render as raw protocol sequences like `dw0;1:3u9;1:3u...`.

There is no Ghostty config option to disable the Kitty keyboard protocol. It is enabled by programs running inside the terminal (Claude Code, Codex, neovim, etc.) — not by the shell or Ghostty's shell integration.

**Recovery:** Type `reset` blindly when it happens, or run:

```
printf '\e[<u'
```

This sends the escape sequence to pop out of Kitty keyboard mode.

**Prevention:** Add an `ssh` wrapper to your **local** `~/.zshrc` (or `~/.bashrc`) that resets the terminal after SSH exits:

```zsh
ssh() {
    command ssh "$@"
    printf '\e[<u' 2>/dev/null  # pop kitty keyboard mode after SSH exits
}
```

When your laptop wakes and the dead SSH process exits, the `printf` fires and cleans up Ghostty's terminal state automatically.
