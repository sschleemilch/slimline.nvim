local C = {}
local with_icons = false
local initialized = false

local lsp_clients = {}
local MiniIcons = {}

local slimline = require('slimline')
local config = slimline.config.configs.filetype_lsp

local track_lsp = vim.schedule_wrap(function(data)
  if not vim.api.nvim_buf_is_valid(data.buf) then
    lsp_clients[data.buf] = nil
    return
  end
  local attached_clients = vim.lsp.get_clients({ bufnr = data.buf })

  local it = vim.iter(attached_clients)
  it:map(function(client)
    if config.map_lsps[client.name] == false then return nil end
    local name = config.map_lsps[client.name] or client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  if #names > 0 then
    lsp_clients[data.buf] = string.format('%s', table.concat(names, config.lsp_sep))
  else
    lsp_clients[data.buf] = nil
  end
end)

local function init()
  if initialized then return end
  local ok
  ok, MiniIcons = pcall(require, 'mini.icons')
  if ok then with_icons = true end
  initialized = true

  slimline.au({ 'LspAttach', 'LspDetach', 'BufEnter' }, '*', track_lsp, 'Track LSP')
end

---@param opts render.options
---@return string
function C.render(opts)
  init()

  local filetype = vim.bo.filetype
  if filetype == '' then filetype = '[No Name]' end
  if with_icons then
    local icon = MiniIcons.get('filetype', filetype) --luacheck: ignore
    filetype = icon .. ' ' .. filetype
  end

  return slimline.highlights.hl_component(
    { primary = filetype or '', secondary = lsp_clients[vim.api.nvim_get_current_buf()] or '' },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
end

return C
