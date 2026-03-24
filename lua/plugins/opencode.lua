return {
  'nickjvandyke/opencode.nvim',
  version = '*', -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      'folke/snacks.nvim',
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...) return require('opencode').snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ['<CR>'] = { 'opencode_send', mode = { 'n', 'i' } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any; goto definition on the type or field for details
    }

    vim.o.autoread = true -- Required for `opts.events.reload`

    local opencode_fs = { active = false }

    -- Recommended/example keymaps
    vim.keymap.set({ 'n', 'x' }, '<C-CR>', function() require('opencode').ask('@this: ', { submit = true }) end, { desc = 'Ask opencode…' })
    vim.keymap.set({ 'n', 'x' }, "<C-'>", function() require('opencode').select() end, { desc = 'Execute opencode action…' })
    vim.keymap.set({ 'n', 't' }, "<C-'>", function()
      require('opencode').toggle()
      opencode_fs.active = false
    end, { desc = 'Toggle opencode' })

    vim.keymap.set({ 'n', 'x' }, 'go', function() return require('opencode').operator('@this ') end, { desc = 'Add range to opencode', expr = true })
    vim.keymap.set('n', 'goo', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Add line to opencode', expr = true })

    vim.keymap.set('n', '<C-u>', function() require('opencode').command('session.half.page.up') end, { desc = 'Scroll opencode up' })
    vim.keymap.set('n', '<C-d>', function() require('opencode').command('session.half.page.down') end, { desc = 'Scroll opencode down' })
    vim.keymap.set('n', '<leader>oc', function() require('opencode').command('prompt.clear') end, { desc = 'Clear opencode input' })
    vim.keymap.set('n', '<leader>os', function() require('opencode').command('prompt.submit') end, { desc = 'Submit opencode input' })
    vim.keymap.set('n', '<leader>ot', function() require('opencode').command('agent.cycle') end, { desc = 'Toggle Build/Plan' })
    vim.keymap.set('n', '<leader>om', function()
      require('opencode').prompt('/models')
      vim.defer_fn(function()
        -- Find and focus the opencode terminal window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == 'terminal' then
            vim.api.nvim_set_current_win(win)
            vim.cmd 'startinsert'
            return
          end
        end
      end, 100)
    end, { desc = 'Change opencode model' })

    vim.keymap.set('n', '<leader>of', function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype == 'terminal' then
          if not opencode_fs.active then
            vim.api.nvim_win_set_width(win, vim.o.columns)
            opencode_fs.active = true
          else
            vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.35))
            opencode_fs.active = false
          end
          vim.api.nvim_set_current_win(win)
          vim.cmd 'startinsert'
          return
        end
      end
    end, { desc = 'Fullscreen opencode panel' })

    -- You may want these if you use the opinionated `<C-u>` and `<C-d>` keymaps above
    vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment under cursor', noremap = true })
    vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement under cursor', noremap = true })
  end,
}
