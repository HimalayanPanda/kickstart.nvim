-- Null-ls configuration for formatting and linting
return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
  },
  opts = {},
  config = function()
    local null_ls = require 'null-ls'

    vim.diagnostic.config {
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = true,
      severity_sort = true,
    }

    null_ls.setup {
      debug = false,
      sources = {},

      default_timeout = 5000,
      diagnostics_format = '[#{c}] #{m} (#{s})',
      notify_format = '[null-ls] %s',
    }
  end,
}
