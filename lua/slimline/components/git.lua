local C = {}

local slimline = require('slimline')

local function get_branch_from_git()
  local handle = io.popen('git rev-parse --abbrev-ref HEAD 2>/dev/null')
  if not handle then return '' end
  local branch = handle:read('*a'):gsub('\n', '') or ''
  handle:close()
  return branch
end

---@param opts render.options
---@return string
function C.render(opts)
  local gitsigns = vim.b.gitsigns_status_dict
  local minidiff = vim.b.minidiff_summary

  local branch
  if gitsigns and gitsigns.head and gitsigns.head ~= '' then
    branch = gitsigns.head
  elseif vim.fn.exists('*FugitiveHead') == 1 then
    branch = vim.fn['FugitiveHead']()
  else
    branch = get_branch_from_git()
  end

  if not branch or branch == '' then return '' end

  local icons = slimline.config.configs['git'].icons

  local branch_display = string.format('%s %s', icons.branch, branch)

  local status = { added = 0, removed = 0, changed = 0 }

  if gitsigns and gitsigns.head and gitsigns.head ~= '' then
    status.added = gitsigns.added or 0
    status.removed = gitsigns.removed or 0
    status.changed = gitsigns.changed or 0
  elseif minidiff and minidiff.source_name and minidiff.source_name ~= '' then
    status.added = minidiff.add or 0
    status.removed = minidiff.delete or 0
    status.changed = minidiff.change or 0
  elseif vim.fn.exists('*GitGutterGetHunkSummary') == 1 then
    local gitgutter = vim.fn.GitGutterGetHunkSummary() or {}
    status.added = gitgutter[1] or 0
    status.changed = gitgutter[2] or 0
    status.removed = gitgutter[3] or 0
  end

  local mods = {}
  if status.added > 0 then table.insert(mods, string.format('%s%s', icons.added, status.added)) end
  if status.changed > 0 then table.insert(mods, string.format('%s%s', icons.modified, status.changed)) end
  if status.removed > 0 then table.insert(mods, string.format('%s%s', icons.removed, status.removed)) end

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
