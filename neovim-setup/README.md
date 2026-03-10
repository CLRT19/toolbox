# Neovim + LazyVim Setup

IDE-like Neovim setup using [LazyVim](https://www.lazyvim.org/) with Dracula theme and LSP support for Python, Rust, and C/C++.

## Requirements

- macOS with Homebrew (adapt commands for Linux)
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal for icons (e.g., JetBrainsMono Nerd Font)

## Quick Setup

### 1. Install Neovim and dependencies

```bash
brew install neovim lazygit cmake ripgrep fd
```

### 2. Clone LazyVim starter config

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 3. Add language extras to lazy.lua

Edit `~/.config/nvim/lua/config/lazy.lua` and add language extras **between** the LazyVim import and your plugins import (order matters):

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import language extras (must come before custom plugins)
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  -- ... rest of config
})
```

> **Note:** Language extras must be imported in `lazy.lua` between `lazyvim.plugins` and `plugins` — not in a separate file under `lua/plugins/`. LazyVim enforces this load order.

### 4. Set Dracula color theme

```bash
cat > ~/.config/nvim/lua/plugins/colorscheme.lua <<'EOF'
return {
  { "Mofiqul/dracula.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
EOF
```

### 5. Enable line wrap

```bash
cat > ~/.config/nvim/lua/config/options.lua <<'EOF'
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.wrap = true
EOF
```

### 6. First launch

```bash
nvim
```

On first launch, Lazy.nvim will install all plugins and Mason will auto-install language servers (pyright, rust-analyzer, clangd). This takes a minute.

## Config Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua        # Custom autocommands
│   │   ├── keymaps.lua         # Custom keybindings
│   │   ├── lazy.lua            # Lazy.nvim bootstrap + language extras
│   │   └── options.lua         # Vim options (line wrap, etc.)
│   └── plugins/
│       ├── colorscheme.lua     # Dracula theme
│       └── example.lua         # Example plugin spec (disabled)
```

Add new plugins by creating any `.lua` file in `~/.config/nvim/lua/plugins/`.

## Autocomplete

**Yes, LazyVim has full autocomplete out of the box** via [blink.cmp](https://github.com/Saghen/blink.cmp):

- Autocomplete popup appears automatically as you type
- Sources: LSP completions, snippets, buffer words, file paths
- `<Tab>` / `<S-Tab>` — cycle through suggestions
- `<CR>` (Enter) — accept the selected completion
- `<C-Space>` — manually trigger completion menu
- `<C-e>` — dismiss the completion menu
- `<C-b>` / `<C-f>` — scroll docs in the completion popup

LSP-powered completions include function signatures, type info, and auto-imports.

## Python Virtual Environment

Pyright won't find packages like `torch` or `transformers` unless it knows your venv. Two options:

**Option A: Activate before launching nvim**
```bash
source .venv/bin/activate
nvim .
```

**Option B: Add `pyrightconfig.json` to your project root**
```json
{
  "venvPath": ".",
  "venv": ".venv"
}
```

## Essential Keybindings

`<leader>` is `<Space>`. Press Space and wait to see a which-key popup showing all available commands.

### Navigation

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files (fuzzy) |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | File explorer (neo-tree) |
| `<leader>,` | Switch buffer |
| `s` | Flash jump (leap to any visible text) |
| `H` / `L` | Previous / next buffer |

### Code (LSP)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>cf` | Format file |

### Windows and Tabs

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>-` | Horizontal split |
| `<leader>\|` | Vertical split |
| `<leader><tab>n` | New tab |
| `<leader><tab>]` | Next tab |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gf` | Git file history |
| `]h` / `[h` | Next / previous hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |

### General

| Key | Action |
|-----|--------|
| `<leader>l` | Lazy plugin manager |
| `<leader>cm` | Mason (LSP/tool installer) |
| `<leader>qq` | Quit all |
| `<leader>fn` | New file |
| `<leader>ur` | Redraw / clear hlsearch |
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle word wrap |

## Adding More Languages

Add extras in `~/.config/nvim/lua/config/lazy.lua` (between the LazyVim import and plugins import):

```lua
{ import = "lazyvim.plugins.extras.lang.go" },         -- requires: brew install go
{ import = "lazyvim.plugins.extras.lang.typescript" },
{ import = "lazyvim.plugins.extras.lang.docker" },
{ import = "lazyvim.plugins.extras.lang.terraform" },
{ import = "lazyvim.plugins.extras.lang.markdown" },
```

Or browse available extras with `:LazyExtras` inside Neovim.

## Customization Examples

### Add custom options (`~/.config/nvim/lua/config/options.lua`)

```lua
vim.opt.relativenumber = true    -- Relative line numbers (on by default)
vim.opt.scrolloff = 8            -- Keep 8 lines visible above/below cursor
vim.opt.tabstop = 4              -- 4-space tabs
vim.opt.shiftwidth = 4
```

### Add custom keymaps (`~/.config/nvim/lua/config/keymaps.lua`)

```lua
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
```

### Add a plugin (`~/.config/nvim/lua/plugins/myplugin.lua`)

```lua
return {
  {
    "github-user/plugin-name",
    opts = {
      -- plugin config here
    },
  },
}
```

## Troubleshooting

- **Icons look broken**: Install a Nerd Font and set it in your terminal settings.
- **LSP not working**: Run `:Mason` to check if the server installed. Run `:LspInfo` to see active servers.
- **mason-lspconfig failed to install**: Usually means a language toolchain is missing (e.g., Go for gopls). Install the toolchain or remove the language extra.
- **Import order warning**: Language extras (`lazyvim.plugins.extras.*`) must be imported in `lazy.lua` between `lazyvim.plugins` and your `plugins` — not in a separate file under `lua/plugins/`.
- **Slow startup**: Run `:Lazy profile` to identify slow plugins.
- **Check health**: Run `:checkhealth` for a full diagnostics report.

## Uninstall

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```
