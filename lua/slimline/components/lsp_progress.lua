-- borrowed from https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/statusline.lua#L128
local M = {}
local highlights = require('slimline.highlights')

---@type table<string, string?>
local progress_status = {
  client = nil,
  kind = nil,
  title = nil,
  icon = nil,
}

vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('sschleemilch/slimline/lsp_progress', { clear = true }),
  desc = 'Update slimline lsp progress',
  callback = function(ev)
    -- This should in theory never happen, but I've seen weird errors.
    if not ev.data then
      return
    end

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
  end,
})

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function M.render(sep, direction, hls)
  if not progress_status.client or not progress_status.title then
    return ''
  end

  -- Avoid noisy messages while typing.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return ''
  end

  return highlights.hl_component(
    { primary = string.format('%s %s: %s', progress_status.icon, progress_status.client, progress_status.title) },
    hls,
    sep,
    direction
  )
end

return M
