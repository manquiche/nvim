return {
  'cenk1cenk2/schema-companion.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'b0o/schemastore.nvim' },
  },
  config = function()
    -- require('telescope').load_extension 'yaml_schema'
    local schema_companion = require 'schema-companion'
    schema_companion.setup {
      -- if you have telescope you can register the extension
      enable_telescope = true,
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
  end,
}
