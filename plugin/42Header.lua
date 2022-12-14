local plugin = require("main")
local cmd = vim.api.nvim_create_user_command

cmd('H42',
function(opts)
	print (opts["fargs"][1])
	if (table.getn(opts["fargs"]) > 1) then
		plugin.printError("invalid number of arguments")
		return
	end
	plugin.main(opts["fargs"][1])
end,
{desc = '42Header', nargs = '*'})
