vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd 'Neotree position=current'
  end,
})
