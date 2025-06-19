local Slimline = {}
Slimline.highlights = require('slimline.highlights')

---@alias Component function

---@type table<string, Component[]>
Slimline.active = vim.defaulttable()
---@type table<string, Component[]>
Slimline.inactive = vim.defaulttable()

local augroup = vim.api.nvim_create_augroup('Slimline', { clear = true })
function Slimline.au(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end

--- Function to translate a mode into a string to show
--- @return string
function Slimline.get_mode()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_map = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  local mode = mode_map[vim.fn.mode()] or 'UNKNOWN'
  return mode
end

---@param component string
---@return table
function Slimline.get_sep(component)
  local sep = {
    left = nil,
    right = nil,
  }
  local style = (Slimline.config.configs[component] and Slimline.config.configs[component].style)
    or Slimline.config.style

  if style == 'fg' then
    sep.left = ''
    sep.right = ''
  else
    sep = {
      left = (
        Slimline.config.configs[component]
        and Slimline.config.configs[component].sep
        and Slimline.config.configs[component].sep.left
      ) or Slimline.config.sep.left,
      right = (
        Slimline.config.configs[component]
        and Slimline.config.configs[component].sep
        and Slimline.config.configs[component].sep.right
      ) or Slimline.config.sep.right,
    }
  end
  return sep
end

---@param component string | function
---@param position string?
---|'"last"'
---|'"first"'
---@param direction string
---|'"right"'
---|'"left"'
---@return Component
local function get_component(component, position, direction)
  if type(component) == 'function' then
    return component
  elseif type(component) == 'string' then
    local ok, cmp = pcall(require, string.format('slimline.components.%s', component))
    if ok then
      if Slimline.config.configs[component].follow then
        component = Slimline.config.configs[component].follow
      end
      local sep = Slimline.get_sep(component)
      if Slimline.config.sep.hide.first and position == 'first' then
        sep.left = ''
      end
      if Slimline.config.sep.hide.last and position == 'last' then
        sep.right = ''
      end
      return function(active)
        local hls = Slimline.highlights.hls.components[component]
        if component == 'mode' then
          hls = Slimline.highlights.get_mode_hl(Slimline.get_mode())
        end
        return cmp.render(sep, direction, hls, active)
      end
    else
      return function()
        return component
      end
    end
  end
  return function()
    return ''
  end
end

---@param active boolean
---@param components Component[]
---@return string
function Slimline.concat_components(components, active)
  local result = ''
  for i, component in ipairs(components) do
    local space = Slimline.config.spaces.components
    if i == 1 then
      space = ''
    end
    result = result .. space .. component(active)
  end
  return result
end

---@param active integer
---@return string
function Slimline.render(active)
  Slimline.highlights.create()
  local components = Slimline.active
  local is_active = active == 1
  if not is_active then
    components = Slimline.inactive
  end
  local result = '%#Slimline#' .. Slimline.config.spaces.left
  result = result .. Slimline.concat_components(components.left, is_active)
  result = result .. '%='
  result = result .. Slimline.concat_components(components.center, is_active)
  result = result .. '%='
  result = result .. Slimline.concat_components(components.right, is_active)
  result = result .. Slimline.config.spaces.right
  return result
end

---@param components table<string|function>
---@param group_position string
---|'"left"'
---|'"center"'
---|'"right"'
---@return Component[]
local function get_components(components, group_position)
  local result = {}
  for i, component in ipairs(components) do
    local component_position = nil
    if i == 1 and group_position == 'left' then
      component_position = 'first'
    end
    if i == #components and group_position == 'right' then
      component_position = 'last'
    end
    local direction = 'right'
    if group_position == 'right' then
      direction = 'left'
    end
    table.insert(result, get_component(component, component_position, direction))
  end
  return result
end

---@param opts table
function Slimline.setup(opts)
  if opts == nil then
    opts = {}
  end

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
    callback = function()
      Slimline.highlights.initialized = true
    end,
  })
end

return Slimline
