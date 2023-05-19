return {

  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    init = function()
      vim.o.background = "dark"
    end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    lazy = false,
    opts = {
      auto_trigger = true,
      suggestion = { enabled = true
      },
      panel = { enabled = true },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    "chikko80/error-lens.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-telescope/telescope.nvim"
    },
  },
  {
    "ggandor/leap.nvim",
    event = 'BufRead',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      require('leap').add_default_mappings()
    end,
  },
}
