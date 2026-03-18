-- nvim-make plugin loader
-- This file is automatically loaded when the plugin is installed

if vim.g.loaded_nvim_make then
	return
end
vim.g.loaded_nvim_make = true

vim.api.nvim_create_user_command("NvimMake", function(cmd_opts)
	local path = nil
	if cmd_opts.args ~= "" then
		path = cmd_opts.args
	end
	require("nvim_make").pick_make_target(path)
end, {
	nargs = "?",
	complete = "dir",
	desc = "Pick and run make targets",
})
