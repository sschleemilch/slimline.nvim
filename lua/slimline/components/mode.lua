local M = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @return string
function M.render(sep)
  local mode = utils.get_mode()
  local render = mode
  if config.verbose_mode == false then
    render = string.sub(mode, 1, 1)
  end
  local hl = highlights.get_mode_hl(mode)
  return highlights.hl_component({ primary = render }, hl, sep, 'right')
end

return M
