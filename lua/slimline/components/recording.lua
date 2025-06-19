local C = {}
local config = Slimline.config.configs.recording

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  local recording = vim.fn.reg_recording()
  if recording == '' then
    return ''
  end
  local status = config.icon .. recording
  return Slimline.highlights.hl_component({ primary = status }, hls, sep, direction, active)
end

return C
