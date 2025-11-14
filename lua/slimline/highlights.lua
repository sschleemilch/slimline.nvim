local M = {}
local cache = {}

---@class highlights
---@field base string
---@field components table<string, component.highlights|mode.highlights>

---@class highlight
---@field text string
---@field sep? string
---@field sep2sec? string

---@class mode.highlights
---@field normal component.highlights
---@field visual component.highlights
---@field insert component.highlights
---@field replace component.highlights
---@field command component.highlights
---@field other component.highlights
---@field secondary highlight

---@class component.highlights
---@field primary highlight
---@field secondary? highlight

---@type highlights
M.hls = vim.defaulttable()

M.initialized = true

---@param str string
---@return string
local function firstToUpper(str) return (str:gsub('^%l', string.upper)) end

---@param hl string
---@param base string?
---@param inverse boolean?
---@param bold boolean?
---@param bg_from_fg string?
---@param bg_from_bg string?
---@return string
local function create(hl, base, inverse, bold, bg_from_fg, bg_from_bg)
  local basename = 'Slimline'
  if hl:sub(1, #basename) ~= basename then hl = basename .. hl end

  if next(vim.api.nvim_get_hl(0, { name = hl })) ~= nil then return hl end

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
  if bg_from_bg ~= nil then bg = vim.api.nvim_get_hl(0, { name = bg_from_bg, link = false }).bg end
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

function M.create()
  if not M.initialized then return end

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
      if component_config.style ~= nil then style = component_config.style end
      if style == 'bg' then inverse = true end
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
          create(prefix .. 'Error', component_config.hl.error, inverse, false, nil, M.hls.base)
          create(prefix .. 'ErrorSep', component_config.hl.error, false, false, nil, M.hls.base)
          create(prefix .. 'Warn', component_config.hl.warn, inverse, false, nil, M.hls.base)
          create(prefix .. 'WarnSep', component_config.hl.warn, false, false, nil, M.hls.base)
          create(prefix .. 'Info', component_config.hl.info, inverse, false, nil, M.hls.base)
          create(prefix .. 'InfoSep', component_config.hl.info, false, false, nil, M.hls.base)
          create(prefix .. 'Hint', component_config.hl.hint, inverse, false, nil, M.hls.base)
          create(prefix .. 'HintSep', component_config.hl.hint, false, false, nil, M.hls.base)
          create(prefix .. 'Secondary', secondary, inverse, false, nil, M.hls.base)
          create(prefix .. 'SecondarySep', secondary, false, false, nil, M.hls.base)
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
--- @param hl highlight
--- @param sep sep
--- @return string
function M.hl_content(content, hl, sep)
  if content == nil then return '' end
  local rendered = ''
  if sep.left ~= nil then rendered = rendered .. string.format('%%%%#%s#%s', hl.sep, sep.left) end
  rendered = rendered .. string.format('%%%%#%s#%s', hl.text, content)
  if sep.right ~= nil then rendered = rendered .. string.format('%%%%#%s#%s', hl.sep, sep.right) end
  return rendered
end

---@param content {primary: string?, secondary: string?}
---@param style component.style
---@param direction component.direction?
---@return {primary: string?, secondary: string?}
function M.pad(content, style, direction)
  content.primary = ' ' .. content.primary .. ' '

  if content.secondary and content.secondary ~= '' then
    if style == 'bg' then
      content.secondary = ' ' .. content.secondary .. ' '
    else
      if direction == 'right' then
        content.secondary = content.secondary .. ' '
      else
        content.secondary = ' ' .. content.secondary
      end
    end
  end

  return content
end

--- Function to produce a format string
--- The content is not actual final rendered content
--- but a placeholder where items will be rendered into
--- It's important for the format string logic that the secondary
--- part is nil when the final one should be also nil
---@param hl component.highlights
---@param sep sep
---@param direction component.direction?
---@param active boolean
---@return string
function M.hl_component_fmt(content, hl, sep, direction, active)
  local result
  if content.secondary == nil then
    if active then
      result = M.hl_content(content.primary, hl.primary, sep)
    else
      result = M.hl_content(content.primary, hl.secondary, sep)
    end
  else
    if direction == 'left' then
      result = M.hl_content(content.secondary, hl.secondary, { left = sep.left })
      if active then
        result = result .. M.hl_content(sep.left, { text = hl.primary.sep2sec }, {})
        result = result .. M.hl_content(content.primary, hl.primary, { right = sep.right })
      else
        if sep.left ~= '' then content.primary = ' ' .. content.primary end
        result = result .. M.hl_content(content.primary, hl.secondary, { right = sep.right })
      end
    else
      if active then
        result = M.hl_content(content.primary, hl.primary, { left = sep.left })
        result = result .. M.hl_content(sep.right, { text = hl.primary.sep2sec }, {})
      else
        if sep.right ~= '' then content.primary = content.primary .. ' ' end
        result = M.hl_content(content.primary, hl.secondary, { left = sep.left })
      end
      result = result .. M.hl_content(content.secondary, hl.secondary, { right = sep.right })
    end
  end
  result = result .. '%%#' .. M.hls.base .. '#'
  return result
end

---@param content {primary: string?, secondary: string?}
---@param hl component.highlights
---@param sep sep
---@param direction component.direction?
---@param active boolean
---@param style component.style
---@return string
function M.hl_component(content, hl, sep, direction, active, style)
  active = active == nil or active
  if content.primary == nil or content.primary == '' then return '' end

  content = M.pad(content, style, direction)

  local cache_key = table.concat({
    (content.secondary ~= nil and 's') or '-',
    hl.primary.sep or '-',
    hl.primary.sep2sec or '-',
    hl.primary.text,
    hl.secondary.sep or '-',
    hl.secondary.sep2sec or '-',
    hl.secondary.text or '-',
    sep.left or '-',
    sep.right or '-',
    direction or '-',
    active and 't' or 'f',
    style,
  }, '|')

  local fmt = cache[cache_key]

  if not fmt then
    local fmt_content = { primary = '%s', secondary = content.secondary and '%s' or nil }
    fmt = M.hl_component_fmt(fmt_content, hl, sep, direction, active)
    cache[cache_key] = fmt
  end

  if content.secondary == nil then return string.format(fmt, content.primary) end

  local first = content.primary
  local second = content.secondary
  if direction == 'left' then
    first = content.secondary
    second = content.primary
  end
  return string.format(fmt, first, second)
end

return M
