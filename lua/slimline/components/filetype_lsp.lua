local C = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local with_icons = false
local initialized = false

local lsp_clients = {}

local track_lsp = vim.schedule_wrap(function(data)
  if not vim.api.nvim_buf_is_valid(data.buf) then
    lsp_clients[data.buf] = nil
    return
  end
  local attached_clients = vim.lsp.get_clients { bufnr = data.buf }
  local it = vim.iter(attached_clients)
  it:map(function(client)
    local name = client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  if #names > 0 then
    lsp_clients[data.buf] = string.format('%s', table.concat(names, ','))
  else
    lsp_clients[data.buf] = nil
  end
end)

local function init()
  if initialized then
    return
  end
  local ok, _ = pcall(require, 'mini.icons')
  if ok then
    with_icons = true
  end
  initialized = true

  utils.au({ 'LspAttach', 'LspDetach' }, '*', track_lsp, 'Track LSP')
end

--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function C.render(sep, direction, hls)
  init()

  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end
  local icon = ''
  if with_icons then
    icon = MiniIcons.get('filetype', filetype)
    filetype = icon .. ' ' .. filetype
  end

  return highlights.hl_component(
    { primary = filetype or '', secondary = lsp_clients[vim.api.nvim_get_current_buf()] or '' },
    hls,
    sep,
    direction
  )
end

return C
