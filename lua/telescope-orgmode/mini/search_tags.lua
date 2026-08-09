local config = require('telescope-orgmode.lib.config')
local org = require('telescope-orgmode.org')
local lib_actions = require('telescope-orgmode.lib.actions')
local tags_lib = require('telescope-orgmode.lib.tags')

local pick = require('mini.pick')
local mini_lib = require('telescope-orgmode.lib.mini')

local M = {}

-- local function custom_show(items_arr, picker_opts)
--   local items = {}
--   for _, raw_entry in ipairs(items_arr) do
--
--   end
-- end

-- Needs to show  
-- <tag> (count)
-- preview should be
---- Heading
---- -> ~/path/to/file.org
---
local function make_show(picker_opts)
  return function(buf_id, items_arr, query)
    local lines = {}
    for _, item in ipairs(items_arr) do
      vim.print(item)
      local line = item.tag .. " (" .. item.count .. ")"
      table.insert(lines, line)
    end

    pick.default_show(buf_id, lines, query)
  end
end

function M.search_tags(org_opts)
  local opts = config:new('search_tags', org_opts)

  opts.original_buffer = vim.api.nvim_get_current_buf()
  opts.original_file = vim.api.nvim_buf_get_name(opts.original_buffer)
  opts.current_file = opts.original_file

  local tags, sort_mode = tags_lib.load_and_sort_tags(opts)

  if #tags == 0 then
    vim.notify('No tags found in org files', vim.log.levels.INFO)
    return
  end
  -- vim.print(tags)
  --
  local items = {}

  for _, tag_info in ipairs(tags) do
    local tag = tag_info.tag
    local lines = tags_lib.get_tag_preview_lines(tag, { max_count = 50 })
    table.insert(items, lines)
  end

  local pick_opts = vim.tbl_deep_extend("keep", org_opts or {}, {
    window = { prompt_prefix = " Tag: " },
    source = {
      name = "Choose Tag",
      items = items,
      show = make_show(org_opts)
    }
  })

  return pick.start(pick_opts)
end

return M
