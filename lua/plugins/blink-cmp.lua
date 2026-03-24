-- Autocompletion
return {
  'Saghen/blink.cmp',
  version = '*',
  dependencies = {
    'rafamadriz/friendly-snippets',
  },
  opts = {
    keymap = {
      preset = 'default',
      -- Accept suggestion with C-y (mirrors old nvim-cmp binding)
      ['<C-y>'] = { 'accept', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-Space>'] = { 'show', 'fallback' },
      -- Accept with S-Tab; Tab left free for minuet virtual text
      ['<S-Tab>'] = { 'accept', 'fallback' },
      ['<Tab>'] = {},
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },
    completion = {
      trigger = { prefetch_on_insert = false },
    },
  },
}
