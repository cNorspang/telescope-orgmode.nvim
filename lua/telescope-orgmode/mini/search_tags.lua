local config = require('telescope-orgmode.lib.config')
local org = require('telescope-orgmode.org')
local lib_actions = require('telescope-orgmode.lib.actions')
local tags_lib = require('telescope-orgmode.lib.tags')

local pick = require('mini.pick')
local mini_lib = require('telescope-orgmode.lib.mini')

local M = {}

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

  vim.print(tags)

  -- for _, tag_info in ipairs(tags) do
  --   local tag = tag_info.tag
  --   local lines = tags_lib.get_tag_preview_lines(tag, { max_count = 50 })
  --   vim.print(lines)
  -- end

end

return M
