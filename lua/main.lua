local M = {}

-- TODO
-- real time global var usage update
-- check for max-length
--
local user = vim.g.user42 or "marvin"
local width = vim.g.Header42Width or 80

local countryCode = vim.g.countryCode or "fr"
if (#countryCode ~= 2) then
	countryCode = "fr"
end

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

local commentTable =
{
	c = { start = "/*", fill = "*", ["end"] = "*/" }, h = c,
	cpp = c, hpp = cpp,
	lua = { start = "--[[", fill = "-", ["end"] = "]]--" },
	default = { start = "#", fill = "#", ["end"] = "#" },
	sh = default,
	bash = default,
	html = { start = "<!--", fill = "-", ["end"] = "-->"}
}

-- need a bit more protection
if (vim.g.commentTable) then
	for k, v in pairs(vim.g.commentTable) do
		if (v["start"] and v["fill"] and v["end"]) then
			commentTable[k] = v
		end
	end
end

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
	end
	return true
end

M.main = function ()
	local fileName = vim.fn.expand("%:t")
	local time = os.date("%Y/%m/%d %H:%H:%S")
	local comment = commentTable[vim.fn.expand("%:e")] or commentTable["default"]
	local SELen = #comment["start"] + #comment["end"]
	local header =
	{
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[1] + SELen)) .. logo[1] .. comment["end"],
		comment["start"] .. "   " .. fileName .. string.rep(" ", width - (#logo[2] + #fileName + SELen + 3)) .. logo[2] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[3] + SELen)) .. logo[3] .. comment["end"],
		comment["start"] .. "   By: " .. user .. " <" .. user .. "@student.42." .. countryCode .. ">"
			.. string.rep(" ", (width - (#logo[4] + #user * 2 + #countryCode + SELen + 22))) .. logo[4] .. comment["end"],
		comment["start"] .. string.rep(" ", width - (#logo[5] + SELen)) .. logo[5] .. comment["end"],
		comment["start"].. "   Created: " .. time .. " by " .. user .. string.rep(" ", width - (#logo[6] + #time + #user + SELen + 16)) .. logo[6] .. comment["end"],
		comment["start"] .. "   Updated: " .. time .. " by " .. user .. string.rep(" ", width - (#logo[7] + #time + #user + SELen + 16)) .. logo[7] .. comment["end"],
		comment["start"] .. string.rep(" ", width - SELen) .. comment["end"],
		comment["start"] .. " " .. string.rep(comment["fill"], width - (SELen + 2)) .. " " .. comment["end"]
	}

	if (not isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	else
		vim.api.nvim_buf_set_lines(0, 0, 7, false, { unpack(header, 1, 7) })
		-- TODO
		-- override comm["start"] and comm["end"]
		--
		vim.api.nvim_buf_set_lines(0, 8, 11, false, { unpack(header, 9, 11) })
	end
end

return M
