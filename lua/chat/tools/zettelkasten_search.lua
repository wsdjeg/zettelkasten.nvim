local M = {}

local browser = require('zettelkasten.browser')

---@class ZettelkastenSearchAction
---@field query string search keyword
---@field tags string[]|nil optional tag filter

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

--- Read note file content
---@param file_path string
---@return string|nil content
local function read_file_content(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

--- Find a snippet around the first match of query in text (case-insensitive)
---@param text string
---@param query string
---@return string|nil snippet
local function find_snippet(text, query)
  local lower_text = string.lower(text)
  local lower_query = string.lower(query)
  local start = string.find(lower_text, lower_query, 1, true)
  if not start then
    return nil
  end
  local snippet_start = math.max(1, start - 30)
  local snippet_end = math.min(#text, start + #query + 30)
  local prefix = snippet_start > 1 and '...' or ''
  local suffix = snippet_end < #text and '...' or ''
  return prefix .. string.sub(text, snippet_start, snippet_end) .. suffix
end

--- Check if a note matches the tag filter
---@param note ZettelkastenNote
---@param filter_tags table<string, boolean>
---@return boolean
local function matches_tags(note, filter_tags)
  if not filter_tags or next(filter_tags) == nil then
    return true
  end
  for _, tag in ipairs(note.tags) do
    if filter_tags[tag.name] then
      return true
    end
  end
  return false
end

--- Search notes by keyword in title and body
---@param action ZettelkastenSearchAction
---@return table result with content or error
function M.zettelkasten_search(action)
  if not action.query then
    return { error = 'query is required.' }
  end
  if type(action.query) ~= 'string' then
    return { error = 'the type of query should be string.' }
  end

  local all_notes = browser.get_notes()

  -- Build tag filter if tags are provided
  local filter_tags = nil
  if action.tags and #action.tags > 0 then
    filter_tags = {}
    for _, tag in ipairs(action.tags) do
      if not vim.startswith(tag, '#') then
        tag = '#' .. tag
      end
      filter_tags[tag] = true
    end
  end

  local results = {}
  for _, note in ipairs(all_notes) do
    if matches_tags(note, filter_tags) then
      -- Search in title first
      local title_match = string.find(string.lower(note.title), string.lower(action.query), 1, true) ~= nil

      -- Read body content and search
      local body_match = false
      local snippet = nil

      if not title_match then
        local content = read_file_content(note.file_name)
        if content then
          local lower_content = string.lower(content)
          local lower_query = string.lower(action.query)
          if string.find(lower_content, lower_query, 1, true) then
            body_match = true
            snippet = find_snippet(content, action.query)
          end
        end
      else
        snippet = note.title
      end

      if title_match or body_match then
        local entry = {
          id = note.id,
          title = note.title,
          tags = extract_tag_names(note),
          file_name = note.file_name,
          references = extract_ref_ids(note),
          back_references = extract_back_refs(note),
          snippet = snippet,
        }
        table.insert(results, entry)
      end
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
      name = 'zettelkasten_search',
      description = [[
      Search zettelkasten notes by keyword. Searches both note titles and body content (case-insensitive).

      Parameters:
      - query: Search keyword (required)
      - tags: Optional tag filter to narrow search scope (e.g., ["programming"])

      Each result contains:
      - id: note ID
      - title: note title
      - tags: array of tag names
      - file_name: file path
      - references: array of note IDs this note links to
      - back_references: array of { id, title } for notes linking to this note
      - snippet: text snippet showing match context

      Use @zk read with the id to get full note content.
      ]],
      parameters = {
        type = 'object',
        properties = {
          query = {
            type = 'string',
            description = 'Search keyword to find in note title and body.',
          },
          tags = {
            type = 'array',
            items = {
              type = 'string',
            },
            description = 'Optional tags to filter notes before searching (e.g., ["programming", "vim"]).',
          },
        },
        required = { 'query' },
      },
    },
  }
end

return M

