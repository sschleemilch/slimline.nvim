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

---@type table<string, boolean>
local disabled_filetypes_cache = {}

local last_win_width
local active_components_cache = {
  left = nil,
  center = nil,
  right = nil,
}

local augroup = vim.api.nvim_create_augroup('Slimline', { clear = true })
function Slimline.au(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end

--- @type table<string, mode>?
local mode_map_cache = nil

--- Build the mode map from config and current highlight groups.
--- Called once at startup and again after ColorScheme changes.
local function build_mode_map()
  local hls = Slimline.highlights.hls.components.mode
  local format = Slimline.config.configs.mode.format
  local secondary = hls.secondary

  --- @param key string
  --- @param mode_hls component.highlights
  --- @return mode
  local function entry(key, mode_hls)
    local fmt = format[key]
    return {
      verbose = fmt.verbose,
      short = fmt.short,
      hls = { primary = mode_hls.primary, secondary = secondary },
    }
  end

  -- Note that: \19 = ^S and \22 = ^V.
  mode_map_cache = {
    ['n'] = entry('n', hls.normal),
    ['v'] = entry('v', hls.visual),
    ['V'] = entry('V', hls.visual),
    ['\22'] = entry('\22', hls.visual),
    ['s'] = entry('s', hls.visual),
    ['S'] = entry('S', hls.visual),
    ['\19'] = entry('\19', hls.visual),
    ['i'] = entry('i', hls.insert),
    ['R'] = entry('R', hls.replace),
    ['c'] = entry('c', hls.command),
    ['r'] = entry('r', hls.command),
    ['!'] = entry('!', hls.command),
    ['t'] = entry('t', hls.command),
    ['U'] = entry('U', hls.other),
  }
end

--- @return mode
function Slimline.get_mode()
  if not mode_map_cache then build_mode_map() end
  return mode_map_cache[vim.fn.mode()] or mode_map_cache['U']
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
          if follow == 'mode' then hls = Slimline.get_mode().hls end
          return cmp.render({ sep = sep, direction = direction, hls = hls, active = active, style = style })
        end,
      }
    else
      return { render = function() return component_ref end }
    end
  end
  return { render = function() return '' end }
end

---@param win_width integer
---@param components component[]
---@param active boolean
---@param direction component.direction
---@return string
function Slimline.concat_components(win_width, components, active, direction)
  if #components == 0 then return '' end
  local result = ''

  local filter = true
  if win_width == last_win_width then
    if active_components_cache[direction] then
      components = active_components_cache[direction]
      filter = false
    end
  else
    last_win_width = win_width
  end

  if filter then
    ---@type component[]
    components = vim.tbl_filter(function(c) return win_width >= (c.trunc_width or -1) end, components)
    active_components_cache[direction] = components
  end

  local parts = {}
  for _, component in ipairs(components) do
    local rendered = component.render(active)
    if rendered ~= '' then table.insert(parts, rendered) end
  end
  result = result .. table.concat(parts, Slimline.config.spaces.components)
  return result
end

---@param active integer
---@return string
function Slimline.render(active)
  Slimline.highlights.create()

  if disabled_filetypes_cache[vim.bo.filetype] == nil then
    disabled_filetypes_cache[vim.bo.filetype] = vim.tbl_contains(Slimline.config.disabled_filetypes, vim.bo.filetype)
  end

  if disabled_filetypes_cache[vim.bo.filetype] == true then return '' end

  local components = Slimline.active
  local is_active = active == 1
  if not is_active then components = Slimline.inactive end
  local base_hl = (is_active and Slimline.highlights.hls.base) or Slimline.highlights.hls.base_inactive
  local result = '%#' .. base_hl .. '#' .. Slimline.config.spaces.left
  local win_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
  result = result .. Slimline.concat_components(win_width, components.left, is_active, 'left')
  result = result .. '%=%<'
  result = result .. Slimline.concat_components(win_width, components.center, is_active, 'center')
  result = result .. '%='
  result = result .. Slimline.concat_components(win_width, components.right, is_active, 'right')
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

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = augroup,
    callback = function()
      Slimline.highlights.initialized = true
      mode_map_cache = nil
    end,
  })
end

return Slimline
