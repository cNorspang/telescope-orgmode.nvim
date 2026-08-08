local config = require('telescope-orgmode.lib.config')
local headings = require('telescope-orgmode.mini.headings')
local refile = require('telescope-orgmode.mini.refile')
local insert_link = require('telescope-orgmode.mini.insert_link')
local search_tags = require('telescope-orgmode.mini.search_tags')

require('telescope-orgmode.mini.register_pickers')

local M = {}

---@param user_opts table|nil
function M.search_headings(user_opts)
  headings.start_picker(user_opts)
end

---@param user_opts table|nil
function M.refile_heading(user_opts)
  refile.refile_heading(user_opts)
end

---@param user_opts table|nil
function M.insert_link(user_opts)
  insert_link.insert_link(user_opts)
end

---@param user_opts table|nil
function M.search_tags(user_opts)
  search_tags.search_tags(user_opts)
end

return M
