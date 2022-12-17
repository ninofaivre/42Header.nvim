local utils = utils or require("utils")
local M = {}

local defaultSettings =
{
	["width"] = 80,
	["user"] = "marvin",
	["countryCode"] = "fr"
}

local validCommentTableParams =
{
	["required"] = { ["start"] = nil, ["fill"] = nil, ["end"] = nil },
	["authorized"] = { ["width"] = nil }
}

local function invalidSetting(setting)
	utils.printError("invalid " .. setting .. ", using default : " .. defaultSettings[setting])
end

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

M.getUserCommentTable = function ()
	if (not vim.g["commentTable"]) then
		return
	end
	local userCommentTable = {}
	for k, v in pairs(vim.g["commentTable"]) do
		if (k and v and areCommentTableParamsValid(v)) then
			userCommentTable[k] = v
		else
			utils.printError('vim.g["commentTable"][' .. k .. '] is not valid')
		end
	end
	return userCommentTable
end

M.update = function ()
	M.user = vim.g["42user"] or defaultSettings["user"]

	M.width = vim.g["42HeaderWidth"] or defaultSettings["width"]
	if (not tonumber(M.width) or M.width < 80) then
		M.width = defaultSettings["width"]
		invalidSetting("width")
	end

	M.countryCode = vim.g["countryCode"] or defaultSettings["countryCode"]
	if (#M.countryCode ~= 2) then
		M.countryCode = defaultSettings["countryCode"]
		invalidSetting("countryCode")
	end

	M.mail = vim.g["42mail"] or M.user .. "@studen.42." .. M.countryCode
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
	for k, v in pairs({"c", "h", "cpp", "hpp", "js", "ts", "go", "java", "php", "rs", "sc", "css"}) do
		M.commentTable[v] = { start = "/*", fill = "*", ["end"] = "*/" }
	end
	for k, v in pairs({"default", "sh", "bash", "py", "zsh", "ksh", "csh", "tcsh", "pdksh"}) do
		M.commentTable[v] = { start = "#", fill = "#", ["end"] = "#" }
	end
	for k, v in pairs(M.getUserCommentTable()) do
		M.commentTable[k] = v
	end
end

return M
