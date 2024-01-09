local ts_parser = require("complex.typescript_parser")
assert(ts_parser, "typescript_parser module could not be required???")

-- local ts_utils = require("nvim_treesitter.ts_utils")

local filetype_checker = require("complex.filetype_checker")
local scorer = require("complex.scorer")

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

	P(scorer.calculate_complexity(top_level_fn_node))
end)

return M
