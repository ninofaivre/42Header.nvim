local utils = (vim.g["42Header"]["Dev"]) and dofile("./lua/utils.lua") or require("lua.utils")
local plugin = (vim.g["42Header"]["Dev"]) and dofile("./lua/main.lua") or require("lua.main")
local cmd = vim.api.nvim_create_user_command

cmd('H42',
function(opts)
	if (#opts["fargs"] > 1) then
		utils.printError("invalid number of arguments")
		return
	end
	plugin.main(opts["fargs"][1])
end,
{desc = '42Header', nargs = '*'})
