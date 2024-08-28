local M = {}

M.resolved_components = {
  left = {},
  center = {},
  right = {}
}

--- Returns correct component from config
---@return function
---@param component_name string | function
---@param component_position string? "last"|"first"|nil
local function resolve_component(component_name, component_position)
  local config = M.config
  local components = require('slimline.components')
  if type(component_name) == 'function' then
    return component_name
  elseif type(component_name) == 'string' then
    if components[component_name] then
      local sep = {
        left = config.sep.left,
        right = config.sep.right,
      }
      if config.sep.hide.first and component_position == "first" then
        sep.left = ''
      end
      if config.sep.hide.last and component_position == "last" then
        sep.right = ''
      end
      return function(...)
        return components[component_name](config, sep, ...)
      end
    else
      return function()
        return component_name
      end
    end
  end
  return function()
    return ''
  end
end

-- Concats resolved components with given spacing
---@param comps table
---@param spacing string
---@return string
function M.concat_components(comps, spacing)
  local result = ''
  local first = true
  for _, c_fn in ipairs(comps) do
    local space = spacing
    if first then
      space = ''
      first = false
    end
    if type(c_fn) == 'function' then
      result = result .. space .. c_fn()
    elseif type(c_fn) == 'string' then
      result = result .. space .. c_fn
    end
  end
  return result
end

--- Renders the statusline.
---@return string
function M.render()
  local config = M.config
  local components = M.resolved_components
  if not config or not (components.left or components.right or components.center) then
    return ''
  end

  local result = '%#Slimline#' .. config.spaces.left
  result = result .. M.concat_components(components.left, config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(components.center, config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(components.right, config.spaces.components)
  result = result .. config.spaces.right

  return result
end

-- Resolving components into a table
---@param comps table
---@param group_position string "left"|"center"|"right"
---@return table
local function resolve_components(comps, group_position)
  local result = {}
  for i, component in ipairs(comps) do
    local component_position = nil
    if i == 1 and group_position == "left" then
      component_position = "first"
    end
    if i == #comps and group_position == "right" then
      component_position = "last"
    end
    table.insert(result, resolve_component(component, component_position))
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

  -- Resolve component references
  M.resolved_components.left = resolve_components(opts.components.left, "left")
  M.resolved_components.center = resolve_components(opts.components.center, "center")
  M.resolved_components.right = resolve_components(opts.components.right, "right")

  vim.o.statusline = "%!v:lua.require'slimline'.render()"

  require('slimline.autocommands')
  require('slimline.usercommands')
end

return M
