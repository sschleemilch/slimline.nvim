local slimline = require('slimline')
local C = {}

local config = slimline.config.configs.searchcount

---@param opts render.options
---@return string
function C.render(opts)
  if vim.v.hlsearch == 0 then return '' end
  local ok, count = pcall(vim.fn.searchcount, config.options)
  if not ok or count.current == nil or count.total == 0 then return '' end

  local result = '?/?'
  if count.incomplete ~= 1 then
    local too_many = '>' .. count.maxcount
    local current = count.current > count.maxcount and too_many or count.current
    local total = count.total > count.maxcount and too_many or count.total
    result = current .. '/' .. total
  end

  return slimline.highlights.hl_component(
    { primary = config.icon .. result },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active
  )
end

return C
