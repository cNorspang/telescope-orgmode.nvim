local PickerState = require('telescope-orgmode.lib.state')
local headlines_entry = require('telescope-orgmode.entry_maker.headlines')
local orgfiles_entry = require('telescope-orgmode.entry_maker.orgfiles')
local highlights = require('telescope-orgmode.lib.highlights')
local pick = require('mini.pick')

local M = {}

local function is_blank(input)
  local blank = (input == nil or #string.gsub(input, "^%s*(.-)%s*$", "%1") == 0)
  return blank
end

---@param opts table
---@return PickerState
M.create_state = function(opts)
  return PickerState:new(opts.mode or 'headlines', {
    only_current_file = opts.only_current_file or false,
    current_file = opts.original_file,
    archived = opts.archived or false,
    max_depth = opts.max_depth,
    tag_query = opts.tag_query,
  })
end

---@return OrgFileEntry[] | OrgHeadlineEntry[]
M.get_entries = function(state, opts)
  local mode = state:get_current()

  if mode == 'headlines' then
    ---@type OrgHeadlineEntry[]
    local filters = state:get_all_filters()
    local headline_opts = vim.tbl_extend('force', opts, filters)

    local results, widths = headlines_entry.get_entries(headline_opts)
    headline_opts.widths = widths

    return results, headline_opts
  else
    return orgfiles_entry.get_entries(opts)
  end
end

M.format = function(items_arr, picker_opts)
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


M.highlight_line_segment = function(buf_id, line, start_col, hl_group)
  local opts = { end_row = line, end_col = 0, hl_mode = 'blend', hl_group = hl_group, priority = 999 }
  local ns = vim.api.nvim_create_namespace('MiniOrgPicker')
  vim.api.nvim_buf_set_extmark(buf_id, ns, line - 1, start_col, opts)
end

M.make_show = function(picker_opts)
  return function(buf_id, items_arr, query)
    local lines = {}
    local items = M.format(items_arr, picker_opts)
    local sections = {}

    for _, x in ipairs(items) do
      vim.print(x)
      local line = "";
      local section_start = 0
      for _, section in ipairs(x.formatted) do
        if not is_blank(section[1]) then
          vim.print(section)
          line = line .. section[1]
          table.insert(sections, { section = x, start_index = section_start, hl = section[2] })
          section_start = section_start + #section[1]
        end
      end
      table.insert(lines, line)
    end

    pick.default_show(buf_id, lines, query)

    pcall(vim.api.nvim_buf_clear_namespace, buf_id, 'MiniOrgPicker', 0, -1)
    for i, section in ipairs(sections) do
      -- local section_delims = {}
      -- local formatted = x.formatted
      -- local column = 0
      --
      -- local filename = formatted[1][1]
      -- local filename_hl = formatted[1][2]
      -- local filename_start_column = column
      --
      -- column = column + #filename
      --
      -- local tags = formatted[2][1]
      -- local tags_hl = formatted[2][2]
      -- local tags_start_column = column
      --
      -- column = column + #tags
      --
      -- local headline = formatted[5][1]
      -- local headline_hl = formatted[5][2]
      -- local headline_start_column = column
      --
      M.highlight_line_segment(buf_id, i, section.start_index, section.hl)
    end
  end
end

return M
