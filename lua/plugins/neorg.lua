return {
  "nvim-neorg/neorg",
  dependencies = { "luarocks.nvim", "benlubas/neorg-interim-ls" },
  lazy = false,
  version = "*",
  config = function()
    require("neorg").setup {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.summary"] = {},
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",
          },
        }, -- Adds pretty icons to your documents
        ["core.export"] = {},
        ["core.itero"] = {},
        ["core.keybinds"] = {
          config = {
            hook = function(keybinds) keybinds.remap_key("norg", "i", "<M-CR>", "<C-n>") end,
          },
        },
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              main = "~/neorg/main",
              root = "~/neorg",
            },
            default_workspace = "main",
          },
        },
        ["core.journal"] = {
          config = {
            workspace = "root",
          },
        },
        ["core.completion"] = {
          config = { engine = { module_name = "external.lsp-completion" } },
        },
        ["external.interim-ls"] = {
          config = {
            -- default config shown
            completion_provider = {
              -- Enable or disable the completion provider
              enable = true,

              -- Show file contents as documentation when you complete a file name
              documentation = true,

              -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
              categories = false,

              -- suggest heading completions from the given file for `{@x|}` where `|` is your cursor
              -- and `x` is an alphanumeric character. `{@name}` expands to `[name]{:$/people:# name}`
              people = {
                enable = false,

                -- path to the file you're like to use with the `{@x` syntax, relative to the
                -- workspace root, without the `.norg` at the end.
                -- ie. `folder/people` results in searching `$/folder/people.norg` for headings.
                -- Note that this will change with your workspace, so it fails silently if the file
                -- doesn't exist
                path = "people",
              },
            },
          },
        },
      },
    }
  end,
}
