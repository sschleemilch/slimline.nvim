local M = {}

--- Renders the statusline.
---@return string
function M.render()
  local config = vim.g.slimline_config
  local sep = config.component_spacing
  local components = require('slimline.components')
  local mode = components.get_mode()
  local stl = table.concat {
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
  }
  return stl
end

---@param opts table
function M.setup(opts)
  require('slimline.autocommands')
  vim.o.showmode = false
  vim.g.slimline_config = vim.tbl_deep_extend('force', require('slimline.default_config'), opts)
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
