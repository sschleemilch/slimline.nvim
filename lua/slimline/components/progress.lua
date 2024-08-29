local M = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @return string
function M.render(sep)
  local cur = vim.fn.line('.')
  local total = vim.fn.line('$')
  local content
  if cur == 1 then
    content = 'Top'
  elseif cur == total then
    content = 'Bot'
  else
    content = string.format('%2d%%%%', math.floor(cur / total * 100))
  end
  content = string.format('%s %s / %s', config.icons.lines, content, total)
  return highlights.hl_component({primary = content}, highlights.get_mode_hl(utils.get_mode()), sep, 'left')
end

return M
