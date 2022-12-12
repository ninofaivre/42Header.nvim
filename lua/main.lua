--[[ -------------------------------------------------------------------------------------------------------------------------------------------- ]]--
--[[                                                                                                                                              ]]--
--[[                                                                                                                         :::      ::::::::    ]]--
--[[   main.lua                                                                                                            :+:      :+:    :+:    ]]--
--[[                                                                                                                     +:+ +:+         +:+      ]]--
--[[   By: nfaivre <nfaivre@student.42.zz>                                                                             +#+  +:+       +#+         ]]--
--[[                                                                                                                 +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2019/12/12 20:20:14 by nfaivre                                                                            #+#    #+#              ]]--
--[[   Updated: 2022/12/12 20:04:21 by nfaivre                                                                           ###   ########.zz        ]]--
--[[                                                                                                                                              ]]--
--[[ -------------------------------------------------------------------------------------------------------------------------------------------- ]]--
local M = {}

-- TODO
-- Header42 -> 42Header
-- user42 -> 42user
-- let user set Header42Height and Header42Logo

local user, width, countryCode, commentTable, logo, commentTable

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
	--[[
	for key in "c", "h", "cpp", "hpp", "js", "ts", "go", "java", "php", "rs", "sc", "css" do
		commentTable[key] = { start = "/*", fill = "*", ["end"] = "*/" }
	end
	for key in "default", "sh", "bash", "py", "zsh", "ksh", "csh", "tcsh", "pdksh" do
		commentTable[key] = { start = "#", fill = "#", ["end"] = "#" }
	end
	--]]
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
	local oldHeaderLen = 0
	for _ in pairs(oldHeader) do oldHeaderLen = oldHeaderLen + 1 end
	if (oldHeaderLen ~= 11) then
		return false
	end
	for i = 1, 6 do
		a, b = (oldHeader[i + 2]):find(logo[i], 1, true)
		if (not a or not b) then
			return false
		end
	end
	-- need a bit of rework (tmp)
	a, b = (oldHeader[9]):find(string.sub(logo[7], 1, string.find(logo[7], "."), 1, true))
	if (not a or not b) then
		return false
	end
	-- (tmp)
	return true
end

M.main = function ()
	updateEnv()
	local comment = commentTable[vim.fn.expand("%:e")] or commentTable["default"]
	local SELen = #comment["start"] + #comment["end"]
	local maxFileNameLen = width - (#logo[2] + SELen + 3) - 1
	local fileName = vim.fn.expand("%:t")
	if (#fileName > maxFileNameLen) then -- if fileName too long cut it
		fileName = string.sub(fileName, 1, maxFileNameLen - 1)
		fileName = fileName .. "+"
	end
	local time = os.date("%Y/%m/%d %H:%M:%S")
	local maxUserLen = ((width - (#logo[4] + #countryCode + SELen + 22)) / 2) - 1
	if (#user > maxUserLen) then
		user = string.sub(user, 1, maxUserLen - 1)
		user = user .. "+"
	end
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[1] + SELen)) .. logo[1] .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#logo[2] + #fileName + SELen + 3)) .. logo[2] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[3] + SELen)) .. logo[3] .. comment["end"],
		comment["start"] .. "   By: " .. user .. " <" .. user .. "@student.42." .. countryCode .. ">"
			.. string.rep(" ", (width - (#logo[4] + #user * 2 + #countryCode + SELen + 22))) .. logo[4] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[5] + SELen)) .. logo[5] .. comment["end"],
		comment["start"].. "   Created: " .. time .. " by " .. user .. string.rep(" ", width - (#logo[6] + #time + #user + SELen + 16)) .. logo[6] .. comment["end"],
	}
	maxUserLen = width - (#logo[7] + #time + SELen + 16) - 1
	if (#user > maxUserLen) then
		user = string.sub(user, 1, maxUserLen - 1)
		user = user .. "+"
	end
	header[9] = comment["start"] .. "   Updated: " .. time .. " by " .. user .. string.rep(" ", width - (#logo[7] + #time + #user + SELen + 16)) .. logo[7] .. comment["end"]
	header[10] = comment["start"] .. string.rep(" ", width - SELen) .. comment["end"]
	header[11] = comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"]
	if (not isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	else
		--vim.api.nvim_buf_set_lines(0, 0, 7, false, { unpack(header, 1, 7) })
		local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)
		local tmp = string.find(oldHeader[8], "20")
		header[8] = string.gsub(header[8], time, string.sub(oldHeader[8], tmp, tmp + 18), 1)
		vim.api.nvim_buf_set_lines(0, 0, 11, false, header)
	end
end

M.main()

return M
