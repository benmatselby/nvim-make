# Make plugin for neovim

This plugin aims to run Make targets from your project, if a Makefile is found.

```
┌────────────────────────────────────────────────────────────────────┐
│                                                                    │
│                                                                    │
│       ╭──────────────────── my-project ────────────────────╮       │
│       │ docker-build        Build the docker image         │       │
│       │ docker-push         Push the docker image          │       │
│       │ docker-run          Run the docker image           │       │
│       │ install-ci          Install the CI dependencies    │       │
│       │ install-dev         Install the dev dependencies   │       │
│       │ lint                Lint the code with Ruff        │       │
│       │ test                Run the tests                  │       │
│       │                                                    │       │
│       │ Finished command (exit code: 0)                    │       │
│       ╰────────────────────────────────────────────────────╯       │
│                                                                    │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

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
