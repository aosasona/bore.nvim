local health = vim.health or require("health")

local M = {}

M.check = function()
  health.start("Checking for bore binary")
  if vim.fn.executable("bore") == 0 then
    health.error(
      "bore binary not found, make sure it is installed and in your PATH, you can get bore at github.com/aosasona/bore"
    )
  else
    health.ok("bore binary installed")
  end
end

return M
