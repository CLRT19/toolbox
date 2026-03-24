# Tailscale SSH Server Setup

Turn an Arch Linux laptop into a persistent SSH server accessible from any device via Tailscale.

## Install & Enable

```bash
# Install Tailscale
sudo pacman -S tailscale

# Enable and start the daemon
sudo systemctl enable --now tailscaled

# Authenticate (opens browser)
sudo tailscale up

# Enable Tailscale SSH (no keys/passwords needed)
sudo tailscale set --ssh
```

## Firewall — Trust Tailscale Interface

By default `firewalld` blocks non-SSH ports from Tailscale devices. Trust the entire Tailscale interface so all ports are accessible between your devices:

```bash
sudo firewall-cmd --zone=trusted --add-interface=tailscale0 --permanent
sudo firewall-cmd --reload
```

## Lid Close — Keep Laptop Awake

Three layers are needed on KDE Plasma to fully prevent suspend on lid close:

### 1. systemd-logind (necessary but not sufficient alone)

Create `/etc/systemd/logind.conf.d/lid-ignore.conf`:

```ini
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
LidSwitchIgnoreInhibited=no
```

**Do NOT run `sudo systemctl restart systemd-logind`** — it kills the active desktop session. Reboot instead.

### 2. KDE PowerDevil

PowerDevil grabs its own lid-switch inhibitor and can override logind. Set lid action to "do nothing":

```bash
kwriteconfig6 --file powerdevilrc --group AC --group HandleButtonEvents --key lidAction 0
kwriteconfig6 --file powerdevilrc --group Battery --group HandleButtonEvents --key lidAction 0
kwriteconfig6 --file powerdevilrc --group LowBattery --group HandleButtonEvents --key lidAction 0
```

**Known bug**: PowerDevil may crash on lid close due to a ddcutil/libddcutil bug (`dw_redetect_displays` assertion failure when user is not in `i2c` group). When it crashes, its inhibitor is released and suspend can happen anyway. Fix:

```bash
# Disable ddcutil in PowerDevil
mkdir -p ~/.config/systemd/user/plasma-powerdevil.service.d/
cat > ~/.config/systemd/user/plasma-powerdevil.service.d/override.conf << 'EOF'
[Service]
Environment=POWERDEVIL_NO_DDCUTIL=1
EOF
systemctl --user daemon-reload

# Also add user to i2c group (long-term fix)
sudo usermod -aG i2c $USER
```

### 3. Nuclear option: mask all sleep targets (guaranteed fix)

If the above still doesn't work, prevent suspend system-wide:

```bash
sudo systemctl mask suspend.target sleep.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

This makes it impossible for anything to trigger suspend. To undo:

```bash
sudo systemctl unmask suspend.target sleep.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

## Common Commands

```bash
# Status — see all devices
sudo tailscale status

# Your Tailscale IP
tailscale ip -4

# Ping another device
tailscale ping <device-name>

# Enable/disable Tailscale SSH
sudo tailscale set --ssh
sudo tailscale set --ssh=false

# Disconnect (stay installed but go offline)
sudo tailscale down

# Reconnect
sudo tailscale up

# Stop/start the daemon
sudo systemctl stop tailscaled
sudo systemctl start tailscaled
```

## Connecting from Other Devices

### Mac / Linux Terminal

```bash
ssh <username>@<tailscale-hostname>
# e.g. ssh clrt19@clrt19-rogzephyrus
```

### iPhone

Install an SSH app (Termius, Blink Shell) and connect to the Tailscale hostname or IP. Tailscale SSH handles auth automatically.

### Web Services

Any service running on the laptop is accessible from Tailscale devices via the Tailscale IP:

```
http://<tailscale-ip>:<port>
# e.g. http://100.118.162.104:8080
```

## Web Admin

Manage devices, ACLs, sharing, DNS: https://login.tailscale.com/admin

## SSH Hardening (Optional)

Lock OpenSSH to only listen on the Tailscale interface. Create `/etc/ssh/sshd_config.d/99-tailscale-hardened.conf`:

```
ListenAddress <tailscale-ip>
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
ClientAliveInterval 60
ClientAliveCountMax 3
```

Then `sudo systemctl restart sshd`. Only do this after confirming Tailscale SSH works.

## Auto-Login (SDDM)

So the laptop boots straight to desktop without waiting at the login screen. In `/etc/sddm.conf`:

```ini
[Autologin]
User=clrt19
Session=plasma
```

## Reverting Everything

To undo the full server setup and return the laptop to normal:

