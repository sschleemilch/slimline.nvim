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
  local primary
  if cur == 1 then
    primary = 'Top'
  elseif cur == total then
    primary = 'Bot'
  else
    primary = string.format('%2d%%%%', math.floor(cur / total * 100))
  end

  local secondary = ''

  if config.configs[name].column then
    local col = vim.fn.col('.')
    secondary = string.format('%2d', col)
  end

  primary = string.format('%s %s / %s', config.configs[name].icon, primary, total)

  return highlights.hl_component({ primary = primary, secondary = secondary }, hls, sep, direction)
end

return M
