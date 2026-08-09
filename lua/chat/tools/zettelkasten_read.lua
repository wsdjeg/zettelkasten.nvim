local M = {}

local browser = require('zettelkasten.browser')

---@class ZettelkastenReadAction
---@field id string note ID

--- Read full content of a note by its ID
---@param action ZettelkastenReadAction
---@return table result with content or error
function M.zettelkasten_read(action)
  if not action.id then
    return { error = 'note id is required.' }
  end
  if type(action.id) ~= 'string' then
    return { error = 'the type of id should be string.' }
  end

  local note = browser.get_note(action.id)
  if note == nil then
    return { error = 'note not found: ' .. action.id }
  end

  local file = io.open(note.file_name, 'r')
  if not file then
    return { error = 'failed to read note file: ' .. note.file_name }
  end
  local content = file:read('*a')
  file:close()

  return { content = content }
end

function M.scheme()
  return {
    type = 'function',
    ['function'] = {
      name = 'zettelkasten_read',
      description = [[
      Read the full content of a zettelkasten note by its ID.

      Parameters:
      - id: The note ID (e.g., "2024-01-15-10-30-00"), obtainable from @zk get

      Returns the raw markdown content of the note file.
      ]],
      parameters = {
        type = 'object',
        properties = {
          id = {
            type = 'string',
            description = 'The note ID to read (e.g., "2024-01-15-10-30-00").',
          },
        },
        required = { 'id' },
      },
    },
  }
end

return M

