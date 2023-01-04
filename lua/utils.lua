local M = {}

M.getUserSettingsStr = function ()
	local toReturn = 'require("42Header").setup(\n{\n'
	for _, v in ipairs({"user", "mail", "countryCode", "width", "logoID"}) do
		if (require("userSettings").get()[v]) then
			toReturn = toReturn .. '\t' .. v .. ' = ' .. tostring(require("userSettings").get()[v]) .. ',\n'
		end
	end
	-- add print of commentTable
	toReturn = toReturn .. '}'
	return toReturn
end

local function deepcopy (orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

M.deepcopy = deepcopy

M.shrink = function (toShrink, maxLen)
	maxLen = (maxLen <= 0) and 1 or maxLen
	toShrink = (#toShrink > maxLen) and toShrink:sub(1, maxLen - 1) .. "+" or toShrink
	return toShrink
end

M.arrayTrimNil = function (array)
	local toReturn = {}
	for i = 1, table.maxn(array) do
		if (array[i]) then
			table.insert(toReturn, array[i])
		end
	end
	return toReturn
end

M.plainText = function (str)
	return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

return M
