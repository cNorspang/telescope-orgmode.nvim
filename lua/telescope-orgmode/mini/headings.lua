local pick = require("mini.pick")

local M = {}

local function open_file()
  local current = pick.get_picker_matches().current
  vim.schedule(function()
    vim.cmd.edit(current)
  end)
  return true
end

local function highlight_line_segment(buf_id, line, start_col, end_col, hl_group)
  local opts = { end_row = line, end_col = end_col, hl_mode = 'blend', hl_group = hl_group, priority = 999 }
  local ns = vim.api.nvim_create_namespace('MiniOrgPicker')
  vim.api.nvim_buf_set_extmark(buf_id, ns, line - 1, start_col, opts)
end

---@param buf_id number
---@param items_arr table[]
---@param query string[]
local function show(buf_id, items_arr, query)
  ---@type string[]
  local lines = {}

  for i, x in ipairs(items_arr) do
    local filename = x[1][1]
    local tags = x[2][1]
    local headline = x[5][1]
    local line = filename .. tags .. headline
    table.insert(lines, line)
  end

  pick.default_show(buf_id, lines, query)

  pcall(vim.api.nvim_buf_clear_namespace, buf_id, 'MiniOrgPicker', 0, -1)
  for i, x in ipairs(items_arr) do
    local column = 0

    local filename = x[1][1]
    local filename_hl = x[1][2]
    local filename_start_column = column
    local filename_end_column = column + #filename

    column = column + #filename + 1

    local tags = x[2][1]
    local tags_hl = x[2][2]
    local tags_start_column = column
    local tags_end_column = column + #tags

    column = column + #tags + 1

    local headline = x[5][1]
    local headline_hl = x[5][2]
    local headline_start_column = column
    local headline_end_column = column + #headline

    highlight_line_segment(buf_id, i, filename_start_column, filename_end_column, filename_hl)
    highlight_line_segment(buf_id, i, tags_start_column, tags_end_column, tags_hl)
    highlight_line_segment(buf_id, i, headline_start_column, headline_end_column, headline_hl)
  end
end

function M.start_picker(local_opts)
  local_opts = vim.tbl_deep_extend("keep", local_opts or {}, {
    window = { prompt_prefix = " Heading: "},
    source = {
      name = "Choose Heading",
      show = show
    },
    mappings = {
      choose = "",
      toggle_preview = "",
      custom_choose = {
        char = "<CR>", func = open_file
      }
    }
  })

  local_opts = vim.tbl_deep_extend("force", local_opts, {
    options = { use_cache = false },
  })

  return pick.start(local_opts)
end


return M
