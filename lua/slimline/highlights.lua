local M = {}

M.hls = {
  base = nil,
  primary = {
    text = nil,
    sep = nil,
    sep_transition = nil,
  },
  secondary = {
    text = nil,
    sep = nil,
  },
  mode = {
    normal = {
      text = nil,
      sep = nil,
    },
    pending = {
      text = nil,
      sep = nil,
    },
    visual = {
      text = nil,
      sep = nil,
    },
    insert = {
      text = nil,
      sep = nil,
    },
    command = {
      text = nil,
      sep = nil,
    },
  },
}
---@param config table
function M.create(config)
  M.hls.base = M.get_or_create('', config.hl.base)

  local as_background = true
  if config.style == 'fg' then
    as_background = false
  end

  M.hls.primary.text = M.get_or_create('Primary', config.hl.primary, as_background, config.bold)
  M.hls.primary.sep = M.get_or_create('PrimarySep', config.hl.primary)
  M.hls.primary.sep_transition =
    M.get_or_create('PrimarySepTransition', config.hl.primary, false, false, config.hl.secondary)

  M.hls.secondary.text = M.get_or_create('Secondary', config.hl.secondary, as_background, false)
  M.hls.secondary.sep = M.get_or_create('SecondarySep', config.hl.secondary)

  M.hls.mode.normal.text = M.get_or_create('NormalMode', config.hl.modes.normal, as_background, config.bold)
  M.hls.mode.normal.sep = M.get_or_create('NormalModeSep', config.hl.modes.normal)
  M.hls.mode.pending.text = M.get_or_create('PendingMode', config.hl.modes.pending, as_background, config.bold)
  M.hls.mode.pending.sep = M.get_or_create('PendingModeSep', config.hl.modes.pending)
  M.hls.mode.visual.text = M.get_or_create('VisualMode', config.hl.modes.visual, as_background, config.bold)
  M.hls.mode.visual.sep = M.get_or_create('VisualModeSep', config.hl.modes.visual)
  M.hls.mode.insert.text = M.get_or_create('InsertMode', config.hl.modes.insert, as_background, config.bold)
  M.hls.mode.insert.sep = M.get_or_create('InsertModeSep', config.hl.modes.insert)
  M.hls.mode.command.text = M.get_or_create('CommandMode', config.hl.modes.command, as_background, config.bold)
  M.hls.mode.command.sep = M.get_or_create('CommandModeSep', config.hl.modes.command)
end

---@type table<string, boolean>
M.hl_cache = {}
---@param hl string
---@param base string?
---@param bg_from string?
---@param reverse boolean?
---@param bold boolean?
function M.get_or_create(hl, base, reverse, bold, bg_from)
  local basename = 'Slimline'
  if hl:sub(1, #basename) ~= basename then
    hl = basename .. hl
  end

  if not M.hl_cache[hl] then
    local hl_normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
    local hl_ref = vim.api.nvim_get_hl(0, { name = base })
    local hl_bg_ref = vim.api.nvim_get_hl(0, { name = bg_from })
    local fg = hl_ref.fg or 'fg'
    local bg = hl_bg_ref.fg or hl_ref.bg or hl_normal.bg
    if reverse then
      local tmp = fg
      fg = bg
      if fg == nil then
        local bg_style = vim.o.background
        if bg_style == "dark" then
          fg = "#000000"
        else
          fg = "#ffffff"
        end
      end
      bg = tmp
    end

    vim.api.nvim_set_hl(0, hl, { bg = bg, fg = fg, bold = hl_ref.bold or bold })
    M.hl_cache[hl] = true
  end
  return hl
end

--- Helper function to highlight a given content
--- Resets the highlight afterwards
--- @param content string
--- @param hl string?
--- @param sep_left string?
--- @param sep_right string?
--- @return string
function M.highlight_content(content, hl, sep_left, sep_right)
  if content == nil then
    return ''
  end
  local rendered = ''
  if sep_left ~= nil then
    rendered = rendered .. string.format('%%#%s#%s', hl .. 'Sep', sep_left)
  end
  rendered = rendered .. string.format('%%#%s#%s', hl, content)
  if sep_right ~= nil then
    rendered = rendered .. string.format('%%#%s#%s', hl .. 'Sep', sep_right)
  end
  rendered = rendered .. '%#' .. M.hls.base .. '#'
  return rendered
end

return M
