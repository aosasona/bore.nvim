local base64 = require("bore.base64")

local M = {}

-- TODO: implement telescope integration

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

-- Utility function to use `bore copy` to copy the selected text to the clipboard
function M.copy_text(text)
	-- Copy the selected text to the clipboard using `bore copy`
	if text ~= "" then
		-- Use a shell command to copy the selected text to the clipboard while preserving newlines
		local shell_cmd = "echo '"
			.. vim.fn.shellescape(base64.encode(text, nil, true))
			.. "' | bore copy --format=base64"
		vim.fn.system(shell_cmd)
	end
end

-- Copy the visually selected text to the clipboard
function M.copy_selected()
	-- Get the visually selected lines
	local selected_text = M.get_visual_selection()
	M.copy_text(selected_text)
end

-- Get the most recent text from the clipboard
function M.get_last_item()
	local paste_output = vim.fn.system("bore paste")
	if vim.v.shell_error == 0 then
		-- Remove the ^A character from the output
		paste_output = string.gsub(paste_output, "\001", "")
		return paste_output
	end
	return nil
end

-- Paste the most recent text from the clipboard
function M.paste_last()
	local text = M.get_last_item()
	if text == nil then
		return
	end

	vim.api.nvim_put(vim.split(text, "\n"), "", true, true)
end

-- Copy a single line in normal mode
function M.copy_current_line()
	local current_line = vim.api.nvim_get_current_line()
	M.copy_text(current_line)
end

M.setup = function(opts)
	-- Create user commands for copying and pasting text using bore
	vim.api.nvim_create_user_command("BoreCopy", function()
		M.copy_selected()
	end, {
		range = true,
		desc = "Copy selected text to clipboard using bore",
	})

	vim.api.nvim_create_user_command("BorePaste", function()
		M.paste_last()
	end, {
		range = true,
		desc = "Paste text from clipboard using bore",
	})

	local use_default_keybindings = opts["use_default_keybindings"] ~= nil and opts["use_default_keybindings"] or false
	if not use_default_keybindings then
		-- Use custom keybindings
		vim.api.nvim_set_keymap("n", "<leader>y", ":BoreCopy<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>p", ":BorePaste<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("v", "<leader>y", ":BoreCopy<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>yy",
			':lua require("bore").copy_current_line()<CR>',
			{ noremap = true, silent = true }
		)
		vim.api.nvim_set_keymap("v", "<leader>p", ":BorePaste<CR>", { noremap = true, silent = true })
		return
	end

	-- Override `y` and `yy` to use BoreCopy
	vim.api.nvim_set_keymap(
		"n",
		"yy",
		':lua require("bore").copy_current_line()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap("n", "y", ":BoreCopy<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "y", ":BoreCopy<CR>", { noremap = true, silent = true })

	-- Override `p` to use BorePaste
	vim.api.nvim_set_keymap("n", "p", ":BorePaste<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("v", "p", ":BorePaste<CR>", { noremap = true, silent = true })
end

return M
