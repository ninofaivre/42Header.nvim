local M = {}

local user = vim.g.user42
if (not user) then
	user = "marvin"
end

local countryCode = vim.g.countryCode
if (not countryCode or #countryCode ~= 2) then
	countryCode = "fr"
end

local width = 80

local logo =
{
	"        :::      ::::::::    ",
	"      :+:      :+:    :+:    ",
	"    +:+ +:+         +:+      ",
	"  +#+  +:+       +#+         ",
	"+#+#+#+#+#+   +#+            ",
	"     #+#    #+#              ",
	"    ###   ########." .. countryCode .. "        "
}

local comment =
{
	c = { start = "/*", fill = "*", ["end"] = "*/" }, cpp = c,
	h = c, hpp = cpp,
	lua = {start = "--[[", fill = "-", ["end"] = "]]--"}
}

local function isThereAHeader ()
	local oldHeader = vim.api.nvim_buf_get_lines(0, 0, 11, false)
	local oldHeaderLen = 0
	for _ in pairs(oldHeader) do oldHeaderLen = oldHeaderLen + 1 end
	if (oldHeaderLen ~= 11) then
		return false
	end
	for i = 1, 7 do
		a, b = (oldHeader[i + 2]):find(logo[i], 1, true)
		if (not a or not b) then
			return false
		end
		a = a - 50
		b = b - 50
		if (a ~= 0 or b ~= 24) then
			return false
		end
	end
	return true
end

M.main = function ()
	local fileName = vim.fn.expand("%:t")
	local timestamp = os.date("%Y/%m/%d %H:%H:%S")
	local comm = comment[vim.fn.expand("%:e")] --{ start = "/*", fill = "*", ["end"] = "*/" }
	local bothCommLen = #comm["start"] + #comm["end"]
	local header =
	{
		comm["start"] .. " " .. string.rep(comm["fill"], width - (bothCommLen + 2)) .. " " .. comm["end"],
		comm["start"] .. string.rep(" ", width - bothCommLen) .. comm["end"],
		comm["start"] .. string.rep(" ", width - (#logo[1] + bothCommLen)) .. logo[1] .. comm["end"],
		comm["start"] .. "   " .. fileName .. string.rep(" ", width - (#logo[2] + #fileName + bothCommLen + 3)) .. logo[2] .. comm["end"],
		comm["start"] .. string.rep(" ", width - (#logo[3] + bothCommLen)) .. logo[3] .. comm["end"],
		comm["start"] .. "   By: " .. user .. " <" .. user .. "@student.42." .. countryCode .. ">" .. string.rep(" ", (width - (#logo[4] + #user * 2 + #countryCode + bothCommLen + 22))) .. logo[4] .. comm["end"],
		comm["start"] .. string.rep(" ", width - (#logo[5] + bothCommLen)) .. logo[5] .. comm["end"],
		comm["start"].. "   Created: " .. timestamp .. " by " .. user .. string.rep(" ", width - (#logo[6] + #timestamp + #user + bothCommLen + 16)) .. logo[6] .. comm["end"],
		comm["start"] .. "   Updated: " .. timestamp .. " by " .. user .. string.rep(" ", width - (#logo[7] + #timestamp + #user + bothCommLen + 16)) .. logo[7] .. comm["end"],
		comm["start"] .. string.rep(" ", width - bothCommLen) .. comm["end"],
		comm["start"] .. " " .. string.rep(comm["fill"], width - (bothCommLen + 2)) .. " " .. comm["end"]
	}

	if (not isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	else
		vim.api.nvim_buf_set_lines(0, 0, 7, false, { unpack(header, 1, 7) })
		vim.api.nvim_buf_set_lines(0, 8, 11, false, { unpack(header, 9, 11) })
	end
end

return M
