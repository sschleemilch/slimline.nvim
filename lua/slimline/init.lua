local M = {}

--- Renders the statusline.
---@return string
function M.render()
  local config = vim.g.slimline_config
  local hl = require("slimline.highlights")
  hl.create()
  local sep = " "
  if config.sep.left == nil and config.sep.right == nil then
    sep = ""
  end
  local components = require("slimline.components")
  local mode = components.get_mode()
  local stl = table.concat {
    hl.highlight_content(sep, hl.hls.base),
    components.mode(mode),
    sep,
    components.path(),
    sep,
    components.git(),
    "%=",
    components.diagnostics(),
    sep,
    components.filetype_lsp(),
    sep,
    components.progress(mode),
    sep
  }
  return stl
end

---@param opts table
function M.setup(opts)
  require("slimline.autocommands")
  vim.g.qf_disable_statusline = 1
  vim.o.showmode = false
  vim.g.slimline_config = vim.tbl_deep_extend("force", require("slimline.default_config"), opts)
  vim.o.statusline = "%!v:lua.require'slimline'.render()"
end

--- Refreshes the line
--- To be called e.g. from autocommands
function M.refresh()
  vim.cmd.redrawstatus()
end

return M
