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
local utils = utils or require("utils")
local env = env or require("env")

-- TODO
-- split in to file / sanitize
-- mode to ensure the norm compliance (override wrong setting if needed to ensure it)
-- auto width, let user go under 80 width ensure a minimum width depend of SELen
-- let user set Header42Height and Header42Logo

local function isThereAHeader ()
	local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)
	if (table.getn(oldHeader) ~= 11) then
		return false
	end
	for i = 1, 6 do
		if (not oldHeader[i + 2]:find(env["logo"][i], 1, true)) then
			return false
		end
	end
	return oldHeader[9]:find(logo[7]:sub(1, env["logo"][7]:find("."), 1, true)) and true or false
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

local function genNewHeader()
	local comment = env["commentTable"][vim.fn.expand("%:e")] or env["commentTable"]["default"]
	local width = comment["width"] or env["width"]
	local SELen = #comment["start"] + #comment["end"]
	local fileName = utils.shrink(vim.fn.expand("%:t"), width - (#env["logo"][2] + SELen + 3))
	local time = os.date("%Y/%m/%d %H:%M:%S")
	local mailUser = utils.shrink(env["mailUser"], width - (#env["logo"][4] + #env["mailDomain"] + #env["user"] + SELen + 11))
	local mailDomain = utils.shrink(env["mailDomain"], width - (#env["logo"][4] + #mailUser + #env["user"] + SELen + 11))
	local topUser = utils.shrink(env["user"], width - (#env["logo"][4] + #mailUser + #mailDomain + SELen + 11))
	local botUser = utils.shrink(env["user"], width - (#env["logo"][7] + #time + SELen + 16))
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][1] + SELen)) .. env["logo"][1] .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#env["logo"][2] + #fileName + SELen + 3)) .. env["logo"][2] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][3] + SELen)) .. env["logo"][3] .. comment["end"],
		comment["start"] .. "   By: " .. topUser .. " <" .. mailUser .. "@" .. mailDomain .. ">"
			.. string.rep(" ", (width - (#env["logo"][4] + #topUser + #mailUser + #mailDomain + SELen + 11))) .. env["logo"][4] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#env["logo"][5] + SELen)) .. env["logo"][5] .. comment["end"],
		comment["start"] .. "   Created: " .. time .. " by " .. botUser .. string.rep(" ", width - (#env["logo"][6] + #time + #botUser + SELen + 16)) .. env["logo"][6] .. comment["end"],
		comment["start"] .. "   Updated: " .. time .. " by " .. botUser .. string.rep(" ", width - (#env["logo"][7] + #time + #botUser + SELen + 16)) .. env["logo"][7] .. comment["end"],
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

local B = {}

B.yank = function ()
	local currentSettings = '-- Awesome 42Header nvim plugin user settings :\n' .. utils.getUserSettingsStr(env.getUserCommentTable()) .. '\n'
	vim.fn.setreg('"', currentSettings)
	vim.fn.setreg('+', '```lua\n' .. currentSettings .. '```') -- only work on linux
	print ("current settings yanked")
end

B.print = function ()
	print("current user settings :\n", "\n" .. utils.getUserSettingsStr(env.getUserCommentTable()))
end

B["42"] = function ()
	print("easter egg")
end

M.main = function (arg)
	env.update()
	if (not arg) then
		writeHeader()
		return
	end
	if (B[arg]) then
		B[arg]()
		return
	end
	utils.printError("unrecognized arg : " .. arg)
end

return M
