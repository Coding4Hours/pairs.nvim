--[[
the smallest pair plugin in the universe
--]]

local M = {}

local config = {
  enabled = true,
  pairs = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = '"',
    ["'"] = "'",
    ['`'] = '`',
  },
}

local function autopairs_open(open_char)
  local close_char = config.pairs[open_char]
  return open_char .. close_char .. "<Left>"
end

local function autopairs_close(close_char)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char_after_cursor = line:sub(col + 1, col + 1)

  if char_after_cursor == close_char then
    return "<Right>"
  else
    return close_char
  end
end

local function autopairs_closeopen(char)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char_after_cursor = line:sub(col + 1, col + 1)

  if char_after_cursor == char then
    return "<Right>"
  else
    return char .. char .. "<Left>"
  end
end

local function autopairs_bs()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()

  if col == 0 then return "<BS>" end

  local char_before_cursor = line:sub(col, col)
  local char_after_cursor = line:sub(col + 1, col + 1)

  if config.pairs[char_before_cursor] and config.pairs[char_before_cursor] == char_after_cursor then
    return "<BS><Del>"
  end

  return "<BS>"
end

function M.mappairs()
  local map = vim.keymap.set
  local opts = { expr = true, noremap = true }

  for open_char, close_char in pairs(config.pairs) do
    if open_char == close_char then
      opts.desc = "Autopair symmetric " .. open_char
      map('i', open_char, function() return autopairs_closeopen(open_char) end, opts)
    else
      opts.desc = "Autopair open " .. open_char
      map('i', open_char, function() return autopairs_open(open_char) end, opts)

      opts.desc = "Autopair close " .. close_char
      map('i', close_char, function() return autopairs_close(close_char) end, opts)
    end
  end

  opts.desc = "Autopair backspace"
  map('i', '<BS>', autopairs_bs, opts)
end

function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend("force", config, opts)
  end

  if config.enabled then
    M.mappairs()
  end
end

return M
