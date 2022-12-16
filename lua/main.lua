-- ------------------------------------------------------------------------------------ <3
--                                                                                      <3
--                                                                 :::      ::::::::    <3
--   main.lua                                                    :+:      :+:    :+:    <3
--                                                             +:+ +:+         +:+      <3
--   By: nfaivre <nfaivre@student.42.fr>                     +#+  +:+       +#+         <3
--                                                         +#+#+#+#+#+   +#+            <3
--   Created: 2022/12/13 12:07:46 by nfaivre                    #+#    #+#              <3
--   Updated: 2022/12/15 00:13:38 by nfaivre                   ###   ########.zz        <3
--                                                                                      <3
-- ------------------------------------------------------------------------------------ <3
local M = {}

-- TODO
-- split in to file / sanitize
-- mode to ensure the norm compliance (override wrong setting if needed to ensure it)
-- auto width, let user go under 80 width ensure a minimum width depend of SELen
-- let user set Header42Height and Header42Logo

local user, mail, mailUser, mailDomain, width, countryCode, commentTable, logo

M.printError = function (err)
	vim.api.nvim_err_writeln("42Header : " .. err)
end

function mapSize (map)
	local size = 0
	for _ in pairs(map) do
		size = size + 1
	end
	return size
end

local validCommentTableParams =
{
	["required"] = { ["start"] = nil, ["fill"] = nil, ["end"] = nil },
	["authorized"] = { ["width"] = nil }
}

local function areCommentTableParamsValid(params)
	for k, _ in pairs(validCommentTableParams["required"]) do
		if (not params[k]) then
			return false
		end
		for k, _ in pairs(params) do
			if (not validCommentTableParams["required"][k] and not validCommentTableParams["authorized"][k]) then
				return false
			end
		end
	end
	return true
end

local function getUserCommentTable()
	if (not vim.g["commentTable"]) then
		return
	end
	local userCommentTable = {}
	for k, v in pairs(vim.g["commentTable"]) do
		if (k and v and areCommentTableParamsValid(v)) then
			userCommentTable[k] = v
		else
			M.printError('vim.g["commentTable"][' .. k .. '] is not valid')
		end
	end
	return userCommentTable
end

local function updateEnv ()
	user = vim.g["42user"] or "marvin"

	width = vim.g["42HeaderWidth"] or 80
	if (not tonumber(width) or width < 80) then
		width = 80
		M.printError ("invalid width, using default : 80")
	end

	countryCode = vim.g["countryCode"] or "fr"
	if (#countryCode ~= 2) then
		countryCode = "fr"
		M.printError ("invalid country code, using default : \"fr\"")
	end

	mail = vim.g["42mail"] or user .. "@studen.42." .. countryCode
	if (not mail:find("@", 1, true)) then
		mail = user .. "@student.42." .. countryCode
		M.printError ("invalid mail provided, using default : \"" .. user .. "@student.42." .. countryCode .. "\"")
	end
	mailUser = mail:sub(1, mail:find("@", 1, true) - 1)
	mailDomain = mail:sub(mail:find("@", 1, true) + 1)

	logo =
	{
		"        :::      ::::::::    ",
		"      :+:      :+:    :+:    ",
		"    +:+ +:+         +:+      ",
		"  +#+  +:+       +#+         ",
		"+#+#+#+#+#+   +#+            ",
		"     #+#    #+#              ",
		"    ###   ########." .. countryCode .. "        "
	}

	commentTable =
	{
		lua		= { start = "--[[", fill = "-", ["end"] = "]]--" },
		html	= { start = "<!--", fill = "-", ["end"] = "-->" },
		rb		= { start = "=begin", fill = "#", ["end"] = "=end" },
		hs		= { start = "{-", fill = "-", ["end"] = "-}" }
	}
	for k, v in pairs({"c", "h", "cpp", "hpp", "js", "ts", "go", "java", "php", "rs", "sc", "css"}) do
		commentTable[v] = { start = "/*", fill = "*", ["end"] = "*/" }
	end
	for k, v in pairs({"default", "sh", "bash", "py", "zsh", "ksh", "csh", "tcsh", "pdksh"}) do
		commentTable[v] = { start = "#", fill = "#", ["end"] = "#" }
	end
	for k, v in pairs(getUserCommentTable()) do
		commentTable[k] = v
	end
end

local function isThereAHeader ()
	local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)
	if (table.getn(oldHeader) ~= 11) then
		return false
	end
	for i = 1, 6 do
		if (not oldHeader[i + 2]:find(logo[i], 1, true)) then
			return false
		end
	end
	return oldHeader[9]:find(logo[7]:sub(1, logo[7]:find("."), 1, true)) and true or false
end

local function getCreationTime ()
	if (not isThereAHeader ()) then
		return
	end
	local creationLine = vim.api.nvim_buf_get_lines(0, 7, 8, false)[1]
	return creationLine:sub(creationLine:find("20", 1, true), creationLine:find("20", 1, true) + 18)
