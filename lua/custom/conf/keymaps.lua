vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true })
vim.keymap.set('n', '<leader>se', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>')
vim.keymap.set('n', '<C-s>', ':w<CR>')
