local config = vim.g.slimline_config
local highlights = require('slimline.highlights')
local M = {}

--- Function to translate a mode into a string to show
--- @return string
function M.get_mode()
  -- Note that: \19 = ^S and \22 = ^V.
  local mode_map = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP-PENDING',
    ['nov'] = 'OP-PENDING',
    ['noV'] = 'OP-PENDING',
    ['no\22'] = 'OP-PENDING',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['nt'] = 'NORMAL',
    ['ntT'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['vs'] = 'VISUAL',
    ['V'] = 'VISUAL',
    ['Vs'] = 'VISUAL',
    ['\22'] = 'VISUAL',
    ['\22s'] = 'VISUAL',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    ['\19'] = 'SELECT',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rx'] = 'REPLACE',
    ['Rv'] = 'VIRT REPLACE',
    ['Rvc'] = 'VIRT REPLACE',
    ['Rvx'] = 'VIRT REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'VIM EX',
    ['ce'] = 'EX',
    ['r'] = 'PROMPT',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERMINAL',
  }

  local mode = mode_map[vim.api.nvim_get_mode().mode] or 'UNKNOWN'
  return mode
end

--- Function to get the highlight of a given mode
--- @param mode string
--- @return string
function M.get_mode_hl(mode)
  local hl = config.hl.secondary
  local hl_name = 'Secondary'
  if mode == 'NORMAL' then
    hl = config.hl.modes.normal
    hl_name = 'Normal'
  elseif mode:find('PENDING') then
    hl = config.hl.modes.pending or hl
    hl_name = 'Pending'
  elseif mode:find('VISUAL') then
    hl = config.hl.modes.visual or hl
    hl_name = 'Visual'
  elseif mode:find('INSERT') or mode:find('SELECT') then
    hl = config.hl.modes.insert or hl
    hl_name = 'Insert'
  elseif mode:find('COMMAND') or mode:find('TERMINAL') or mode:find('EX') then
    hl = config.hl.modes.command or hl
    hl_name = 'Command'
  end
  return highlights.get_or_create(hl_name .. 'Mode', hl, true, config.bold)
end

--- Mode component
--- @param mode string
--- @return string
function M.mode(mode)
  local render = mode
  if config.verbose_mode == false then
    render = string.sub(mode, 1, 1)
  end
  local content = ' ' .. render .. ' '
  return highlights.highlight_content(content, M.get_mode_hl(mode), config.sep.left, config.sep.right)
end

--- Git component showing branch
--- as well as changed, added and removed lines
--- Using gitsigns for it
--- @return string
function M.git()
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end
  if not status.head or status.head == '' then
    return ''
  end

  local added = status.added and status.added > 0
  local removed = status.removed and status.removed > 0
  local changed = status.changed and status.changed > 0
  local modifications = added or removed or changed

  local branch = string.format(' %s %s ', config.icons.git.branch, status.head)
  branch = highlights.highlight_content(branch, highlights.hls.primary.text, config.sep.left)
  local branch_hl_right_sep = highlights.hls.primary.sep
  if modifications then
    branch_hl_right_sep = highlights.hls.primary.sep_transition
  end
  branch = branch .. highlights.highlight_content(config.sep.right, branch_hl_right_sep)

  local mods = ''
  if modifications then
    if added then
      mods = mods .. string.format(' +%s', status.added)
    end
    if changed then
      mods = mods .. string.format(' ~%s', status.changed)
    end
    if removed then
      mods = mods .. string.format(' -%s', status.removed)
    end
    mods = highlights.highlight_content(mods .. ' ', highlights.hls.secondary.text, nil, config.sep.right)
  end
  return branch .. mods
end

--- Path component
--- Displays directory and file seperately
--- @return string
function M.path()
  local file =
    highlights.highlight_content(' ' .. vim.fn.expand('%:t') .. ' %m%r', highlights.hls.primary.text, config.sep.left)
  file = file .. highlights.highlight_content(config.sep.right, highlights.hls.primary.sep_transition)

  local path = vim.fs.normalize(vim.fn.expand('%:.:h'))
  if #path == 0 then
    return ''
  end
  path = highlights.highlight_content(
    ' ' .. config.icons.folder .. path .. ' ',
    highlights.hls.secondary.text,
    nil,
    config.sep.right
  )

  return file .. path
end

local last_diagnostic_component = ''
--- Diagnostics component
--- @return string
function M.diagnostics()
  -- Lazy uses diagnostic icons, but those aren"t errors per se.
  if vim.bo.filetype == 'lazy' then
    return ''
  end

  -- Use the last computed value if in insert mode.
  if vim.startswith(vim.api.nvim_get_mode().mode, 'i') then
    return last_diagnostic_component
  end

  local counts = vim.iter(vim.diagnostic.get(0)):fold({
    ERROR = 0,
    WARN = 0,
    HINT = 0,
    INFO = 0,
  }, function(acc, diagnostic)
    local severity = vim.diagnostic.severity[diagnostic.severity]
    acc[severity] = acc[severity] + 1
    return acc
  end)

  local parts = vim
    .iter(counts)
    :map(function(severity, count)
      if count == 0 then
        return nil
      end

      return string.format('%s%d', config.icons.diagnostics[severity], count)
    end)
    :totable()

  last_diagnostic_component = table.concat(parts, ' ')
  if last_diagnostic_component == '' then
    return ''
  end
  last_diagnostic_component = highlights.highlight_content(
    ' ' .. last_diagnostic_component .. ' ',
    highlights.hls.primary.text,
    config.sep.left,
    config.sep.right
  )
  return last_diagnostic_component
end

--- Filetype and attached LSPs component
function M.filetype_lsp()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[No Name]'
  end
  local icon = ""
  local status, MiniIcons = pcall(require, 'mini.icons')
  if status then
    icon = ' ' .. MiniIcons.get('filetype', filetype)
  end
  filetype = highlights.highlight_content(
    icon .. ' ' .. filetype .. ' ',
    highlights.hls.primary.text,
    nil,
    config.sep.right
  )

  local attached_clients = vim.lsp.get_clients { bufnr = 0 }
  local it = vim.iter(attached_clients)
  it:map(function(client)
    local name = client.name:gsub('language.server', 'ls')
    return name
  end)
  local names = it:totable()
  local lsp_clients = string.format('%s', table.concat(names, ','))

  local filetype_hl_sep_left = highlights.hls.primary.sep
  if #attached_clients > 0 then
    filetype_hl_sep_left = highlights.hls.primary.sep_transition
  end
  filetype = highlights.highlight_content(config.sep.left, filetype_hl_sep_left) .. filetype
  lsp_clients = highlights.highlight_content(' ' .. lsp_clients .. ' ', highlights.hls.secondary.text, config.sep.left)

  local result = filetype
  if #attached_clients > 0 then
    result = lsp_clients .. result
  end
  return result
end

--- File progress component
--- @return string
function M.progress(mode)
  local cur = vim.fn.line('.')
  local total = vim.fn.line('$')
  local content = ''
  if cur == 1 then
    content = 'Top'
  elseif cur == total then
    content = 'Bot'
  else
    content = string.format('%2d%%%%', math.floor(cur / total * 100))
  end
  content = string.format(' %s %s / %s ', config.icons.lines, content, total)
  return highlights.highlight_content(content, M.get_mode_hl(mode), config.sep.left, config.sep.right)
end

return M
