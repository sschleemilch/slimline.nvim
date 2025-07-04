local M = {}

M.hls = vim.defaulttable()

M.initialized = true

local function firstToUpper(str)
  return (str:gsub('^%l', string.upper))
end

---@param hl string
---@param base string?
---@param inverse boolean?
---@param bold boolean?
---@param bg_from_fg string?
---@param bg_from_bg string?
---@return string
local function create(hl, base, inverse, bold, bg_from_fg, bg_from_bg)
  local basename = 'Slimline'
  if hl:sub(1, #basename) ~= basename then
    hl = basename .. hl
  end

  local hl_ref = vim.api.nvim_get_hl(0, { name = base, link = false })
  local hl_ref_bold = hl_ref.bold or false

  if inverse == false and bold == hl_ref_bold and bg_from_fg == nil and bg_from_bg == nil then
    vim.api.nvim_set_hl(0, hl, { link = base })
    return hl
  end

  local hl_normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local hl_bg_ref = vim.api.nvim_get_hl(0, { name = bg_from_fg, link = false })
  local fg = hl_ref.fg or hl_normal.fg
  local bg = hl_bg_ref.fg or hl_ref.bg or hl_normal.bg
  if bg_from_bg ~= nil then
    bg = vim.api.nvim_get_hl(0, { name = bg_from_bg, link = false }).bg
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

  vim.api.nvim_set_hl(0, hl, { bg = bg, fg = fg, bold = bold })

  return hl
end

local function create_diagnostic_highlights()
  local slimline = require('slimline')
  local style = slimline.config.configs.diagnostics.style or slimline.config.style

  if style == 'fg' then
    --- Make sure that Diagnostic* hl groups have base as background for fg mode
    create('DiagnosticHint', 'DiagnosticHint', false, false, nil, M.hls.base)
    create('DiagnosticInfo', 'DiagnosticInfo', false, false, nil, M.hls.base)
    create('DiagnosticWarn', 'DiagnosticWarn', false, false, nil, M.hls.base)
    create('DiagnosticError', 'DiagnosticError', false, false, nil, M.hls.base)
  else
    local dv_bg = vim.api.nvim_get_hl(0, { name = 'DiagnosticVirtualTextError', link = false }).bg
    if dv_bg == nil then
      create('DiagnosticVirtualTextHint', 'SlimlineDiagnosticHint', true, false, nil, nil)
      create('DiagnosticVirtualTextInfo', 'SlimlineDiagnosticInfo', true, false, nil, nil)
      create('DiagnosticVirtualTextWarn', 'SlimlineDiagnosticWarn', true, false, nil, nil)
      create('DiagnosticVirtualTextError', 'SlimlineDiagnosticError', true, false, nil, nil)
    else
      create('DiagnosticVirtualTextHint', 'DiagnosticVirtualTextHint', false, false, nil, nil)
      create('DiagnosticVirtualTextInfo', 'DiagnosticVirtualTextInfo', false, false, nil, nil)
      create('DiagnosticVirtualTextWarn', 'DiagnosticVirtualTextWarn', false, false, nil, nil)
      create('DiagnosticVirtualTextError', 'DiagnosticVirtualTextError', false, false, nil, nil)
    end

    --- Create Diagnostic Seps for bg mode
    local bg = vim.api.nvim_get_hl(0, { name = M.hls.base, link = false }).bg
    local fg
    fg = vim.api.nvim_get_hl(0, { name = 'SlimlineDiagnosticVirtualTextError', link = false }).bg
    vim.api.nvim_set_hl(0, 'SlimlineDiagnosticVirtualTextErrorSep', { bg = bg, fg = fg })
    fg = vim.api.nvim_get_hl(0, { name = 'SlimlineDiagnosticVirtualTextWarn', link = false }).bg
    vim.api.nvim_set_hl(0, 'SlimlineDiagnosticVirtualTextWarnSep', { bg = bg, fg = fg })
    fg = vim.api.nvim_get_hl(0, { name = 'SlimlineDiagnosticVirtualTextInfo', link = false }).bg
    vim.api.nvim_set_hl(0, 'SlimlineDiagnosticVirtualTextInfoSep', { bg = bg, fg = fg })
    fg = vim.api.nvim_get_hl(0, { name = 'SlimlineDiagnosticVirtualTextHint', link = false }).bg
    vim.api.nvim_set_hl(0, 'SlimlineDiagnosticVirtualTextHintSep', { bg = bg, fg = fg })
  end
end

function M.create()
  if not M.initialized then
    return
  end

  local config = require('slimline').config

  M.hls.base = create('', config.hl.base)

  local components = {}
  for _, section in pairs(config.components) do
    for _, component in ipairs(section) do
      components[component] = {}
    end
  end
  for _, section in pairs(config.components_inactive) do
    for _, component in ipairs(section) do
      components[component] = {}
    end
  end

  --- Create component highlights
  for component, _ in pairs(components) do
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
              text = create(prefix .. 'Normal', hls.normal, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'NormalSep', hls.normal, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'NormalSep2Sec', hls.normal, false, false, secondary),
            },
          },
          visual = {
            primary = {
              text = create(prefix .. 'Visual', hls.visual, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'VisualSep', hls.visual, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'VisualSep2Sec', hls.visual, false, false, secondary),
            },
          },
          insert = {
            primary = {
              text = create(prefix .. 'Insert', hls.insert, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'InsertSep', hls.insert, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'InsertSep2Sec', hls.insert, false, false, secondary),
            },
          },
          replace = {
            primary = {
              text = create(prefix .. 'Replace', hls.replace, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'ReplaceSep', hls.replace, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'ReplaceSep2Sec', hls.replace, false, false, secondary),
            },
          },
          command = {
            primary = {
              text = create(prefix .. 'Command', hls.command, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'CommandSep', hls.command, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'CommandSep2Sec', hls.command, false, false, secondary),
            },
          },
          other = {
            primary = {
              text = create(prefix .. 'Other', hls.other, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'OtherSep', hls.other, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'OtherSep2Sec', hls.other, false, false, secondary),
            },
          },
          secondary = {
            text = create(prefix .. 'Secondary', secondary, inverse, false, nil, M.hls.base),
            sep = create(prefix .. 'SecondarySep', secondary, false, false, nil, M.hls.base),
          },
        }
      else
        if component == 'diagnostics' then
          create_diagnostic_highlights()
        else
          local primary = config.hl.primary
          if config.configs[component] and config.configs[component].hl and config.configs[component].hl.primary then
            primary = config.configs[component].hl.primary
          end

          M.hls.components[component] = {
            primary = {
              text = create(prefix .. 'Primary', primary, inverse, config.bold, nil, M.hls.base),
              sep = create(prefix .. 'PrimarySep', primary, false, false, nil, M.hls.base),
              sep2sec = create(prefix .. 'PrimarySep2Sec', primary, false, false, secondary),
            },
            secondary = {
              text = create(prefix .. 'Secondary', secondary, inverse, false, nil, M.hls.base),
              sep = create(prefix .. 'SecondarySep', secondary, false, false, nil, M.hls.base),
            },
          }
        end
      end
    end
  end

  M.initialized = false
