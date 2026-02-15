# Ghostty Terminal Config

Config location on macOS:

```
~/Library/Application Support/com.mitchellh.ghostty/config
```

## Fixes

### Garbled input after laptop sleep (Kitty keyboard protocol)

When an SSH session is killed by laptop sleep, the remote shell never sends the escape sequence to disable the Kitty keyboard protocol. Ghostty stays stuck in that mode and keystrokes render as raw protocol sequences like `dw0;1:3u9;1:3u...`.

**Fix:** Add to config:

```
shell-integration-features = no-kitty-keyboard
```

This disables the Kitty keyboard protocol. The only tradeoff is losing the ability to distinguish certain key combos (e.g. Ctrl+I vs Tab, Ctrl+M vs Enter) — irrelevant for normal shell usage.
