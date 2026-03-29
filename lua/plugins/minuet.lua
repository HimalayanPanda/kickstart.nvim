-- AI inline suggestions via minuet-ai (routed through 9router)
return {
  'milanglacier/minuet-ai.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = 'InsertEnter',
  config = function()
    require('minuet').setup {
      provider = 'openai_compatible',
      provider_options = {
        openai_compatible = {
          model = 'cc/claude-haiku-4-5-20251001',
          end_point = 'http://localhost:20128/v1/chat/completions',
          api_key = function() return '9router' end,
          stream = true,
          optional = {
            max_tokens = 128,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
        keymap = {
          accept = '<A-a>',
          accept_line = '<A-A>',
          next = '<A-]>',
          prev = '<A-[>',
          dismiss = '<A-e>',
        },
      },
      throttle = 1000,
      debounce = 400,
      notify = 'verbose',
    }
  end,
}
