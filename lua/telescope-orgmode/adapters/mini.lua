local PickerState = require('telescope-orgmode.lib.state')
local config = require('telescope-orgmode.lib.config')

local headlines_entry = require('telescope-orgmode.entry_maker.headlines')
local orgfiles_entry = require('telescope-orgmode.entry_maker.orgfiles')
local highlights = require('telescope-orgmode.lib.highlights')

local pick = require('mini.pick')
require('telescope-orgmode.mini.register_pickers')

local M = {}

---@return OrgFileEntry[] | OrgHeadlineEntry[]
local function get_entries(state, opts)
  local mode = state:get_current()

  if mode == 'headlines' then
    ---@type OrgHeadlineEntry[]
    local filters = state:get_all_filters()
    local headline_opts = vim.tbl_extend('force', opts, filters)

    local results, widths = headlines_entry.get_entries(headline_opts)
    headline_opts.widths = widths
    results.opts = headline_opts

    return results
  else
    return orgfiles_entry.get_entries(opts)
  end
end

---@param opts table
---@return PickerState
local function create_state(opts)
  return PickerState:new(opts.mode or 'headlines', {
    only_current_file = opts.only_current_file or false,
    current_file = opts.original_file,
    archived = opts.archived or false,
    max_depth = opts.max_depth,
    tag_query = opts.tag_query,
  })
end

---@param user_opts table|nil
function M.search_headings(user_opts)
  local opts = config:new('search_headings', user_opts)

  opts.original_buffer = vim.api.nvim_get_current_buf()
  opts.original_file = vim.api.nvim_buf_get_name(opts.original_buffer)
  opts.current_file = opts.original_file

  local state = create_state(opts)
  local items = get_entries(state, opts)

  pick.registry.orgmode_headings({
    source = {
      items = items
    }
  })
end

---@param user_opts table|nil
function M.refile_heading(user_opts)
end

---@param user_opts table|nil
function M.insert_link(user_opts)
  
end

---@param user_opts table|nil
function M.search_tags(user_opts)

end


return M
