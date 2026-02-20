local M = {}

function M.check()
	vim.health.start("nvim-make")

	-- Check Neovim version
	if vim.fn.has("nvim-0.10") == 1 then
		vim.health.ok("Neovim >= 0.10")
	else
		vim.health.error("Neovim >= 0.10 is required")
	end

	-- Check for plenary.nvim
	local has_plenary, _ = pcall(require, "plenary")
	if has_plenary then
		vim.health.ok("plenary.nvim is installed")
	else
		vim.health.error("plenary.nvim is required but not found", {
			"Install plenary.nvim: https://github.com/nvim-lua/plenary.nvim",
		})
	end

	-- Check for make binary
	if vim.fn.executable("make") == 1 then
		vim.health.ok("make is available")
	else
		vim.health.error("make executable not found in PATH")
	end

	-- Check for Makefile in project root
	local makefile_root = vim.fs.root(0, { "Makefile" })
	if makefile_root then
		vim.health.ok("Makefile found in " .. makefile_root)
	else
		vim.health.warn("No Makefile found in project root")
	end
end

return M
