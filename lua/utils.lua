local M = {}

M.deepcopy = function(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
		end
		setmetatable(copy, M.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

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
	if (not vim.g["42Header"] or not vim.g["42Header"][setting]) then
		return ''
	end
	local value = vim.g["42Header"][setting]
	local quote = type(value) == "number" and '' or '"'
	return 'vim.g["' .. setting .. '"] = '.. quote .. value .. quote
end

M.getUserSettingsStr = function (userCommentTable)
	local currentSettings = 'vim.g["42Header"] =\n{'
	for _, v in ipairs({ "user", "mail", "countryCode", "width" }) do
		currentSettings = currentSettings ..'\n\t' .. getOneUserSettingStr(v)
	end
	if (not userCommentTable) then
		return currentSettings .. '\n}'
	end
	currentSettings = currentSettings .. '\nvim.g["commentTable"] =\n{\n'
	local firstLang = true
	for k, v in pairs(userCommentTable) do
		local line = (firstLang and '' or ',\n') .. '\t\t["' .. k .. '"] = {'
		local firstParam = true
		for k, v in pairs(v) do
			local quote = type(v) == "number" and '' or '"'
			line = line .. (firstParam and '' or ',') .. ' ["' .. k .. '"] = ' .. quote .. v .. quote
			firstParam = false
		end
		currentSettings = currentSettings .. line .. ' }'
		firstLang = false
	end
	return currentSettings .. '\n\t}\n}'
end

return M