end

local function getCreationUser ()
	if (not isThereAHeader ()) then
		return
	end
	local creationLine = vim.api.nvim_buf_get_lines(0, 7, 8, false)[1]
	creationLine = creationLine:sub(({creationLine:find("by ", 1, true)})[2] + 1)
	return creationLine:sub(0, creationLine:find(" ", 1, true) - 1)
end

local function shrink(toShrink, maxLen)
	maxLen = (maxLen <= 0) and 1 or maxLen
	toShrink = (#toShrink > maxLen) and toShrink:sub(1, maxLen - 1) .. "+" or toShrink
	return toShrink
end

local function genNewHeader()
	local comment = commentTable[vim.fn.expand("%:e")] or commentTable["default"]
	width = comment["width"] or width
	local SELen = #comment["start"] + #comment["end"]
	local fileName = shrink(vim.fn.expand("%:t"), width - (#logo[2] + SELen + 3))
	local time = os.date("%Y/%m/%d %H:%M:%S")
	mailUser = shrink(mailUser, width - (#logo[4] + #mailDomain + #user + SELen + 11))
	mailDomain = shrink(mailDomain, width - (#logo[4] + #mailUser + #user + SELen + 11))
	local topUser = shrink(user, width - (#logo[4] + #mailUser + #mailDomain + SELen + 11))
	local botUser = shrink(user, width - (#logo[7] + #time + SELen + 16))
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[1] + SELen)) .. logo[1] .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#logo[2] + #fileName + SELen + 3)) .. logo[2] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[3] + SELen)) .. logo[3] .. comment["end"],
		comment["start"] .. "   By: " .. topUser .. " <" .. mailUser .. "@" .. mailDomain .. ">"
			.. string.rep(" ", (width - (#logo[4] + #topUser + #mailUser + #mailDomain + SELen + 11))) .. logo[4] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[5] + SELen)) .. logo[5] .. comment["end"],
		comment["start"] .. "   Created: " .. time .. " by " .. botUser .. string.rep(" ", width - (#logo[6] + #time + #botUser + SELen + 16)) .. logo[6] .. comment["end"],
		comment["start"] .. "   Updated: " .. time .. " by " .. botUser .. string.rep(" ", width - (#logo[7] + #time + #botUser + SELen + 16)) .. logo[7] .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
	}
	if (isThereAHeader()) then
		header[8] = header[8]:gsub(time, getCreationTime(), 1)
		if (#getCreationUser() <= #botUser) then
			header[8] = header[8]:gsub(botUser:gsub("%+", "%%+"), getCreationUser() .. string.rep(" ", #botUser - #getCreationUser()), 1)
		else
			header[8] = header[8]:gsub(botUser .. string.rep(" ", #getCreationUser() - #botUser), getCreationUser(), 1)
		end
	end
	return header
end

local function writeHeader()
	local header = genNewHeader()
	if (isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
	else
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	end
end

local function getOneSetting(setting)
	local value = vim.g[setting]
	return value and 'vim.g["' .. setting .. '"] = "' .. value ..'"' or ''
end

local function getUserSettings()
	local currentSettings = ''
	local firstIt = true
	for _, v in ipairs({ "42user", "42mail", "countryCode", "42HeaderWidth" }) do
		currentSettings = currentSettings .. ((getOneSetting(v) ~= '' and not firstIt) and '\n' or '') .. getOneSetting(v)
		firstIt = false
	end
	local userCommentTable = getUserCommentTable()
	if (not userCommentTable) then
		return currentSettings
	end
	currentSettings = currentSettings .. '\nvim.g["commentTable"] =\n{\n'
	local firstLang = true
	for k, v in pairs(userCommentTable) do
		local line = (firstLang and '' or ',\n') .. '\t["' .. k .. '"] = {'
		local firstParam = true
		for k, v in pairs(v) do
			line = line .. (firstParam and '' or ',') .. ' ["' .. k .. '"] = ' .. (tonumber(v) and '' or '"') .. v .. (tonumber(v) and '' or '"')
			firstParam = false
		end
		currentSettings = currentSettings .. line .. ' }'
		firstLang = false
	end
	return currentSettings .. '\n}'
end

local B = {}

B.yank = function ()
	local currentSettings = '-- Awesome 42Header nvim plugin user settings :\n' .. getUserSettings() .. '\n'
	vim.fn.setreg('"', currentSettings)
	vim.fn.setreg('+', '```lua\n' .. currentSettings .. '```') -- only work on linux
	print ("current settings yanked")
end

B.print = function ()
	print("current user settings :\n", "\n" .. getUserSettings())
end

B["42"] = function ()
	print("easter egg")
end

M.main = function (arg)
	updateEnv()
	if (not arg) then
		writeHeader()
		return
	end
	if (B[arg]) then
		B[arg]()
		return
	end
	M.printError("unrecognized arg : " .. arg)
end

return M
