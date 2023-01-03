local function ensureUserSettingsExist ()
	if (not vim.g["42Header"]) then
		vim.g["42Header"] = {}
	end
end

local function setUserSettings (settings)
	if (not settings) then
		vim.g["42Header"] = {}
		return
	end
	vim.g["42Header"] = settings
end

local function updateUserSettings (settings)
	ensureUserSettingsExist()
	local tmp = vim.g["42Header"]
	for k, v in pairs(settings or {}) do
		tmp[k] = v
	end
	setUserSettings(tmp)
end

local function getUserSettings (setting)
	ensureUserSettingsExist()
	if (not setting) then
		return
	end
	return vim.g["42Header"][setting]
end

local function printUserSettings ()
	ensureUserSettingsExist()
	print (vim.inspect(vim.g["42Header"]))
end

return
{
	set = setUserSettings,
	update = updateUserSettings,
	get = getUserSettings,
	print = printUserSettings,
}
