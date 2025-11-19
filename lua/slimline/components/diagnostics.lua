local C = {}
local diagnostics = {}

local slimline = require('slimline')

local config = slimline.config.configs.diagnostics
local icons = config.icons
local style = config.style or slimline.config.style
local direction_ = nil
local sep_ = vim.defaulttable()
local initialized = false

---@alias diagnostics table<vim.diagnostic.Severity, integer>

local sec_hls = {
  text = 'SlimlineDiagnosticsSecondary',
  sep = 'SlimlineDiagnosticsSecondarySep',
}

local sev2hl = {
  [vim.diagnostic.severity.ERROR] = {
    text = 'SlimlineDiagnosticsError',
    sep = 'SlimlineDiagnosticsErrorSep',
  },
  [vim.diagnostic.severity.WARN] = {
    text = 'SlimlineDiagnosticsWarn',
    sep = 'SlimlineDiagnosticsWarnSep',
  },
  [vim.diagnostic.severity.INFO] = {
    text = 'SlimlineDiagnosticsInfo',
    sep = 'SlimlineDiagnosticsInfoSep',
  },
  [vim.diagnostic.severity.HINT] = {
    text = 'SlimlineDiagnosticsHint',
    sep = 'SlimlineDiagnosticsHintSep',
  },
}

local sev2icon_key = {
  [vim.diagnostic.severity.ERROR] = 'ERROR',
  [vim.diagnostic.severity.WARN] = 'WARN',
  [vim.diagnostic.severity.INFO] = 'INFO',
  [vim.diagnostic.severity.HINT] = 'HINT',
}

---@param counts diagnostics
---@return {active: string, inactive: string}
local function format(counts)
  local parts_active = {}
  local parts_inactive = {}

  for severity, count in pairs(counts) do
    if count > 0 then
      local hls = {
        primary = sev2hl[severity],
        secondary = sec_hls,
      }
      table.insert(
        parts_active,
        slimline.highlights.hl_component(
          { primary = string.format('%s%d', icons[sev2icon_key[severity]], count) },
          hls,
          sep_,
          direction_,
          true,
          style
        )
      )
      table.insert(
        parts_inactive,
        slimline.highlights.hl_component(
          { primary = string.format('%s%d', icons[sev2icon_key[severity]], count) },
          hls,
          sep_,
          direction_,
          false,
          style
        )
      )
    end
  end

  local sep = slimline.config.spaces.components
  if style == 'fg' then sep = '' end

  return { active = table.concat(parts_active, sep), inactive = table.concat(parts_inactive, sep) }
end

local track_diagnostics = vim.schedule_wrap(function(data)
  if not vim.api.nvim_buf_is_valid(data.buf) then
    diagnostics[data.buf] = nil
    return
  end

  if vim.fn.mode() == 'i' then return end

  --- @type integer?
  local bufnr = 0
  if config.workspace then bufnr = nil end

  local counts = vim.diagnostic.count(bufnr)
  diagnostics[data.buf] = format(counts)
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
