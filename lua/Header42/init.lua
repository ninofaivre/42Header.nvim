local M = {}
M.setup = function ()
	local main = require("Header42.srcs.main")
	local cmd = vim.api.nvim_create_user_command

	cmd('Header42',
	function()
		require("main").main()
	end,
	{desc = 'Header42'})
end
return M
