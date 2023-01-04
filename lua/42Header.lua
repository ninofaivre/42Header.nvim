local lazy = setmetatable({}, {
	__index = function(_, key)
		return require('' .. key)
	end
})

local function main (arg)
	if (not arg) then
		lazy.cmd["writeHeader"](false)
		return
	end
	if (lazy.cmd[arg]) then
		lazy.cmd[arg]()
		return
	end
	print ("error unknown command")
end

return
{
	setup = lazy.userSettings.set,
	update = lazy.userSettings.update,
	main = main,
	print = lazy.userSettings.print
}
