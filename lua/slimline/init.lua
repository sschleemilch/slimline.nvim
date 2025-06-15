local Slimline = {}

local highlights = require('slimline.highlights')
local utils = require('slimline.utils')

---@alias Component function

---@type table<string, Component[]>
Slimline.components = {
  left = {},
  center = {},
  right = {},
}

---@param component string
---@return table
local function get_sep(component)
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
      local sep = get_sep(component)
      if Slimline.config.sep.hide.first and position == 'first' then
        sep.left = ''
      end
      if Slimline.config.sep.hide.last and position == 'last' then
        sep.right = ''
      end
      return function()
        local hls = highlights.hls.components[component]
        if component == 'mode' then
          hls = highlights.get_mode_hl(utils.get_mode())
        end
        return cmp.render(sep, direction, hls)
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

---@param components Component[]
---@return string
function Slimline.concat_components(components)
  local result = ''
  for i, component in ipairs(components) do
    local space = Slimline.config.spaces.components
    if i == 1 then
      space = ''
    end
    result = result .. space .. component()
  end
  return result
end

---@return string
function Slimline.render()
  highlights.create_hls()
  local result = '%#Slimline#' .. Slimline.config.spaces.left
  result = result .. Slimline.concat_components(Slimline.components.left)
  result = result .. '%='
  result = result .. Slimline.concat_components(Slimline.components.center)
  result = result .. '%='
  result = result .. Slimline.concat_components(Slimline.components.right)
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

---@return string
function Slimline.inactive()
  return '%#Slimline#%F'
end

---@param opts table
function Slimline.setup(opts)
  if opts == nil then
    opts = {}
  end

  _G.Slimline = Slimline

  opts = vim.tbl_deep_extend('force', require('slimline.defaults'), opts)

  Slimline.config = opts

  Slimline.components.left = get_components(opts.components.left, 'left')
  Slimline.components.center = get_components(opts.components.center, 'center')
  Slimline.components.right = get_components(opts.components.right, 'right')

  vim.go.statusline =
    '%{%(nvim_get_current_win()==#g:actual_curwin || &laststatus==3) ? v:lua.Slimline.render() : v:lua.Slimline.inactive()%}'

  vim.api.nvim_create_autocmd('Colorscheme', {
    group = Slimline.augroup,
    callback = function()
      require('slimline.highlights').create = true
    end,
  })
end

return Slimline
