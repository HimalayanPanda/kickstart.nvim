-- Neo-tree file explorer
return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  keys = {
    { '\\', '<cmd>Neotree reveal toggle<cr>', desc = 'Toggle file tree', mode = 'n' },
    {
      '|',
      function()
        vim.g.neotree_source = vim.g.neotree_source == 'git_status' and 'filesystem' or 'git_status'
        vim.cmd('Neotree action=focus source=' .. vim.g.neotree_source)
      end,
      desc = 'Toggle filesystem/git_status source',
      mode = 'n',
    },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('QuitPre', {
      callback = function()
        local wins = vim.api.nvim_list_wins()
        local real_wins = 0
        for _, w in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(w)
          local ft = vim.bo[buf].filetype
          local is_floating = vim.api.nvim_win_get_config(w).relative ~= ''
          if ft ~= 'neo-tree' and not is_floating then
            real_wins = real_wins + 1
          end
        end
        if real_wins == 1 and package.loaded['neo-tree'] then
          vim.cmd 'Neotree close'
        end
      end,
    })
  end,
}
