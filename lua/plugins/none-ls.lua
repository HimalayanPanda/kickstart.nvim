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

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    null_ls.setup {
      debug = false,
      sources = {},

      default_timeout = 60000,
      diagnostics_format = '[#{c}] #{m} (#{s})',
      notify_format = '[null-ls] %s',

      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format {
                bufnr = bufnr,
                group = augroup,
                async = false,
                timeout_ms = 10000,
                filter = function(c)
                  return c.name == 'null-ls'
                end,
              }
            end,
          })
        end
      end,
    }
  end,
}
