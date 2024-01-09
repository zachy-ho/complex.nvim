local helpers = require("complex.helpers")
local ok = helpers.check_module("nvim-treesitter.ts_utils")
if not ok then
	print("Node finder module will not work because nvim-treesitter.ts_utils cannot be required")
	return false
end
local ts_utils = require("nvim-treesitter.ts_utils")

-- This module only handles typescript
local M = {}

---@param node TSNode
local is_lexical_declaration_of_arrow_function = function(node)
	-- child(1) is the "variable_declarator" node
	-- child(0) of the "variable_declarator" node is the "identifier"
	-- child(1) of the "variable_declarator" node is the "=" sign
	return node:type() == "lexical_declaration" and node:child(1):child(2):type() == "arrow_function"
end

---@param node TSNode
---@return boolean is_function_declaration
local is_function_declaration = function(node)
	return node:type() == "function_declaration"
end

---@param node TSNode
---@return boolean is_function
local is_top_level_node_of_function = function(node)
	return is_function_declaration(node) or is_lexical_declaration_of_arrow_function(node)
end

---@param node TSNode
---@return TSNode | nil
M.get_top_level_function_node = function(node)
	local current_node = node
	local root = ts_utils.get_root_for_node(node)
	local outermost_fn

	-- Go all the way to the top of the file/module
	while current_node ~= nil and current_node ~= root do
		if is_top_level_node_of_function(current_node) then
			outermost_fn = current_node
		end
		current_node = current_node:parent()
	end

	return outermost_fn
end

---@param node TSNode top-level function node
---@return TSNode
M.get_body_node = function(node)
	if is_function_declaration(node) then
		return node:child(3)
	end

	if is_lexical_declaration_of_arrow_function(node) then
		P(node:child(1):child(2):child(2):child_count())
		P(node:child(1):child(2):child(2):child(0):type())
		P(node:child(1):child(2):child(2):child(1):type())
		P(node:child(1):child(2):child(2):child(2):type())
		P(node:child(1):child(2):child(2):child(3):type())
		P(node:child(1):child(2):child(2):child(4):type())
		P(node:child(1):child(2):child(2):child(5):type())
		return node:child(1):child(2):child(2)
	end
end

return M
