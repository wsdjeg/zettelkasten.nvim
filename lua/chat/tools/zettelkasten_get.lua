local M = {}

local browser = require('zettelkasten.browser')

---@class ZettelkastenGetAction
---@field tags

function M.zettelkasten_get(action, ctx)
  local all_notes = browser.get_notes()
  local filter_tags = {}
  for _, tag in ipairs(action.tags) do
    if not vim.startswith(tag, '#') then
      tag = '#' .. tag
    end
    filter_tags[tag] = true
  end
  local results = {}
  for _, note in ipairs(all_notes) do
    local has_tag
    if #action.tags == 0 then
      has_tag = true
    else
      for _, tag in ipairs(note.tags) do
        if filter_tags[tag.name] then
          has_tag = true
          break
        end
      end
    end
    if has_tag then
      table.insert(results, {
        file_name = note.file_name,
        title = note.title,
      })
    end
  end

  return {
    content = vim.json.encode(results),
  }
end

function M.scheme()
  return {
    type = 'function',
    ['function'] = {
      name = 'zettelkasten_get',
      description = [[
      use @zk get <tags> to get zettelkasten note. return JSON object.

      file_name: is the file name of note.
      title: zettelkasten note's title.

      ]],
      parameters = {
        type = 'object',
        properties = {
          tags = {
            type = 'array',
            items = {
              type = 'string',
            },
            description = 'Optional tags for the note (e.g., ["programming", "vim"]), the tag should be english.',
          },
        },
        required = { 'tags' },
      },
    },
  }
end

return M
