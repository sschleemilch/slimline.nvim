local M = {}

---@alias Component function

---@type table<string, Component[]>
M.components = {
  left = {},
  center = {},
  right = {},
}

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
    local exist, component_module = pcall(require, string.format('slimline.components.%s', component))
    if exist then
      local sep = {
        left = M.config.sep.left,
        right = M.config.sep.right,
      }
      if M.config.sep.hide.first and position == 'first' then
        sep.left = ''
      end
      if M.config.sep.hide.last and position == 'last' then
        sep.right = ''
      end
      return function(...)
        return component_module.render(sep, direction, ...)
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
function M.concat_components(components)
  local result = ''
  for i, component in ipairs(components) do
    local space = M.config.spaces.components
    if i == 1 then
      space = ''
    end
    result = result .. space .. component()
  end
  return result
end

---@return string
function M.render()
  local result = '%#Slimline#' .. M.config.spaces.left
  result = result .. M.concat_components(M.components.left)
  result = result .. '%='
  result = result .. M.concat_components(M.components.center)
  result = result .. '%='
  result = result .. M.concat_components(M.components.right)
  result = result .. M.config.spaces.right
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
function M.setup(opts)
  if opts == nil then
    opts = {}
  end

  if vim.o.showmode == true then
    vim.o.showmode = false
  end

  opts = vim.tbl_deep_extend('force', require('slimline.default_config'), opts)

  -- Clear seps if we are in foreground mode
  if opts.style == 'fg' then
    opts.sep.left = ''
    opts.sep.right = ''
  end

  M.config = opts

  require('slimline.highlights').create_hls()

  M.components.left = get_components(opts.components.left, 'left')
  M.components.center = get_components(opts.components.center, 'center')
  M.components.right = get_components(opts.components.right, 'right')

  vim.o.statusline = "%!v:lua.require'slimline'.render()"

  require('slimline.autocommands')
  require('slimline.usercommands')
end

return M
