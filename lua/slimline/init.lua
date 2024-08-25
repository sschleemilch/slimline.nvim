local M = {}

--- Renders the statusline.
---@return string
function M.render()
  local config = vim.g.slimline_config
  local sep = config.spaces.components
  local components = require('slimline.components')
  local mode = components.get_mode()
  local stl = table.concat {
    '%#Slimline#' .. config.spaces.left,
    components.mode(mode),
    sep,
    components.path(),
    sep,
    components.git(),
    '%=',
    components.diagnostics(),
    sep,
    components.filetype_lsp(),
    sep,
    components.progress(mode),
    config.spaces.right,
  }
  return stl
end

---@param opts table
function M.setup(opts)
  if opts == nil then
    opts = {}
  end
  require('slimline.autocommands')
  vim.o.showmode = false
  opts = vim.tbl_deep_extend('force', require('slimline.default_config'), opts)
  if opts.style == 'fg' then
    opts.sep.left = ''
    opts.sep.right = ''
  end
  vim.g.slimline_config = opts
  local hl = require('slimline.highlights')
  hl.create()
  vim.o.statusline = "%!v:lua.require'slimline'.render()"
end

--- Refreshes the line
--- To be called e.g. from autocommands
function M.refresh()
  vim.cmd.redrawstatus()
end

return M
