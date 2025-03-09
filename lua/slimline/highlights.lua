local M = {}

M.hls = {
  base = nil,
  component = {
    primary = {
      text = nil,
      sep = nil,
      sep2sec = nil,
    },
    secondary = {
      text = nil,
      sep = nil,
    },
  },
  mode = {
    normal = {
      primary = {
        text = nil,
        sep = nil,
      },
    },
    pending = {
      primary = {
        text = nil,
        sep = nil,
      },
    },
    visual = {
      primary = {
        text = nil,
        sep = nil,
      },
    },
    insert = {
      primary = {
        text = nil,
        sep = nil,
      },
    },
    command = {
      primary = {
        text = nil,
        sep = nil,
      },
    },
  },
}

function M.create_hls()
  local config = require('slimline').config
  M.hls.base = M.create_hl('', config.hl.base)

  local as_background = true
  if config.style == 'fg' then
    as_background = false
  end

  M.hls.component.primary.text = M.create_hl('Primary', config.hl.primary, as_background, config.bold)
  M.hls.component.primary.sep = M.create_hl('PrimarySep', config.hl.primary)
  M.hls.component.primary.sep2sec = M.create_hl('PrimarySep2Sec', config.hl.primary, false, false, config.hl.secondary)
  M.hls.component.secondary.text = M.create_hl('Secondary', config.hl.secondary, as_background, false)
  M.hls.component.secondary.sep = M.create_hl('SecondarySep', config.hl.secondary)

  local mode_as_background = as_background
  if not config.mode_follow_style then
    mode_as_background = true
  end

  M.hls.mode.normal.primary.text = M.create_hl('NormalMode', config.hl.modes.normal, mode_as_background, config.bold)
  M.hls.mode.normal.primary.sep = M.create_hl('NormalModeSep', config.hl.modes.normal)
  M.hls.mode.pending.primary.text = M.create_hl('PendingMode', config.hl.modes.pending, mode_as_background, config.bold)
  M.hls.mode.pending.primary.sep = M.create_hl('PendingModeSep', config.hl.modes.pending)
  M.hls.mode.visual.primary.text = M.create_hl('VisualMode', config.hl.modes.visual, mode_as_background, config.bold)
  M.hls.mode.visual.primary.sep = M.create_hl('VisualModeSep', config.hl.modes.visual)
  M.hls.mode.insert.primary.text = M.create_hl('InsertMode', config.hl.modes.insert, mode_as_background, config.bold)
  M.hls.mode.insert.primary.sep = M.create_hl('InsertModeSep', config.hl.modes.insert)
  M.hls.mode.command.primary.text = M.create_hl('CommandMode', config.hl.modes.command, mode_as_background, config.bold)
  M.hls.mode.command.primary.sep = M.create_hl('CommandModeSep', config.hl.modes.command)

  --- Make sure that Diagnostic* hl groups have base as background
  M.create_hl('DiagnosticHint', 'DiagnosticHint', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticInfo', 'DiagnosticInfo', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticWarn', 'DiagnosticWarn', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticError', 'DiagnosticError', false, false, nil, M.hls.base)
end

---@param hl string
---@param base string?
---@param reverse boolean?
---@param bold boolean?
---@param bg_from_fg string?
---@param bg_from_bg string?
---@return string
function M.create_hl(hl, base, reverse, bold, bg_from_fg, bg_from_bg)
  local basename = 'Slimline'
  if hl:sub(1, #basename) ~= basename then
    hl = basename .. hl
  end

  local hl_normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
  local hl_ref = vim.api.nvim_get_hl(0, { name = base })
  local hl_bg_ref = vim.api.nvim_get_hl(0, { name = bg_from_fg })
  local fg = hl_ref.fg or 'fg'
  local bg = hl_bg_ref.fg or hl_ref.bg or hl_normal.bg
  if bg_from_bg ~= nil then
    bg = vim.api.nvim_get_hl(0, { name = bg_from_bg }).bg
  end
  if reverse then
    local tmp = fg
    fg = bg
    if fg == nil then
      local bg_style = vim.o.background
      if bg_style == 'dark' then
        fg = '#000000'
      else
        fg = '#ffffff'
      end
    end
    bg = tmp
  end

  vim.api.nvim_set_hl(0, hl, { bg = bg, fg = fg, bold = hl_ref.bold or bold })

  return hl
end

--- Helper function to highlight a given content
--- Resets the highlight afterwards
--- @param content string?
--- @param hl string?
--- @param sep_left string?
--- @param sep_right string?
--- @return string
function M.hl_content(content, hl, sep_left, sep_right)
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
  return rendered
end

---@param content string?
---@return string?
function M.pad(content)
  if content == nil then
    return nil
  end
  return ' ' .. content .. ' '
end

---@param content {primary: string, secondary: string?}
---@param hl {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
---@param sep {left: string, right: string}
---@param direction string?
---|"'left'"
---|"'right'"
---@return string
function M.hl_component(content, hl, sep, direction)
  local result
  if content.primary == nil then
    return ''
  end
  if content.secondary == '' then
    content.secondary = nil
  end

  if content.secondary == nil then
    result = M.hl_content(M.pad(content.primary), hl.primary.text, sep.left, sep.right)
  else
    if direction == 'left' then
      result = M.hl_content(M.pad(content.secondary), hl.secondary.text, sep.left)
      result = result .. M.hl_content(sep.left, hl.primary.sep2sec)
      result = result .. M.hl_content(M.pad(content.primary), hl.primary.text, nil, sep.right)
    else
      result = M.hl_content(M.pad(content.primary), hl.primary.text, sep.left)
      result = result .. M.hl_content(sep.right, hl.primary.sep2sec)
      result = result .. M.hl_content(M.pad(content.secondary), hl.secondary.text, nil, sep.right)
    end
  end
  result = result .. '%#' .. M.hls.base .. '#'
  return result
end

--- Function to get the highlight config
--- @param mode string
--- @return table
function M.get_mode_hl(mode)
  if mode == 'NORMAL' then
    return M.hls.mode.normal
  elseif mode:find('PENDING') then
    return M.hls.mode.pending
  elseif mode:find('VISUAL') then
    return M.hls.mode.visual
  elseif mode:find('INSERT') or mode:find('SELECT') then
    return M.hls.mode.insert
  elseif mode:find('COMMAND') or mode:find('TERMINAL') or mode:find('EX') then
    return M.hls.mode.command
  end
  return M.hls.mode.command
end

return M
