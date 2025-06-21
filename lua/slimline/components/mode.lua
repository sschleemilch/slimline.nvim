local slimline = require('slimline')
local initialized = false
local verbose = slimline.config.configs.mode.verbose

local C = {}

local function init()
  if initialized then
    return
  end
  vim.opt.showmode = false
  initialized = true
end

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  init()
  local mode = slimline.get_mode()
  if not verbose then
    mode = string.sub(mode, 1, 1)
  end
  return slimline.highlights.hl_component({ primary = mode }, hls, sep, direction, active)
end

return C
