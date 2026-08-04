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
---@param items_arr OrgFileEntry[]
---@param query string[]
local function show(buf_id, items_arr, query)
  ---@type string[]
  local lines = {}

  for i, x in ipairs(items_arr) do
    local line = x.filename .. "    " .. x.title
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
