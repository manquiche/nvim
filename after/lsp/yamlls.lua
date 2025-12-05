local schema_companion = require 'schema-companion'

return schema_companion.setup_client(
  schema_companion.adapters.yamlls.setup {
    sources = {
      -- your sources for the language server
      require('schema-companion').sources.matchers.kubernetes.setup { version = 'master' },
      require('schema-companion').sources.lsp.setup(),
      require('schema-companion').sources.schemas.setup {
        {
          name = 'Kubernetes master',
          uri = 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master-standalone-strict/all.json',
        },
      },
    },
  },
  {
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = '',
        },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  }
)
