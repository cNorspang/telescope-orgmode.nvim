local pick = require("mini.pick")

local M = {}

local function open_file()
  local current = pick.get_picker_matches().current
  vim.schedule(function()
    vim.cmd.edit(current)
  end)
  return true
end

function M.start_picker(local_opts)
  opts = vim.tbl_deep_extend("keep", local_opts or {}, {
    window = { prompt_prefix = " Heading: "},
    source = { name = "Choose Heading" },
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
