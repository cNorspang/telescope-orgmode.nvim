local PickerState = require('telescope-orgmode.lib.state')
local operations = require('telescope-orgmode.lib.operations')
local config = require('telescope-orgmode.lib.config')
local org = require('telescope-orgmode.org')
local headlines_entry = require('telescope-orgmode.entry_maker.headlines')
local orgfiles_entry = require('telescope-orgmode.entry_maker.orgfiles')
local lib_actions = require('telescope-orgmode.lib.actions')
local keybindings = require('telescope-orgmode.lib.keybindings')

local pick = require('mini.pick')
local mini_lib = require('telescope-orgmode.lib.mini')

local M = {}

local function highlight_line_segment(buf_id, line, start_col, hl_group)
  local opts = { end_row = line, end_col = 0, hl_mode = 'blend', hl_group = hl_group, priority = 999 }
  local ns = vim.api.nvim_create_namespace('MiniOrgPicker')
  vim.api.nvim_buf_set_extmark(buf_id, ns, line - 1, start_col, opts)
end

local function make_show(picker_opts)
  return function(buf_id, items_arr, query)
    local lines = {}
    local items = mini_lib.format(items_arr, picker_opts)

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

local function custom_choose(source_headline)
  return function(item)
    vim.schedule(function()
      local success, message = lib_actions.execute_refile(source_headline, item)
      vim.notify(message, success and vim.log.levels.INFO or vim.log.levels.WARN)
    end)
    return false
  end
end

function M.refile_heading(org_opts)
  local opts = config:new('refile_heading', user_opts)

  opts.original_buffer = vim.api.nvim_get_current_buf()
  opts.original_file = vim.api.nvim_buf_get_name(opts.original_buffer)
  opts.current_file = opts.original_file

  local source_headline = org.get_closest_headline()

  if not source_headline then
    local filetype = vim.bo.filetype
    if filetype == 'org' then
      vim.notify('No headline found at cursor position in org file', vim.log.levels.WARN)
    else
      vim.notify(
        'No headline found at cursor position. Make sure cursor is on a valid agenda item or org headline.',
        vim.log.levels.WARN
      )
    end
    return
  end

  local state = mini_lib.create_state(opts)
  local items, resolved_opts = mini_lib.get_entries(state, opts)

  local base_title = opts.prompt_titles[state:get_current()]
  local full_title = state:get_full_title(base_title)

  local pick_opts = vim.tbl_deep_extend("keep", org_opts or {}, {
    window = { prompt_prefix = full_title },
    source = {
      name = "Refile",
      items = items,
      show = make_show(resolved_opts),
      choose = custom_choose(source_headline)
    }
  })

  return pick.start(pick_opts)
end


return M
