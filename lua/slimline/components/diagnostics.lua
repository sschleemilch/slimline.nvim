local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local config = require('slimline').config
local C = {}
local content = ''

local icons = config.configs['diagnostics'].icons
local style = config.configs['diagnostics'].style or config.style
local initialized = false
local diagnostics = {}

local function get_diagnostic_count(buf_id)
  local res = {}
  for _, d in ipairs(vim.diagnostic.get(buf_id)) do
    local sev = vim.diagnostic.severity[d.severity]
    res[sev] = (res[sev] or 0) + 1
  end
  return res
end

local track_diagnostics = vim.schedule_wrap(function(data)
  if not vim.api.nvim_buf_is_valid(data.buf) then
    diagnostics[data.buf] = nil
    return
  end
  local buf = nil
  if not config.configs.diagnostics.workspace then
    buf = data.buf
  end

  local counts = get_diagnostic_count(buf)
  diagnostics[data.buf] = counts
end)

local function init()
  if initialized then
    return
  end
  initialized = true

  utils.au({ 'DiagnosticChanged', 'BufEnter' }, '*', track_diagnostics, 'Track Diagnostics')
end

local function capitalize(str)
  return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @return string
function C.render(sep, direction, _)
  -- Lazy uses diagnostic icons, but those aren"t errors per se.
  if vim.bo.filetype == 'lazy' then
    return ''
  end

  init()

  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return content
  end

  local counts = diagnostics[vim.api.nvim_get_current_buf()]
    or {
      ERROR = 0,
      WARN = 0,
      HINT = 0,
      INFO = 0,
    }

  local parts = {}

  for severity, count in pairs(counts) do
    local capsev = capitalize(severity)
    if count > 0 then
      if style == 'fg' then
        local hl = 'SlimlineDiagnostic' .. capitalize(severity)
        table.insert(parts, string.format('%%#%s#%s%%#%s#%d', hl, icons[severity], highlights.hls.base, count))
      else
        table.insert(
          parts,
          highlights.hl_component({ primary = string.format('%s%d', icons[severity], count) }, {
            primary = {
              text = 'SlimlineDiagnosticVirtualText' .. capsev,
              sep = 'SlimlineDiagnosticVirtualText' .. capsev .. 'Sep',
            },
          }, sep, direction)
        )
      end
    end
  end

  content = table.concat(parts, config.spaces.components)
  if content == '' then
    return ''
  end
  return content
end

return C
