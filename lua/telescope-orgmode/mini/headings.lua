local pick = require("mini.pick")

local M = {}

local function open_file()
  local current = pick.get_picker_matches().current
  vim.schedule(function()
    vim.cmd.edit(current)
  end)
  return true
end

---@param buf_id number
---@param items_arr OrgHeadlineEntry[]
---@param query string[]
local function show(buf_id, items_arr, query)
  ---@type string[]
  local lines = {}

  for i, x in ipairs(items_arr) do
    local file_stub = vim.fs.basename(x.filename)
    local line_nr = x.headline.position.start_line
    local tags_string = table.concat(x.headline.tags, ":")
    local level_string = string.rep('*', x.headline.level)

    -- local line = file_stub .. "    " .. x.headline.title

    local line = string.format('%s:%i  %s  %s %s', file_stub, line_nr, tags_string, level_string, x.headline.title)
    table.insert(lines, line)
  end
  pick.default_show(buf_id, lines, query)
end

function M.start_picker(local_opts)
  local_opts = vim.tbl_deep_extend("keep", local_opts or {}, {
    window = { prompt_prefix = " Heading: "},
    source = {
      name = "Choose Heading",
      show = show
    },
    mappings = {
      choose = "",
      toggle_preview = "",
      custom_choose = {
        char = "<CR>", func = open_file
      }
    }
  })

  local_opts = vim.tbl_deep_extend("force", local_opts, {
    options = { use_cache = false },
  })

  return pick.start(local_opts)
end


return M
