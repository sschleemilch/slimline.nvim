local M = {}

M.hls = {
  base = nil,
  components = {},
}

M.hls_created = false

local function firstToUpper(str)
  return (str:gsub('^%l', string.upper))
end

function M.create_hls()
  if M.hls_created then
    return
  end

  local config = require('slimline').config

  M.hls.base = M.create_hl('', config.hl.base)

  --- Make sure that Diagnostic* hl groups have base as background
  M.create_hl('DiagnosticHint', 'DiagnosticHint', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticInfo', 'DiagnosticInfo', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticWarn', 'DiagnosticWarn', false, false, nil, M.hls.base)
  M.create_hl('DiagnosticError', 'DiagnosticError', false, false, nil, M.hls.base)

  local components = {}
  for _, section in pairs(config.components) do
    for _, component in ipairs(section) do
      table.insert(components, component)
    end
  end

  --- Create component highlights
  for _, component in ipairs(components) do
    local component_config = config.configs[component]

    if component_config and (component_config.follow == nil or component_config.follow == false) then
      local inverse = false
      local style = config.style
      if component_config.style ~= nil then
        style = component_config.style
      end
      if style == 'bg' then
        inverse = true
      end
      local prefix = firstToUpper(component)

      local secondary = config.hl.secondary
      if config.configs[component] and config.configs[component].hl and config.configs[component].hl.secondary then
        secondary = config.configs[component].hl.secondary
      end

      if component == 'mode' then
        local hls = config.configs['mode'].hl
        M.hls.components[component] = {
          normal = {
            primary = {
              text = M.create_hl(prefix .. 'Normal', hls.normal, inverse, config.bold, nil, M.hls.base),
              sep = M.create_hl(prefix .. 'NormalSep', hls.normal, false, false, nil, M.hls.base),
              sep2sec = M.create_hl(prefix .. 'NormalSep2Sec', hls.normal, false, false, secondary),
            },
          },
          pending = {
            primary = {
              text = M.create_hl(prefix .. 'Pending', hls.pending, inverse, config.bold, nil, M.hls.base),
              sep = M.create_hl(prefix .. 'PendingSep', hls.pending, false, false, nil, M.hls.base),
              sep2sec = M.create_hl(prefix .. 'PendingSep2Sec', hls.pending, false, false, secondary),
            },
          },
          visual = {
            primary = {
              text = M.create_hl(prefix .. 'Visual', hls.visual, inverse, config.bold, nil, M.hls.base),
              sep = M.create_hl(prefix .. 'VisualSep', hls.visual, false, false, nil, M.hls.base),
              sep2sec = M.create_hl(prefix .. 'VisualSep2Sec', hls.visual, false, false, secondary),
            },
          },
          insert = {
            primary = {
              text = M.create_hl(prefix .. 'Insert', hls.insert, inverse, config.bold, nil, M.hls.base),
              sep = M.create_hl(prefix .. 'InsertSep', hls.insert, false, false, nil, M.hls.base),
              sep2sec = M.create_hl(prefix .. 'InsertSep2Sec', hls.insert, false, false, secondary),
            },
          },
          command = {
            primary = {
              text = M.create_hl(prefix .. 'Command', hls.command, inverse, config.bold, nil, M.hls.base),
              sep = M.create_hl(prefix .. 'CommandSep', hls.command, false, false, nil, M.hls.base),
              sep2sec = M.create_hl(prefix .. 'CommandSep2Sec', hls.command, false, false, secondary),
            },
          },
          secondary = {
            text = M.create_hl(prefix .. 'Secondary', secondary, inverse, false, nil, M.hls.base),
            sep = M.create_hl(prefix .. 'SecondarySep', secondary, false, false, nil, M.hls.base),
          },
        }
      else
        local primary = config.hl.primary
        if config.configs[component] and config.configs[component].hl and config.configs[component].hl.primary then
          primary = config.configs[component].hl.primary
        end

        M.hls.components[component] = {
          primary = {
            text = M.create_hl(prefix .. 'Primary', primary, inverse, config.bold, nil, M.hls.base),
            sep = M.create_hl(prefix .. 'PrimarySep', primary, false, false, nil, M.hls.base),
            sep2sec = M.create_hl(prefix .. 'PrimarySep2Sec', primary, false, false, secondary),
          },
          secondary = {
            text = M.create_hl(prefix .. 'Secondary', secondary, inverse, false, nil, M.hls.base),
            sep = M.create_hl(prefix .. 'SecondarySep', secondary, false, false, nil, M.hls.base),
          },
        }
      end
    end
  end
  M.hls_created = true
end

---@param hl string
---@param base string?
---@param inverse boolean?
---@param bold boolean?
---@param bg_from_fg string?
---@param bg_from_bg string?
---@return string
function M.create_hl(hl, base, inverse, bold, bg_from_fg, bg_from_bg)
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
  if inverse then
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
  local hls = {
    secondary = M.hls.components['mode'].secondary,
    primary = M.hls.components['mode'].command.primary,
  }
  if mode == 'NORMAL' then
    hls.primary = M.hls.components['mode'].normal.primary
  elseif mode:find('PENDING') then
    hls.primary = M.hls.components['mode'].pending.primary
  elseif mode:find('VISUAL') then
    hls.primary = M.hls.components['mode'].visual.primary
  elseif mode:find('INSERT') or mode:find('SELECT') then
    hls.primary = M.hls.components['mode'].insert.primary
  elseif mode:find('COMMAND') or mode:find('TERMINAL') or mode:find('EX') then
    hls.primary = M.hls.components['mode'].command.primary
  end
  return hls
end

return M
