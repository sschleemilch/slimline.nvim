local M = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')

--- @param config table
--- @param sep {left: string, right: string}
--- @return string
function M.render(config, sep)
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
  content = string.format(' %s %s / %s ', config.icons.lines, content, total)
  return highlights.hl_content(content, highlights.get_mode_hl(utils.get_mode()), sep.left, sep.right)
end

return M
