vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd 'Neotree current'
  end,
})
