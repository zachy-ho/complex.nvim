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
      assert(scorer.calculate_complexity(node, 0) == 5)
    end)
  end)
end)
