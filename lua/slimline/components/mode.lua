local slimline = require('slimline')
local initialized = false
local verbose = slimline.config.configs.mode.verbose

local C = {}

local function init()
  if initialized then return end
  vim.opt.showmode = false
  initialized = true
end

--- @param sep sep
--- @param direction component.direction
--- @param hls component.highlights
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  init()
  local mode = slimline.get_mode()
  local primary = mode.short
  if verbose then primary = mode.verbose end
  return slimline.highlights.hl_component({ primary = primary }, hls, sep, direction, active)
end

return C
