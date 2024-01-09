local ts_parser = require("complex.typescript_parser")
assert(ts_parser, "typescript_parser module could not be required???")

local M = {}

---@class Scorer
---@field new fun(self: Scorer, score: (integer | nil), nest: (integer | nil)): Scorer
---@field increment fun(self: Scorer): integer
---@field score fun(self: Scorer): integer
local Scorer = {}
Scorer.__index = Scorer

---@param score integer | nil
---@param nest integer | nil
function Scorer:new(score, nest)
	return setmetatable({
		__score = score or 0,
		__nest = nest or 0,
	}, Scorer)
end

--TODO implement nest level increments
function Scorer:increment()
	self.__score = self.__score + 1
	return self.__score
end

function Scorer:score()
	return self.__score
end

---@param node TSNode
---@return boolean is_loop_node
local is_loop_statement_node = function(node)
	return node:type() == "for_statement" or node:type() == "while_statement"
end

-- TODO augment this functino to return points of score additions and nesting multiplier
---@param node TSNode Top-level node for a function
---@return number complexity
M.calculate_complexity = function(node)
	local scorer = Scorer:new()
	-----------
	local body = ts_parser.get_body_node(node)
	if body == nil then
		error({
			msg = "No function body node found.",
		})
	end

	local body_children_iter = body:iter_children()
	local child = body_children_iter()
	while child ~= nil do
		if is_loop_statement_node(child) then
			scorer:increment()
		end
		child = body_children_iter()
	end

	return scorer:score()
end

return M
