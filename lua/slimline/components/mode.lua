local verbose = Slimline.config.configs.mode.verbose
local initialized = false

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
  local mode = Slimline.get_mode()
  if not verbose then
    mode = string.sub(mode, 1, 1)
  end
  return Slimline.highlights.hl_component({ primary = mode }, hls, sep, direction, active)
end

return C
