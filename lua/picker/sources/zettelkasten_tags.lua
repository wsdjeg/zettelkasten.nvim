local M = {}
local browser = require('zettelkasten.browser')

local function unique_string_table(t)
    local temp = {}
    for _, k in ipairs(t) do
        temp[k] = true
    end
    local rst = {}
    for m, _ in pairs(temp) do
        table.insert(rst, m)
    end
    return rst
end

function M.get()
    local tags = {}
    local result = browser.get_tags()

    for _, tag in ipairs(result) do
        table.insert(tags, tag.name)
    end
    tags = unique_string_table(tags)

    return vim.tbl_map(function(t)
        return {
            value = t,
            str = t,
        }
    end, tags)
end

function M.default_action(entry)
    vim.cmd('ZkBrowse --tags ' .. entry.str)
end

return M
