local M = {}

function M.check_module(module)
	local ok = pcall(require, module)
	if not ok then
		vim.notify(string.format("Module '%s' cannot be required :(", module), vim.log.levels.ERROR)
	end
	return ok
end

function M.P(ting)
	print(vim.inspect(ting))
end

return M
