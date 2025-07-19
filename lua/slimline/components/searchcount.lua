local slimline = require('slimline')
local C = {}

local config = slimline.config.searchcount

---@param opts render.options
---@return string
function C.render(opts)
  if vim.v.hlsearch == 0 then return '' end
  local ok, count = pcall(vim.fn.searchcount, (config.args or {}).options or { recompute = true })
  if not ok or count.current == nil or count.total == 0 then return '' end

  local result = '?/?'
  if count.incomplete == 1 then return result end

  local too_many = '>' .. count.maxcount
  local current = count.current > count.maxcount and too_many or count.current
  local total = count.total > count.maxcount and too_many or count.total
  result = current .. '/' .. total
  return slimline.highlights.hl_component({ primary = result }, opts.hls, opts.sep, opts.direction, opts.active)
end

return C
