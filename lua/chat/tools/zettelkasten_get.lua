local M = {}

local browser = require('zettelkasten.browser')

---@class ZettelkastenGetAction
---@field tags string[]

--- Extract tag names from note tags
---@param note ZettelkastenNote
---@return string[]
local function extract_tag_names(note)
  local names = {}
  for _, tag in ipairs(note.tags) do
    table.insert(names, tag.name)
  end
  return names
end

--- Extract reference ids from note references
---@param note ZettelkastenNote
---@return string[]
local function extract_ref_ids(note)
  local ids = {}
  for _, ref in ipairs(note.references) do
    table.insert(ids, ref.id)
  end
  return ids
end

--- Extract back references as { id, title } objects
---@param note ZettelkastenNote
---@return table[]
local function extract_back_refs(note)
  local refs = {}
  for _, bref in ipairs(note.back_references) do
    table.insert(refs, { id = bref.id, title = bref.title })
  end
  return refs
end

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
        id = note.id,
        title = note.title,
        tags = extract_tag_names(note),
        file_name = note.file_name,
        references = extract_ref_ids(note),
        back_references = extract_back_refs(note),
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

      Each result contains:
      - id: note ID (e.g., "2024-01-15-10-30-00"), use this for @zk update
      - title: note title
      - tags: array of tag names (e.g., ["#python", "#vim"])
      - file_name: file path of the note
      - references: array of note IDs this note links to
      - back_references: array of { id, title } for notes that link to this note

      Pass empty tags array to get all notes.
      ]],
      parameters = {
        type = 'object',
        properties = {
          tags = {
            type = 'array',
            items = {
              type = 'string',
            },
            description = 'Optional tags for the note (e.g., ["programming", "vim"]), the tag should be english. Pass empty array to get all notes.',
          },
        },
        required = { 'tags' },
      },
    },
  }
end

return M

