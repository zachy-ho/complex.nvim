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

-- Returns a new list with table2 concatenated on table1
---@param table1 table keyed table
---@param table2 table keyed table
---@return table merged { ...table1, ...table2 }
function M.concat(table1, table2)
	local merged = {}
	for _, v in ipairs(table1) do
		table.insert(merged, v)
	end
	for _, v in ipairs(table2) do
		table.insert(merged, v)
	end
	return merged
end

return M
