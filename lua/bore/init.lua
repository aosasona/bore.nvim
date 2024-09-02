local M = {}

-- TODO: implement telescope integration

-- https://github.com/ibhagwan/fzf-lua/blob/f7f54dd685cfdf5469a763d3a00392b9291e75f2/lua/fzf-lua/utils.lua#L372-L404
function M.get_visual_selection()
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
	local lines = vim.fn.getline(csrow, cerow)
	local n = M.tbl_length(lines)
	if n <= 0 then
		return ""
	end
	lines[n] = string.sub(lines[n], 1, cecol)
	lines[1] = string.sub(lines[1], cscol)
	return table.concat(lines, "\n")
end

function M.tbl_length(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

M.copy_selected = function()
	-- Get the visually selected lines
	local selected_text = M.get_visual_selection()

	-- Copy the selected text to the clipboard using `bore copy`
	if selected_text ~= "" then
		-- Use a shell command to copy the selected text to the clipboard while preserving newlines
		local shell_cmd = "echo -n " .. vim.fn.shellescape(selected_text) .. " | bore copy"
		vim.fn.system(shell_cmd)
	end
end

-- Paste the most recent text from the clipboard
M.paste_most_recent = function()
	-- FIX: pasting in visual mode
	local paste_output = vim.fn.system("bore paste")
	vim.api.nvim_put(vim.split(paste_output, "\n"), "", true, true)
end

-- Copy a single line in normal mode
M.copy_current_line = function()
	local current_line = vim.api.nvim_get_current_line()
	current_line = vim.fn.escape(current_line, "'")
	vim.fn.system("echo '" .. current_line .. "' | bore copy")
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
		M.paste_most_recent()
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
