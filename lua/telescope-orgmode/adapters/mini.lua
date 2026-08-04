local PickerState = require('telescope-orgmode.lib.state')
local config = require('telescope-orgmode.lib.config')

local headlines_entry = require('telescope-orgmode.entry_maker.headlines')
local orgfiles_entry = require('telescope-orgmode.entry_maker.orgfiles')

local pick = require('mini.pick')

local M = {}

---@param state PickerState
local function search_headings(state, opts)
  local mode = state:get_current()

  if mode == 'headlines' then
    local filters = state:get_all_filters()
    local headline_opts = vim.tbl_extend('force', opts, filters)

    local results, widths = headlines_entry.get_entries(headline_opts)
    headline_opts.widths = widths

    return results
  else
    return orgfiles_entry.get_entries(opts)
  end
end

---@param picker_name string
---@param prompt string 
---@param source_name string 
---@param on_select function
---@param items any
local function register_picker(picker_name, prompt, source_name, on_select, items)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    window = { prompt_prefix = prompt },
    source = { name = source_name },
    mappings = {
      choose = "",
      toggle_preview = "",
      custom_choose = {
        char = "<CR>", func = on_select
      }
    }
  })

  opts = vim.tbl_deep_extend("force", opts, {
    options = { use_cache = false },
    source = {
      items = items
    }
  })

  return opts
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
  local items = search_headings(state, opts)

  pick.registry.orgmode_headings({ source = { items = items }})
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
