local M = {}
local highlights = require('slimline.highlights')
local config = require('slimline').config
local name = 'recording'

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function M.render(sep, direction, hls)
  local recording = vim.fn.reg_recording()
  if recording == '' then
    return ''
  end
  local status = config.configs[name].icon .. recording
  return highlights.hl_component({ primary = status }, hls, sep, direction)
end

return M
