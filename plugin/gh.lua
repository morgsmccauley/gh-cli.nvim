local Job = require('plenary.job')

local function gh_command_handler(args)
  print("Command passed: " .. args.args)
end

local function gh_completion()
  local output_lines = {}

  local job = Job:new({
    command = 'gh',
    args = { '__complete', '' },
    on_stdout = function(_, line)
      if line:sub(1, 1) == ":" then
        return
      end
      local command = line:match('^(%S+)')
      if command then
        table.insert(output_lines, command)
      end
    end
  })

  job:sync()

  return output_lines
end

vim.api.nvim_create_user_command("GH", gh_command_handler, {
  nargs = '*',
  complete = gh_completion
})
