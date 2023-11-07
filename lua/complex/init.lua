-- what do i need?
--> rendering module
--> input parsing module
--> complexity calculation module

local ok = check_module("nvim-treesitter.ts_utils")
if not ok then
	print("node_fetcher module will not work because nvim-treesitter.ts_utils cannot be required")
	return false
end
local ts_utils = require("nvim-treesitter.ts_utils")

local node_fetcher = {}

---@return TSNode | nil
node_fetcher.get_outermost_fn = function()
	local node = ts_utils.get_node_at_cursor()
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

	if outermost_fn ~= nil then
		ts_utils.update_selection(vim.api.nvim_get_current_buf(), outermost_fn)
	end
	return outermost_fn
end

return node_fetcher
