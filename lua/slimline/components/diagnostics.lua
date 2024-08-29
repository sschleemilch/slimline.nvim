local highlights = require('slimline.highlights')
local M = {}

local last_diagnostic_component = ''

--- @param config table
--- @param sep {left: string, right: string}
--- @return string
function M.render(config, sep)
  -- Lazy uses diagnostic icons, but those aren"t errors per se.
  if vim.bo.filetype == 'lazy' then
    return ''
  end

  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return last_diagnostic_component
  end

  local counts = vim.iter(vim.diagnostic.get(0)):fold({
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = acc[severity] + 1
    return acc
  end)

  local parts = vim
    .iter(counts)
    :map(function(severity, count)
      if count == 0 then
        return nil
      end

      return string.format('%s%d', config.icons.diagnostics[severity], count)
    end)
    :totable()

  last_diagnostic_component = table.concat(parts, ' ')
  if last_diagnostic_component == '' then
    return ''
  end
  last_diagnostic_component =
    highlights.hl_content(' ' .. last_diagnostic_component .. ' ', highlights.hls.primary.text, sep.left, sep.right)
  return last_diagnostic_component
end

return M
