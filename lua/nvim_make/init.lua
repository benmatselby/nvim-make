local M = {}
local api = require("nvim_make.api")

M.opts = {}

--- Get all make targets from the Makefile in the specified path.
-- @param path string: The path to the codebase containing the Makefile.
-- @return table: A list of target names (strings).
local function get_make_targets(path)
	if not path then
		vim.notify("No valid path for Makefile", vim.log.levels.ERROR)
		return {}
	end

	local file = io.open(path .. "/Makefile", "r")
	if not file then
		vim.notify("Could not open Makefile: " .. path, vim.log.levels.ERROR)
		return {}
	end

	local targets = {}
	for line in file:lines() do
		---@type string|nil
		local target = line:match("^([%w-_%.]+):")
		if target and target ~= ".PHONY" then
			table.insert(targets, target)
		end
	end
	file:close()
	return targets
end

--- Setup function to configure the module.
-- @param opts table: Configuration options.
function M.setup(opts)
	M.opts = opts or {}
end

--- Show a menu to pick a make target and run it.
---@param path? string Optional path to the project containing a Makefile.
---   If nil, the plugin will search for a Makefile from the current buffer's directory.
function M.pick_make_target(path)
	if not path then
		path = vim.fs.root(0, { "Makefile" })
	end

	if not path then
		vim.notify("No Makefile found in project root.", vim.log.levels.ERROR)
		return
	end

	path = vim.fn.expand(path)

	-- Normalize: remove any trailing slashes before extracting the basename
	path = path:gsub("/+$", "")
	local project_name = vim.fs.basename(path)
	if not project_name or project_name == "" then
		project_name = path
	end

	---@type string[]
	local targets = get_make_targets(path)

	if #targets == 0 then
		vim.notify("No make targets found.", vim.log.levels.WARN)
		return
	end

	vim.ui.select(targets, { prompt = project_name }, function(choice)
		if choice then
			local command = "make -C " .. path .. " " .. choice
			api.execute(project_name, command)
		end
	end)
end

return M
