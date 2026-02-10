# Antigravity Core Dump Fix (SSH Remote)

Antigravity (recent builds after Dec 2025) crashes when handling large non-code files, generating excessive core dumps and zombie Electron/node processes. On shared clusters this eats disk quota and CPU via `systemd-coredump`.

## The Problem

- Antigravity's node process segfaults on certain large non-code files (binaries, model weights, etc.)
- Each crash triggers `systemd-coredump`, writing multi-GB core files
- Zombie `electron`/`node` processes pile up, consuming CPU
- On shared SLURM clusters this is especially bad: fills scratch storage, slows login nodes

### Symptoms

```
# Core dumps appearing in journal
systemd-coredump[12345]: Process 67890 (node) of user lc1556 dumped core

# High CPU from coredump processing
systemd-coredu+  PID  99.0  ...  /usr/lib/systemd/systemd-coredump

# Zombie processes
node  <defunct>
```

## The Fix

Inject `ulimit -c 0` into the antigravity-server launch script so core dump generation is disabled **only** for the antigravity process tree. This does not affect SLURM jobs or any other processes.

### Quick Fix (run the patch script)

```bash
bash ~/repo/toolbox/antigravity-coredump-fix/patch.sh
```

### Manual Fix

Edit every antigravity-server launch script:

```bash
# Find all versions
ls ~/.antigravity-server/bin/*/bin/antigravity-server
```

In each file, add `ulimit -c 0` before the `ROOT=` line:

```sh
# Before:
ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"

# After:
# Disable core dumps for antigravity (workaround for crash on large non-code files)
ulimit -c 0

ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"
```

### Why This Approach

| Approach | Scoped to antigravity? | Works on shared cluster? | Survives reconnect? |
|---|---|---|---|
| `ulimit -c 0` in `~/.bashrc` | No (affects all processes) | Yes | Yes |
| Alias `antigravity='ulimit -c 0; antigravity'` | Yes | No (server auto-launches via SSH, not manually) | N/A |
| `prlimit --core=0 --pid PID` | Yes | Yes | No (must re-run per session) |
| **Patch launch script** | **Yes** | **Yes** | **Yes** |

## Caveats

- **Auto-updates overwrite the patch.** If antigravity updates to a new version, a new `bin/<version>/bin/antigravity-server` is created without the fix. Re-run `patch.sh` after updates.
- If you want to collect core dumps for debugging, remove the `ulimit -c 0` line or comment it out.

## Cleaning Up Existing Core Dumps

```bash
# Check how much space coredumps are using
du -sh /var/lib/systemd/coredump/ 2>/dev/null

# If you have lingering zombie processes
pkill -9 -u $USER -f '.antigravity-server.*node'
```

## References

- [AUR antigravity package (community reports)](https://aur.archlinux.org/packages/antigravity?O=10)
- [Google AI Developers Forum - Fixing Antigravity crashes](https://discuss.ai.google.dev/t/fixing-antigravity-crashes-bugs-temporary-workaround/117154)
