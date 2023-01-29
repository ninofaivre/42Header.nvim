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
	local background = creationLine:sub(creationLine:find("by", 1, true) - 1, creationLine:find("by", 1, true) - 1)
	creationLine = creationLine:sub(({creationLine:find("by", 1, true)})[2] + 2)
	return creationLine:sub(0, creationLine:find(background, 1, true) - 1)
end

local function genNewHeader()
	local env = lazy.env.get()
	local bg = env["background"]
	local comment = env["comment"]
	local width = env["width"]
	local SELen = #comment["start"] + #comment["end"]
	local fileName = lazy.utils.shrink(vim.fn.expand("%:t"), width - (#env["logo"][2] + SELen + 7))
	local time = os.date("%Y/%m/%d %H:%M:%S"):gsub(" ", bg)
	local mailUser = lazy.utils.shrink(env["mailUser"], width - (#env["logo"][4] + #env["mailDomain"] + #env["user"] + SELen + 16))
	local mailDomain = lazy.utils.shrink(env["mailDomain"], width - (#env["logo"][4] + #mailUser + #env["user"] + SELen + 16))
	local topUser = lazy.utils.shrink(env["user"], width - (#env["logo"][4] + #mailUser + #mailDomain + SELen + 16))
	local botUser = lazy.utils.shrink(env["user"], width - (#env["logo"][7] + #time + SELen + 21))
	local topBotBorder = string.rep(comment["fill"] ~= "" and comment["fill"] or env["background"], width - (SELen + 2)):sub(1, width - (SELen + 2))
	local header =
	{
		comment["start"] .. bg .. topBotBorder .. bg .. comment["end"],
		comment["start"] .. string.rep(bg, width - SELen) .. comment["end"],
		comment["start"] .. string.rep(bg, width - (#env["logo"][1] + SELen + 4)) .. env["logo"][1] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, 3) .. fileName .. string.rep(bg, width - (#env["logo"][2] + #fileName + SELen + 7)) .. env["logo"][2] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, width - (#env["logo"][3] + SELen + 4)) .. env["logo"][3] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, 3) .. "By:" .. bg .. topUser .. bg .. "<" .. mailUser .. "@" .. mailDomain .. ">" .. string.rep(bg, (width - (#env["logo"][4] + #topUser + #mailUser + #mailDomain + SELen + 15))) .. env["logo"][4] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, width - (#env["logo"][5] + SELen + 4)) .. env["logo"][5] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, 3) .. "Created:" .. bg .. time .. bg .. "by" .. bg .. botUser .. string.rep(bg, width - (#env["logo"][6] + #time + #botUser + SELen + 20)) .. env["logo"][6] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, 3) .. "Updated:" .. bg .. time .. bg .. "by" .. bg .. botUser .. string.rep(bg, width - (#env["logo"][7] + #time + #botUser + SELen + 20)) .. env["logo"][7] .. string.rep(bg, 4) .. comment["end"],
		comment["start"] .. string.rep(bg, width - SELen) .. comment["end"],
		comment["start"] .. bg .. topBotBorder .. bg .. comment["end"],
	}
	if (isThereAHeader()) then
		header[8] = header[8]:gsub(time, getCreationTime(), 1)
		if (#getCreationUser() <= #botUser) then
			header[8] = header[8]:gsub(botUser:gsub("%+", "%%+"), getCreationUser() .. string.rep(bg, #botUser - #getCreationUser()), 1)
		elseif (botUser == '+' or botUser[#botUser] == '+') then
			header[8] = header[8]:gsub(botUser:sub(1, #botUser - 1), getCreationUser():sub(1, #botUser - 1), 1)
		else
			header[8] = header[8]:gsub(botUser .. string.rep(bg, #getCreationUser() - #botUser), getCreationUser(), 1)
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

local function printUserSettings()
	print('vim.g["42Header"] =\n' .. vim.inspect(vim.g["42Header"]))
end

local function yankUserSettings()
	local currentSettings = '-- Awesome 42Header nvim plugin user settings :\n' .. 'vim.g["42Header"] =\n' .. vim.inspect(vim.g["42Header"]) .. '\n'
	-- I feel dumb doing this by hand but can't find a way with lua pattern
	local f = currentSettings:find("\n")
	while f do
		while currentSettings:sub(f + 1, f + 1) == " " and currentSettings:sub(f + 2, f + 2) == " " do
			currentSettings = currentSettings:sub(0, f) .. "\t" .. currentSettings:sub(f + 3)
			f = f + 1
		end
		f = currentSettings:find("\n", f + 1)
	end
	vim.fn.setreg('"', currentSettings)
	vim.fn.setreg('+', '```lua\n' .. currentSettings .. '```')
	print ("current settings yanked")
end

local function easterEgg()
	print("3 + 4 + 5 + 6 + 7 + 8 + 9")
end

local function updateOnly()
	writeHeader (true)
end

return
{
	print = printUserSettings,
	yank = yankUserSettings,
	["42"] = easterEgg,
	writeHeader = writeHeader,
	updateOnly = updateOnly
}
