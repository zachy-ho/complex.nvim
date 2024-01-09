local ts_parser = require("complex.typescript_parser")
assert(ts_parser, "typescript_parser module could not be required???")

local M = {}

-- TODO augment this functino to return points of score additions and nesting multiplier
---@param node TSNode Top-level node for a function
---@return number complexity
M.calculate_complexity = function(node)
	local score = 0
	-- TODO implement nesting
	local nesting = 0
	local get_increment = function()
		return 1
	end
	-----------
	local body = ts_parser.get_body_node(node)

	return score
end

return M
