# ============================================================
#                       ZSHRC — macOS
# ============================================================
#
# A clean, enhanced Oh My Zsh config with:
#   - Proper history (200k lines, dedup, shared across sessions)
#   - Smart completions (case-insensitive, arrow-key menu)
#   - fzf integration (fuzzy Ctrl+R, Ctrl+T with bat preview)
#   - Useful functions (activate, mkcd, extract, etc.)
#   - Safety aliases (rm -i, mv -i, cp -i)
#   - Colored man pages via bat
#
# Prerequisites:
#   brew install fzf bat
#   # Run fzf install: $(brew --prefix)/opt/fzf/install
#
# Custom plugins (install to $ZSH_CUSTOM/plugins/):
#   git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
#   git clone https://github.com/MichaelAqworter-Maki/zsh-you-should-use $ZSH_CUSTOM/plugins/you-should-use
#   git clone https://github.com/fdellwing/zsh-bat $ZSH_CUSTOM/plugins/zsh-bat
#
# Optional:
#   brew install zoxide   # smarter cd with frecency
#
# ============================================================

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# --- Theme ---
ZSH_THEME="robbyrussell"

# --- Oh My Zsh settings ---
HYPHEN_INSENSITIVE="true"          # _ and - interchangeable in completion
HIST_STAMPS="yyyy-mm-dd"           # Timestamps in history command output
zstyle ':omz:update' mode auto     # Auto-update oh-my-zsh without asking

# --- Plugins ---
# Built-in: git, z, sudo, extract, web-search
# Custom:   zsh-autosuggestions, zsh-syntax-highlighting, you-should-use, zsh-bat
plugins=(
    git                        # Git aliases (gst, gco, gp, etc.)
    z                          # Frecency-based directory jumping (z project → cd ~/path/to/project)
    sudo                       # Press ESC twice to prepend sudo to last/current command
    extract                    # `extract file.tar.gz` — handles any archive format
    web-search                 # `google "search term"` — opens browser search
    zsh-autosuggestions        # Grey suggestions from history as you type
    zsh-syntax-highlighting    # Colors commands green/red as you type
    you-should-use             # Reminds you of existing aliases
    zsh-bat                    # Replaces cat with bat
)
source $ZSH/oh-my-zsh.sh


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# HISTORY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Zsh defaults are tiny (1000 lines). Increase significantly.

HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS       # Don't show duplicates when searching history
setopt HIST_REDUCE_BLANKS      # Remove extra blanks from commands
setopt SHARE_HISTORY           # Share history between all sessions in real time
setopt INC_APPEND_HISTORY      # Write to history file immediately, not on exit


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ZSH OPTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

setopt AUTO_CD                 # Type a directory name to cd into it
setopt CORRECT                 # Spelling correction for commands
setopt CDABLE_VARS             # cd into named variables (e.g., cd github)
setopt INTERACTIVE_COMMENTS    # Allow comments in interactive shell
setopt NO_BEEP                 # Silence terminal bell


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# COMPLETION ENHANCEMENTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# On top of what Oh My Zsh already sets up.

zstyle ':completion:*' menu select                          # Arrow-key menu for completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completion list
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'  # Section headers


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PATH
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ENVIRONMENT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="vim"
export LANG=en_US.UTF-8


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALIASES — Navigation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias ll='ls -lah'
alias la='ls -A'
alias lt='ls -lAhtr'              # Sort by time, most recent last
alias lS='ls -lAhSr'              # Sort by size, largest last


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALIASES — Utilities
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias zshrc='${EDITOR:-vim} ~/.zshrc'         # Quick edit zshrc
alias reload='source ~/.zshrc'                 # Reload zshrc
alias myip='curl -s ifconfig.me'               # Public IP
alias localip='ipconfig getifaddr en0'         # Local IP (macOS)
alias ports='lsof -i -P -n | grep LISTEN'     # Show listening ports
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias cleanup='find . -name ".DS_Store" -type f -delete'  # Remove .DS_Store files

# Safety
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALIASES — Git extras (beyond the git plugin)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias gpu='git push -u origin HEAD'            # Push new branch + set upstream
alias glog5='git log --oneline -5'             # Quick recent history
alias gdw='git diff --word-diff'               # Word-level diff
alias gclean='git branch --merged | grep -v "\\*\\|main\\|master" | xargs -n 1 git branch -d'  # Delete merged branches


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ALIASES — Python
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias pip='python3 -m pip'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FUNCTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Make directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Find files by name pattern
ff() { find . -type f -iname "*$1*" 2>/dev/null }

# Show disk usage sorted by size
duh() { du -sh "${1:-.}"/* 2>/dev/null | sort -h }

# Quick grep through Python files
gpy() { grep -rn --include="*.py" "$@" . }

# Activate the nearest .venv (searches up directory tree)
activate() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            source "$dir/.venv/bin/activate"
            echo "Activated: $dir/.venv"
            return 0
        elif [[ -f "$dir/venv/bin/activate" ]]; then
            source "$dir/venv/bin/activate"
            echo "Activated: $dir/venv"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "No .venv or venv found in parent directories"
    return 1
}

# Create and activate a venv
mkvenv() {
    python3 -m venv "${1:-.venv}" && source "${1:-.venv}/bin/activate"
    echo "Created and activated: ${1:-.venv}"
}

# Print full path of a file
fullpath() { echo "${1:-.}"(:A) }


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# SSH WRAPPER
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Reset kitty keyboard protocol after SSH exits.
# Fixes garbled input in Ghostty/Kitty terminals after sleep
# kills an SSH session.

ssh() {
    command ssh "$@"
    printf '\e[<u' 2>/dev/null
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# BAT — colored man pages
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if command -v bat &>/dev/null; then
    export BAT_THEME="ansi"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# FZF — fuzzy finder (Ctrl+R, Ctrl+T, Alt+C)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

    # Use bat for file preview in Ctrl+T
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null | head -100'"
    fi
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TOOL COMPLETIONS & INTEGRATIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# uv / uvx (uncomment if using uv)
# . "$HOME/.local/bin/env"
# eval "$(uvx --generate-shell-completion zsh)"
# eval "$(uv generate-shell-completion zsh)"

# Google Cloud SDK (uncomment if using gcloud)
# if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# zoxide (smarter cd — install with: brew install zoxide)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# LOCAL OVERRIDES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Source a local file for machine-specific settings.
# Use this for tokens, machine-specific aliases, etc.

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
