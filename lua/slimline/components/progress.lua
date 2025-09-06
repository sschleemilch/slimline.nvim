local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.progress

---@param opts render.options
---@return string
function C.render(opts)
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

  if config.column then secondary = '%3.(%c%V%)' end

  primary = string.format('%s / %s', primary, total)

  if config.icon ~= '' then primary = config.icon .. ' ' .. primary end

  return slimline.highlights.hl_component(
    { primary = primary, secondary = secondary },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
end

return C
