-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  event = 'VimEnter',
  cmd = 'Neotree',
  init = function()
    -- If a buffer is already open in another window, switch to it instead of creating a new buffer
    vim.g.neo_tree_remove_legacy_commands = true

    -- Prevent buffer reuse issues
    if vim.fn.argc() == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == 'directory' then
        require 'neo-tree'
      end
    end
  end,
  keys = {
    { '<leader>e', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
    { '<leader>o', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
    close_if_last_window = false, -- Prevent Neovim from closing when Neo-tree is the last window
    popup_border_style = 'rounded',
    enable_git_status = true,
    enable_diagnostics = true,
    source_selector = {
      winbar = true,
      content_layout = 'center',
      sources = {
        { source = 'filesystem', display_name = ' File' },
        { source = 'buffers', display_name = '󰈙 Bufs' },
        { source = 'git_status', display_name = '󰊢 Git' },
        { source = 'document_symbols', display_name = ' Syms' },
      },
    },
    open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' }, -- prevent files from replacing these windows
    retain_hidden_root_indent = true, -- Prevent issues with buffer handling
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
        position = 'left',
        width = 30,
      },
      follow_current_file = {
        enabled = true, -- Focus the current file in Neo-tree
        leave_dirs_open = true, -- Keep parent directories open when following
      },
      filtered_items = {
        hide_dotfiles = true,
        hide_gitignored = true,
      },
      bind_to_cwd = false, -- Prevent Neo-tree from changing directory
      use_libuv_file_watcher = true, -- Better file watching
    },
    buffers = {
      follow_current_file = {
        enabled = true, -- Focus the current buffer in Neo-tree
        leave_dirs_open = true, -- Keep parent directories open when following
      },
      window = {
        position = 'left',
        mappings = {
          ['\\'] = 'close_window',
        },
      },
      group_empty_dirs = true, -- Compact empty directories
      show_unloaded = true,
    },
    window = {
      position = 'left',
      width = 30,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      auto_expand_width = false, -- Do not expand window width when long file names
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- Use expanders like VS Code
        expander_collapsed = '',
        expander_expanded = '',
        expander_highlight = 'NeoTreeExpander',
      },
    },
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.opt_local.signcolumn = 'auto'
        end,
      },
      {
        event = 'file_opened',
        handler = function(file_path)
          -- Auto close neo-tree after opening a file
          require('neo-tree.command').execute { action = 'close' }
        end,
      },
      {
        event = 'neo_tree_window_before_close',
        handler = function()
          -- Prevent accidental Neovim shutdown when closing Neo-tree
          if #vim.api.nvim_list_wins() == 1 then
            return false
          end
        end,
      },
    },
  },
}
