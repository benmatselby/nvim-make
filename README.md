# Make plugin for neovim

This plugin aims to run Make targets from your project, if a Makefile is found.

## Prerequisites

- Neovim >0.40
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Required for async job execution

## Configuration

### Lazy.nvim

```lua
return {
  "benmatselby/nvim-make",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = "NvimMake",
  opts = {},
  keys = {
    {
      "<leader>xm",
      function()
        require("nvim_make").pick_make_target()
      end,
      desc = "Run make target",
    },
  },
}
```
