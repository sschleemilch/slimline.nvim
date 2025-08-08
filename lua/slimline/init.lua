local Slimline = {}
Slimline.highlights = require('slimline.highlights')

---@class sep
---@field left? string
---@field right? string

---@class component
---@field render function
---@field trunc_width integer|nil

---@alias component.direction string
---|'"right"'
---|'"left"'

---@alias component.position string
---|'"first"'
---|'"last"'

---@alias component.style string
---|'"fg"'
---|'"bg"'

---@alias group_position string
---|'"left"'
---|'"center"'
---|'"right"'

---@class mode
---@field verbose string
---@field short string
---@field hls component.highlights

---@class components
---@field left component[]
---@field center component[]
---@field right component[]

---@class render.options
---@field active boolean
---@field direction component.direction
---@field sep sep
---@field hls component.highlights
---@field style component.style

---@type components
Slimline.active = vim.defaulttable()
---@type components
Slimline.inactive = vim.defaulttable()

local augroup = vim.api.nvim_create_augroup('Slimline', { clear = true })
function Slimline.au(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end

--- @param key string
--- @param hls component.highlights
--- @return mode
local function get_mode_table(key, hls)
  local entry = Slimline.config.configs.mode.format[key]
  entry.hls = {
    primary = hls.primary,
    secondary = Slimline.highlights.hls.components.mode.secondary,
  }
  return entry
end

--- @return mode
function Slimline.get_mode()
  local hls = Slimline.highlights.hls.components.mode
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_map = {
    ['n'] = get_mode_table('n', hls.normal),
    ['v'] = get_mode_table('v', hls.visual),
    ['V'] = get_mode_table('V', hls.visual),
    ['\22'] = get_mode_table('\22', hls.visual),
    ['s'] = get_mode_table('s', hls.visual),
    ['S'] = get_mode_table('S', hls.visual),
    ['\19'] = get_mode_table('\19', hls.visual),
    ['i'] = get_mode_table('i', hls.insert),
    ['R'] = get_mode_table('R', hls.replace),
    ['c'] = get_mode_table('c', hls.command),
    ['r'] = get_mode_table('r', hls.command),
    ['!'] = get_mode_table('!', hls.command),
    ['t'] = get_mode_table('t', hls.command),
  }

  local mode = mode_map[vim.fn.mode()] or get_mode_table('U', hls.other)
  return mode
end

---@param component string
---@return sep
function Slimline.get_sep(component)
  local sep = vim.defaulttable()

  local cfg = Slimline.config.configs[component]

  local style = (cfg and cfg.style) or Slimline.config.style

  if style == 'fg' then
    sep.left = ''
    sep.right = ''
  else
    sep = {
      left = (cfg and cfg.sep and cfg.sep.left) or Slimline.config.sep.left,
      right = (cfg and cfg.sep and cfg.sep.right) or Slimline.config.sep.right,
    }
  end
  return sep
end

---@param component_ref string | function
---@param position component.position?
---@param direction component.direction
---@return component
local function get_component(component_ref, position, direction)
  if type(component_ref) == 'function' then
    return { render = component_ref }
  elseif type(component_ref) == 'string' then
    local ok, cmp = pcall(require, string.format('slimline.components.%s', component_ref))
    if ok then
      local cfg = Slimline.config.configs[component_ref]
      local follow = cfg.follow
      local style = (cfg and cfg.style) or Slimline.config.style
      local sep = Slimline.get_sep(follow or component_ref)
      if Slimline.config.sep.hide.first and position == 'first' then sep.left = '' end
      if Slimline.config.sep.hide.last and position == 'last' then sep.right = '' end
      return {
        trunc_width = Slimline.config.configs[component_ref].trunc_width,
        render = function(active)
          local hls = Slimline.highlights.hls.components[follow or component_ref]
          if component_ref == 'mode' or follow == 'mode' then hls = Slimline.get_mode().hls end
          return cmp.render({ sep = sep, direction = direction, hls = hls, active = active, style = style })
        end,
      }
    else
      return { render = function() return component_ref end }
    end
  end
  return { render = function() return '' end }
end

---@param active boolean
---@param components component[]
---@return string
function Slimline.concat_components(components, active)
  local result = ''

  local win_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
  components = vim.tbl_filter(function(c) return win_width >= (c.trunc_width or -1) end, components)

  for i, component in ipairs(components) do
    local space = Slimline.config.spaces.components
    if i == 1 then space = '' end
    result = result .. space .. component.render(active)
  end
  return result
end

---@param active integer
---@return string
function Slimline.render(active)
  Slimline.highlights.create()

  if vim.tbl_contains(Slimline.config.disabled_filetypes, vim.bo.filetype) then return '%#Slimline#' end

  local components = Slimline.active
  local is_active = active == 1
  if not is_active then components = Slimline.inactive end
  local result = '%#Slimline#' .. Slimline.config.spaces.left
  result = result .. Slimline.concat_components(components.left, is_active)
  result = result .. '%=%<'
  result = result .. Slimline.concat_components(components.center, is_active)
  result = result .. '%='
  result = result .. Slimline.concat_components(components.right, is_active)
  result = result .. Slimline.config.spaces.right
  return result
end

---@param components table<string|function>
---@param position group_position
---@return component[]
local function get_components(components, position)
  local result = {}
  for i, component in ipairs(components) do
    local component_position = nil
    if i == 1 and position == 'left' then component_position = 'first' end
    if i == #components and position == 'right' then component_position = 'last' end
    local direction = 'right'
    if position == 'right' then direction = 'left' end
    table.insert(result, get_component(component, component_position, direction))
  end
  return result
end

---@param opts table
function Slimline.setup(opts)
  if opts == nil then opts = {} end

  _G.Slimline = Slimline

  opts = vim.tbl_deep_extend('force', require('slimline.defaults'), opts)

  Slimline.config = opts
  local active = opts.components
  local inactive = vim.tbl_deep_extend('force', active, opts.components_inactive)

  Slimline.active = {
    left = get_components(active.left, 'left'),
    center = get_components(active.center, 'center'),
    right = get_components(active.right, 'right'),
  }
  Slimline.inactive = {
    left = get_components(inactive.left, 'left'),
    center = get_components(inactive.center, 'center'),
    right = get_components(inactive.right, 'right'),
  }

  vim.go.statusline =
    '%{%(nvim_get_current_win()==#g:actual_curwin || &laststatus==3) ? v:lua.Slimline.render(1) : v:lua.Slimline.render(0)%}'

  vim.api.nvim_create_autocmd('Colorscheme', {
    group = Slimline.augroup,
    callback = function() Slimline.highlights.initialized = true end,
  })
end

return Slimline
