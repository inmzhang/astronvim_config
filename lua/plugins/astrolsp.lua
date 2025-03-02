local util = require "vim.lsp.util"

-- Replace HTML symbols with their literal versions.
local function split_lines(value)
  value = string.gsub(value, "&nbsp;", " ")
  value = string.gsub(value, "&gt;", ">")
  value = string.gsub(value, "&lt;", "<")
  value = string.gsub(value, "\\", "")
  value = string.gsub(value, "```python", "")
  value = string.gsub(value, "```", "")
  return vim.split(value, "\n", { plain = true, trimempty = true })
end

-- Convert the LSP input to a table of strings.
local function convert_input_to_markdown_lines(input, contents)
  contents = contents or {}
  assert(type(input) == "table", "Expected a table for LSP input")
  if input.kind then
    local value = input.value or ""
    vim.list_extend(contents, split_lines(value))
  end
  if (contents[1] == "" or contents[1] == nil) and #contents == 1 then return {} end
  return contents
end

-- The overwritten hover function used by Pyright.
local function pyright_hover(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method

  if vim.api.nvim_get_current_buf() ~= ctx.bufnr then
    -- Ignore result since buffer changed (happens with slow LSP responses).
    return
  end

  if not (result and result.contents) then
    if config.silent ~= true then vim.notify "No information available" end
    return
  end

  local contents = convert_input_to_markdown_lines(result.contents)
  if vim.tbl_isempty(contents) then
    if config.silent ~= true then vim.notify "No information available" end
    return
  end

  -- Separate the function signature and the docstring.
  local signature = {}
  local docstring = {}
  local in_signature = true

  for _, line in ipairs(contents) do
    -- We assume the signature ends when a blank line is encountered.
    if in_signature then
      if line:match "^%s*$" then
        in_signature = false
      else
        table.insert(signature, line)
      end
    else
      table.insert(docstring, line)
    end
  end

  -- Build the final contents:
  -- Wrap the signature as a Python code block, and leave the docstring as markdown.
  local final_contents = {}

  if #signature > 0 then
    table.insert(final_contents, "```python")
    for _, line in ipairs(signature) do
      table.insert(final_contents, line)
    end
    table.insert(final_contents, "```")
  end

  if #docstring > 0 then
    -- Insert an empty line as separator if needed.
    if #signature > 0 then table.insert(final_contents, "") end
    for _, line in ipairs(docstring) do
      table.insert(final_contents, line)
    end
  end

  return util.open_floating_preview(final_contents, "markdown", config)
end

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          "lua",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      "basedpyright",
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      clangd = { capabilities = { offsetEncoding = "utf-8" } },
      rust_analyzer = {
        cargo = {
          buildScripts = {
            enable = true,
          },
          extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
          extraArgs = { "--profile", "rust-analyzer" },
        },
        procMacro = {
          enable = true,
        },
      },
      basedpyright = {
        handlers = {
          ["textDocument/hover"] = vim.lsp.with(pyright_hover, {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
            title = " |･ω･) ",
            max_width = 120,
            zindex = 500,
          }),
        },
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticSeverityOverrides = {
                reportUnusedImport = "information",
                reportUnusedFunction = "information",
                reportUnusedVariable = "information",
                reportGeneralTypeIssues = "none",
                reportOptionalMemberAccess = "none",
                reportOptionalSubscript = "none",
                reportPrivateImportUsage = "none",
              },
            },
          },
        },
      },
      -- tinymist = {
      --   offset_encoding = "utf-8",
      -- },
      tailwindcss = {
        filetypes = {
          "html",
          "markdown",
          "css",
          "sass",
          "scss",
          "stylus",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "rust",
        },
        settings = {
          tailwindCSS = {
            includeLanguages = {
              rust = "html",
            },
            experimental = {
              classRegex = {
                'class: "(.*)"',
              },
            },
          },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_document_highlight = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/documentHighlight",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "CursorHold", "CursorHoldI" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Document Highlighting",
          callback = function() vim.lsp.buf.document_highlight() end,
        },
        {
          event = { "CursorMoved", "CursorMovedI", "BufLeave" },
          desc = "Document Highlighting Clear",
          callback = function() vim.lsp.buf.clear_references() end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gl = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        -- gD = {
        --   function() vim.lsp.buf.declaration() end,
        --   desc = "Declaration of current symbol",
        --   cond = "textDocument/declaration",
        -- },
        -- ["<Leader>uY"] = {
        --   function() require("astrolsp.toggles").buffer_semantic_tokens() end,
        --   desc = "Toggle LSP semantic highlight (buffer)",
        --   cond = function(client) return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens end,
        -- },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
