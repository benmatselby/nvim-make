# Make plugin for neovim

This plugin aims to run Make targets from your project, if a Makefile is found.

```text
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

Press `<CR>` to run the target under the cursor, or use `<Tab>` to select
multiple targets and then `<CR>` to run them in the order selected.

## Prerequisites

- Neovim >= 0.10
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Required for async job execution
- [snacks.nvim](https://github.com/folke/snacks.nvim) - Required for the picker

## Configuration

### Lazy.nvim

```lua
return {
  "benmatselby/nvim-make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  cmd = "NvimMake",
  opts = {},
  keys = {
    {
      "<leader>xm",
      function()
        require("nvim_make").pick_make_target()
      end,
      desc = "Run make target(s)",
    },
  },
}
```

You can also provide a specific project path to target a Makefile in a different directory, bypassing the automatic discovery:

```lua
keys = {
  {
    "<leader>xp",
    function()
      require("nvim_make").pick_make_target("/path/to/project")
    end,
    desc = "Run make target for specific project",
  },
}
```

Or via the command:

```text
:NvimMake /path/to/project
```
