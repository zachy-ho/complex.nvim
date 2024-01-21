local ts_parser = require("complex.parsers.typescript")
assert(ts_parser, "typescript_parser module could not be required???")

local M = {}

---@param node TSNode
---@return boolean is_loop_node
local is_loop_statement_node = function(node)
  return node:type() == "for_statement" or node:type() == "while_statement" or node:type() == "do_statement"
end

-- TODO augment this functino to return points of score additions and nesting multiplier
---@param node TSNode Top-level node from which children nodes can be iterated
---@param score Score
---@param score_controller ScoreController
---@return number complexity
M.calculate_complexity = function(node, score, score_controller)
  local get_next_child = node:iter_children()
  local child = get_next_child()
  while child ~= nil do
    if is_loop_statement_node(child) then
      -- loop block
      score_controller.increment(score)
      score_controller.increment_nest(score)
      P(ts_parser.get_loop_body_node(child):type())
      -- recurse calculate_complexity from the body node
      -- decrement nest after getting out of recursion
    elseif false then
      -- if block
    elseif false then
      -- catch
    elseif false then
      -- function declaration
    elseif false then
      -- break or continue
    elseif false then
      -- sequence of binary operators
    elseif false then
      -- recursion call
    end
    child = get_next_child()
  end

  return score_controller.get_complexity(score)
end

return M
