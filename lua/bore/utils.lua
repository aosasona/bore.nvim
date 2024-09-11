local M = {}

-- https://github.com/ibhagwan/fzf-lua/blob/f7f54dd685cfdf5469a763d3a00392b9291e75f2/lua/fzf-lua/utils.lua#L372-L404
function M.get_selected_positions()
	-- this will exit visual mode
	-- use 'gv' to reselect the text
	local _, csrow, cscol, cerow, cecol
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "" then
		-- if we are in visual mode use the live position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("."))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
		if mode == "V" then
			-- visual line doesn't provide columns
			cscol, cecol = 0, 999
		end
		-- exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- otherwise, use the last known visual position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
	end
	-- swap vars if needed
	if cerow < csrow then
		csrow, cerow = cerow, csrow
	end
	if cecol < cscol then
		cscol, cecol = cecol, cscol
	end

	return {
		start_row = csrow,
		start_col = cscol,
		end_row = cerow,
		end_col = cecol,
	}
end

-- Get the visually selected text
function M.get_visual_selection()
	local pos = M.get_selected_positions()
	local lines = vim.fn.getline(pos.start_row, pos.end_row)

	local n = M.tbl_length(lines)
	if n <= 0 then
		return ""
	end

	lines[n] = string.sub(lines[n], 1, pos.end_col)
	lines[1] = string.sub(lines[1], pos.start_col)
	return table.concat(lines, "\n")
end

function M.tbl_length(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

return M
