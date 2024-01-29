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

---@param t table
---@return number size of table
function M.size(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

return M
