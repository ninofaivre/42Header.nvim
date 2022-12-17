local M = {}

M.mapSize = function (map)
	local size = 0
	for _ in pairs(map) do
		size = size + 1
	end
	return size
end

M.shrink = function (toShrink, maxLen)
	maxLen = (maxLen <= 0) and 1 or maxLen
	toShrink = (#toShrink > maxLen) and toShrink:sub(1, maxLen - 1) .. "+" or toShrink
	return toShrink
end

M.printError = function (err)
	vim.api.nvim_err_writeln("42Header : " .. err)
end

local function getOneUserSettingStr(setting)
	local value = vim.g[setting]
	return value and 'vim.g["' .. setting .. '"] = "' .. value ..'"' or ''
end

M.getUserSettingsStr = function (userCommentTable)
	local currentSettings = ''
	local firstIt = true
	for _, v in ipairs({ "42user", "42mail", "countryCode", "42HeaderWidth" }) do
		currentSettings = currentSettings .. ((getOneUserSettingStr(v) ~= '' and not firstIt) and '\n' or '') .. getOneUserSettingStr(v)
		firstIt = false
	end
	if (not userCommentTable) then
		return currentSettings
	end
	currentSettings = currentSettings .. '\nvim.g["commentTable"] =\n{\n'
	local firstLang = true
	for k, v in pairs(userCommentTable) do
		local line = (firstLang and '' or ',\n') .. '\t["' .. k .. '"] = {'
		local firstParam = true
		for k, v in pairs(v) do
			line = line .. (firstParam and '' or ',') .. ' ["' .. k .. '"] = ' .. (tonumber(v) and '' or '"') .. v .. (tonumber(v) and '' or '"')
			firstParam = false
		end
		currentSettings = currentSettings .. line .. ' }'
		firstLang = false
	end
	return currentSettings .. '\n}'
end

return M
