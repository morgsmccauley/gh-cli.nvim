local Job = require('plenary.job')

local function gh_command_handler(args)
  print("Command passed: " .. args.args)
end

local function fetch_reviewers()
  local query = [[
    {
      organization(login: "near") {
        membersWithRole(first:10) {
          nodes {
            login
          }
        }
      }
    }
  ]]

  local reviewers = {}

  Job:new({
    command = 'gh',
    args = {
      'api',
      'graphql',
      '-f',
      'query=' .. query,
      '--jq=.data.organization.membersWithRole.nodes[].login'
    },
    on_stdout = function(_err, data)
      table.insert(reviewers, data)
    end,
  }):sync()

  return reviewers
end

local cache = {}

local function gh_completion(lead, line)
  local output_lines = {}

  local args = {}
  for arg in line:gmatch('%S+') do
    if arg ~= 'GH' then
      table.insert(args, arg)
    end
  end

  if #args == 0 or lead == '' then
    table.insert(args, '')
  end

  if args[#args] == '--reviewer' or args[#args] == '' and args[#args - 1] == '--reviewer' then
    return fetch_reviewers()
  end

  if cache[#args] then
    -- remove previously cached subcommands to avoid re-showing them
    table.remove(cache, #args + 1)
    return cache[#args]
  end

  Job:new({
    command = 'gh',
    args = { '__complete', unpack(args) },
    on_stdout = function(_, line)
      if line:sub(1, 1) == ":" then
        return
      end
      local command = line:match('^(%S+)')
      print('hi', command)
      if command then
        table.insert(output_lines, command)
      end
    end,
    on_exit = function()
      print('called')
      cache[#args] = output_lines
    end
  }):sync()

  return output_lines
end

vim.api.nvim_create_user_command("GH", gh_command_handler, {
  nargs = '*',
  complete = gh_completion
})
