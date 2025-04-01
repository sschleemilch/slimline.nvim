local M = {}

local highlights = require('slimline.highlights')
local utils = require('slimline.utils')

---@alias Component function

---@type table<string, Component[]>
M.components = {
  left = {},
  center = {},
  right = {},
}

---@param component string
---@return table
local function get_sep(component)
  local sep = {
    left = M.config.sep.left,
    right = M.config.sep.right,
  }
  local style = M.config.style

  if M.config.configs[component] and M.config.configs[component].style ~= nil then
    style = M.config.configs[component].style
  end
  if style == 'fg' then
    sep.left = ''
    sep.right = ''
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
    local exist, component_module = pcall(require, string.format('slimline.components.%s', component))
    if exist then
      if M.config.configs[component].follow then
        component = M.config.configs[component].follow
      end
      local sep = get_sep(component)
      if M.config.sep.hide.first and position == 'first' then
        sep.left = ''
      end
      if M.config.sep.hide.last and position == 'last' then
        sep.right = ''
      end
      local hls = highlights.hls.components[component]
      return function(...)
        if component == 'mode' then
          hls = highlights.get_mode_hl(utils.get_mode())
        end
        return component_module.render(sep, direction, hls, ...)
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

---Migrate options between versions and notify about deprecated options
---@param opts table
local function migrate_opts(opts)
  local warnings = {}

  if opts.verbose_mode ~= nil then
    opts.configs.mode.verbose = opts.verbose_mode
    table.insert(warnings, '`verbose_mode` deprecated. Use `configs.mode.verbose` instead.')
  end

  if opts.mode_follow_style ~= nil then
    if opts.mode_follow_style == true then
      opts.configs.mode.style = opts.style
    else
      opts.configs.mode.style = 'bg'
    end
    table.insert(warnings, '`mode_follow_style` deprecated. Use `configs.mode.style` instead.')
  end

  if opts.workspace_diagnostics ~= nil then
    opts.configs.diagnostics.workspace = opts.workspace_diagnostics
    table.insert(warnings, '`workspace_diagnostics` deprecated. Use `configs.diagnostics.workspace` instead.')
  end

  if opts.icons ~= nil then
    table.insert(warnings, '`icons` deprecated. Use `configs.<component>.icon(s)` instead.')
    if opts.icons.diagnostics then
      opts.configs.diagnostics.icons =
        vim.tbl_deep_extend('force', opts.configs.diagnostics.icons, opts.icons.diagnostics)
    end
    if opts.icons.git then
      opts.configs.git.icons = opts.icons.git
    end
    if opts.icons.folder then
      opts.configs.path.icons.folder = opts.icons.folder
    end
    if opts.icons.lines then
      opts.configs.progress.icon = opts.icons.lines
    end
    if opts.icons.recording then
      opts.configs.recording.icon = opts.icons.recording
    end
    if opts.icons.buffer then
      if opts.icons.buffer.modified then
        opts.configs.path.icons.modified = opts.icons.buffer.modified
      end
      if opts.icons.buffer.read_only then
        opts.configs.path.icons.read_only = opts.icons.buffer.read_only
      end
    end
  end

  if opts.hl.modes then
    table.insert(warnings, '`hl.modes` deprecated. Use `configs.mode.hl` instead.')
    opts.configs.mode.hl = opts.hl.modes
  end

  if #warnings > 0 then
    table.insert(
      warnings,
      '\nSee [here](https://github.com/sschleemilch/slimline.nvim/blob/main/lua/slimline/defaults.lua) for reference'
    )
    vim.notify(table.concat(warnings, '\n'), vim.log.levels.WARN, {
      title = 'slimline.nvim',
    })
  end
end

---@param opts table
function M.setup(opts)
  if opts == nil then
    opts = {}
  end

  if vim.o.showmode == true then
    vim.o.showmode = false
  end

  opts = vim.tbl_deep_extend('force', require('slimline.defaults'), opts)

  migrate_opts(opts)

  M.config = opts

  highlights.create_hls()

  M.components.left = get_components(opts.components.left, 'left')
  M.components.center = get_components(opts.components.center, 'center')
  M.components.right = get_components(opts.components.right, 'right')

  vim.o.statusline = "%!v:lua.require'slimline'.render()"

  require('slimline.autocommands')
  require('slimline.usercommands')
end

return M
