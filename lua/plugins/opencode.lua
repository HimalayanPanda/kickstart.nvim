-- Sends context and questions to an opencode instance running in a tmux pane.
-- No plugin needed — uses tmux send-keys to talk to the existing pane.
return {
  dir = vim.fn.stdpath 'config',
  name = 'opencode-tmux',
  lazy = false,
  config = function()
    vim.o.autoread = true -- reload buffers when opencode edits files on disk

    -- Find the pane currently running opencode (searches all panes in all sessions)
    local function find_pane()
      local out = vim.fn.system "tmux list-panes -a -F '#{pane_id} #{pane_current_command}' 2>/dev/null"
      for line in out:gmatch '[^\n]+' do
        local id, cmd = line:match '^(%S+)%s+(.+)$'
        if cmd and cmd:match 'opencode' then
          return id
        end
      end
      return nil
    end

    -- Switch tmux focus to the opencode pane
    local function focus(pane_id)
      -- Use jobstart (non-blocking) so nvim doesn't recapture focus
      vim.fn.jobstart({ 'tmux', 'select-pane', '-t', pane_id })
    end

    -- Type text into the opencode pane (optionally press Enter to submit)
    local function send(text, submit)
      local pane = find_pane()
      if not pane then
        vim.notify('opencode: no tmux pane found — start opencode in a tmux pane first', vim.log.levels.WARN)
        return
      end
      -- set-buffer runs synchronously so the buffer is ready before paste-buffer fires.
      -- paste-buffer -p uses bracketed-paste escape sequences, delivering the whole string
      -- atomically and bypassing TUI key-binding interception (e.g. opencode's @-mention UI).
      vim.fn.system({ 'tmux', 'set-buffer', '--', text })
      vim.fn.jobstart({ 'tmux', 'paste-buffer', '-p', '-t', pane }, { detach = true })
      if submit then
        vim.defer_fn(function()
          vim.fn.jobstart({ 'tmux', 'send-keys', '-t', pane, 'Enter' }, { detach = true })
          vim.defer_fn(function() focus(pane) end, 50)
        end, 100)
      else
        vim.defer_fn(function() focus(pane) end, 50)
      end
    end

    -- <leader>aa (normal): ask opencode about the current file
    vim.keymap.set('n', '<leader>aa', function()
      local file = vim.api.nvim_buf_get_name(0)
      if file == '' then
        vim.notify('opencode: buffer has no file path', vim.log.levels.WARN)
        return
      end
      vim.ui.input({ prompt = 'Ask opencode (@' .. vim.fn.fnamemodify(file, ':t') .. '): ' }, function(q)
        if q and q ~= '' then
          vim.schedule(function()
            send('@' .. file .. ' ' .. q, true)
          end)
        end
      end)
    end, { desc = '[A]I [A]sk about current file' })

    -- <leader>aa (visual): ask opencode, scoping context to the selected line range
    vim.keymap.set('x', '<leader>aa', function()
      local file = vim.api.nvim_buf_get_name(0)
      if file == '' then
        vim.notify('opencode: buffer has no file path', vim.log.levels.WARN)
        return
      end
      -- '< and '> are only written on visual-mode exit; read the live selection instead.
      local s = math.min(vim.fn.line '.', vim.fn.line 'v')
      local e = math.max(vim.fn.line '.', vim.fn.line 'v')
      vim.ui.input({ prompt = 'Ask opencode (lines ' .. s .. '-' .. e .. '): ' }, function(q)
        if q and q ~= '' then
          vim.schedule(function()
            send('@' .. file .. ':' .. s .. '-' .. e .. ' ' .. q, true)
          end)
        end
      end)
    end, { desc = '[A]I [A]sk about selection' })

    -- <leader>ao: drop current file reference into opencode input (no submit)
    vim.keymap.set('n', '<leader>ao', function()
      local file = vim.api.nvim_buf_get_name(0)
      if file ~= '' then
        send('@' .. file .. ' ', false)
      end
    end, { desc = '[A]I send file to [O]pencode context' })

    -- <C-.>: switch tmux focus to the opencode pane
    vim.keymap.set({ 'n', 't' }, '<C-.>', function()
      local pane = find_pane()
      if pane then
        focus(pane)
      else
        vim.notify('opencode: no tmux pane found', vim.log.levels.WARN)
      end
    end, { desc = 'Focus opencode tmux pane' })
  end,
}
