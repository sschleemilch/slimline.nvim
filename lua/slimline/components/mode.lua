local slimline = require('slimline')
local initialized = false
local verbose = slimline.config.configs.mode.verbose

local C = {}

local function init()
  if initialized then return end
  vim.opt.showmode = false
  initialized = true
end

---@param opts render.options
---@return string
function C.render(opts)
  init()
  local mode = slimline.get_mode()
  local primary = mode.short
  if verbose then primary = mode.verbose end
  return slimline.highlights.hl_component({ primary = primary }, opts.hls, opts.sep, opts.direction, opts.active, opts.style)
end

return C
