local function dump(o)
  if type(o) == "table" then
    local s = ""
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      --s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
      s = s .. dump(v) .. ","
    end
    return s
  else
    return tostring(o)
  end
end

local function lsp_clients()
  local clients = vim.lsp.get_active_clients()
  local clients_list = {}
  for _, client in pairs(clients) do
    table.insert(clients_list, client.name)
  end
  return dump(clients_list)
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("lualine").setup {
      options = {
        theme = "gruvbox",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename", lsp_clients, "diagnostics" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}
