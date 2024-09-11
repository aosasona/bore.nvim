local base64 = require("bore.base64")
local utils = require("bore.utils")

local M = {}

-- Returns a table matching the `vim.g.clipboard` "provider"
function M.get_provider()
	local copy = function(text, _)
		M.copy_text(text)
	end

	return {
		name = "Bore",
		copy = {
			["+"] = copy,
			["*"] = copy,
		},
		paste = {
			["+"] = M.get_last_item,
			["*"] = M.get_last_item,
		},
	}
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
	local selected_text = utils.get_visual_selection()
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

return M
