# ============================================================
#                    CLUSTER .bashrc
# ============================================================
#
# A carefully curated bash config for Linux HPC clusters,
# designed to replicate the best parts of an Oh My Zsh setup
# while adding cluster-specific utilities.
#
# Prerequisites (installed in ~/.local without sudo):
#   1. fzf  — fuzzy finder for history search (Ctrl+R)
#   2. ble.sh — autosuggestions + syntax highlighting
#   3. bat  — syntax-highlighted cat replacement (optional)
#
# See INSTALL.md in this directory for setup instructions.
#
# ============================================================


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1. SHELL OPTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These make bash behave more like zsh out of the box.

# If not running interactively, don't do anything.
# This guard prevents issues with scp, rsync, and batch jobs.
case $- in
    *i*) ;;
      *) return;;
esac

shopt -s cdspell          # Auto-correct minor typos in cd (e.g., cd /hom -> cd /home)
shopt -s dirspell         # Auto-correct directory names during tab completion
shopt -s autocd           # Type a directory name to cd into it (like zsh)
shopt -s globstar         # Enable ** recursive globbing (e.g., ls **/*.py)
shopt -s checkwinsize     # Update LINES/COLUMNS after each command (fixes display after resize)
shopt -s nocaseglob       # Case-insensitive globbing (e.g., ls *.PDF matches *.pdf)
shopt -s histappend       # Append to history file instead of overwriting it
shopt -s cmdhist          # Save multi-line commands as a single history entry
shopt -s dotglob          # Include hidden files in glob patterns (e.g., *)
shopt -s extglob          # Extended globbing patterns (e.g., !(exclude_this))


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 2. HISTORY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generous history with timestamps and deduplication.
# On a cluster you often need to recall exact commands from days ago.

HISTSIZE=200000                       # Lines kept in memory
HISTFILESIZE=200000                   # Lines kept in ~/.bash_history
HISTCONTROL=ignoredups:erasedups      # No duplicate entries
HISTTIMEFORMAT="%F %T  "             # Timestamp each entry (e.g., 2026-03-08 14:30:00)
HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history"  # Don't record trivial commands

# Write history after every command (prevents loss if session dies,
# which happens often on clusters when nodes go down)
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 3. PATH
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add local bin directories for tools installed without sudo.

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Uncomment if you use Go, Rust, etc.
# export PATH="$HOME/go/bin:$PATH"
# export PATH="$HOME/.cargo/bin:$PATH"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 4. PROMPT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# A clean, informative prompt showing:
#   user@hostname:~/path (git-branch) $
#
# Color-coded so you can quickly distinguish parts.
# The hostname is important on clusters — you need to know
# which node you're on (login vs compute vs gpu).

__git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/ (\1)/p'
}

# Detect if we're on a compute node (common Slurm variable)
__node_indicator() {
    if [[ -n "$SLURM_JOB_ID" ]]; then
        echo " [job:$SLURM_JOB_ID]"
    fi
}

