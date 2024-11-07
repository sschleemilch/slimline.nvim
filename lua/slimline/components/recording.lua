local M = {}
local highlights = require('slimline.highlights')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @return string
function M.render(sep, direction)
  local recording = vim.fn.reg_recording()
  if recording == '' then
    return ''
  end
  local status = config.icons.recording .. recording
  return highlights.hl_component({ primary = status }, highlights.hls.component, sep, direction)
end

return M
