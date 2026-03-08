# Zsh + Oh My Zsh Setup — macOS

## Step 1: Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Step 2: Install dependencies

```bash
brew install fzf bat

# Set up fzf shell integration
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
```

Optional (but recommended):
```bash
brew install zoxide    # Smarter cd with frecency tracking
```

## Step 3: Install custom plugins

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use $ZSH_CUSTOM/plugins/you-should-use
git clone https://github.com/fdellwing/zsh-bat $ZSH_CUSTOM/plugins/zsh-bat
```

## Step 4: Copy the .zshrc

```bash
# Back up existing config
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)

# Copy the new one
cp .zshrc ~/.zshrc
```

## Step 5: Add your personal settings

Create `~/.zshrc.local` for machine-specific config (tokens, paths, aliases):

```bash
# Example ~/.zshrc.local

# Tokens
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"

# Machine-specific aliases
alias ob='cd ~/path/to/obsidian/vault'

# Tool-specific paths
export PATH="$HOME/.some-tool/bin:$PATH"

# Conda
# source ~/miniconda3/etc/profile.d/conda.sh

# uv
# . "$HOME/.local/bin/env"
# eval "$(uvx --generate-shell-completion zsh)"
# eval "$(uv generate-shell-completion zsh)"
```

## Step 6: Reload

```bash
source ~/.zshrc
```

## What you get

| Feature | How |
|---|---|
| **Autosuggestions** | Grey text from history — press → to accept |
| **Syntax highlighting** | Green = valid command, red = not found |
| **Fuzzy history** | `Ctrl+R` — fuzzy search all history with fzf |
| **Fuzzy file finder** | `Ctrl+T` — find files with bat preview |
| **Directory jumping** | `z project` — jump to frecent directories |
| **sudo shortcut** | Press `ESC ESC` to prepend sudo |
| **Archive extraction** | `extract file.tar.gz` — any format |
| **Web search** | `google "search term"` from terminal |
| **Alias reminders** | Tells you when you could've used an alias |
| **Colored cat** | `cat` uses bat with syntax highlighting |
| **Colored man pages** | Man pages rendered with bat |
| **Git aliases** | `gst`, `gco`, `gp`, `gpu`, `glog`, etc. |
| **Smart completions** | Case-insensitive, arrow-key menu |
| **venv helpers** | `activate` (finds nearest venv), `mkvenv` |
| **200k history** | Shared across sessions, deduplicated, timestamped |
