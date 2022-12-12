--[[ ---------------------------------------------------------------------- ]]--
--[[                                                                        ]]--
--[[                                                   :::      ::::::::    ]]--
--[[   main.lua                                      :+:      :+:    :+:    ]]--
--[[                                               +:+ +:+         +:+      ]]--
--[[   By: nfaivre <nfaivre@student.42.fr>       +#+  +:+       +#+         ]]--
--[[                                           +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2022/12/12 23:49:57 by nfaivre      #+#    #+#              ]]--
--[[   Updated: 2022/12/13 00:02:34 by nfaivre     ###   ########.fr        ]]--
--[[                                                                        ]]--
--[[ ---------------------------------------------------------------------- ]]--
local M = {}

-- TODO
-- Header42 -> 42Header
-- user42 -> 42user
-- let user set Header42Height and Header42Logo
-- reduce api call (get_buffer) in the isThereAHeader func

local user, width, countryCode, commentTable, logo

local function printError(error)
	print ("Header 42 : ", error)
end

local function updateEnv ()
	user = vim.g.user42 or "marvin"

	width = vim.g.Header42Width or 80
	if (not tonumber(width) or width < 80) then
		width = 80
		printError ("invalid width, using default : 80")
	end

	countryCode = vim.g.countryCode or "fr"
	if (#countryCode ~= 2) then
		countryCode = "fr"
		printError ("invalid country code, using default : \"fr\"")
	end

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
	if (vim.g.commentTable) then
		for k, v in pairs(vim.g.commentTable) do
			if (k and v and v["start"] and v["fill"] and v["end"]) then
				commentTable[k] = v
			else
				printError("invalid entry in commentTable not added")
			end
		end
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

M.main = function ()
	updateEnv()
	local comment = commentTable[vim.fn.expand("%:e")] or commentTable["default"]
	local SELen = #comment["start"] + #comment["end"]
	local maxFileNameLen = width - (#logo[2] + SELen + 3)
	local fileName = vim.fn.expand("%:t")
	if (#fileName > maxFileNameLen) then -- if fileName too long cut it
		fileName = fileName:sub(1, maxFileNameLen - 1) .. "+"
	end
	local time = os.date("%Y/%m/%d %H:%M:%S")
	local maxUserLen = (width - (#logo[4] + #countryCode + SELen + 22)) / 2
	local topUser = (#user > maxUserLen) and user:sub(1, maxUserLen - 1) .. "+" or user
	maxUserLen = width - (#logo[7] + #time + SELen + 16)
	local botUser = (#user > maxUserLen) and user:sub(1, maxUserLen - 1) .. "+" or user
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[1] + SELen)) .. logo[1] .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#logo[2] + #fileName + SELen + 3)) .. logo[2] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[3] + SELen)) .. logo[3] .. comment["end"],
		comment["start"] .. "   By: " .. topUser .. " <" .. topUser .. "@student.42." .. countryCode .. ">"
			.. string.rep(" ", (width - (#logo[4] + #topUser * 2 + #countryCode + SELen + 22))) .. logo[4] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[5] + SELen)) .. logo[5] .. comment["end"],
		comment["start"].. "   Created: " .. time .. " by " .. botUser .. string.rep(" ", width - (#logo[6] + #time + #botUser + SELen + 16)) .. logo[6] .. comment["end"],
		comment["start"] .. "   Updated: " .. time .. " by " .. botUser .. string.rep(" ", width - (#logo[7] + #time + #botUser + SELen + 16)) .. logo[7] .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
	}
	if (not isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	else
		header[8] = header[8]:gsub(time, getCreationTime(), 1)
		if (#getCreationUser() <= #botUser) then
			header[8] = header[8]:gsub(botUser, getCreationUser() .. string.rep(" ", #botUser - #getCreationUser()), 1)
		else
			header[8] = header[8]:gsub(botUser .. string.rep(" ", #getCreationUser() - #botUser), getCreationUser(), 1)
		end
		vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
	end
end

return M
