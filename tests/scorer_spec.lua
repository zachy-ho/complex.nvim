local scorer = require("complex.scorer")

local create_typescript_buf = function()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "filetype", "typescript")
	return buf
end
describe("[Typescript]", function()
	describe("calculate_complexity", function()
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

		it("handles functions with if statements", function()
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

		it("handles functions with catch clauses", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"function basicFn() {",
				"  try {}",
				"  catch(e) {}",
				"  finally {}",
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 1, 0 },
			})
			assert.equal(scorer.calculate_complexity(node, 0), 1)
		end)
	end)

	describe("get_if_complexity", function()
		it("considers the if statement itself as a point of complexity", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"if (true) {}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.equal(scorer.get_if_complexity(node, 0), 1)
		end)

		it("calculates complexity for an if statement with alternatives", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"if (true) {}",
				"else if (true) {}",
				"else {}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.equal(scorer.get_if_complexity(node, 0), 3)
		end)

		it("calculates complexity for an if statement with nested statements", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"if (true) {",
				"  if (true) {}",
				"}",
				"else if (false) {",
				"  if (true) {}",
				"  else if (false) {}",
				"  else {",
				"    if (true) {}",
				"  }",
				"}",
				"else {}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.equal(scorer.get_if_complexity(node, 0), 14)
		end)
	end)

	describe("calculate_logical_op_complexity", function()
		it("handles simple binary expression", function()
			local seq = { Comparable.BASIC, "||", { Comparable.BASIC, "&&", Comparable.BASIC }, "||", Comparable.BASIC }
			print(scorer.calculate_logical_op_complexity(seq, 0))
		end)
	end)
end)
