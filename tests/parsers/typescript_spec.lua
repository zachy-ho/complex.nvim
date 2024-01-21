local ts_parser = require("complex.parsers.typescript")
if not ts_parser then
	return
end

describe("get_top_level_function_node", function()
	local buf = vim.api.nvim_create_buf(false, true)

	it("returns the top level function node for a simple function", function()
		vim.api.nvim_buf_set_option(buf, "filetype", "typescript")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"function basicFn() {",
			"  console.log('basicFn');",
			"}",
		})

		local node = vim.treesitter.get_node({
			bufnr = buf,
			pos = {
				1,
				0,
			},
		})

		local outermost_fn = ts_parser.get_top_level_function_node(node)
		assert(outermost_fn ~= nil)

		local function_name
		for child in outermost_fn:iter_children() do
			if child:type() == "identifier" then
				function_name = vim.treesitter.get_node_text(child, buf)
				break
			end
		end
		assert.equal(function_name, "basicFn")
	end)

	it("returns nil if the node parameter is not in a function", function()
		vim.api.nvim_buf_set_option(buf, "filetype", "typescript")
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
			"const foo = 1",
			"const bar = 'hi'",
			"function fn() {}",
		})

		local node = vim.treesitter.get_node({
			bufnr = buf,
			pos = {
				1,
				0,
			},
		})

		local outermost_fn = ts_parser.get_top_level_function_node(node)
		assert(outermost_fn ~= nil)

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
