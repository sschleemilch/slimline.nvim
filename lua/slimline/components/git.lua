local C = {}

local slimline = require('slimline')
local initialized = false

--- @class gitstatus
--- @field head string
--- @field added integer
--- @field changed integer
--- @field removed integer

--- @type gitstatus|nil
local status = nil

local function gitsigns()
  local s = vim.b.gitsigns_status_dict
  if not s then
    status = nil
    return
  end
  status = { head = s.head, added = s.added, removed = s.removed, changed = s.changed }
end

local function init()
  if initialized then return end
  slimline.au('User', 'MiniDiffUpdated', function(data)
    local summary = vim.b[data.buf].minidiff_summary
    status = { head = summary.source_name, added = summary.add, removed = summary.delete, changed = summary.change }
  end)
  initialized = true
end

---@param opts render.options
---@return string
function C.render(opts)
  init()
  -- gitsigns()
  if not status or not status.head then return '' end

  local icons = slimline.config.configs['git'].icons
  local head = string.format('%s %s', icons.branch, status.head)
  local modifications = status.added or status.removed or status.changed

  local mods = {}
  if modifications then
    if status.added > 0 then table.insert(mods, string.format('%s%s', icons.added, status.added)) end
    if status.changed > 0 then table.insert(mods, string.format('%s%s', icons.modified, status.changed)) end
    if status.removed > 0 then table.insert(mods, string.format('%s%s', icons.removed, status.removed)) end
  end
  return slimline.highlights.hl_component(
    { primary = head, secondary = table.concat(mods, ' ') },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active
  )
end

return C
