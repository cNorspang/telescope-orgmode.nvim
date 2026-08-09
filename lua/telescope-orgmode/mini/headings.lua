local pick = require("mini.pick")
local operations = require("telescope-orgmode.lib.operations")
local highlights = require("telescope-orgmode.lib.highlights")
local actions = require('telescope-orgmode.lib.actions')
local config = require('telescope-orgmode.lib.config')
local mini_lib = require('telescope-orgmode.lib.mini')
local opts

local M = {}

local function highlight_line_segment(buf_id, line, start_col, hl_group)
  local opts = { end_row = line, end_col = 0, hl_mode = 'blend', hl_group = hl_group, priority = 999 }
  local ns = vim.api.nvim_create_namespace('MiniOrgPicker')
  vim.api.nvim_buf_set_extmark(buf_id, ns, line - 1, start_col, opts)
end

local function format(items_arr, picker_opts)
  local items = {}
  for _, raw_entry in ipairs(items_arr) do
    local segments, search_text = highlights.get_headline_segments(raw_entry.headline, raw_entry.filename, picker_opts)
    table.insert(items, {
      formatted = segments,
      text = search_text,
      file = raw_entry.filename
    })
  end

  return items
end

local function make_show(picker_opts)
  return function(buf_id, items_arr, query)
    local lines = {}
    local items = format(items_arr, picker_opts)

    for _, x in ipairs(items) do
      local formatted = x.formatted
      local filename = formatted[1][1]
      local tags = formatted[2][1]
      local headline = formatted[5][1]
      local line = filename .. tags .. headline
      table.insert(lines, line)
    end

    pick.default_show(buf_id, lines, query)

    pcall(vim.api.nvim_buf_clear_namespace, buf_id, 'MiniOrgPicker', 0, -1)
    for i, x in ipairs(items) do
      local formatted = x.formatted
      local column = 0

      local filename = formatted[1][1]
      local filename_hl = formatted[1][2]
      local filename_start_column = column

      column = column + #filename

      local tags = formatted[2][1]
      local tags_hl = formatted[2][2]
      local tags_start_column = column

      column = column + #tags

      local headline = formatted[5][1]
      local headline_hl = formatted[5][2]
      local headline_start_column = column

      highlight_line_segment(buf_id, i, filename_start_column, filename_hl)
      highlight_line_segment(buf_id, i, tags_start_column, tags_hl)
      highlight_line_segment(buf_id, i, headline_start_column, headline_hl)
    end
  end
end

local function custom_choose(item)
  local destination = actions.entry_to_destination(item)
  vim.api.nvim_win_call(
    pick.get_picker_state().windows.target,
    function() vim.schedule(function() operations.navigate_to(destination) end) end
  )
  return false
end

function M.start_picker(org_opts)
  opts = config:new('search_headings', org_opts)
  local state = mini_lib.create_state(opts)

  local items, resolved_opts = mini_lib.get_entries(state, opts)

  local pick_opts = vim.tbl_deep_extend("keep", org_opts or {}, {
    window = { prompt_prefix = " Heading: "},
    source = {
      name = "Choose Heading",
      items = items,
      show = mini_lib.make_show(resolved_opts),
      choose = custom_choose
    },
    mappings = {
      toggle_preview = ""
    }
  })

  return pick.start(pick_opts)
end


return M
