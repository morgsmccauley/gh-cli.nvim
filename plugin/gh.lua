local function gh_command_handler(args)
  print("Command passed: " .. args.args)
end

local function gh_completion()
  local command_output = io.popen("gh __complete \"\"")
  local output_lines = {}
  for line in command_output:lines() do
    table.insert(output_lines, line)
  end
  command_output:close()

  return output_lines
end

vim.api.nvim_create_user_command("GH", gh_command_handler, {
  nargs = '*',
  complete = gh_completion
})
