return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>gg', '<cmd>LazyGit<CR>', desc = '[G]it TUI' },
    { '<leader>gf', '<cmd>LazyGitCurrentFile<CR>', desc = '[G]it current [F]ile' },
    { '<leader>gl', '<cmd>LazyGitFilter<CR>', desc = '[G]it [L]og' },
    { '<leader>gc', '<cmd>LazyGitFilterCurrentFile<CR>', desc = '[G]it [C]ommits (buffer)' },
    { '<leader>g,', '<cmd>LazyGitConfig<CR>', desc = '[G]it config' },
  },
}
