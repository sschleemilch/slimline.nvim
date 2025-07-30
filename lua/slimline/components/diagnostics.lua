local C = {}
local diagnostics = {}

local slimline = require('slimline')

local config = slimline.config.configs.diagnostics
local icons = config.icons
local style = config.style or slimline.config.style
local direction_ = nil
local sep_ = vim.defaulttable()
local initialized = false

---@alias diagnostics {ERROR: integer, WARN: integer, HINT: integer, INFO: integer}

---@param str string
---@return string
local function capitalize(str) return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2)) end

---@param buf_id integer|nil
---@return diagnostics
local function get_diagnostic_count(buf_id)
  local res = {
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }
  for _, d in ipairs(vim.diagnostic.get(buf_id)) do
    local sev = vim.diagnostic.severity[d.severity]
    res[sev] = res[sev] + 1
  end
  return res
end

---@param buffer integer
---@param workspace integer
---@return string
local function get_count_format(buffer, workspace)
  local count = ''
  if buffer > 0 then count = string.format('%d', buffer) end
  if workspace > 0 and buffer ~= workspace then count = string.format('%s(%d)', count, workspace) end
  return count
end

---@param buffer diagnostics
---@param workspace diagnostics
---@return {active: string, inactive: string}
local function format(buffer, workspace)
  local parts_active = {}
  local parts_inactive = {}

  for severity, bc in pairs(buffer) do
    local capsev = capitalize(severity)
    local wc = workspace[severity]
    if wc > 0 or bc > 0 then
      local count = get_count_format(bc, wc)
      if style == 'fg' then
        local hl = 'SlimlineDiagnostic' .. capitalize(severity)
        table.insert(parts_active, string.format('%%#%s#%s%s', hl, icons[severity], count))
        table.insert(parts_inactive, string.format('%%#%s#%s%s', 'SlimlineDiagnosticSecondary', icons[severity], count))
      else
        local hls = {
          primary = {
            text = 'SlimlineDiagnosticVirtualText' .. capsev,
            sep = 'SlimlineDiagnosticVirtualText' .. capsev .. 'Sep',
          },
          secondary = {
            text = 'SlimlineDiagnosticSecondary',
            sep = 'SlimlineDiagnosticSecondarySep',
          },
        }
        table.insert(
          parts_active,
          slimline.highlights.hl_component(
            { primary = string.format('%s%s', icons[severity], count) },
            hls,
            sep_,
            direction_,
            true
          )
        )
        table.insert(
          parts_inactive,
          slimline.highlights.hl_component(
            { primary = string.format('%s%s', icons[severity], count) },
            hls,
            sep_,
            direction_,
            false
          )
        )
      end
    end
  end

  local hl_reset = string.format('%%#%s#', slimline.highlights.hls.base)

  if #parts_active > 0 then table.insert(parts_active, hl_reset) end
  if #parts_inactive > 0 then table.insert(parts_inactive, hl_reset) end

  local sep = slimline.config.spaces.components
  if style == 'fg' then sep = ' ' end

  return { active = table.concat(parts_active, sep), inactive = table.concat(parts_inactive, sep) }
end

local track_diagnostics = vim.schedule_wrap(function(data)
  if not vim.api.nvim_buf_is_valid(data.buf) then
    diagnostics[data.buf] = nil
    return
  end

  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then return end

  local buffer_counts = get_diagnostic_count(0)
  local workspace_counts = {
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }
  if config.workspace then workspace_counts = get_diagnostic_count(nil) end
  diagnostics[data.buf] = format(buffer_counts, workspace_counts)
  vim.cmd.redrawstatus()
end)

---@param sep sep
---@param direction component.direction
local function init(sep, direction)
  if initialized then return end

  sep_ = sep
  direction_ = direction

  initialized = true

  slimline.au({ 'DiagnosticChanged', 'BufEnter', 'ModeChanged' }, '*', track_diagnostics, 'Track Diagnostics')
end

---@param opts render.options
---@return string
function C.render(opts)
  init(opts.sep, opts.direction)

  local buf = vim.api.nvim_get_current_buf()

  if not diagnostics[buf] then return '' end

  if opts.active then
    return diagnostics[buf].active
  else
    return diagnostics[buf].inactive
  end
end

return C
