local utils = require("complex.utils")
local ts_parser = require("complex.parsers.typescript")
assert(ts_parser, "typescript_parser module could not be required???")

Comparable = {
	BASIC = "basic",
}

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

---@param node TSNode
local is_equality_comparator = function(node)
	return node:type() == "<"
		or node:type() == ">"
		or node:type() == "<="
		or node:type() == ">="
		or node:type() == "<=="
		or node:type() == ">=="
		or node:type() == "=="
		or node:type() == "==="
end

---@generic T: table | string
---@param comparable T
---@return T
local validate_comparable = function(comparable)
	if type(comparable) == "string" and comparable ~= Comparable.BASIC then
		error(
			string.format(
				"Comparable is invalid. Comparable can only be of type table or %s. %s has been provided instead.",
				Comparable.BASIC,
				comparable
			)
		)
	end
	return comparable
end

local M = {}

---@param expression table A list of symbols, representing a boolean expression. Callers should use `flatten_boolean_expression` to generate this list.
---@param nest integer nesting level
--Will throw if `expression` input is invalid
M.calculate_boolean_expression_complexity = function(expression, nest)
	if utils.size(expression) == 0 then
		error("Trying to calculate complexity for a sequence of length 0")
	end
	if math.fmod(utils.size(expression), 2) == 0 then
		error("Sequence has invalid length of " .. tostring(utils.size(expression)))
	end

	local increment, increment_by, get_score = create_score_controller(0, nest)

	if utils.size(expression) == 1 then
		local comparable = validate_comparable(expression[1])
		if type(comparable) == "table" then
			return increment_by(M.calculate_boolean_expression_complexity(expression[1], nest))
		else
			return 0
		end
	end

	increment() -- A binary boolean operation costs at least 1 complexity
	local last_operator = expression[2]
	for i = 3, utils.size(expression), 2 do
		local comparable = validate_comparable(expression[i])
		local operator = expression[i + 1]
		if type(comparable) == "table" then
			increment_by(M.calculate_boolean_expression_complexity(comparable, nest))
		end
		if operator ~= nil and last_operator ~= operator then
			increment()
			last_operator = operator
		end
	end
	return get_score()
end

---@param node TSNode
---@return table
M.flatten_boolean_expression = function(node)
	-- Basic base cases
	if
		node:type() == "true"
		or node:type() == "false"
		or node:type() == "number"
		or node:type() == "string"
		or node:type() == "identifier"
		or node:type() == "null"
		or node:type() == "undefined"
		or node:type() == "update_expression"
		or node:type() == "call_expression"
	then
		return { Comparable.BASIC }
	end

	-- Unary expression base case
	if node:type() == "unary_expression" then
		if node:child(0):type() == "!" then
			return M.flatten_boolean_expression(node:child(1))
		else
			local iter = node:iter_children()
			local child = iter()
			local concatenated_children = ""
			while child ~= nil do
				concatenated_children = "" .. child:type() .. " "
				child = iter()
			end
			error(
				"unary_expression that doesn't start with a `!` is not supported. This unary_expression looks like "
					.. concatenated_children
			)
		end
	end

	-- Put parenthesized_expressions in an inner table
	if node:type() == "parenthesized_expression" then
		return { M.flatten_boolean_expression(node:child(1)) }
	end

	assert(
		node:type() == "binary_expression",
		node:type() .. " type should have been handled as a base case before this point."
	)

	local left = node:child(0)
	local operator = node:child(1)
	local right = node:child(2)
	if is_equality_comparator(operator) then
		return { Comparable.BASIC }
	end
	local left_flattened = M.flatten_boolean_expression(left)
	local right_flattened = M.flatten_boolean_expression(right)
	local flattened = utils.concat(utils.concat(left_flattened, { operator:type() }), right_flattened)
	return flattened
end

---@param node TSNode
---@param nest integer
M.calculate_if_complexity = function(node, nest)
	assert(ts_parser.is_if_statement_node(node), "Called get_if_complexity on a non if_statement node")
	local increment, increment_by, get_score = create_score_controller(0, nest)
	-- Increment for the if statement itself
	increment()
	-- Increment for the condition
	increment_by(M.calculate_boolean_expression_complexity(M.flatten_boolean_expression(node:child(1)), nest))
	-- Increment by the complexity of the consequence body
	increment_by(M.calculate_complexity(ts_parser.get_consequence_node(node), nest + 1))
	-- Increment by the complexity of the alternative
	local alternative = ts_parser.get_alternative_node(node)
	if alternative ~= nil then
		if alternative:child(1):type() == "if_statement" then
			-- `else if (predicate)`
			increment_by(M.calculate_if_complexity(alternative:child(1), nest))
		elseif alternative:child(1):type() == "statement_block" then
			-- `else`
			increment()
			increment_by(M.calculate_complexity(alternative:child(1), nest + 1))
		end
	end

	return get_score()
end

---@param node TSNode Loop statement node
---@param nest integer
M.calculate_loop_complexity = function(node, nest)
	assert(ts_parser.is_loop_statement_node(node), "Called get_loop_complexity for a non loop statement node")
	local increment, increment_by, get_score = create_score_controller(0, nest)

	-- Increment for the loop statement itself
	increment()
	local body_node = assert(ts_parser.get_statement_block_node(node), "Loop doesn't have a body node for some reason?")
	-- Calculate complexity for the loop body
	increment_by(M.calculate_complexity(body_node, nest + 1))

	return get_score()
end

M.calculate_catch_complexity = function(node, nest)
	local increment, increment_by, get_score = create_score_controller(0, nest)
	local catch = ts_parser.get_catch_node(node)
	if catch then
		increment()
		local statement = ts_parser.get_statement_block_node(catch)
		if statement then
			increment_by(M.calculate_complexity(statement, nest + 1))
		end
	end
	return get_score()
end

---@param node TSNode
---@param nest integer Nesting level of node's scope
---@return number complexity
M.calculate_complexity = function(node, nest)
	local _, increment_by, get_score = create_score_controller(0, nest)

	-- Base cases
	if ts_parser.is_loop_statement_node(node) then
		return increment_by(M.calculate_loop_complexity(node, nest))
	elseif ts_parser.is_if_statement_node(node) then
		return increment_by(M.calculate_if_complexity(node, nest))
	elseif ts_parser.is_try_statement_node(node) then
		return increment_by(M.calculate_catch_complexity(node, nest))
	elseif ts_parser.is_binary_expression_node(node) then
		return increment_by(M.calculate_boolean_expression_complexity(M.flatten_boolean_expression(node), nest))
	elseif false then
		-- function declaration
	elseif false then
		-- recursion call
	end

	-- Otherwise, increment complexity for each child of node
	local get_next_child = node:iter_children()
	local child = get_next_child()
	while child ~= nil do
		increment_by(M.calculate_complexity(child, nest))
		child = get_next_child()
	end

	return get_score()
end

return M
