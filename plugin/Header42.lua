local main = require("srcs.main")
local cmd = vim.api.nvim_create_user_command

cmd('Header42',
function()
	main.main()
end,
{desc = 'Header42'})
