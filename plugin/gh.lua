local function gh_command_handler(args)
  print("Command passed: " .. args.args)
end

local function gh_completion()
  return {}
end

vim.api.nvim_create_user_command("GH", gh_command_handler, {
  nargs = '*',
  complete = gh_completion
})
