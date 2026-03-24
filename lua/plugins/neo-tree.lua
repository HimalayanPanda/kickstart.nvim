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
    vim.api.nvim_create_autocmd('BufAdd', {
      callback = function()
        vim.schedule(function()
          vim.cmd 'Neotree show reveal'
        end)
      end,
    })

    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        vim.api.nvim_create_autocmd('BufEnter', {
          callback = function(ev)
            local ft = vim.bo[ev.buf].filetype
            local buftype = vim.bo[ev.buf].buftype
            if ft == 'neo-tree' or buftype ~= '' then
              return
            end
            vim.schedule(function()
              vim.cmd 'Neotree show reveal'
            end)
          end,
        })
      end,
    })

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
        if real_wins == 1 then
          vim.cmd 'Neotree close'
        end
      end,
    })
  end,
}
