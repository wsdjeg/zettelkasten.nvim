local M = {}
local browser = require("zettelkasten.browser")

local previewer = require('picker.previewer.file')

local function concat_tags(t)
	local tags = {}
	for _, tag in ipairs(t) do
		if vim.tbl_contains(tags, tag.name) == false then
			table.insert(tags, tag.name)
		end
	end

	return table.concat(tags, " ")
end

local widths = {23, 45, -1}

local function format(note)
   return note.file_name
   .. string.rep(' ', widths[1] - vim.fn.strdisplaywidth(note.file_name))
   .. note.title
   .. string.rep(' ', widths[2] - vim.fn.strdisplaywidth(note.title))
   .. concat_tags(note.tags)
end

function M.get()
    return vim.tbl_map(function(t)
        return {
            value = t,
            str = format(t),
            highlight = {
                {
                    0,
                    widths[1],
                    'String',
                },
                {
                    widths[1],
                    widths[1] + widths[2],
                    'NormalFG',
                },
                {
                    widths[1] + widths[2],
                    -1,
                    'Tag',
                },
            },
        }
    end, browser.get_notes())
end

function M.default_action(entry)
    vim.cmd('edit ' .. entry.value.file)
end

M.preview_win = true

---@field item PickerItem
function M.preview(item, win, buf)
    previewer.preview(item.value.file_name, win, buf)
end

return M
