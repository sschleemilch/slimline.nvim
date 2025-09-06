-- borrowed from https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/statusline.lua#L128
local C = {}
local slimline = require('slimline')
local initialized = false

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
  icon = nil,
}

local track_lsp_progress = vim.schedule_wrap(function(ev)
  -- This should in theory never happen, but I've seen weird errors.
  if not ev.data then return end

  progress_status = {
    client = vim.lsp.get_client_by_id(ev.data.client_id).name,
    kind = ev.data.params.value.kind,
    title = ev.data.params.value.title,
  }
  local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
  progress_status.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]

  if progress_status.kind == 'end' then
    progress_status.title = nil
    vim.cmd.redrawstatus()
  else
    vim.cmd.redrawstatus()
  end
end)

local function init()
  if initialized then return end

  slimline.au('LspProgress', '*', track_lsp_progress, 'Track LSP Progress')

  initialized = true
end

--- @param opts render.options
--- @return string
function C.render(opts)
  init()
  if not progress_status.client or not progress_status.title then return '' end

  -- Avoid noisy messages while typing.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then return '' end

  return slimline.highlights.hl_component(
    { primary = string.format('%s %s: %s', progress_status.icon, progress_status.client, progress_status.title) },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
end

return C
