local main = require("main")
local cmd = vim.api.nvim_create_user_command

cmd('H42',
function()
	main.main()
end,
{desc = '42Header'})
