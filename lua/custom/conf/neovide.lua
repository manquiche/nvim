local map = vim.keymap.set

if vim.g.neovide then
  -- Disable animation
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_length = 0
  vim.g.neovide_cursor_antialiasing = false
  vim.g.neovide_cursor_vfx_mode = ''

  -- Disable transparency
  vim.g.neovide_transparency = 1.0

  -- Disable floating shadows
  vim.g.neovide_floating_shadow = false

  -- Disable blur
  vim.g.neovide_window_blurred = false

  -- Performance settings
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_no_idle = false

  -- Font settings
  vim.g.neovide_scale_factor = 1.0
  vim.o.guifont = '0xProto:h13'

  -- Hardware acceleration
  vim.g.neovide_prefer_global_shader = true

  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  -- vim.g.neovide_no_idle = true
  -- vim.g.neovide_refresh_rate = 75

  -- vim.g.neovide_cursor_animation_length = 0.05 -- Very short animation
  -- vim.g.neovide_cursor_trail_length = 0.1 -- Minimal trail
  -- vim.g.neovide_cursor_vfx_mode = "railgun" -- Simple effect

  map({ 'n', 'v' }, '<C-+>', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>')
  map({ 'n', 'v' }, '<C-->', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>')
  map({ 'n', 'v' }, '<C-0>', ':lua vim.g.neovide_scale_factor = 1<CR>')
end
