local utils = require("complex.utils")
local ok = utils.check_module("nvim-treesitter.ts_utils")
if not ok then
  print("Node finder module will not work because nvim-treesitter.ts_utils cannot be required")
  return false
end
local ts_utils = require("nvim-treesitter.ts_utils")

-- This module only handles typescript
local M = {}

---@param node TSNode
local is_lexical_declaration_of_arrow_function = function(node)
  -- child(1) is the "variable_declarator" node
  -- child(0) of the "variable_declarator" node is the "identifier"
  -- child(1) of the "variable_declarator" node is the "=" sign
  return node:type() == "lexical_declaration" and node:child(1):child(2):type() == "arrow_function"
end

---@param node TSNode
---@return boolean is_function_declaration
local is_function_declaration = function(node)
  return node:type() == "function_declaration"
end

---@param node TSNode
---@return boolean is_function
local is_top_level_node_of_function = function(node)
  return is_function_declaration(node) or is_lexical_declaration_of_arrow_function(node)
end

---@param node TSNode
---@return TSNode | nil
M.get_top_level_function_node = function(node)
  local current_node = node
  local root = ts_utils.get_root_for_node(node)
  local outermost_fn

  -- Go all the way to the top of the file/module
  while current_node ~= nil and current_node ~= root do
    if is_top_level_node_of_function(current_node) then
      outermost_fn = current_node
    end
    current_node = current_node:parent()
  end

  return outermost_fn
end

---@param node TSNode function node
---@return TSNode | nil
M.get_body_node = function(node)
  if is_function_declaration(node) then
    return node:child(3)
  end

  if is_lexical_declaration_of_arrow_function(node) then
    return node:child(1):child(2):child(2)
  end

  return nil
end

---@param loop_statement_node TSNode
---@return TSNode | nil
M.get_loop_body_node = function(loop_statement_node)
  local get_next_child = loop_statement_node:iter_children()
  local child = get_next_child()
  while child:type() ~= "statement_block" do
    -- if loop_statement_node:type() == "for_statement" then
    -- P(child)
    -- elseif loop_statement_node:type() == "while_statement" then
    -- elseif loop_statement_node:type() == "do_statement" then
    -- end
    child = get_next_child()
  end
  return child
end

return M
