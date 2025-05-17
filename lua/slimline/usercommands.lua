---@class SlimlineSubcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

local seps = {
  left = nil,
  right = nil,
}

---@type table<string, SlimlineSubcommand>
local subcommand_tbl = {
  switch = {
    impl = function(args)
      if args[1] == 'style' then
        local sl = require('slimline')
        local cfg = sl.config
        if seps.left == nil then
          seps.left = cfg.sep.left
        end
        if seps.right == nil then
          seps.right = cfg.sep.right
        end
        if cfg.style == 'bg' then
          cfg.style = 'fg'
          seps.left = cfg.sep.left
          seps.right = cfg.sep.right
        else
          cfg.style = 'bg'
          cfg.sep.left = seps.left
          cfg.sep.right = seps.right
        end
        local slh = require('slimline.highlights')
        slh.hls_created = false
        sl.setup(cfg)
      else
        vim.notify('Slimline: unknown switch target: ' .. args[1], vim.log.levels.ERROR)
      end
    end,
    complete = function(subcmd_arg_lead)
      local switch_args = {
        'style',
      }
      return vim
        .iter(switch_args)
        :filter(function(switch_arg)
          return switch_arg:find(subcmd_arg_lead) ~= nil
        end)
        :totable()
    end,
  },
}

---@param opts table :h lua-guide-commands-create
local function slimline_cmd(opts)
  local fargs = opts.fargs
  local subcommand_key = fargs[1]
  -- Get the subcommand's arguments, if any
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local subcommand = subcommand_tbl[subcommand_key]
  if not subcommand then
    vim.notify('Slimline: Unknown command: ' .. subcommand_key, vim.log.levels.ERROR)
    return
  end
  -- Invoke the subcommand
  subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command('Slimline', slimline_cmd, {
  nargs = '+',
  desc = 'Slimline commands',
  complete = function(arg_lead, cmdline, _)
    -- Get the subcommand.
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Slimline[!]*%s(%S+)%s(.*)$")
    if subcmd_key and subcmd_arg_lead and subcommand_tbl[subcmd_key] and subcommand_tbl[subcmd_key].complete then
      -- The subcommand has completions. Return them.
      return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
    end
    -- Check if cmdline is a subcommand
    if cmdline:match("^['<,'>]*Slimline[!]*%s+%w*$") then
      -- Filter subcommands that match
      local subcommand_keys = vim.tbl_keys(subcommand_tbl)
      return vim
        .iter(subcommand_keys)
        :filter(function(key)
          return key:find(arg_lead) ~= nil
        end)
        :totable()
    end
  end,
  bang = false,
})
