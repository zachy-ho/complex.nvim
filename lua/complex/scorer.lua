local ts_parser = require("complex.parsers.typescript")
assert(ts_parser, "typescript_parser module could not be required???")

local M = {}

local handle_if_statement = function(node, nest)
	local score = 0
	local increment = function()
		score = score + nest + 1
		return score
	end
	---@param n integer
	local increment_by = function(n)
		score = score + n
		return score
	end
	-- increment for the 'if' itself
	increment()
	-- handle consequence block
	increment_by(M.calculate_complexity(ts_parser.get_consequence_node(node), nest + 1))
	-- handle alternative
	local alternative = ts_parser.get_alternative_node(node)
	if alternative ~= nil then
		if alternative:child(1):type() == "if_statement" then
			increment_by(M.calculate_complexity(alternative, nest))
		elseif alternative:child(1):type() == "statement_block" then
			increment()
			increment_by(M.calculate_complexity(alternative:child(1), nest + 1))
		end
	end
	return score
end

-- TODO augment this functino to return points of score additions and nesting multiplier
---@param node TSNode Top-level node from which children nodes can be iterated
---@param nest integer Nesting level of node's scope
---@return number complexity
M.calculate_complexity = function(node, nest)
	local score = 0
	local increment = function()
		score = score + nest + 1
		return score
	end
	---@param n integer
	local increment_by = function(n)
		score = score + n
		return score
	end

	-- For each child of node
	-- - increment for itself
	-- - if it adds a nesting level, increment score by calculate_complexity(node, nest_level)
	local get_next_child = node:iter_children()
	local child = get_next_child()
	while child ~= nil do
		if ts_parser.is_loop_statement_node(child) then
			-- loop
			increment()
			local body_node =
				assert(ts_parser.get_loop_body_node(child), "Loop doesn't have a body node for some reason?")
			increment_by(M.calculate_complexity(body_node, nest + 1))
		elseif ts_parser.is_if_statement_node(child) then
			increment_by(handle_if_statement(child, nest))
		elseif false then
		-- catch
		elseif false then
		-- function declaration
		elseif false then
		-- break or continue
		elseif false then
		-- sequence of binary operators
		elseif false then
			-- recursion call
		end
		child = get_next_child()
	end

	return score
end

return M
