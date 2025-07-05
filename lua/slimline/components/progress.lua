local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.progress

--- @param sep sep
--- @param direction component.direction
--- @param hls component.highlights
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
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

  if config.column then
    local col = vim.fn.col('.')
    secondary = string.format('%3d', col)
  end

  primary = string.format('%s %s / %s', config.icon, primary, total)

  return slimline.highlights.hl_component({ primary = primary, secondary = secondary }, hls, sep, direction, active)
end

return C
