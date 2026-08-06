local PickerState = require('telescope-orgmode.lib.state')
local headlines_entry = require('telescope-orgmode.entry_maker.headlines')
local orgfiles_entry = require('telescope-orgmode.entry_maker.orgfiles')

local M = {}


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

return M
