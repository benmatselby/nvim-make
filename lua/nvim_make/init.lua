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

--- Resolve and normalise a path, returning (path, project_name).
---@param path? string
---@return string|nil, string|nil
local function resolve_path(path)
	if not path then
		path = vim.fs.root(0, { "Makefile" })
	end

	if not path then
		vim.notify("No Makefile found in project root.", vim.log.levels.ERROR)
		return nil, nil
	end

	path = vim.fn.expand(path)

	-- Normalize: remove any trailing slashes before extracting the basename
	path = path:gsub("/+$", "")
	local project_name = vim.fs.basename(path)
	if not project_name or project_name == "" then
		project_name = path
	end

	return path, project_name
end

--- Show a picker to select one or more make targets and run them in order.
--- Use <Tab> to select multiple targets; <CR> confirms and runs them.
--- If only <CR> is pressed without any <Tab> selections, the target under
--- the cursor is run. Requires folke/snacks.nvim.
---@param path? string Optional path to the project containing a Makefile.
---   If nil, the plugin will search for a Makefile from the current buffer's directory.
function M.pick_make_target(path)
	local ok, Snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("nvim-make: snacks.nvim is required", vim.log.levels.ERROR)
		return
	end

	local resolved_path, project_name = resolve_path(path)
	if not resolved_path then
		return
	end

	---@type string[]
	local targets = get_make_targets(resolved_path)

	if #targets == 0 then
		vim.notify("No make targets found.", vim.log.levels.WARN)
		return
	end

	-- Convert target strings into snacks picker items
	local items = {}
	for _, target in ipairs(targets) do
		table.insert(items, { text = target })
	end

	-- Tracks the targets in the order the user pressed <Tab> on them.
	-- Keys are target text, value is the insertion position (1-based).
	local selection_order = {}
	local ordered = {}

	Snacks.picker.pick({
		title = project_name,
		items = items,
		format = "text",
		layout = { preset = "select" },
		actions = {
			-- Override <Tab> so we record insertion order while still delegating
			-- the visual toggle to Snacks' built-in select_and_next action.
			nvim_make_toggle = function(picker)
				local item = picker:current()
				if not item then
					return
				end
				local key = item.text
				if selection_order[key] then
					-- Deselect: remove from the ordered list
					selection_order[key] = nil
					for i, t in ipairs(ordered) do
						if t == key then
							table.remove(ordered, i)
							break
						end
					end
				else
					-- Select: append to the ordered list
					table.insert(ordered, key)
					selection_order[key] = #ordered
				end
				-- Delegate to Snacks to update the visual selection state and
				-- advance the cursor.
				Snacks.picker.actions.select_and_next(picker)
			end,
		},
		win = {
			input = {
				keys = {
					["<Tab>"] = { "nvim_make_toggle", mode = { "i", "n" } },
				},
			},
			list = {
				keys = {
					["<Tab>"] = { "nvim_make_toggle", mode = { "i", "n" } },
				},
			},
		},
		confirm = function(picker)
			local current = picker:current()
			picker:close()

			-- If nothing was explicitly tabbed, fall back to the item under the
			-- cursor (single-select behaviour).
			if #ordered == 0 then
				if current then
					api.execute(project_name, { "make", "-C", resolved_path, current.text })
				end
				return
			end

			local cmd_parts = { "make", "-C", resolved_path }
			for _, target in ipairs(ordered) do
				table.insert(cmd_parts, target)
			end
			api.execute(project_name, cmd_parts)
		end,
	})
end

return M
