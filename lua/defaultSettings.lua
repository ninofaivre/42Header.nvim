-- commentTable

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

local function getDefaultComment(env)
	return commentTable[env["fileExt"]] or commentTable["default"]
end

-- commentTable

local function getDefaultWidth(env)
	local width = 43 + #env["logo"][1] + #env["comment"]["start"] + #env["comment"]["end"]
	return (width < 80) and 80 or width
end

local function getDefaultMail(env)
	return env["user"] .. "@student.42." .. env["countryCode"]
end

local defaultSettings =
{
	["width"] = getDefaultWidth,
	["mail"] = getDefaultMail,
	["comment"] = getDefaultComment,
	["user"] = "marvin",
	["countryCode"] = "fr",
	["logoID"] = "42"
}

local function getDefaultSetting(setting, env)
	if (not defaultSettings[setting]) then
		return
	end
	if (type(defaultSettings[setting]) == "function") then
		return defaultSettings[setting](env)
	else
		return defaultSettings[setting]
	end
end

return
{
	get = getDefaultSetting
}
