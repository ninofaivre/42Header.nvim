vim.api.nvim_create_user_command('H42',
function(opts)
	if (#opts["fargs"] > 1) then
		print ("error too many args")
		return
	end
	require('42Header').main(opts["fargs"][1])
end,
{desc = '42Header', nargs = '*'})
