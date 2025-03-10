return {
  "kylechui/nvim-surround",
  opts = {
    keymaps = {
      insert = "<C-g>s",
      insert_line = "<C-g>S",
      normal = "ys",
      normal_cur = "yss",
      normal_line = "yS",
      normal_cur_line = "ySS",
      visual = "<M-s>",
      visual_line = "<M-S>",
      delete = "ds",
      change = "cs",
    },
  },
}
