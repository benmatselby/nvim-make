local Job = require("plenary.job")

local M = {}

--- Call the command, and render output in a floating window.
-- @param cmd string: The command to execute.
function M.execute(project_name, cmd)
	-- Split command into parts for Job
	local cmd_parts = vim.split(cmd, " ")
	local command = table.remove(cmd_parts, 1)
	local args = cmd_parts

	-- Create floating window first
	local buf = vim.api.nvim_create_buf(false, true)

	local width = 80
	local height = 20
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " " .. project_name .. " ",
		title_pos = "center",
		focusable = true,
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Close window when clicking outside or losing focus
	local close_events = vim.api.nvim_create_augroup("NvimMakeFloatClose_" .. win, { clear = true })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		group = close_events,
		buffer = buf,
		callback = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})

	-- Also close on <Esc> key
	vim.keymap.set("n", "<Esc>", function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, { buffer = buf, nowait = true })

	-- Create and start the job
	Job:new({
		command = command,
		args = args,
		on_stdout = function(_, data)
			M.update_status(win, buf, { data })
		end,
		on_stderr = function(_, data)
			M.update_status(win, buf, { data })
		end,
		on_exit = function(_, exit_code)
			local data = { "", "Finished command (exit code: " .. exit_code .. ")" }
			M.update_status(win, buf, data)
		end,
	}):start()
end

--- Updates the status for a given window and buffer with the provided data.
-- @param win (number) The window handle where the status should be updated.
-- @param buf (number) The buffer handle associated with the window.
-- @param data (table) The status data to display
function M.update_status(win, buf, data)
	if not data then
		return
	end

	vim.schedule(function()
		local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		vim.list_extend(current_lines, data)
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, current_lines)
			-- Auto-scroll to bottom
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_cursor(win, { #current_lines, 0 })
			end
		end
	end)
end

return M
