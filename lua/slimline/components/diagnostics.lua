local highlights = require('slimline.highlights')
local config = require('slimline').config
local name = 'diagnostics'
local M = {}

local last_diagnostic_component = ''

local function capitalize(str)
  return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @return string
function M.render(sep, direction, _)
  -- Lazy uses diagnostic icons, but those aren"t errors per se.
  if vim.bo.filetype == 'lazy' then
    return ''
  end

  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return last_diagnostic_component
  end

  local buffer
  if config.configs.diagnostics.workspace then
    buffer = nil
  else
    buffer = 0
  end
  local counts = vim.iter(vim.diagnostic.get(buffer)):fold({
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = acc[severity] + 1
    return acc
  end)

  local icons = config.configs[name].icons

  local style = config.style
  if config.configs[name].style ~= nil then
    style = config.configs[name].style
  end

  local parts = vim
    .iter(counts)
    :map(function(severity, count)
      if count == 0 then
        return nil
      end
      if style == 'fg' then
        local hl = 'SlimlineDiagnostic' .. capitalize(severity)
        return string.format('%%#%s#%s%%#%s#%d', hl, icons[severity], highlights.hls.base, count)
      end
      return highlights.hl_component({ primary = string.format('%s%d', icons[severity], count) }, {
        primary = {
          text = 'DiagnosticVirtualText' .. capitalize(severity),
        },
      }, sep, direction)
    end)
    :totable()

  last_diagnostic_component = table.concat(parts, config.spaces.components)
  if last_diagnostic_component == '' then
    return ''
  end
  return last_diagnostic_component
end

return M
