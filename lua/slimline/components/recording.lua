local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.recording

--- @param sep sep
--- @param direction component.direction
--- @param hls component.highlights
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  local recording = vim.fn.reg_recording()
  if recording == '' then return '' end
  local status = config.icon .. recording
  return slimline.highlights.hl_component({ primary = status }, hls, sep, direction, active)
end

return C
