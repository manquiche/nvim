return {
  'cenk1cenk2/schema-companion.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
  },
  config = function()
    local schema_companion = require 'schema-companion'
    schema_companion.setup {
      -- if you have telescope you can register the extension
      enable_telescope = true,
      matchers = {
        -- add your matchers
        require('schema-companion.matchers.kubernetes').setup { version = 'master' },
      },
      schemas = {
        {
          name = 'Flux CD',
          uri = 'https://raw.githubusercontent.com/fluxcd-community/flux2-schemas/main/all.json',
        },
        {
          name = 'Kustomize',
          uri = 'http://json.schemastore.org/kustomization',
        },
      },
    }
    require('lspconfig').yamlls.setup(schema_companion.setup_client {})
  end,
}
