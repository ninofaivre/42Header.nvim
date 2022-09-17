local M = {}
local user = vim.g.user42
if (not user) then
	user = "marvin"
end
local logo =
{
	"        :::      ::::::::",
	"      :+:      :+:    :+:",
	"    +:+ +:+         +:+  ",
	"  +#+  +:+       +#+     ",
	"+#+#+#+#+#+   +#+        ",
	"     #+#    #+#          ",
	"    ###   ########.fr    "
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
	local header =
	{
	"/* " .. string.rep("*", 74) .. " */",
	"/*" .. string.rep(" ", 76) .. "*/",
	"/*" .. string.rep(" ", 47) .. logo[1] .. "    */",
	"/*   " .. fileName .. string.rep(" ", (44 - string.len(fileName))) .. logo[2] .. "    */",
	"/*" .. string.rep(" ", 47) .. logo[3] .. "    */",
	"/*   By: " .. user .. " <" .. user .. "@student.42.fr>" .. string.rep(" ", (23 - (2 * string.len(user)))) .. logo[4] .. "    */",
	"/*" .. string.rep(" ", 47) .. logo[5] .. "    */",
	"/*   Created: " .. timestamp .. " by " .. user .. string.rep(" ", (31 - string.len(timestamp) - string.len(user))) .. logo[6] .. "    */",
	"/*   Updated: " .. timestamp .. " by " .. user .. string.rep(" ", (31 - string.len(timestamp) - string.len(user))) .. logo[7] .. "    */",
	"/*" .. string.rep(" ", 76) .. "*/",
	"/* " .. string.rep("*", 74) .. " */"
	}

	if (not isThereAHeader()) then
		vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
	else
		vim.api.nvim_buf_set_lines(0, 0, 7, false, { unpack(header, 1, 7) })
		vim.api.nvim_buf_set_lines(0, 8, 11, false, { unpack(header, 9, 11) })
	end
end

return M
