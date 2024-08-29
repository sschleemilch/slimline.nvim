local M = {}
local highlights = require('slimline.highlights')

--- @param config table
--- @param sep {left: string, right: string}
function M.render(config, sep)
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end
  local icon = ''
  local ok, MiniIcons = pcall(require, 'mini.icons')
  if ok then
    icon = ' ' .. MiniIcons.get('filetype', filetype)
  end
  filetype = highlights.hl_content(icon .. ' ' .. filetype .. ' ', highlights.hls.primary.text, nil, sep.right)

  local attached_clients = vim.lsp.get_clients { bufnr = 0 }
  local it = vim.iter(attached_clients)
  it:map(function(client)
    local name = client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  local lsp_clients = string.format('%s', table.concat(names, ','))

  local filetype_hl_sep_left = highlights.hls.primary.sep
  if #attached_clients > 0 then
    filetype_hl_sep_left = highlights.hls.primary.sep_transition
  end
  filetype = highlights.hl_content(config.sep.left, filetype_hl_sep_left) .. filetype
  lsp_clients = highlights.hl_content(' ' .. lsp_clients .. ' ', highlights.hls.secondary.text, sep.left)

  local result = filetype
  if #attached_clients > 0 then
    result = lsp_clients .. result
  end
  return result
end

return M
