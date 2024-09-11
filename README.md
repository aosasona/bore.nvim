# bore.nvim

> [!WARNING]
> Use this at your own risk, it is a work in progress.

This plugin provides direct integration with [`bore`](https://github.com/aosasona/bore) in Neovim, you can use this as a clipboard provider if you are in an environment without one (or just want to use bore for other reasons). See the bore repository for configuration options available in bore's config file itself.

# Requirements

- Neovim (at least 0.9; I haven't tested on less but it should be fine)
- [`bore`](https://github.com/aosasona/bore) (should be in your `PATH` variable)

# Installation

Install this plugin with your preferred package manager (as long as it can install directly from GitHub repositories; which I suppose they all can anyway)

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "aosasona/bore.nvim",
  config = function()
	  require("bore").setup {}
  end,
},
```

This will provide the `BoreCopy` and `BorePaste` command with default bindings to `<leader>y`, `<leader>yy` (in normal mode) and `<leader>p` for copying and pasting directly from the `bore` clipboard.

# Configuration

These are the available options:

```lua
{
  use_as_provider = false, -- automatically override `vim.g.clipboard`
}
```

# Default Keybindings

- `<leader>y` - copy select lines (in visual mode)
- `<leader>yy` - copy current line (in normal mode)
- `<leader>p` - paste the last copied text

# Contributions

I work on this when I can and as I need it personally, I cannot promise to review/merge PRs or respond to issues in the most timely manner, but contributions are appreciated nonetheless.
