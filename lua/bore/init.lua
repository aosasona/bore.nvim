local clipboard = require("bore.clipboard")
local M = {}

-- TODO: implement telescope integration
--
-- Create user commands
function M.create_commands()
	-- Create user commands for copying and pasting text using bore
	vim.api.nvim_create_user_command("BoreCopy", clipboard.copy_selected, {
		range = true,
		desc = "Copy selected text to clipboard using bore",
	})

	vim.api.nvim_create_user_command("BorePaste", clipboard.paste_last, {
		range = true,
		desc = "Paste text from clipboard using bore",
	})
end

-- Create keybindings
function M.create_keybindings()
	local set_keymap = vim.api.nvim_set_keymap

	-- Normal mode
	set_keymap("n", "<leader>y", ":BoreCopy<CR>", { noremap = true, silent = true })

	set_keymap("n", "<leader>p", ":BorePaste<CR>", { noremap = true, silent = true })

	set_keymap(
		"n",
		"<leader>yy",
		':lua require("bore.clipboard").copy_current_line()<CR>',
		{ noremap = true, silent = true }
	)

	-- Visual mode
	set_keymap("v", "<leader>y", ":BoreCopy<CR>", { noremap = true, silent = true })

	set_keymap("v", "<leader>p", ":BorePaste<CR>", { noremap = true, silent = true })
end

function M.setup(_opts)
	local opts = _opts or {}

	local use_as_provider = opts.use_as_provider or false
	if use_as_provider then
		vim.g.clipboard = clipboard.get_provider()
	end

	M.create_commands()
	M.create_keybindings()
end

return M
