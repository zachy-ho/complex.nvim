local ts_parser = require("complex.parsers.typescript")
assert(ts_parser, "typescript_parser module could not be required???")

---@param initial integer
---@param nest integer
local create_score_controller = function(initial, nest)
	local score = initial
	local increment = function()
		score = score + nest + 1
		return score
	end
	---@param n integer
	local increment_by = function(n)
		score = score + n
		return score
	end
	local get_score = function()
		return score
	end

	return increment, increment_by, get_score
end

local M = {}

M.get_if_complexity = function(node, nest)
	assert(ts_parser.is_if_statement_node(node), "Called get_if_complexity on a non if_statement node")
	local increment, increment_by, get_score = create_score_controller(0, nest)
	-- Increment for the if statement itself
	increment()
	-- Increment by the complexity of the consequence body
	increment_by(M.calculate_complexity(ts_parser.get_consequence_node(node), nest + 1))
	-- Increment by the complexity of the alternative
	local alternative = ts_parser.get_alternative_node(node)
	if alternative ~= nil then
		if alternative:child(1):type() == "if_statement" then
			-- `else if (pred) {}`
			increment_by(M.get_if_complexity(alternative:child(1), nest))
		elseif alternative:child(1):type() == "statement_block" then
			-- `else {}`
			increment()
			increment_by(M.calculate_complexity(alternative:child(1), nest + 1))
		end
	end

	return get_score()
end

---@param node TSNode Loop statement node
---@param nest integer
M.get_loop_complexity = function(node, nest)
	assert(ts_parser.is_loop_statement_node(node), "Called get_loop_complexity for a non loop statement node")
	local increment, increment_by, get_score = create_score_controller(0, nest)

	-- Increment for the loop statement itself
	increment()
	local body_node = assert(ts_parser.get_loop_body_node(node), "Loop doesn't have a body node for some reason?")
	-- Calculate complexity for the loop body
	increment_by(M.calculate_complexity(body_node, nest + 1))

	return get_score()
end

-- TODO augment this function to return points of score additions and nesting multiplier
---@param node TSNode Top-level node from which children nodes can be iterated
---@param nest integer Nesting level of node's scope
---@return number complexity
M.calculate_complexity = function(node, nest)
	local increment, increment_by, get_score = create_score_controller(0, nest)

	-- For each child of node
	-- - increment for itself
	-- - if it adds a nesting level, increment score by calculate_complexity(node, nest_level)
	local get_next_child = node:iter_children()
	local child = get_next_child()
	while child ~= nil do
		if ts_parser.is_loop_statement_node(child) then
			increment_by(M.get_loop_complexity(child, nest))
		elseif ts_parser.is_if_statement_node(child) then
			increment_by(M.get_if_complexity(child, nest))
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

	return get_score()
end

return M
