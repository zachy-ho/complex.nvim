local scorer = require("complex.scorer")

local create_typescript_buf = function()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "filetype", "typescript")
	return buf
end
describe("calculate_complexity", function()
	describe("for typescript", function()
		it("handles functions with nested loops", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  while (false) {",
				"    while (false) {",
				"    }",
				"  }",
				"  for (let i = 0; i > 0; i++) {}",
				"  do {} while(true)",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 5)
		end)

		it("handles functions with simple if statement without an alternative", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {}",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 1)
		end)

		it("handles functions with if statement with basic alternative (else)", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {}",
				"  else {}",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 2)
		end)

		it("handles functions with if statement with multiple alternatives", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {}",
				"  else if (false) {}",
				"  else {}",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 3)
		end)

		it("handles functions with nested if statements and alternatives", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  if (true) {",
				"    if (true) {}",
				"  }",
				"  else if (false) {",
				"    if (true) {}",
				"    else if (false) {}",
				"    else {",
				"      if (true) {}",
				"    }",
				"  }",
				"  else {}",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 14)
		end)
	end)
end)
