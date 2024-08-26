local M = {}
local components = require('slimline.components')

--- Returns correct component from config
---@return function
---@param component_name string | function
---@param config table
local function resolve_component(component_name, config)
  if type(component_name) == 'function' then
    return component_name
  elseif type(component_name) == 'string' then
    if components[component_name] then
      return function(...)
        return components[component_name](config, ...)
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

--- Renders the statusline.
---@return string
function M.render()
  local config = vim.g.slimline_config
  if not config or not config.resolved_components then
    return ''
  end

  local result = '%#Slimline#' .. config.spaces.left
  -- call the functions in resolved_components and add them to the statusline string
  for _, component_func in ipairs(config.resolved_components) do
    if type(component_func) == 'function' then
      result = result .. component_func()
    elseif type(component_func) == 'string' then
      result = result .. component_func
    end
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
  -- Resolve component references
  local resolved_components = {}
  for _, component in ipairs(opts.components) do
    table.insert(resolved_components, resolve_component(component, opts))
  end
  opts.resolved_components = resolved_components

  vim.g.slimline_config = opts
  local hl = require('slimline.highlights')
  hl.create(opts)
  vim.o.statusline = "%!v:lua.require'slimline'.render()"
end

--- Refreshes the line
--- To be called e.g. from autocommands
function M.refresh()
  vim.cmd.redrawstatus()
end

return M
