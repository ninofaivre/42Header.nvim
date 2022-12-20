--local plugin = require("main")
local utils = (vim.g["42HeaderDev"]) and dofile("./lua/utils.lua") or require("utils")
local cmd = vim.api.nvim_create_user_command

cmd('H42',
function(opts)
	local plugin = (vim.g["42HeaderDev"]) and dofile("./lua/main.lua") or require("main.lua")
	if (#opts["fargs"] > 1) then
		utils.printError("invalid number of arguments")
		return
	end
	plugin.main(opts["fargs"][1])
end,
{desc = '42Header', nargs = '*'})
