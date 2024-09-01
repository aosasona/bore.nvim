local M = {}

-- TODO: implement telescope integration

M.copy_selected = function()
	-- Get the visually selected lines
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local lines = vim.fn.getline(start_line, end_line)

	-- Join the lines into a single string
	local selected_text = table.concat(lines, "\n")

	-- Copy the selected text to the clipboard using `bore copy`
	if selected_text ~= "" then
		-- Escape all special characters in the selected text (e.g. ', \n)
		selected_text = vim.fn.escape(selected_text, "'")
		vim.fn.system("echo '" .. selected_text .. "' | bore copy")
	end
end

-- Paste the most recent text from the clipboard
M.paste_most_recent = function()
	local paste_output = vim.fn.system("bore paste")
	vim.api.nvim_put(vim.split(paste_output, "\n"), "", true, true)
end

-- Copy a single line in normal mode
M.copy_current_line = function()
	local line = vim.fn.getline(".")
	if line ~= "" then
		line = vim.fn.escape(line, "'")
		vim.fn.system("echo '" .. line .. "' | bore copy")
	end
end

M.setup = function()
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
		desc = "Paste text from clipboard using bore",
	})

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
return M
return M
return M
