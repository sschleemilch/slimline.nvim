local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.progress

---@param opts render.options
---@return string
function C.render(opts)
  return slimline.highlights.hl_component({
    primary = (config.icon ~= '' and config.icon .. ' ' or '') .. '%P / %L',
    secondary = config.column and '%5.(%c%V%)' or '',
  }, opts.hls, opts.sep, opts.direction, opts.active, opts.style)
end

return C
