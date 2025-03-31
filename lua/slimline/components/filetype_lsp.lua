local M = {}
local highlights = require('slimline.highlights')

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls table
--- @return string
function M.render(sep, direction, hls)
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end
  local icon = ''
  local ok, MiniIcons = pcall(require, 'mini.icons')
  if ok then
    icon = MiniIcons.get('filetype', filetype)
  end
  filetype = icon .. ' ' .. filetype

  local attached_clients = vim.lsp.get_clients { bufnr = 0 }
  local it = vim.iter(attached_clients)
  it:map(function(client)
    local name = client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  local lsp_clients = string.format('%s', table.concat(names, ','))

  return highlights.hl_component({ primary = filetype, secondary = lsp_clients }, hls, sep, direction)
end

return M
