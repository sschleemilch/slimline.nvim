local slimline = require('slimline')
local C = {}

local config = slimline.config.configs.selectioncount

---@param opts render.options
---@return string
function C.render(opts)
  local mode = vim.fn.mode(true)

  local line_start, col_start = vim.fn.line('v'), vim.fn.col('v')
  local line_end, col_end = vim.fn.line('.'), vim.fn.col('.')

  local result = ''

  if mode:match('') then
    result = string.format('%2dx%2d', math.abs(line_start - line_end) + 1, math.abs(col_start - col_end) + 1)
  elseif mode:match('V') or line_start ~= line_end then
    result = string.format('%2d', math.abs(line_start - line_end) + 1)
  elseif mode:match('v') then
    result = string.format('%2d', math.abs(col_start - col_end) + 1)
  end

  if result == '' then return '' end

  return slimline.highlights.hl_component(
    { primary = config.icon .. result },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
end

return C
