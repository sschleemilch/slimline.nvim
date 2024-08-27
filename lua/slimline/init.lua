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
  if not comps then
    return ''
  end
  local result = ''
  local first = true
  for _, c_fn in ipairs(comps) do
    local space = spacing
    if first then
      space = ''
      first = false
    end
    local component_result = ''
    if type(c_fn) == 'function' then
      local status, output = pcall(c_fn)
      if status then
        component_result = output
      else
        -- Log the error but continue with other components
        vim.api.nvim_err_writeln('Slimline component error: ' .. tostring(output))
      end
    elseif type(c_fn) == 'string' then
      component_result = c_fn
    end
    result = result .. space .. component_result
  end
  return result
end

--- Renders the statusline.
---@return string
function M.render()
  local config = vim.g.slimline_config
  if not config or not (config.components.left or config.components.right or config.components.center) then
    return ''
  end

  -- Check if we're in a valid buffer
  if vim.fn.bufnr('%') == -1 then
    return ''
  end

  -- Wrap the statusline generation in pcall to catch any errors
  local status, result = pcall(function()
    local line = '%#Slimline#' .. config.spaces.left
    line = line .. M.concat_components(config.components.left, config.spaces.components)
    line = line .. '%='
    line = line .. M.concat_components(config.components.center, config.spaces.components)
    line = line .. '%='
    line = line .. M.concat_components(config.components.right, config.spaces.components)
    line = line .. config.spaces.right
    return line
  end)

  if status then
    return result
  else
    -- If an error occurred, return a simple statusline and log the error
    vim.api.nvim_err_writeln('Slimline error: ' .. tostring(result))
    return '%f %h%w%m%r %=%l,%c %P'
  end
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
  vim.g.slimline_config = opts
  local hl = require('slimline.highlights')
  hl.create(opts)
  vim.o.statusline = "%!v:lua.require'slimline'.render()"
end

--- Refreshes the line
--- To be called e.g. from autocommands
function M.refresh()
  -- Check if we're in a valid buffer
  if vim.fn.bufnr('%') == -1 or vim.fn.line('$') == 0 then
    return
  end

  -- Wrap the redrawstatus command in pcall to catch any errors
  local status, err = pcall(function()
    -- Ensure we're in a valid window
    if vim.fn.winnr('$') > 0 then
      local current_win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_is_valid(current_win) then
        vim.cmd.redrawstatus()
      end
    end
  end)

  if not status then
    -- Check if the error is E315
    if type(err) == 'string' and err:match('E315:') then
      -- Silently ignore E315 errors
      return
    else
      vim.api.nvim_err_writeln('Slimline refresh error: ' .. tostring(err))
    end
    -- Attempt to set a simple statusline as a fallback
    pcall(function()
      vim.o.statusline = '%f %h%w%m%r %=%l,%c %P'
    end)
  end
end

return M
