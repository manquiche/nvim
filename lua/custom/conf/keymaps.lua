vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true })
vim.keymap.set('n', '<leader>se', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>')
vim.keymap.set('n', '<C-s>', ':w<CR>')

-- vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Show signature help' })
vim.keymap.set('i', '<C-k>', function()
  require('lsp_signature').toggle_float_win()
end, { silent = true, noremap = true, desc = 'toggle signature help' })
