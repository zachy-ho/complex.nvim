local ts_parser = require("complex.parsers.typescript")
if not ts_parser then
	error({ msg = "Typescript parser couldn't be required" })
	return
end

local filetype_checker = require("complex.filetype_checker")
local scorer = require("complex.scorer")
local S = require("complex.score")

-- The main API
local M = {}

-- TODO
-- set up default set of tags for different score ranges
-- add optional customization
M.setup = function() end

M.get_function_complexity = filetype_checker.with_check_filetype(function()
	local node = vim.treesitter.get_node()
	local top_level_fn_node = ts_parser.get_top_level_function_node(node)
	if top_level_fn_node == nil then
		print("Node under cursor is not in a function")
		return
	end

	local starting_body_node = ts_parser.get_body_node(top_level_fn_node)
	assert(starting_body_node ~= nil, "Function node doesn't have a body?")

	local ok, result = pcall(scorer.calculate_complexity, starting_body_node, S.Score:new(), S.score_controller)
	if not ok then
		P(result)
		return
	end

	P("Complexity: " .. result)
end)

return M
