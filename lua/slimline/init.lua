local M = {}

M.resolved_components = {
  left = {},
  center = {},
  right = {}
}

--- Keep track of resolve component position
local position = 0

--- Returns correct component from config
---@return function
---@param component_name string | function
---@param n_components integer
---@param config table
local function resolve_component(component_name, config, n_components)
  local components = require('slimline.components')
  position = position + 1
  if type(component_name) == 'function' then
    return component_name
  elseif type(component_name) == 'string' then
    if components[component_name] then
      local sep = {
        left = config.sep.left,
        right = config.sep.right,
      }
      if config.sep.hide.first and position == 1 then
        sep.left = ''
      end
      if config.sep.hide.last and position == n_components then
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
---comment
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
---@param opts table
---@param n_components integer
---@return table
local function resolve_components(comps, opts, n_components)
  local result = {}
  for _, component in ipairs(comps) do
    table.insert(result, resolve_component(component, opts, n_components))
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

  local n_components = #opts.components.left + #opts.components.center + #opts.components.right
  -- Resolve component references
  M.resolved_components.left = resolve_components(opts.components.left, opts, n_components)
  M.resolved_components.center = resolve_components(opts.components.center, opts, n_components)
  M.resolved_components.right = resolve_components(opts.components.right, opts, n_components)

  vim.o.statusline = "%!v:lua.require'slimline'.render()"

  require('slimline.autocommands')
end

return M
