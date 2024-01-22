local ts_parser = require("complex.parsers.typescript")
assert(ts_parser, "typescript_parser module could not be required???")

local M = {}

---@param node TSNode
---@return boolean is_loop_node
local is_loop_statement_node = function(node)
  return node:type() == "for_statement" or node:type() == "while_statement" or node:type() == "do_statement"
end

---@param node TSNode
---@return boolean is_loop_node
local is_if_statement_node = function(node)
  return node:type() == "if_statement"
end

---@param node TSNode An if_statement node
---@return integer complexity
local calculate_if_complexity = function(node)
  assert(is_if_statement_node(node), "Called `calculate_if_complexity(node) on an invalid node.")
  -- 1. increment for the 'if' itself

  -- 2. increment by the complexity of the consequence statement
  -- 3. handle alternative
  --    - if (alternative)
end

-- TODO augment this functino to return points of score additions and nesting multiplier
---@param node TSNode Top-level node from which children nodes can be iterated
---@param nest integer Nesting level of node's scope
---@return number complexity
M.calculate_complexity = function(node, nest)
  local score = 0
  local increment = function()
    score = score + nest + 1
    return score
  end
  ---@param n integer
  local increment_by = function(n)
    score = score + n
    return score
  end

  -- For each child of node
  -- - increment for itself
  -- - if it adds a nesting level, increment score by calculate_complexity(node, nest_level)
  local get_next_child = node:iter_children()
  local child = get_next_child()
  for _, c in ipairs(child:named_children()) do
    P(c:type())
  end
  while child ~= nil do
    if is_loop_statement_node(child) then
      -- loop block
      increment()
      local body_node =
          assert(ts_parser.get_loop_body_node(child), "Loop doesn't have a body node for some reason?")
      increment_by(M.calculate_complexity(body_node, nest + 1))
    elseif is_if_statement_node(child) then
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

  return score
end

return M
