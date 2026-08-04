local pick = require("mini.pick")

local M = {}

local function open_file()
  local current = pick.get_picker_matches().current
  vim.schedule(function()
    vim.cmd.edit(current)
  end)
  return true
end

function M.start_picker(local_opts, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
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

  opts = vim.tbl_deep_extend("force", opts, {
    options = { use_cache = false },
  })

  return pick.start(opts)
end


return M
