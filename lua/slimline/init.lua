local M = {}

---@type table<string, function[]>
M.function_components = {
  left = {},
  center = {},
  right = {},
}

--- Returns a component function
---@param name string | function
---@param position string? "last"|"first"|nil
---@return function
local function get_function_component(name, position)
  if type(name) == 'function' then
    return name
  elseif type(name) == 'string' then
    local exist, component = pcall(require, string.format('slimline.components.%s', name))
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
        return component.render(M.config, sep, ...)
      end
    else
      return function()
        return name
      end
    end
  end
  return function()
    return ''
  end
end

-- Calls function components and concatenate the output
---@param fn_components function[]
---@param spacing string
---@return string
function M.concat_components(fn_components, spacing)
  local result = ''
  for i, fn in ipairs(fn_components) do
    local space = spacing
    if i == 1 then
      space = ''
    end
    result = result .. space .. fn()
  end
  return result
end

--- Renders the statusline.
---@return string
function M.render()
  local result = '%#Slimline#' .. M.config.spaces.left
  result = result .. M.concat_components(M.function_components.left, M.config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(M.function_components.center, M.config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(M.function_components.right, M.config.spaces.components)
  result = result .. M.config.spaces.right
  return result
end

-- Generates function components
---@param components table
---@param group_position string "left"|"center"|"right"
---@return function[]
local function get_function_components(components, group_position)
  local result = {}
  for i, component in ipairs(components) do
    local component_position = nil
    if i == 1 and group_position == 'left' then
      component_position = 'first'
    end
    if i == #components and group_position == 'right' then
      component_position = 'last'
    end
    table.insert(result, get_function_component(component, component_position))
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

  -- Create function components
  M.function_components.left = get_function_components(opts.components.left, 'left')
  M.function_components.center = get_function_components(opts.components.center, 'center')
  M.function_components.right = get_function_components(opts.components.right, 'right')

  vim.o.statusline = "%!v:lua.require'slimline'.render()"

  require('slimline.autocommands')
  require('slimline.usercommands')
end

return M
