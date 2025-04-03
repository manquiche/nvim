local function getTheme()
  local light_theme = 'dayfox'
  local dark_theme = 'obscure'

  local home = os.getenv 'HOME'
  local desktop_theme_file = io.open(home .. '/.desktop_theme', 'rb')

  if not desktop_theme_file then
    vim.notify('cannot find ~/.desktop_theme file, using dark theme', vim.log.levels.INFO, {
      title = 'UI',
    })
    return dark_theme
  end

  local desktop_theme = desktop_theme_file:read '*l'
  desktop_theme_file:close()

  if desktop_theme == nil or desktop_theme == '' then
    return dark_theme
  end

  return (desktop_theme == 'light') and light_theme or dark_theme
end

vim.cmd.colorscheme(getTheme())
vim.cmd.hi 'Comment gui=none'
