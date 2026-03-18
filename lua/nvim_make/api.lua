local M = {}

--- Call the command, and render output in a floating window.
-- @param cmd string: The command to execute.
function M.execute(project_name, cmd)
	local ok, Job = pcall(require, "plenary.job")
	if not ok then
		vim.notify("nvim-make: plenary.nvim is required", vim.log.levels.ERROR)
		return
	end

	-- Split command into parts for Job
	local cmd_parts = vim.split(cmd, " ")
	local command = table.remove(cmd_parts, 1)
	local args = cmd_parts

	-- Create floating window with a terminal buffer for ANSI color support
	local buf = vim.api.nvim_create_buf(false, true)

	local width = 80
	local height = 40
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
		footer = "'q' close",
		footer_pos = "center",
		focusable = true,
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Open a terminal emulator in the buffer to render ANSI escape sequences
	local chan = vim.api.nvim_open_term(buf, {})

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

	-- Close on <Esc> key in both normal and terminal modes
	for _, mode in ipairs({ "n", "t" }) do
		vim.keymap.set(mode, "q", function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, { buffer = buf, nowait = true })
	end

	-- Create and start the job
	Job:new({
		command = command,
		args = args,
		on_stdout = function(_, data)
			M.send_output(chan, data)
		end,
		on_stderr = function(_, data)
			M.send_output(chan, data)
		end,
		on_exit = function(_, exit_code)
			M.send_output(chan, "")
			M.send_output(chan, "Finished command (exit code: " .. exit_code .. ")")
		end,
	}):start()
end

--- Sends output data to the terminal channel for display.
-- @param chan (number) The terminal channel id.
-- @param data (string) The output line to display.
function M.send_output(chan, data)
	if not data then
		return
	end

	vim.schedule(function()
		vim.api.nvim_chan_send(chan, data .. "\r\n")
	end)
end

return M
