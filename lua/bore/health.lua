local health = vim.health or require("health")

local M = {}

M.check = function()
	health.start("Checking if bore is installed")
	if vim.fn.executable("bore") == 0 then
		health.error(
			"bore binary not found, make sure it is installed and in your PATH variable, you can get bore at github.com/aosasona/bore/releases"
		)
	else
		health.ok("bore is installed")
	end
end

return M
