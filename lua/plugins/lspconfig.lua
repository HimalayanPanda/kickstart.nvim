-- Main LSP Configuration
return {
  'neovim/nvim-lspconfig',
  init = function()
    -- Override the upstream biome lsp config which crashes on nvim 0.12.0-dev
    -- due to vim.fs.root receiving a nested table it doesn't support.
    vim.lsp.config('biome', {
      root_dir = function(bufnr, on_dir)
        local root_markers = {
          'package-lock.json',
          'yarn.lock',
          'pnpm-lock.yaml',
          'bun.lockb',
          'bun.lock',
          'deno.lock',
          '.git',
        }
        local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

        local filename = vim.api.nvim_buf_get_name(bufnr)
        local biome_config_files = { 'biome.json', 'biome.jsonc' }
        local is_buffer_using_biome = vim.fs.find(biome_config_files, {
          path = filename,
          type = 'file',
          limit = 1,
          upward = true,
          stop = vim.fs.dirname(project_root),
        })[1]
        if not is_buffer_using_biome then
          return
        end

        on_dir(project_root)
      end,
    })
  end,
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    { 'williamboman/mason.nvim', opts = {} },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    -- Allows extra capabilities provided by blink.cmp
    { 'Saghen/blink.cmp', version = '*' },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gE', function()
          vim.cmd 'tab split'
          require('telescope.builtin').lsp_definitions()
        end, '[G]oto [D]efinition in new tab')

        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end

        -- Enable format on save for Prisma files
        if client.name == 'prismals' and client.supports_method(vim.lsp.protocol.Methods.textDocument_formatting) then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = event.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = event.buf })
            end,
          })
        end
      end,
    })

    -- Change diagnostic symbols in the sign column (gutter)
    if vim.g.have_nerd_font then
      local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      local diagnostic_signs = {}
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
      vim.diagnostic.config { signs = { text = diagnostic_signs } }
    end

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      prismals = {
        filetypes = { 'prisma' },
        settings = {
          prisma = {
            prismaFmt = {
              binaryPath = '',
            },
          },
        },
      },
      biome = {
        -- Disable formatting so conform handles it (via biome CLI)
        capabilities = {
          documentFormattingProvider = false,
          documentRangeFormattingProvider = false,
        },
        root_dir = function(filename)
          local lsputil = require 'lspconfig.util'
          local root_markers = {
            'package-lock.json',
            'yarn.lock',
            'pnpm-lock.yaml',
            'bun.lockb',
            'bun.lock',
            'deno.lock',
            '.git',
          }
          local project_root = lsputil.root_pattern(unpack(root_markers))(filename)
            or vim.fn.getcwd()

          local biome_config = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
            path = filename,
            type = 'file',
            limit = 1,
            upward = true,
            stop = vim.fs.dirname(project_root),
          })[1]
          if not biome_config then
            return nil
          end

          return project_root
        end,
      },
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
