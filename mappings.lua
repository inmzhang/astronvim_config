-- Mapping data with "desc" stored directly by vim.keymap.set().
vim.g.magma_image_provider = "ueberzug"
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr)
          require("astronvim.utils.buffer").close(
            bufnr)
        end)
      end,
      desc = "Pick to close",
    },
    -- ["<leader>r"] = { "<cmd>lua vim.api.nvim_exec('MagmaEvaluateOperator', true)<CR>", desc =
    -- "Magma Evaluate Operator" },
    ["<leader>ri"] = { ":MagmaInit<CR>", desc = "Magma Init kernel" },
    ["<leader>re"] = { ":MagmaRestart!<CR>", desc = "Magma Init kernel and delete all the outputs" },
    ["<leader>rr"] = { ":MagmaEvaluateLine<CR>", desc = "Magma Evaluate Line" },
    ["<leader>rc"] = { ":MagmaReevaluateCell<CR>", desc = "Magma Reevaluate Cell" },
    ["<leader>ro"] = { ":MagmaShowOutput<CR>", desc = "Magma show output" },
    ["<leader>rq"] = { ":noautocmd MagmaEnterOutput<CR>", desc = "Magma enter the output" },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  x = {
    ["<leader>r"] = { ":<C-u>MagmaEvaluateVisual<CR>", desc = "Magma Evaluate Visual" },
  },
}
