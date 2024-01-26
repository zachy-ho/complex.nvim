local ts_parser = require("complex.parsers.typescript")
if not ts_parser then
	return
end

local create_typescript_buf = function()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "filetype", "typescript")
	return buf
end

describe("typescript parser", function()
	describe("get_top_level_function_node", function()
		it("returns the top level function node for a simple function", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  console.log('basicFn');",
				"}",
			})

			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
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
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"const foo = 1",
				"const bar = 'hi'",
				"function fn() {}",
			})

			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})

			local outermost_fn = ts_parser.get_top_level_function_node(node)
			assert.is_nil(outermost_fn)
		end)
	end)

	describe("get_consequence_node", function()
		it("returns the consequence node for an if_statement node", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {",
				"  } else {",
				"  }",
				"}",
			})

			local if_statement_node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 2 },
			})

			local consequence_node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 2, 2 },
			})

			assert.equal(ts_parser.get_consequence_node(if_statement_node), consequence_node)
		end)

		it("will throw an error if called with a non if_statement TSNode", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  local foo = 1",
				"}",
			})

			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 2 },
			})

			assert.has_error(function()
				ts_parser.get_consequence_node(node)
			end)
		end)
	end)

	describe("get_alternative_node", function()
		it("returns the alternative node for an if_statement node if there is an alternative", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {",
				"  } else {",
				"  }",
				"}",
			})

			local if_statement_node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 2 },
			})

			local alternative_node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 2, 4 },
			})

			assert.equal(ts_parser.get_alternative_node(if_statement_node), alternative_node)
		end)

		it("returns nil if the if_statement doesn't have an alternative", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {",
				"  }",
				"}",
			})

			local if_statement_node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 2 },
			})

			assert.is_nil(ts_parser.get_alternative_node(if_statement_node))
		end)

		it("will throw an error if called with a non if_statement TSNode", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  local foo = 1",
				"}",
			})

			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 2 },
			})

			assert.has_error(function()
				ts_parser.get_consequence_node(node)
			end)
		end)
	end)
end)
