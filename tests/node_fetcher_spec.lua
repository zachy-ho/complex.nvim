local ts_utils = require("nvim-treesitter.ts_utils")
local node_finder = require("complex")

local P = function(ting)
	print(vim.inspect(ting))
end

describe("get_outermost_fn_node", function()
	local buf = vim.api.nvim_create_buf(false, true)

	it("finds the outermost function node", function()
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"function basicFn() {",
			"  console.log('basicFn');",
			"}",
		})
		vim.api.nvim_buf_set_option(buf, "filetype", "typescript")

		local node = vim.treesitter.get_node({
			bufnr = buf,
			pos = {
				1,
				0,
			},
		})

		local outermost_fn = node_finder.get_outermost_fn_node(node)

		local function_name
		for child in outermost_fn:iter_children() do
			if child:type() == "identifier" then
				function_name = vim.treesitter.get_node_text(child, buf)
				break
			end
		end
		assert.equal(function_name, "basicFn")
	end)
end)
