local lazy = setmetatable({}, {
	__index = function(_, key)
		return require('' .. key)
	end
})

local function isThereAHeader ()
	local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)

	if (#oldHeader ~= 11) then
		return false
	end
	return ((oldHeader[8]:find("Created:")) and (oldHeader[9]:find("Updated:")))
end

local function getCreationTime ()
	if (not isThereAHeader ()) then
		return ''
	end
	local creationLine = vim.api.nvim_buf_get_lines(0, 7, 8, false)[1]
	return creationLine:sub(creationLine:find("20", 1, true), creationLine:find("20", 1, true) + 18)
end

local function getCreationUser ()
	if (not isThereAHeader ()) then
		return ''
	end
	local creationLine = vim.api.nvim_buf_get_lines(0, 7, 8, false)[1]
	creationLine = creationLine:sub(({creationLine:find("by ", 1, true)})[2] + 1)
	return creationLine:sub(0, creationLine:find(" ", 1, true) - 1)
end

local function genNewHeader()
	local env = require("env").get()
	local comment = env["comment"]
	local width = env["width"]
	local SELen = #comment["start"] + #comment["end"]
	local fileName = lazy.utils.shrink(vim.fn.expand("%:t"), width - (#env["logo"][2] + SELen + 3))
	local time = os.date("%Y/%m/%d %H:%M:%S") .. ''
	local mailUser = lazy.utils.shrink(env["mailUser"], width - (#env["logo"][4] + #env["mailDomain"] + #env["user"] + SELen + 11))
	local mailDomain = lazy.utils.shrink(env["mailDomain"], width - (#env["logo"][4] + #mailUser + #env["user"] + SELen + 11))
	local topUser = lazy.utils.shrink(env["user"], width - (#env["logo"][4] + #mailUser + #mailDomain + SELen + 11))
	local botUser = lazy.utils.shrink(env["user"], width - (#env["logo"][7] + #time + SELen + 16))
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][1] + SELen + 4)) .. env["logo"][1] .. "    " .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#env["logo"][2] + #fileName + SELen + 7)) .. env["logo"][2] .. "    " .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][3] + SELen + 4)) .. env["logo"][3] .. "    " .. comment["end"],
		comment["start"] .. "   By: " .. topUser .. " <" .. mailUser .. "@" .. mailDomain .. ">"
			.. string.rep(" ", (width - (#env["logo"][4] + #topUser + #mailUser + #mailDomain + SELen + 15))) .. env["logo"][4] .. "    " .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][5] + SELen + 4)) .. env["logo"][5] .. "    " .. comment["end"],
		comment["start"] .. "   Created: " .. time .. " by " .. botUser .. string.rep(" ", width - (#env["logo"][6] + #time + #botUser + SELen + 20)) .. env["logo"][6] .. "    " .. comment["end"],
		comment["start"] .. "   Updated: " .. time .. " by " .. botUser .. string.rep(" ", width - (#env["logo"][7] + #time + #botUser + SELen + 20)) .. env["logo"][7] .. "    " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
	}
	if (isThereAHeader()) then
		header[8] = header[8]:gsub(time, getCreationTime(), 1)
		if (#getCreationUser() <= #botUser) then
			header[8] = header[8]:gsub(botUser:gsub("%+", "%%+"), getCreationUser() .. string.rep(" ", #botUser - #getCreationUser()), 1)
		elseif (botUser == '+' or botUser[#botUser] == '+') then
			header[8] = header[8]:gsub(botUser:sub(1, #botUser - 1), getCreationUser():sub(1, #botUser - 1), 1)
		else
			header[8] = header[8]:gsub(botUser .. string.rep(" ", #getCreationUser() - #botUser), getCreationUser(), 1)
		end
	end
	return header
end

local function writeHeader(updateOnly)
	if (not isThereAHeader() and updateOnly) then
		return
	end
	local header = genNewHeader()
	if (isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
	else
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	end
end

local function print()
	print("current user settings :\n", "\n" .. lazy.utils.getUserSettingsStr())
end

local function yank()
	local currentSettings = '-- Awesome 42Header nvim plugin user settings :\n' .. lazy.utils.getUserSettingsStr() .. '\n'
	vim.fn.setreg('"', currentSettings)
	vim.fn.setreg('+', '```lua\n' .. currentSettings .. '```') -- only work on linux
	print ("current settings yanked")
end

local function easterEgg()
	print("easter egg")
end

local function updateOnly()
	writeHeader (true)
end

return
{
	print = print,
	yank = yank,
	["42"] = easterEgg,
	writeHeader = writeHeader,
	updateOnly = updateOnly
}