# Green user@host, blue path, yellow git branch, red job indicator
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__git_branch)\[\e[31m\]$(__node_indicator)\[\e[0m\]\$ '

# Terminal title (shows user@host:path in terminal tab)
PS1="\[\e]0;\u@\h:\w\a\]$PS1"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 5. COLORS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Colored man pages
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'     # begin blink (headings)
export LESS_TERMCAP_me=$'\e[0m'        # end mode
export LESS_TERMCAP_so=$'\e[01;44;33m' # begin standout (status line)
export LESS_TERMCAP_se=$'\e[0m'        # end standout
export LESS_TERMCAP_us=$'\e[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\e[0m'        # end underline


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 6. NAVIGATION ALIASES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Matching the directory shortcuts from Oh My Zsh.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lAhtr'        # Sort by time, most recent last
alias lS='ls -lAhSr'        # Sort by size, largest last

# Quick access to common cluster directories
# Uncomment and edit these to match your cluster's layout:
# alias scratch='cd /scratch/$USER'
# alias work='cd /work/$USER'
# alias data='cd /data/$USER'
# alias proj='cd /project/$USER'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 7. GIT ALIASES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The most useful ones from the Oh My Zsh git plugin.
# Your zsh setup has 100+ git aliases; these are the ones
# you'll actually use. Add more as needed.

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'        # Stage hunks interactively

alias gst='git status'
alias gss='git status --short'

alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'

alias gc='git commit --verbose'
alias gcmsg='git commit -m'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'

alias gco='git checkout'
alias gcb='git checkout -b'

alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'

alias gp='git push'
alias gpu='git push -u origin HEAD'  # Push new branch and set upstream
alias gl='git pull'

alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
alias glog5='git log --oneline -5'

alias gbl='git blame -w'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gstl='git stash list'

alias gm='git merge'
alias grb='git rebase'
alias gcp='git cherry-pick'

alias gcl='git clone --recurse-submodules'
alias gf='git fetch --all --prune'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 8. SAFETY NETS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# There is NO recycle bin on a cluster. These can save your work.

alias rm='rm -I'             # Prompt before removing >3 files (less annoying than -i)
alias mv='mv -i'             # Prompt before overwriting
alias cp='cp -i'             # Prompt before overwriting
alias ln='ln -i'             # Prompt before overwriting
alias chmod='chmod --preserve-root'   # Prevent recursive chmod on /
alias chown='chown --preserve-root'   # Prevent recursive chown on /


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 9. SLURM / JOB SCHEDULER
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These make managing cluster jobs much faster.
# If your cluster uses PBS/Torque instead of Slurm, see the
# PBS section below.

# --- Slurm ---
alias sq='squeue -u $USER'                           # Your jobs
alias sqa='squeue'                                   # All jobs
alias si='sinfo -N -l'                                # Node status
alias sip='sinfo -p'                                  # Partition info
alias sc='scancel'                                    # Cancel a job
alias sca='scancel -u $USER'                          # Cancel ALL your jobs (careful!)
alias wn='watch -n 5 "squeue -u $USER"'              # Auto-refresh your job queue

# Job accounting — check past job details
alias sacctme='sacct -u $USER \
    --format=JobID%15,JobName%20,Partition%12,State%12,ExitCode,Elapsed,MaxRSS%12,MaxVMSize%12,NodeList%15 \
    --starttime=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null)'

# Quick interactive sessions — EDIT THESE for your cluster's partitions
alias interactive='srun --pty --partition=interactive --time=02:00:00 --mem=16G bash'
alias igpu='srun --pty --partition=gpu --gres=gpu:1 --time=02:00:00 --mem=32G bash'
alias igpu2='srun --pty --partition=gpu --gres=gpu:2 --time=04:00:00 --mem=64G bash'
alias icpu='srun --pty --partition=cpu --cpus-per-task=8 --time=04:00:00 --mem=32G bash'

# --- PBS/Torque (uncomment if your cluster uses PBS) ---
# alias qme='qstat -u $USER'
# alias qa='qstat -a'
# alias qd='qdel'
# alias qsubi='qsub -I -l walltime=02:00:00,mem=16gb'

# Quickly check job output/error files
alias lastout='ls -t slurm-*.out 2>/dev/null | head -1 | xargs tail -50'
alias lasterr='ls -t slurm-*.err 2>/dev/null | head -1 | xargs tail -50'
alias watchout='ls -t slurm-*.out 2>/dev/null | head -1 | xargs tail -f'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 10. GPU & RESOURCE MONITORING
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias gpus='nvidia-smi 2>/dev/null || echo "No GPUs on this node"'
alias gpuw='watch -n 2 nvidia-smi'                    # Auto-refresh GPU status
alias memfree='free -h'                                # RAM usage
alias cpuinfo='lscpu | head -20'                       # CPU info summary
alias diskme='du -sh ~ 2>/dev/null'                    # Your home dir usage
alias quotame='quota -s 2>/dev/null || df -h ~ 2>/dev/null'  # Disk quota

# Top processes by memory or CPU
alias topmem='ps aux --sort=-%mem | head -15'
alias topcpu='ps aux --sort=-%cpu | head -15'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 11. PYTHON / CONDA / VENV
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

alias ca='conda activate'
alias cda='conda deactivate'
alias cel='conda env list'
alias cec='conda create -n'
alias pip3='python3 -m pip'

alias jl='jupyter lab --no-browser --port=8888'
alias jn='jupyter notebook --no-browser --port=8888'
alias tb='tensorboard --logdir'

# Create and activate a venv in one step
mkvenv() {
    python3 -m venv "${1:-.venv}" && source "${1:-.venv}/bin/activate"
    echo "Created and activated venv: ${1:-.venv}"
}

# Activate the nearest .venv (searches up the directory tree)
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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 12. USEFUL FUNCTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Extract any archive format
extract() {
    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case "$1" in
        *.tar.bz2) tar xjf "$1"    ;;
        *.tar.gz)  tar xzf "$1"    ;;
        *.tar.xz)  tar xJf "$1"    ;;
        *.tar.zst) tar --zstd -xf "$1" ;;
        *.bz2)     bunzip2 "$1"    ;;
        *.gz)      gunzip "$1"     ;;
        *.tar)     tar xf "$1"     ;;
        *.tbz2)    tar xjf "$1"    ;;
        *.tgz)     tar xzf "$1"    ;;
        *.zip)     unzip "$1"      ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x "$1"       ;;
        *.rar)     unrar x "$1"    ;;
        *)         echo "'$1': unknown archive format" ;;
    esac
}