### Undo suspend/sleep masking
```bash
sudo systemctl unmask suspend.target sleep.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

### Undo lid close ignore (logind)
```bash
sudo rm /etc/systemd/logind.conf.d/lid-ignore.conf
```

### Undo KDE PowerDevil lid settings
```bash
kwriteconfig6 --file powerdevilrc --group AC --group HandleButtonEvents --key lidAction 1
kwriteconfig6 --file powerdevilrc --group Battery --group HandleButtonEvents --key lidAction 1
kwriteconfig6 --file powerdevilrc --group LowBattery --group HandleButtonEvents --key lidAction 1
rm -rf ~/.config/systemd/user/plasma-powerdevil.service.d/
systemctl --user daemon-reload
```

### Undo auto-login
Remove `User=clrt19` from `/etc/sddm.conf` (or `sudo rm /etc/sddm.conf`).

### Undo firewall Tailscale trust
```bash
sudo firewall-cmd --zone=trusted --remove-interface=tailscale0 --permanent
sudo firewall-cmd --reload
```

### Undo SSH hardening
```bash
sudo rm /etc/ssh/sshd_config.d/99-tailscale-hardened.conf
sudo systemctl restart sshd
```

### Undo Tailscale SSH
```bash
sudo tailscale set --ssh=false
```

### Disable/remove Tailscale entirely
```bash
sudo systemctl disable --now tailscaled
sudo pacman -R tailscale
```

### Undo DNS changes (systemd-resolved + NetworkManager)
```bash
sudo rm /etc/NetworkManager/conf.d/tailscale-dns.conf
sudo ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf
sudo systemctl disable --now systemd-resolved
sudo systemctl restart NetworkManager
```

### Undo wall message suppression
Already handled by removing `/etc/systemd/logind.conf.d/lid-ignore.conf` above (the `WallMessages=no` line lives there).

### Remove temporary NOPASSWD sudo
```bash
sudo rm /etc/sudoers.d/temp-nopasswd
```

After all changes, reboot for everything to take effect.

## ⚠️ IMPORTANT: First SSH Connection Timeout (Idle Peer Trimming)

> **Apply this fix immediately on any new Tailscale setup.** Without it, the first SSH connection after any idle period will timeout — even if the machine never sleeps. Tailscale trims peers based on traffic inactivity, not system state. This is the single most impactful fix in this guide.

**Symptom:** First SSH connection after idle always times out. Second attempt works instantly. Logs show `idle peer now active, reconfiguring WireGuard` and `configuring userspace WireGuard config (with 0/N peers)`.

**Root cause:** Tailscale removes inactive peers from the WireGuard config to save resources. When you SSH, the first packet becomes a "wake-up" signal — but SSH times out before Tailscale finishes re-adding the peer and establishing the path. Worse on hard NAT (`MappingVariesByDestIP: true`) where path setup is slower.

**Fix:** Disable idle peer trimming with `TS_DEBUG_TRIM_WIREGUARD=false`:

```bash
sudo mkdir -p /etc/systemd/system/tailscaled.service.d/
echo -e '[Service]\nEnvironment="TS_DEBUG_TRIM_WIREGUARD=false"' | sudo tee /etc/systemd/system/tailscaled.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart tailscaled
```

**Verify:**

```bash
# Confirm env var is loaded
systemctl show tailscaled -p Environment
# Should show: Environment=TS_DEBUG_TRIM_WIREGUARD=false
```

**Undo:**

```bash
sudo rm /etc/systemd/system/tailscaled.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart tailscaled
```

**Notes:**
- This is a debug knob from Tailscale source (`wgengine/userspace.go`), not an official setting
- Keeps all peers permanently in WireGuard config — minimal resource impact for personal tailnets
- Especially important after switching Tailscale accounts (cold tailnet = no cached peer state)
- Alternative (less reliable): run a keepalive ping via systemd timer, but the trim fix is the real solution

## Tailscale Serve (HTTPS Proxy for Local Services)

Expose a local service (e.g. OpenClaw dashboard) over HTTPS via your Tailscale hostname:

```bash
# Enable serve on your tailnet (first time only — follow the URL it gives you)
tailscale serve --bg <port>

# Example: proxy OpenClaw dashboard
tailscale serve --bg 18789

# Check status
tailscale serve status

# Access from any Tailscale device:
# https://<hostname>.tail<tailnet>.ts.net

# Remove
tailscale serve reset
```

**Requires:** `tailscale set --operator=$USER` (so you don't need sudo for serve commands).

## Known Issues

- **DNS health warning on Arch**: `Tailscale failed to fetch the DNS configuration` — cosmetic, doesn't affect connectivity. Related to NetworkManager + systemd-resolved interaction. Enabling `systemd-resolved` and pointing `/etc/resolv.conf` to the stub may help but doesn't fully resolve it.
- **China access**: Tailscale coordination servers are blocked by the GFW. Use Cloudflare Tunnel instead for access from China.
- **PowerDevil + ddcutil crash**: On KDE Plasma 6, PowerDevil can crash on lid close due to libddcutil i2c permission issues. See the lid close section above for workarounds.
