local C = {}
local with_icons = false
local initialized = false

local lsp_clients = {}
local MiniIcons = {}

local slimline = require('slimline')

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
  local ok
  ok, MiniIcons = pcall(require, 'mini.icons')
  if ok then
    with_icons = true
  end
  initialized = true

  slimline.au({ 'LspAttach', 'LspDetach', 'BufEnter' }, '*', track_lsp, 'Track LSP')
end

--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  init()

  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end
  if with_icons then
    local icon = MiniIcons.get('filetype', filetype) --luacheck: ignore
    filetype = icon .. ' ' .. filetype
  end

  return slimline.highlights.hl_component(
    { primary = filetype or '', secondary = lsp_clients[vim.api.nvim_get_current_buf()] or '' },
    hls,
    sep,
    direction,
    active
  )
end

return C