end

--- Helper function to highlight a given content
--- Resets the highlight afterwards
--- @param content string?
--- @param hl {text: string, sep: string}
--- @param sep_left string?
--- @param sep_right string?
--- @return string
function M.hl_content(content, hl, sep_left, sep_right)
  if content == nil then
    return ''
  end
  local rendered = ''
  if sep_left ~= nil then
    rendered = rendered .. string.format('%%#%s#%s', hl.sep, sep_left)
  end
  rendered = rendered .. string.format('%%#%s#%s', hl.text, content)
  if sep_right ~= nil then
    rendered = rendered .. string.format('%%#%s#%s', hl.sep, sep_right)
  end
  return rendered
end

---@param content string?
---@return string?
function M.pad(content)
  if content == nil or content == '' then
    return content
  end
  return ' ' .. content .. ' '
end

---@param content {primary: string, secondary: string?}
---@param hl {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
---@param sep {left: string, right: string}
---@param direction string?
---|"'left'"
---|"'right'"
---@param active boolean
---@return string
function M.hl_component(content, hl, sep, direction, active)
  active = active == nil or active
  local result
  if content.primary == nil then
    return ''
  end

  if content.secondary == nil then
    if active then
      result = M.hl_content(M.pad(content.primary), hl.primary, sep.left, sep.right)
    else
      result = M.hl_content(M.pad(content.primary), hl.secondary, sep.left, sep.right)
    end
  else
    if direction == 'left' then
      result = M.hl_content(M.pad(content.secondary), hl.secondary, sep.left)
      if active then
        result = result .. M.hl_content(sep.left, { text = hl.primary.sep2sec })
        result = result .. M.hl_content(M.pad(content.primary), hl.primary, nil, sep.right)
      else
        local fill = ' '
        if sep.left == '' and sep.right == '' then
          fill = ''
        end
        result = result .. M.hl_content(fill, { text = hl.secondary.text })
        result = result .. M.hl_content(M.pad(content.primary), hl.secondary, nil, sep.right)
      end
    else
      if active then
        result = M.hl_content(M.pad(content.primary), hl.primary, sep.left)
        result = result .. M.hl_content(sep.right, { text = hl.primary.sep2sec })
      else
        local fill = ' '
        if sep.left == '' and sep.right == '' then
          fill = ''
        end
        result = M.hl_content(M.pad(content.primary), hl.secondary, sep.left)
        result = result .. M.hl_content(fill, { text = hl.secondary.text })
      end
      result = result .. M.hl_content(M.pad(content.secondary), hl.secondary, nil, sep.right)
    end
  end
  result = result .. '%#' .. M.hls.base .. '#'
  return result
end

return M
