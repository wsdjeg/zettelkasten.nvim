local M = {}

local previewer = require('picker.previewer.file')

function M.get()
  local zkc = require('zettelkasten.config')
  local templates = vim.fn.globpath(zkc.templates_path, '*.md', 0, 1)
  return vim.tbl_map(function(t)
    return {
      str = t,
      value = t,
    }
  end, templates)
end

---@field item PickerItem
function M.default_action(item)
  require('zettelkasten').zknew({
    template = item.value,
  })
end

M.preview_win = true

---@field item PickerItem
function M.preview(item, win, buf)
  previewer.preview(item.value, win, buf)
end

return M
