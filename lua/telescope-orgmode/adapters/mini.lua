local config = require('telescope-orgmode.lib.config')
local headings = require('telescope-orgmode.mini.headings')

require('telescope-orgmode.mini.register_pickers')

local M = {}

---@param user_opts table|nil
function M.search_headings(user_opts)
  local opts = config:new('search_headings', user_opts)

  opts.original_buffer = vim.api.nvim_get_current_buf()
  opts.original_file = vim.api.nvim_buf_get_name(opts.original_buffer)
  opts.current_file = opts.original_file

  headings.register_picker(opts)
  headings.start_picker(opts)
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
