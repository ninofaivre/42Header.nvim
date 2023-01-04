local lazy = setmetatable({}, {
	__index = function(_, key)
		return require('' .. key)
	end
})

local function getFileExt(_, _)
	return vim.fn.expand("%:e")
end

local function getComment(_, env)
	local userCommentTable = lazy.userSettings.get("commentTable") or {}
	local comment = userCommentTable[env["fileExt"]] or userCommentTable["default"] or lazy.defaultSettings.get("comment", env)
	for k, v in pairs(lazy.defaultSettings.get("comment", env)) do
		if (not comment[k] or type(comment[k]) ~= type(v)) then
			comment[k] = v
		end
	end
	return comment
end

local function getCommentEnvSetting(setting, env)
	return env["comment"] and env["comment"]["env"] and env["comment"]["env"][setting]
end

local function getByChecker(V, env)
	local args = lazy.utils.arrayTrimNil(
	{
		getCommentEnvSetting(V["var"], env),
		lazy.userSettings.get(V["var"]),
		unpack(V["fb"] or  {})
	})
	for _, v in ipairs(args) do
		if (V["checker"](v, env)) then
			return v
		end
	end
	return lazy.defaultSettings.get(V["var"], env)
end

local function isValidCountryCode(countryCode)
	return type(countryCode) == "string" and #countryCode == 2
end

local logosTable =
{
	["42"] =
	{
		"        :::      ::::::::",
		"      :+:      :+:    :+:",
		"    +:+ +:+         +:+  ",
		"  +#+  +:+       +#+     ",
		"+#+#+#+#+#+   +#+        ",
		"     #+#    #+#          ",
		"    ###   ########.CC    "
	},
	["1337"] =
	{
		"        :::   ::::::::   ::::::::  :::::::::::",
		"     :+:+:   :+:    :+: :+:    :+: :+:     :+:",
		"      +:+        +:+        +:+        +:+    ",
		"     +#+      +#++:      +#++:        +#+     ",
		"    +#+         +#+        +#+      +#+       ",
		"   #+#  #+#    #+# #+#    #+#     #+#         ",
		"####### ########   ########      ###.CC       ",
	},
	["19"] =
	{
		"        :::   ::::::::",
		"     :+:+:  :+:    :+:",
		"      +:+  +:+    +:+ ",
		"     +#+   +#++:++#+  ",
		"    +#+         +#+   ",
		"   #+#  #+#    #+#    ",
		"####### ########.CC   ",
	},
	["21"] =
	{
		"       ::::::::    :::      ",
		"     :+:    :+: :+:+:       ",
		"          +:+    +:+        ",
		"       +#+      +#+         ",
		"    +#+        +#+          ",
		"  #+#         #+#           ",
		"########## #######-school.CC",
	}
}

local function isValidLogo(logo)
	if (type(logo) ~= "table" or #logo ~= 7) then
		return false
	end
	local size = #logo[1]
	for _, v in ipairs(logo) do
		if (type(v) ~= "string" or #v ~= size) then
			return false
		end
	end
	return true
end

local function getLogo(_, env)
	local asciiLogo = nil
	for _, v in ipairs({ getCommentEnvSetting("logosTable", env) or {}, lazy.userSettings.get("logosTable") or {}, logosTable }) do
		if (isValidLogo(v[env["logoID"]])) then
			asciiLogo = lazy.utils.deepcopy(v[env["logoID"]])
			break
		end
	end
	asciiLogo = asciiLogo or lazy.utils.deepcopy(logosTable[lazy.defaultSettings.get("logoID")])
	for k, v in ipairs(asciiLogo) do
		asciiLogo[k] = v:gsub("CC", env["countryCode"])
	end
	return asciiLogo

end

local function isValidLogoID(logoID, env)
	for _, v in ipairs({ getCommentEnvSetting("logosTable", env) or {}, lazy.userSettings.get("logosTable") or {}, logosTable }) do
		if (v[logoID] ~= nil) then
			return true
		end
	end
end

-- width --

local function isValidWidth (width, env)
	if (type(width) ~= "number" or width == tonumber('NaN')) then
		return false
	end
	return width >= (40 + #env.comment["start"] + #env.comment["end"] + #env.logo[1])
end

-- width --

local function isValidMail(mail)
	return type(mail) == "string" and mail:find('@') and true or false
end

local function getMailUser(_, env)
	return env["mail"]:sub(1, env["mail"]:find('@', 1, true) - 1)
end

local function getMailDomain(_, env)
	return env["mail"]:sub(env["mail"]:find('@', 1, true) + 1)
end

local function getEnv()
	local getters =
	{
		{ var = "fileExt", getter = getFileExt },
		{ var = "comment", getter = getComment },
		{ var = "countryCode", checker = isValidCountryCode },
		{ var = "logoID", checker = isValidLogoID },
		{ var = "logo", getter = getLogo },
		{ var = "width", checker = isValidWidth },
		{
			var = "user",
			checker = function (user) return type(user == "string") end,
			fb = { vim.g["user42"], vim.g["42user"], vim.env["42USER"], vim.env["USER42"], vim.env["USER"] }
		},
		{
			var = "mail", checker = isValidMail,
			fb = { vim.g["mail42"], vim.g["42mail"], vim.env["42MAIL"], vim.env["MAIL42"], vim.env["MAIL"] }
		},
		{ var = "mailUser", getter = getMailUser },
		{ var = "mailDomain", getter = getMailDomain },
		-- add logosTable
	}
	local env = {}
	for _, v in pairs(getters) do
		if (v["getter"]) then
			env[v["var"]] = v["getter"](lazy.userSettings.get(v["var"]), env)
		elseif (v["checker"]) then
			env[v["var"]] = getByChecker(v, env)
		end
	end
	return env
end

return
{
	get = getEnv
}
