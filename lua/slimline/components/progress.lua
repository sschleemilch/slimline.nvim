local M = {}
local highlights = require('slimline.highlights')
local config = require('slimline').config
local name = 'progress'

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls table
--- @return string
function M.render(sep, direction, hls)
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
  content = string.format('%s %s / %s', config.configs[name].icon, content, total)

  return highlights.hl_component({ primary = content }, hls, sep, direction)
end

return M