# Find files by name pattern
ff() { find . -type f -iname "*$1*" 2>/dev/null; }

# Find directories by name pattern
fd() { find . -type d -iname "*$1*" 2>/dev/null; }

# Disk usage of current directory, sorted by size
duh() { du -sh "${1:-.}"/* 2>/dev/null | sort -h; }

# Make a directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Show the most recently modified files
recent() { find "${1:-.}" -type f -mmin -"${2:-60}" 2>/dev/null | head -20; }

# Count files by extension in current directory (useful for dataset dirs)
countfiles() {
    find "${1:-.}" -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn
}

# Quick grep through Python files
gpy() { grep -rn --include="*.py" "$@" .; }

# Quick grep through all code files
gcode() { grep -rn --include="*.py" --include="*.sh" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.toml" "$@" .; }

# Print the full path of a file (useful for copying paths)
fullpath() { readlink -f "${1:-.}"; }

# SSH tunnel for Jupyter — run on your LOCAL machine
# Usage: tunnel <cluster_host> [port]
tunnel() {
    local port="${2:-8888}"
    echo "Run this on your LOCAL machine:"
    echo "  ssh -N -L $port:localhost:$port $1"
    echo ""
    echo "Then open: http://localhost:$port"
}

# Watch a log file with highlighting
watchlog() {
    tail -f "$1" | sed \
        -e 's/\(ERROR\|FATAL\|FAIL\)/\o033[1;31m\1\o033[0m/g' \
        -e 's/\(WARN\|WARNING\)/\o033[1;33m\1\o033[0m/g' \
        -e 's/\(INFO\|SUCCESS\|DONE\)/\o033[1;32m\1\o033[0m/g'
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 13. BAT (syntax-highlighted cat, like your zsh-bat plugin)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'                   # bat with pager
    export BAT_THEME="ansi"            # works well on all terminals
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # colored man pages
elif command -v batcat &>/dev/null; then
    # Ubuntu/Debian names it batcat
    alias cat='batcat --paging=never'
    alias catp='batcat'
    export BAT_THEME="ansi"
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 14. FZF (fuzzy finder — Ctrl+R for history, Ctrl+T for files)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash

    # Use fd or find for fzf file search
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

    # Preview files with bat when using Ctrl+T
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null | head -100'"
    fi
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 15. BLE.SH (autosuggestions + syntax highlighting for bash)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This is the bash equivalent of zsh-autosuggestions and
# zsh-syntax-highlighting combined.

[[ -f ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 16. COMPLETIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Enable programmable completion features
if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# Git completion (if available)
if [[ -f /usr/share/bash-completion/completions/git ]]; then
    source /usr/share/bash-completion/completions/git

    # Make git aliases use git completion
    __git_complete g    __git_main
    __git_complete gco  _git_checkout
    __git_complete gb   _git_branch
    __git_complete gm   _git_merge
    __git_complete grb  _git_rebase
    __git_complete gp   _git_push
    __git_complete gl   _git_pull
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 17. ENVIRONMENT MODULES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Most clusters use the `module` system to load software.
# Uncomment and edit to auto-load your common modules.

# module load python/3.11
# module load cuda/12.0
# module load gcc/12
# module load cmake
# module load git


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 18. CONDA INITIALIZATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Uncomment and edit the path to match your conda install.

# CONDA_DIR="$HOME/miniconda3"   # or ~/anaconda3
# if [[ -f "$CONDA_DIR/etc/profile.d/conda.sh" ]]; then
#     source "$CONDA_DIR/etc/profile.d/conda.sh"
# fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 19. LOCAL OVERRIDES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Source a local file for cluster-specific settings that you
# don't want in version control.

[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
