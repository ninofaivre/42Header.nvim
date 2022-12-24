--[[ ---------------------------------------------------------------------- ]]--
--[[                                                                        ]]--
--[[                                                   :::      ::::::::    ]]--
--[[   env.lua                                       :+:      :+:    :+:    ]]--
--[[                                               +:+ +:+         +:+      ]]--
--[[   By: marvin <marvin@student.42.ma>         +#+  +:+       +#+         ]]--
--[[                                           +#+#+#+#+#+   +#+            ]]--
--[[   Created: 2022/12/17 20:46:00 by +            #+#    #+#              ]]--
--[[   Updated: 2022/12/24 19:07:24 by marvin      ###   ########.ma        ]]--
--[[                                                                        ]]--
--[[ ---------------------------------------------------------------------- ]]--

--TODO handle width with different header width

local utils = (vim.g["42Header"] and vim.g["42Header"]["Dev"]) and dofile("./lua/utils.lua") or require("lua.utils")
local M = {}
local env = {}

local function getDefaultWidth()
	local width = 43 + #env["logo"][1] + #env["comment"]["start"] + #env["comment"]["end"]
	return (width < 80) and 80 or width
end

local defaultSettings =
{
	["width"] = getDefaultWidth,
	["user"] = "marvin",
	["countryCode"] = "fr",
	["logoID"] = "42"
}

local function getDefaultSetting(setting)
	if (not defaultSettings[setting]) then
		return
	end
	if (type(defaultSettings[setting]) == "function") then
		return defaultSettings[setting]()
	else
		return defaultSettings[setting]
	end
end

-- width --

local function isValidWidth (width)
	if (width == tonumber('NaN')) then
		return false
	end
	return width >= (36 + #env.comment["start"] + #env.comment["end"] + #env.logo[1])
end

local function getWidth (width)
	width = tonumber(width)
	if (not width or not isValidWidth(width)) then
		return getDefaultSetting("width")
	end
	return width
end

-- width --

local function getCountryCode (countryCode)
	countryCode = tostring(countryCode)
	if (not countryCode or #countryCode ~= 2) then
		return getDefaultSetting("countryCode")
	end
	return countryCode
end

local function getUser (user)
	user = tostring(user)
	if (not user) then
		return getDefaultSetting("user")
	end
	return user
end

local validCommentTableParams =
{
	["required"] = { ["start"] = nil, ["fill"] = nil, ["end"] = nil },
	["authorized"] = { ["width"] = isValidWidth }
}

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

local logosTable =
{
	["42"] =
	{
		"        :::      ::::::::    ",
		"      :+:      :+:    :+:    ",
		"    +:+ +:+         +:+      ",
		"  +#+  +:+       +#+         ",
		"+#+#+#+#+#+   +#+            ",
		"     #+#    #+#              ",
		"    ###   ########.CC        "
	},
	["1337"] =
	{
		"        :::   ::::::::   ::::::::  :::::::::::    ",
		"      :+:+:  :+:    :+: :+:    :+: :+:     :+:    ",
		"     +:+         +:+        +:+        +:+        ",
		"     +#+      +#++:      +#++:        +#+         ",
		"    +#+         +#+        +#+      +#+           ",
		"   #+#  #+#    #+# #+#    #+#     #+#             ",
		"####### ########   ########      ###.CC           ",
	},
	["19"] =
	{
		"        :::   ::::::::    ",
		"     :+:+:  :+:    :+:    ",
		"      +:+  +:+    +:+     ",
		"     +#+   +#++:++#+      ",
		"    +#+         +#+       ",
		"   #+#  #+#    #+#        ",
		"####### ########.CC       ",
	},
	["21"] =
	{
		"       ::::::::    :::          ",
		"     :+:    :+: :+:+:           ",
		"          +:+    +:+            ",
		"       +#+      +#+             ",
		"    +#+        +#+              ",
		"  #+#         #+#               ",
		"########## #######-school.CC    ",
	}
}

local function getLogo()
	local asciiLogo = utils.deepcopy(logosTable[env["logoID"]])
	for k, v in ipairs(asciiLogo) do
		asciiLogo[k] = v:gsub("CC", env["countryCode"])
	end
	return asciiLogo

end

local function getLogoID(logoID)
	logoID = tostring(logoID)
	if (not logoID or not logosTable[logoID]) then
		return getDefaultSetting("logoID")
	end
	return logoID
end

local function getMail(mail)
	mail = tostring(mail)
	if (not mail or not mail:find('@')) then
		return env.user .. "@student.42." .. env.countryCode
	end
	return mail
end

local function getMailUser()
	return env.mail:sub(1, env.mail:find('@', 1, true) - 1)
end

local function getMailDomain()
	return env.mail:sub(env.mail:find('@', 1, true) + 1)
end

local function getCommentTable()
	local commentTable =
	{
		lua	= { start = "--[[", fill = "-", ["end"] = "]]--" },
		html	= { start = "<!--", fill = "-", ["end"] = "-->" },
		rb	= { start = "=begin", fill = "#", ["end"] = "=end" },
		hs	= { start = "{-", fill = "-", ["end"] = "-}" }
	}
	for _, v in pairs({"c", "h", "cpp", "hpp", "js", "ts", "go", "java", "php", "rs", "sc", "css"}) do
		commentTable[v] = { start = "/*", fill = "*", ["end"] = "*/" }
	end
	for _, v in pairs({"default", "sh", "bash", "py", "zsh", "ksh", "csh", "tcsh", "pdksh"}) do
		commentTable[v] = { start = "#", fill = "#", ["end"] = "#" }
	end
	for k, v in pairs(M.getUserCommentTable() or {}) do
		commentTable[k] = v
	end
	return commentTable
end

local function getComment()
	return env.commentTable[vim.fn.expand("%:e") or "default"]
end

-- test --

local settingGetter =
{
	["commentTable"] = { getter = getCommentTable },
	["comment"] = { getter = getComment, required = { "commentTable" } },
	["countryCode"] = { getter = getCountryCode },
	["logoID"] = { getter = getLogoID },
	["logo"] = { getter = getLogo, required = { "logoID", "countryCode" } },
	["width"] = { getter = getWidth, required = { "comment", "logo" } },
	["user"] = { getter = getUser },
	["mail"] = { getter = getMail, required = { "user", "countryCode" } },
	["mailUser"] = { getter = getMailUser, required = { "mail" } },
	["mailDomain"] = { getter = getMailDomain, required = { "mail" } },
	-- add logosTable
}

local function updateOne(setting)
	if (env[setting]) then
		return
	end
	if (settingGetter[setting]["required"]) then
		for _, v in ipairs(settingGetter[setting]["required"]) do
			updateOne(v)
		end
	end
	if (vim.g["42Header"] and vim.g["42Header"][setting]) then
		env[setting] = settingGetter[setting]["getter"](vim.g["42Header"][setting])
	else
		env[setting] = getDefaultSetting(setting) or settingGetter[setting]["getter"]()
	end
end

M.update = function ()
	env = {}
	for k, _ in pairs(settingGetter) do
		updateOne(k)
	end
	for k, v in pairs(env) do
		M[k] = v
	end
end

-- test --

--[[
local function invalidSetting(setting)
	utils.printError("invalid " .. setting .. ", using default : " .. getDefaultSetting(setting))
end
--]]

return M
