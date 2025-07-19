local slimline = require('slimline')
local C = {}

---@param opts render.options
---@return string
function C.render(opts)
  local mode = vim.fn.mode(true)

  local line_start, col_start = vim.fn.line('v'), vim.fn.col('v')
  local line_end, col_end = vim.fn.line('.'), vim.fn.col('.')

  local result = ''

  if mode:match('') then
    result = string.format('%dx%d', math.abs(line_start - line_end) + 1, math.abs(col_start - col_end) + 1)
  elseif mode:match('V') or line_start ~= line_end then
    result = string(math.abs(line_start - line_end) + 1)
  elseif mode:match('v') then
    result = string(math.abs(col_start - col_end) + 1)
  end

  return slimline.highlights.hl_component({ primary = result }, opts.hls, opts.sep, opts.direction, opts.active)
end

return C
