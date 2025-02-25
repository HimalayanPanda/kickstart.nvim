return {
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
    },
    opts = {},
    config = function()
      local null_ls = require 'null-ls'

      null_ls.setup {
        debug = true,
        sources = {
          null_ls.builtins.formatting.prettierd,
          require 'none-ls.diagnostics.eslint_d',
          require 'none-ls.code_actions.eslint_d',
        },

        default_timeout = 60000,
        diagnostics_format = '[#{c}] #{m} (#{s})',
        notify_format = '[null-ls] %s',

        -- This formats the buffers on save
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { bufnr = bufnr, async = false, timeout_ms = 50000 }
              end,
            })
          end
        end,
      }
    end,
  },
}
