local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.recording

---@param opts render.options
---@return string
function C.render(opts)
  local recording = vim.fn.reg_recording()
  if recording == '' then return '' end
  local status = config.icon .. recording
  return slimline.highlights.hl_component({ primary = status }, opts.hls, opts.sep, opts.direction, opts.active, opts.style)
end

return C
