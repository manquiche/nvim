-- plugin: sort-lines.lua
-- A Neovim plugin for sorting lines with support for preserving indentation and structure

---@class SortLinesPlugin
---@field setup fun(opts: table|nil): nil
---@field sort_lines fun(start_line: integer, end_line: integer, opts: table|nil): integer
---@field sort_visual_selection fun(): integer
---@field sort_file fun(): integer
---@field sort_paragraph fun(): integer
---@field sort_structured fun(start_line: integer, end_line: integer): integer
local M = {}

---@class SortNode
---@field line string The text content of the line
---@field indent integer The indentation level
---@field children SortNode[] Child nodes

---@class SortOptions
---@field case_sensitive boolean Whether sorting should be case sensitive
---@field reverse boolean Whether to sort in reverse order

-- Helper function to get the indentation level of a line
---@param line string The line to analyze
---@return integer The number of leading whitespace characters
local function get_indent_level(line)
  local indent = line:match '^%s+'
  return indent and #indent or 0
end

-- Helper function to get the indentation string of a line
---@param line string The line to analyze
---@return string The leading whitespace characters
local function get_indent_str(line)
  return line:match '^%s+' or ''
end

-- Sort lines in the given range
---@param start_line integer First line to sort (1-based)
---@param end_line integer Last line to sort (1-based)
---@param opts? SortOptions Optional sorting options
---@return integer Number of lines affected
function M.sort_lines(start_line, end_line, opts)
  opts = opts or {}
  local bufnr = 0 -- current buffer

  -- Get the lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  -- Group lines by indentation level
  ---@type table[]
  local groups = {}
  ---@type {line: string, children: string[]}[]
  local current_group = {}
  local current_indent = get_indent_level(lines[1])

  for i, line in ipairs(lines) do
    local indent = get_indent_level(line)

    if indent == current_indent then
      -- Same indentation level, add to current group
      table.insert(current_group, { line = line, children = {} })
    elseif indent > current_indent then
      -- Deeper indentation, belongs to the previous line
      if #current_group > 0 then
        table.insert(current_group[#current_group].children, line)
      end
    else
      -- Less indentation, start a new group
      if #current_group > 0 then
        table.insert(groups, current_group)
      end
      current_group = { { line = line, children = {} } }
      current_indent = indent
    end
  end

  -- Add the last group if it's not empty
  if #current_group > 0 then
    table.insert(groups, current_group)
  end

  -- Sort each group
  for _, group in ipairs(groups) do
    table.sort(group, function(a, b)
      -- Strip indentation for comparison
      local a_content = a.line:gsub('^%s+', '')
      local b_content = b.line:gsub('^%s+', '')

      if opts.case_sensitive == false then
        a_content = string.lower(a_content)
        b_content = string.lower(b_content)
      end

      if opts.reverse then
        return a_content > b_content
      else
        return a_content < b_content
      end
    end)
  end

  -- Flatten the groups back into lines
  local sorted_lines = {}
  for _, group in ipairs(groups) do
    for _, item in ipairs(group) do
      table.insert(sorted_lines, item.line)
      for _, child in ipairs(item.children) do
        table.insert(sorted_lines, child)
      end
    end
  end

  -- Replace the lines in the buffer
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, sorted_lines)

  -- Return the number of lines affected
  return #sorted_lines
end

-- Sort lines in visual selection
---@return integer Number of lines affected
function M.sort_visual_selection()
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  return M.sort_lines(start_line, end_line)
end

-- Sort lines in the entire file
---@return integer Number of lines affected
function M.sort_file()
  local start_line = 1
  local end_line = vim.api.nvim_buf_line_count(0)
  return M.sort_lines(start_line, end_line)
end

-- Sort lines in the current paragraph
---@return integer Number of lines affected
function M.sort_paragraph()
  -- Find the start of the paragraph (first non-empty line after an empty line)
  local start_line = vim.fn.search('^s*$', 'bnW') + 1
  -- Find the end of the paragraph (last line before an empty line)
  local end_line = vim.fn.search('^s*$', 'nW') - 1

  -- If no empty line found after the paragraph, use the end of the file
  if end_line < start_line then
    end_line = vim.api.nvim_buf_line_count(0)
  end

  return M.sort_lines(start_line, end_line)
end

-- Enhanced version for YAML-like structures
---@param start_line integer First line to sort (1-based)
---@param end_line integer Last line to sort (1-based)
---@return integer Number of lines affected
function M.sort_structured(start_line, end_line)
  local bufnr = 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  -- Build a tree structure
  ---@type SortNode
  local root = { line = '', children = {}, indent = -1 }
  ---@type SortNode[]
  local stack = { root }

  for _, line in ipairs(lines) do
    if line:match '^%s*$' then
      -- Skip empty lines
      goto continue
    end

    local indent = get_indent_level(line)
    ---@type SortNode
    local node = { line = line, indent = indent, children = {} }

    -- Find the parent node by popping the stack until we find a node with less indentation
    while #stack > 1 and indent <= stack[#stack].indent do
      table.remove(stack)
    end

    -- Add to parent's children
    table.insert(stack[#stack].children, node)

    -- Push this node to the stack if it might have children
    table.insert(stack, node)

    ::continue::
  end

  -- Sort function for nodes
  ---@param nodes SortNode[] The nodes to sort
  local function sort_nodes(nodes)
    table.sort(nodes, function(a, b)
      local a_content = a.line:gsub('^%s+', '')
      local b_content = b.line:gsub('^%s+', '')
      return a_content < b_content
    end)

    -- Recursively sort children
    for _, node in ipairs(nodes) do
      if #node.children > 0 then
        sort_nodes(node.children)
      end
    end
  end

  -- Sort the tree
  sort_nodes(root.children)

  -- Flatten the tree back to lines
  local sorted_lines = {}

  ---@param nodes SortNode[] The nodes to flatten
  local function flatten(nodes)
    for _, node in ipairs(nodes) do
      table.insert(sorted_lines, node.line)
      if #node.children > 0 then
        flatten(node.children)
      end
    end
  end

  flatten(root.children)

  -- Replace the lines in the buffer
  vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, sorted_lines)

  return #sorted_lines
end

-- Setup function to create commands and mappings
---@param opts? table Configuration options
---@field opts.mappings? table<string, table<string, function>> Key mappings by mode
---@field opts.case_sensitive? boolean Whether sorting should be case sensitive
---@field opts.reverse? boolean Whether to sort in reverse order
function M.setup(opts)
  opts = opts or {}

  -- Create commands
  vim.api.nvim_create_user_command('SortLines', function(args)
    local start_line = args.line1
    local end_line = args.line2
    M.sort_lines(start_line, end_line, {
      case_sensitive = opts.case_sensitive,
      reverse = opts.reverse,
    })
  end, { range = true, desc = 'Sort lines preserving indentation' })

  vim.api.nvim_create_user_command('SortStructured', function(args)
    local start_line = args.line1
    local end_line = args.line2
    M.sort_structured(start_line, end_line)
  end, { range = true, desc = 'Sort lines preserving hierarchical structure' })

  -- Create key mappings if specified
  if opts.mappings then
    for mode, maps in pairs(opts.mappings) do
      for lhs, rhs in pairs(maps) do
        vim.keymap.set(mode, lhs, rhs)
      end
    end
  end
end

return M
