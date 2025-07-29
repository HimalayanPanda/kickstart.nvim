return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "Gmove", "Gdelete", "Gbrowse" },
    keys = {
      { "<leader>gs", ":Git<CR>", desc = "Git Status" },
      { "<leader>gc", ":Git commit<CR>", desc = "Git Commit" },
      { "<leader>gp", ":Git push<CR>", desc = "Git Push" },
      { "<leader>gl", ":Git pull<CR>", desc = "Git Pull" },
      { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git Diff" },
      { "<leader>gb", ":Git blame<CR>", desc = "Git Blame" },
    },
  },
}
