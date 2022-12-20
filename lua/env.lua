--[[ ---------------------------------------------------------------- ]]--
--[[                                                                  ]]--
--[[                                             :::      ::::::::    ]]--
--[[   env.lua                                 :+:      :+:    :+:    ]]--
--[[                                         +:+ +:+         +:+      ]]--
--[[   By: nfaivre <nfaiv+@student.42.zz>  +#+  +:+       +#+         ]]--
--[[                                     +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2022/12/17 20:46:00 by n+     #+#    #+#              ]]--
--[[   Updated: 2022/12/20 14:32:40 by n+    ###   ########.zz        ]]--
--[[                                                                  ]]--
--[[ ---------------------------------------------------------------- ]]--
local utils = vim.g["42HeaderDev"] and dofile("./lua/utils.lua") or require("lua.utils")
local M = {}

local defaultSettings =
{
	["width"] = 80,
	["user"] = "marvin",
	["countryCode"] = "fr"
}

local function isValidWidth (width, comment)
	if (width == 'nan') then
		return false
	end
	return width >= (36 + #comment["start"] + #comment["end"] + #M.logo[1])
end

local validCommentTableParams =
{
	["required"] = { ["start"] = nil, ["fill"] = nil, ["end"] = nil },
	["authorized"] = { ["width"] = isValidWidth }
}

local function invalidSetting(setting)
	utils.printError("invalid " .. setting .. ", using default : " .. defaultSettings[setting])
end

local function checkRequiredParams(params)
	for k, _ in pairs(validCommentTableParams["required"]) do
		if (not params[k]) then
			return false
		end
	end
	return true
end

local function isValidParam(param, value, values)
	if ((not validCommentTableParams["required"][param] and not validCommentTableParams["authorized"][param]) or not validCommentTableParams[param](value, values)) then
		return false
	end
	return true
end

M.getUserCommentTable = function ()
	if (not vim.g["commentTable"]) then
		return
	end
	local userCommentTable = {}
	for K, V in pairs(vim.g["commentTable"]) do
		if (K and V and checkRequiredParams(V)) then
			for k, v in pairs(V) do
				if isValidParam(k, v, V) then
					userCommentTable[K][k] = v
				else
					utils.printError('vim.g["commentTable"][' .. K .. '][' .. k .. '] is not valid')
				end
			end
		else
			utils.printError('vim.g["commentTable"][' .. K .. '] is not valid')
		end
	end
	return userCommentTable
end

M.update = function ()
	M.user = vim.g["42user"] or defaultSettings["user"]

	M.countryCode = vim.g["countryCode"] or defaultSettings["countryCode"]
	if (#M.countryCode ~= 2) then
		M.countryCode = defaultSettings["countryCode"]
		invalidSetting("countryCode")
	end

	M.mail = vim.g["42mail"] or M.user .. "@student.42." .. M.countryCode
	if (not M.mail:find("@", 1, true)) then
		M.mail = M.user .. "@student.42." .. M.countryCode
		utils.printError("invalid mail provided, using default : \"" .. M.user .. "@student.42." .. M.countryCode .. "\"")
	end
	M.mailUser = M.mail:sub(1, M.mail:find("@", 1, true) - 1)
	M.mailDomain = M.mail:sub(M.mail:find("@", 1, true) + 1)

	M.logo =
	{
		"        :::      ::::::::    ",
		"      :+:      :+:    :+:    ",
		"    +:+ +:+         +:+      ",
		"  +#+  +:+       +#+         ",
		"+#+#+#+#+#+   +#+            ",
		"     #+#    #+#              ",
		"    ###   ########." .. M.countryCode .. "        "
	}

	M.commentTable =
	{
		lua		= { start = "--[[", fill = "-", ["end"] = "]]--" },
		html	= { start = "<!--", fill = "-", ["end"] = "-->" },
		rb		= { start = "=begin", fill = "#", ["end"] = "=end" },
		hs		= { start = "{-", fill = "-", ["end"] = "-}" }
	}
	for _, v in pairs({"c", "h", "cpp", "hpp", "js", "ts", "go", "java", "php", "rs", "sc", "css"}) do
		M.commentTable[v] = { start = "/*", fill = "*", ["end"] = "*/" }
	end
	for _, v in pairs({"default", "sh", "bash", "py", "zsh", "ksh", "csh", "tcsh", "pdksh"}) do
		M.commentTable[v] = { start = "#", fill = "#", ["end"] = "#" }
	end
	for k, v in pairs(M.getUserCommentTable() or {}) do
		M.commentTable[k] = v
	end
	M.width = vim.g["42HeaderWidth"] or defaultSettings["width"]
	if (not tonumber(M.width) or not isValidWidth(tonumber(M.width), M.commentTable[vim.fn.expand("%:e")] or M.commentTable["default"])) then
		M.width = defaultSettings["width"]
		invalidSetting("width")
	else
		M.width = tonumber(M.widht)
	end
end

return M
