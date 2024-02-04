local scorer = require("complex.scorer")
local utils = require("complex.utils")

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
			assert.equal(scorer.calculate_if_complexity(node, 0), 1)
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
			assert.equal(scorer.calculate_if_complexity(node, 0), 3)
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
			assert.equal(scorer.calculate_if_complexity(node, 0), 14)
		end)
	end)

	describe("calculate_boolean_expression_complexity", function()
		it("throws if nothing to evaluate", function()
			assert.has_error(function()
				scorer.calculate_boolean_expression_complexity({})
			end)
		end)

		it("throws if operation input is invalid", function()
			assert.has_error(function()
				scorer.calculate_boolean_expression_complexity({ Comparable.BASIC, "||" })
			end)

			assert.has_error(function()
				scorer.calculate_boolean_expression_complexity({ Comparable.BASIC, Comparable.BASIC })
			end)

			assert.has_error(function()
				scorer.calculate_boolean_expression_complexity({ "||" })
			end)
		end)

		it(
			"treats comparables wrapped in multiple layers of unnecessary nesting the same as a single wrapped layer",
			function()
				local with_multiple_layers =
					scorer.calculate_boolean_expression_complexity({ { { Comparable.BASIC, "||", Comparable.BASIC } } })
				local with_one_layer =
					scorer.calculate_boolean_expression_complexity({ Comparable.BASIC, "||", Comparable.BASIC })
				assert.equal(with_multiple_layers, with_one_layer)
			end
		)

		it("assesses a fundamental increment for each sequence of binary logical operators", function()
			local operation = {
				Comparable.BASIC,
				"||",
				Comparable.BASIC,
				"||",
				Comparable.BASIC,
				"&&",
				Comparable.BASIC,
				"||",
				Comparable.BASIC,
			}
			assert.equal(scorer.calculate_boolean_expression_complexity(operation), 3)
		end)
	end)

	describe("flatten_logical_expression", function()
		it("handles simple binary expression", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"true && false",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 0, 0 },
				})
				:tree()
				:root()
				:child(0)
				:child(0)

			local flattened = scorer.flatten_boolean_expression(node)
			assert.equal(
				tostring(vim.inspect(flattened)),
				tostring(vim.inspect({ Comparable.BASIC, "&&", Comparable.BASIC }))
			)
		end)

		it("handles simple unary expressions", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"!true",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 0, 0 },
				})
				:tree()
				:root()
				:child(0)
				:child(0)

			local flattened = scorer.flatten_boolean_expression(node)
			assert.equal(utils.size(flattened), 1)
			assert.equal(flattened[1], Comparable.BASIC)
		end)

		it("handles long unary expressions", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"!!!!true",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 0, 0 },
				})
				:tree()
				:root()
				:child(0)
				:child(0)

			local flattened = scorer.flatten_boolean_expression(node)
			assert.equal(tostring(vim.inspect(flattened)), tostring(vim.inspect({ Comparable.BASIC })))
		end)

		it("flattens paranthesized expressions in an inner table", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"(true || false)",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 0, 0 },
				})
				:tree()
				:root()
				:child(0)
				:child(0)

			local flattened = scorer.flatten_boolean_expression(node)
			local inner_flattened = flattened[1]
			assert.is_table(inner_flattened)
			assert.equal(
				tostring(vim.inspect(inner_flattened)),
				tostring(vim.inspect({ Comparable.BASIC, "||", Comparable.BASIC }))
			)
		end)

		it("handles complex logical operations", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"let foo = ''",
				"let bar = 2",
				"true || !!foo && !(bar || (undefined && 2)) || null",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 2, 0 },
				})
				:tree()
				:root()
				:child(2)
				:child(0)

			local flattened = scorer.flatten_boolean_expression(node)
			assert.equal(
				tostring(vim.inspect(flattened)),
				tostring(vim.inspect({
					Comparable.BASIC,
					"||",
					Comparable.BASIC,
					"&&",
					{ Comparable.BASIC, "||", { Comparable.BASIC, "&&", Comparable.BASIC } },
					"||",
					Comparable.BASIC,
				}))
			)
		end)

		it("puts parenthesized_expressions in inner tables", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"(((true || false)))",
			})
			---@type TSNode
			local node = vim.treesitter
				.get_node({
					bufnr = buf,
					pos = { 0, 0 },
				})
				:tree()
				:root()
				:child(0)
				:child(0)
			local flattened = scorer.flatten_boolean_expression(node)
			assert.equal(
				tostring(vim.inspect(unpack(flattened))),
				tostring(vim.inspect({ { { Comparable.BASIC, "||", Comparable.BASIC } } }))
			)
		end)
	end)

	describe("calculate_switch_complexity", function()
		it("throws if called on an invalid node", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"const foo = 0",
			})

			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.has_error(function()
				scorer.calculate_switch_complexity(node, 0)
			end)
		end)

		it("increments for the switch statement itself", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"switch (true) {}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.equal(scorer.calculate_switch_complexity(node, 0), 1)
		end)

		it("calculates complexity for case blocks with an incremented nesting level", function()
			local buf = create_typescript_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				"switch (true) {", -- +1
				"  case true:", -- nesting +1
				"    if (true) {}", -- +2 (+1 nesting)
				"}",
			})
			local node = vim.treesitter.get_node({
				bufnr = buf,
				pos = { 0, 0 },
			})
			assert.equal(scorer.calculate_switch_complexity(node, 0), 3)
		end)
	end)
end)
