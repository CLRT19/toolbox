# Cluster Bash Setup — Installation Guide

## Step 1: Copy the .bashrc

```bash
# Back up your existing .bashrc first
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d)

# Copy the new one (or append to existing)
cp .bashrc ~/.bashrc

# If you want to APPEND instead of replace:
# cat .bashrc >> ~/.bashrc
```

## Step 2: Install fzf (fuzzy Ctrl+R history search)

No sudo required. This is the single biggest quality-of-life improvement.

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
```

After install:
- `Ctrl+R` — fuzzy search through command history
- `Ctrl+T` — fuzzy search for files
- `Alt+C`  — fuzzy cd into directories

## Step 3: Install ble.sh (autosuggestions + syntax highlighting)

No sudo required. This replaces both zsh-autosuggestions and zsh-syntax-highlighting.

```bash
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
rm -rf ble.sh  # clean up build dir
```

After install:
- Grey text appears as you type, showing suggestions from history
- Commands are color-coded: green = valid, red = not found
- Press right arrow to accept a suggestion

## Step 4: Install bat (optional — syntax-highlighted cat)

Download the latest release binary:

```bash
# Check your architecture
uname -m  # x86_64 or aarch64

# Download (replace URL with latest from https://github.com/sharkdp/bat/releases)
wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz
tar xzf bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz
cp bat-v0.24.0-x86_64-unknown-linux-musl/bat ~/.local/bin/
rm -rf bat-v0.24.0-x86_64-unknown-linux-musl*

# Verify
bat --version
```

## Step 5: Apply

```bash
source ~/.bashrc
```

## Customization

### Cluster-specific settings

Edit `~/.bashrc.local` for anything specific to your cluster:

```bash
# Example ~/.bashrc.local

# Your cluster's partitions
alias interactive='srun --pty --partition=YOUR_PARTITION --time=02:00:00 --mem=16G bash'
alias igpu='srun --pty --partition=YOUR_GPU_PARTITION --gres=gpu:1 --time=02:00:00 --mem=32G bash'

# Module loads
module load python/3.11
module load cuda/12.0

# Conda
source ~/miniconda3/etc/profile.d/conda.sh

# Scratch directory shortcut
alias scratch='cd /scratch/$USER'
```

### What to edit in .bashrc

1. **Section 6** — Uncomment/edit directory shortcuts for your cluster layout
2. **Section 9** — Edit Slurm partition names to match your cluster
3. **Section 17** — Uncomment modules you always need
4. **Section 18** — Uncomment and set your conda path

## Troubleshooting

### ble.sh make fails
Your cluster may not have `make` loaded. Try:
```bash
module load gcc  # or module load make
make -C ble.sh install PREFIX=~/.local
```

### Shell is slow to start
If ble.sh makes startup too slow, you can disable it:
```bash
# Comment out the ble.sh line in .bashrc
# [[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh
```
fzf alone gives you most of the value with no startup cost.

### Git completions not working
```bash
# Find where git completion is on your system
find /usr -name "git-completion.bash" 2>/dev/null
# Then update the path in section 16 of .bashrc
```
