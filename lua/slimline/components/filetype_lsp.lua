local C = {}
local initialized = false

local lsp_clients = {}
local MiniIcons = nil
local WebDevIcons = nil

local slimline = require('slimline')
local config = slimline.config.configs.filetype_lsp

local track_lsp = vim.schedule_wrap(function(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    lsp_clients[buf] = nil
    return
  end
  local attached_clients = vim.lsp.get_clients({ bufnr = buf })

  local it = vim.iter(attached_clients)
  it:map(function(client)
    if config.map_lsps[client.name] == false then return nil end
    local name = config.map_lsps[client.name] or client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  if #names > 0 then
    lsp_clients[buf] = string.format('%s', table.concat(names, config.lsp_sep))
  else
    lsp_clients[buf] = nil
  end
end)

local withIcon = function(filetype) return filetype end

local function withMiniIcons(filetype)
  local icon = MiniIcons.get('filetype', filetype) --luacheck: ignore
  filetype = icon .. ' ' .. filetype
  return filetype
end

local function withWebDevIcons(filetype)
  local icon = WebDevIcons.get_icon_by_filetype(filetype, { default = false }) --luacheck: ignore
  if type(icon) == 'string' and string.len(icon) > 0 then filetype = icon .. ' ' .. filetype end
  return filetype
end

local function init()
  if initialized then return end
  local ok
  ok, MiniIcons = pcall(require, 'mini.icons')
  if ok then
    withIcon = withMiniIcons
  else
    ok, WebDevIcons = pcall(require, 'nvim-web-devicons')
    if ok then withIcon = withWebDevIcons end
  end
  initialized = true

  slimline.au({ 'LspAttach', 'LspDetach' }, '*', function(data) track_lsp(data.buf) end, 'Track LSP')

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then track_lsp(buf) end
  end
end

---@param opts render.options
---@return string
function C.render(opts)
  init()

  local filetype = vim.bo.filetype
  if filetype == '' then filetype = '[No Name]' end
  filetype = withIcon(filetype)

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
