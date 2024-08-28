local M = {}
local components = require('slimline.components')
local components_length = 0
local position = 0

--- Returns correct component from config
---@return function
---@param component_name string | function
---@param config table
local function resolve_component(component_name, config)
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
      if config.sep.hide.last and position == components_length then
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
  if not config or not (config.components.left or config.components.right or config.components.center) then
    return ''
  end

  local result = '%#Slimline#' .. config.spaces.left
  result = result .. M.concat_components(config.components.left, config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(config.components.center, config.spaces.components)
  result = result .. '%='
  result = result .. M.concat_components(config.components.right, config.spaces.components)
  result = result .. config.spaces.right

  return result
end

-- Resolving components into a table
---@param comps table
---@param opts table
---@return table
local function resolve_components(comps, opts)
  local result = {}
  for _, component in ipairs(comps) do
    table.insert(result, resolve_component(component, opts))
  end
  return result
end

---@param opts table
function M.setup(opts)
  if opts == nil then
    opts = {}
  end
  require('slimline.autocommands')
  vim.o.showmode = false
  opts = vim.tbl_deep_extend('force', require('slimline.default_config'), opts)
  if opts.style == 'fg' then
    opts.sep.left = ''
    opts.sep.right = ''
  end

  components_length = #opts.components.left + #opts.components.center + #opts.components.right

  -- Resolve component references
  opts.components.left = resolve_components(opts.components.left, opts)
  opts.components.center = resolve_components(opts.components.center, opts)
  opts.components.right = resolve_components(opts.components.right, opts)

  M.config = opts
  local hl = require('slimline.highlights')
  hl.create_hls()
  vim.o.statusline = "%!v:lua.require'slimline'.render()"
end

--- Refreshes the line
--- To be called e.g. from autocommands
function M.refresh()
  vim.cmd.redrawstatus()
end

return M
