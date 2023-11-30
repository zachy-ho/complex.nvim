local helpers = require("complex.helpers")
local ok = helpers.check_module("nvim-treesitter.ts_utils")
if not ok then
	print("Node finder module will not work because nvim-treesitter.ts_utils cannot be required")
	return false
end
local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

---@param node TSNode
---@return TSNode | nil
M.get_outermost_fn_node = function(node)
	if node == nil then
		print("No parsed node at cursor")
		return
	end

	local parent = node:parent()
	local root = ts_utils.get_root_for_node(node)
	local outermost_fn = node:type() == "function_declaration" and node or nil

	-- Go all the way to the top of the file/module
	while parent ~= nil and parent ~= root do
		if parent:type() == "function_declaration" then
			outermost_fn = parent
		end
		parent = parent:parent()
	end

	return outermost_fn
end

return M
