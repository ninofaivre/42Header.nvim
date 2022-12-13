--[[ ---------------------------------------------------------------------- ]]--
--[[                                                                        ]]--
--[[                                                   :::      ::::::::    ]]--
--[[   main.lua                                      :+:      :+:    :+:    ]]--
--[[                                               +:+ +:+         +:+      ]]--
--[[   By: nfaivree <nfaivre@student.42.fr>      +#+  +:+       +#+         ]]--
--[[                                           +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2022/12/13 12:07:46 by nfaivre      #+#    #+#              ]]--
--[[   Updated: 2022/12/13 12:08:25 by nfaivree    ###   ########.fr        ]]--
--[[                                                                        ]]--
--[[ ---------------------------------------------------------------------- ]]--
local M = {}

-- TODO
-- let user set Header42Height and Header42Logo
-- reduce api call (get_buffer) in the isThereAHeader func
-- auto width
-- width by mimetype
-- mimetype table to let the user spell javascript for exemple in the commentTable and not force him to use js

local user, mailUser, mailDomain, width, countryCode, commentTable, logo

local function printError(error)
	print ("42Header : ", error)
end

local function updateEnv ()
	user = vim.g["42user"] or "marvin"

	width = vim.g["42HeaderWidth"] or 80
	if (not tonumber(width) or width < 80) then
		width = 80
		printError ("invalid width, using default : 80")
	end

	countryCode = vim.g.countryCode or "fr"
	if (#countryCode ~= 2) then
		countryCode = "fr"
		printError ("invalid country code, using default : \"fr\"")
	end

	local mail = vim.g["42mail"] or user .. "@studen.42." .. countryCode
	if (not mail:find("@", 1, true)) then
		mail = user .. "@student.42." .. countryCode
		printError ("invalid mail provided, using default : \"" .. user .. "@student.42." .. countryCode .. "\"")
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

local function shrink(toShrink, maxLen)
	maxLen = (maxLen <= 0) and 1 or maxLen
	toShrink = (#toShrink > maxLen) and toShrink:sub(1, maxLen - 1) .. "+" or toShrink
	return toShrink
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
			header[8] = header[8]:gsub(botUser:gsub("%+", "%%+"), getCreationUser() .. string.rep(" ", #botUser - #getCreationUser()), 1)
		else
			header[8] = header[8]:gsub(botUser .. string.rep(" ", #getCreationUser() - #botUser), getCreationUser(), 1)
		end
		vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
	end
end

M.main()

return M
