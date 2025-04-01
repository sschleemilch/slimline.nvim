local M = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function M.render(sep, direction, hls)
  local mode = utils.get_mode()
  local render = mode
  if config.configs.mode.verbose == false then
    render = string.sub(mode, 1, 1)
  end
  return highlights.hl_component({ primary = render }, hls, sep, direction)
end

return M
