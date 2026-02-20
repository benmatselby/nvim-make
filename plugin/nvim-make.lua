-- nvim-make plugin loader
-- This file is automatically loaded when the plugin is installed

if vim.g.loaded_nvim_make then
	return
end
vim.g.loaded_nvim_make = true

vim.api.nvim_create_user_command("NvimMake", function()
	require("nvim_make").pick_make_target()
end, {
	desc = "Pick and run a make target",
})
