local C = {}

local slimline = require('slimline')

local initialized = false

--- @type function(): string?
local get_branch = function() return nil end

--- @class gitdiff
--- @field added integer
--- @field removed integer
--- @field changed integer

--- @type function(): gitdiff
local get_diff = function() return { added = 0, removed = 0, changed = 0 } end

local function init_provider_gitsigns()
  get_branch = function()
    local status = vim.b.gitsigns_status_dict
    if status and status.head then return status.head end
  end
  get_diff = function()
    local status = vim.b.gitsigns_status_dict
    local diff = { added = 0, removed = 0, changed = 0 }
    if status and status.head then
      diff.added = status.added or 0
      diff.removed = status.removed or 0
      diff.changed = status.changed or 0
    end
    return diff
  end
end

local function init()
  if initialized then return end
  initialized = true

  local ok, _ = pcall(require, 'gitsigns')
  if ok then
    init_provider_gitsigns()
    return
  end

  if vim.fn.exists('*FugitiveHead') == 1 then
    get_branch = function() return vim.fn['FugitiveHead']() end
  end

  ok, _ = pcall(require, 'mini.diff')
  if ok then
    get_diff = function()
      local status = vim.b.minidiff_summary
      local diff = { added = 0, removed = 0, changed = 0 }
      if status and status.source_name and status.source_name ~= '' then
        diff.added = status.add or 0
        diff.removed = status.delete or 0
        diff.changed = status.change or 0
      end
      return diff
    end
  elseif vim.fn.exists('*GitGutterGetHunkSummary') == 1 then
    get_diff = function()
      local status = vim.fn.GitGutterGetHunkSummary() or {}
      local diff = { added = 0, removed = 0, changed = 0 }
      diff.added = status[1] or 0
      diff.changed = status[2] or 0
      diff.removed = status[3] or 0
      return diff
    end
  end
end

---@param opts render.options
---@return string
function C.render(opts)
  init()

  local branch = get_branch()
  if not branch or branch == '' then return '' end

  local icons = slimline.config.configs['git'].icons

  local branch_display = string.format('%s %s', icons.branch, branch)

  local status = get_diff()

  local mods = {}
  if status then
    if status.added and status.added > 0 then table.insert(mods, string.format('%s%s', icons.added, status.added)) end
    if status.changed and status.changed > 0 then
      table.insert(mods, string.format('%s%s', icons.modified, status.changed))
    end
    if status.removed and status.removed > 0 then
      table.insert(mods, string.format('%s%s', icons.removed, status.removed))
    end
  end

  return slimline.highlights.hl_component(
    { primary = branch_display, secondary = #mods > 0 and table.concat(mods, ' ') or '' },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
end

return C
