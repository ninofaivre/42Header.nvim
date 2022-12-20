--[[ ---------------------------------------------------------------------- ]]--
--[[                                                                        ]]--
--[[                                                   :::      ::::::::    ]]--
--[[   main.lua                                      :+:      :+:    :+:    ]]--
--[[                                               +:+ +:+         +:+      ]]--
--[[   By: nfaivre <nfaivre@student.42.zz>       +#+  +:+       +#+         ]]--
--[[                                           +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2022/12/20 14:50:14 by +            #+#    #+#              ]]--
--[[   Updated: 2022/12/20 15:18:48 by nfaivre     ###   ########.zz        ]]--
--[[                                                                        ]]--
--[[ ---------------------------------------------------------------------- ]]--
local M = {}
local utils = (vim.g["42HeaderDev"]) and dofile("./lua/utils.lua") or require("lua.utils")
local env = (vim.g["42HeaderDev"]) and dofile("./lua/env.lua") or require("lua.env")

-- TODO
-- option to ensure the norm compliance (override wrong setting if needed to ensure it)
-- auto width option

local function isThereAHeader ()
	local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)

	if (#oldHeader ~= 11) then
		return false
	end
	for i = 1, 6 do
		if (not oldHeader[i + 2]:find(env["logo"][i], 1, true)) then
			return false
		end
	end
	return oldHeader[9]:find(env["logo"][7]:sub(1, env["logo"][7]:find("."), 1, true)) and true or false
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

local function genNewHeader(forceExt)
	local comment = env["commentTable"][forceExt or vim.fn.expand("%:e")] or env["commentTable"]["default"]
	local width = comment["width"] or env["width"]
	local SELen = #comment["start"] + #comment["end"]
	local fileName = utils.shrink(vim.fn.expand("%:t"), width - (#env["logo"][2] + SELen + 3))
	local time = os.date("%Y/%m/%d %H:%M:%S") .. ''
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
	--botUser = botUser:gsub("%+", "%%+")
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
	env.update()
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

B.updateOnly = function ()
	writeHeader (true)
end

local function exec(prog)
	local tmp = io.popen(prog .. ' >/dev/null 2>&1; echo $?')
	if (not tmp) then
		return
	end
	local res = tmp:read("*a")
	tmp:close()
	return res
end

B.norm = function () -- linux only -- betâ testing
	local res = exec('python3 -m norminette -v')
	if (not res or tonumber(res) ~= 0) then
		print ('norm not installed')
		return
	end
	env.update()
	local header = ''
	for _, v in pairs(genNewHeader('c')) do -- force extension
		header = header .. v .. '\n'
	end
	local cmain = 'int\tmain(void)\n{\n}\n'
	res = exec('python3 -m norminette --cfile "' .. header .. cmain .. '"')
	if (not res or tonumber(res) ~= 0) then
		print ('this config is not norm complient')
	else
		print ('this config is norm complient')
	end
end

M.main = function (arg)
	if (not arg) then
		writeHeader(false)
		return
	end
	if (B[arg]) then
		B[arg]()
		return
	end
	utils.printError("unrecognized arg : " .. arg)
end

return M
