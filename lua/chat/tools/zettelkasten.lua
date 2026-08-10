local M = {}

local zk_config = require('zettelkasten.config')
local zk = require('zettelkasten')
local browser = require('zettelkasten.browser')

-- ===== Shared Helpers =====

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

--- Read full file content as a single string
---@param file_path string
---@return string|nil
local function read_file_content(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

--- Read all lines from a file
---@param file_path string
---@return string[]|nil
local function read_lines(file_path)
  local file = io.open(file_path, 'r')
  if not file then
    return nil
  end
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  return lines
end

--- Write lines to a file
---@param file_path string
---@param lines string[]
---@return boolean
local function write_lines(file_path, lines)
  local file = io.open(file_path, 'w')
  if not file then
    return false
  end
  file:write(table.concat(lines, '\n'))
  file:close()
  return true
end

--- Plain string replacement (no pattern matching)
---@param str string
---@param old string
---@param new string
---@return string
local function plain_replace(str, old, new)
  if old == '' then
    return str
  end
  local result = ''
  local i = 1
  while i <= #str do
    local start = str:find(old, i, true)
    if start then
      result = result .. str:sub(i, start - 1) .. new
      i = start + #old
    else
      result = result .. str:sub(i)
      break
    end
  end
  return result
end

--- Find the tags line index (1-based)
---@param lines string[]
---@return integer|nil
local function find_tags_line(lines)
  for i, line in ipairs(lines) do
    if line:match('^tags:') or line:match('^tags :') then
      return i
    end
  end
  return nil
end

--- Extract tags from a tags line
---@param tags_line string
---@return string[]
local function parse_tags(tags_line)
  local tags = {}
  for tag in tags_line:gmatch('(#[%w-]+)') do
    table.insert(tags, tag)
  end
  return tags
end

--- Build a tags line from tag strings
---@param tags string[]
---@return string
local function build_tags_line(tags)
  return 'tags: ' .. table.concat(tags, ' ')
end

--- Ensure tags have # prefix
---@param tags string[]
---@return string[]
local function normalize_tags(tags)
  local result = {}
  for _, tag in ipairs(tags) do
    if not tag:match('^#') then
      tag = '#' .. tag
    end
    table.insert(result, tag)
  end
  return result
end

--- Build a tag filter set from an array of tag strings
---@param tags string[]|nil
---@return table<string, boolean>|nil
local function build_tag_filter(tags)
  if not tags or #tags == 0 then
    return nil
  end
  local filter = {}
  for _, tag in ipairs(tags) do
    if not vim.startswith(tag, '#') then
      tag = '#' .. tag
    end
    filter[tag] = true
  end
  return filter
end

--- Check if a note matches the tag filter
---@param note ZettelkastenNote
---@param filter_tags table<string, boolean>|nil
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

--- Find a snippet around the first match of query in text
---@param text string
---@param query string
---@return string|nil
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

-- ===== Action: create =====

local function handle_create(action)
  if not action.title then
    return { error = 'failed to create zettelkasten note, title is required.' }
  end
  if type(action.title) ~= 'string' then
    return { error = 'the type of title should be string.' }
  end
  if type(action.content) ~= 'string' then
    return { error = 'the type of content should be string.' }
  end

  local id = zk.generate_note_id()
  local filename = zk_config.notes_path .. '/' .. id .. '.md'

  local content_lines = {
    string.format('# %s %s', id, action.title),
    '',
    action.content,
  }

  if action.tags and #action.tags > 0 then
    if type(action.tags) ~= 'table' then
      return { error = 'the type of tags should be table/array.' }
    end
    local tags_str = 'tags:'
    for _, tag in ipairs(action.tags) do
      if type(tag) ~= 'string' then
        return { error = 'each tag should be string type.' }
      end
      tags_str = tags_str .. ' #' .. tag
    end
    table.insert(content_lines, 3, tags_str)
    table.insert(content_lines, 4, '')
  end

  local ok, err = pcall(function()
    local file = io.open(filename, 'w')
    if not file then
      error('failed to open file: ' .. filename)
    end
    file:write(table.concat(content_lines, '\n'))
    file:close()
  end)

  if ok then
    return {
      content = string.format(
        'zettelkasten note created successfully!\n\nID: %s\nTitle: %s\nPath: %s',
        id, action.title, filename
      ),
    }
  else
    return {
      error = string.format('failed to create zettelkasten note:\n%s', tostring(err)),
    }
  end
end

-- ===== Action: get =====

local function handle_get(action)
  local all_notes = browser.get_notes()
  local filter_tags = build_tag_filter(action.tags) or {}
  local has_filter = action.tags and #action.tags > 0

  local results = {}
  for _, note in ipairs(all_notes) do
    local has_tag
    if not has_filter then
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

  return { content = vim.json.encode(results) }
end

-- ===== Action: read =====

local function handle_read(action)
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

  local content = read_file_content(note.file_name)
  if not content then
    return { error = 'failed to read note file: ' .. note.file_name }
  end

  return { content = content }
end

-- ===== Action: search =====

local function handle_search(action)
  if not action.query then
    return { error = 'query is required.' }
  end
  if type(action.query) ~= 'string' then
    return { error = 'the type of query should be string.' }
  end

  local all_notes = browser.get_notes()
  local filter_tags = build_tag_filter(action.tags)

  local results = {}
  for _, note in ipairs(all_notes) do
    if matches_tags(note, filter_tags) then
      local title_match = string.find(string.lower(note.title), string.lower(action.query), 1, true) ~= nil
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
        table.insert(results, {
          id = note.id,
          title = note.title,
          tags = extract_tag_names(note),
          file_name = note.file_name,
          references = extract_ref_ids(note),
          back_references = extract_back_refs(note),
          snippet = snippet,
        })
      end
    end
  end

  return { content = vim.json.encode(results) }
end

-- ===== Action: update =====

local function handle_update(action)
  if not action.id then
    return { error = 'note id is required.' }
  end
  if type(action.id) ~= 'string' then
    return { error = 'the type of id should be string.' }
  end

  local valid_update_actions = {
    update_title = true,
    add_tags = true,
    remove_tags = true,
    replace_text = true,
    delete_note = true,
    override_content = true,
    append_content = true,
    add_reference = true,
  }
  if not action.update_action or not valid_update_actions[action.update_action] then
    return {
      error = 'update_action is required and must be one of: update_title, add_tags, remove_tags, replace_text, delete_note, override_content, append_content, add_reference.',
    }
  end

  local note = browser.get_note(action.id)
  if note == nil then
    return { error = 'note not found: ' .. action.id }
  end

  local file_path = note.file_name
  browser.clear_cache()

  -- delete_note: remove the file entirely
  if action.update_action == 'delete_note' then
    local ok, err = os.remove(file_path)
    if not ok then
      return { error = 'failed to delete note file: ' .. file_path .. (err and (' (' .. err .. ')') or '') }
    end
    return {
      content = string.format('Note deleted successfully!\n\nID: %s\nPath: %s', action.id, file_path),
    }
  end

  local lines = read_lines(file_path)
  if lines == nil then
    return { error = 'failed to read note file: ' .. file_path }
  end

  if action.update_action == 'update_title' then
    if not action.title or type(action.title) ~= 'string' then
      return { error = 'title is required for update_title action.' }
    end
    if #lines == 0 then
      return { error = 'note file is empty.' }
    end
    lines[1] = string.format('# %s %s', action.id, action.title)

  elseif action.update_action == 'add_tags' then
    if not action.tags or type(action.tags) ~= 'table' or #action.tags == 0 then
      return { error = 'tags is required for add_tags action.' }
    end
    for _, tag in ipairs(action.tags) do
      if type(tag) ~= 'string' then
        return { error = 'each tag should be string type.' }
      end
    end
    local new_tags = normalize_tags(action.tags)
    local tags_line_idx = find_tags_line(lines)
    if tags_line_idx then
      local existing = parse_tags(lines[tags_line_idx])
      local seen = {}
      for _, t in ipairs(existing) do
        seen[t] = true
      end
      for _, t in ipairs(new_tags) do
        if not seen[t] then
          table.insert(existing, t)
          seen[t] = true
        end
      end
      lines[tags_line_idx] = build_tags_line(existing)
    else
      table.insert(lines, 2, build_tags_line(new_tags))
    end

  elseif action.update_action == 'remove_tags' then
    if not action.tags or type(action.tags) ~= 'table' or #action.tags == 0 then
      return { error = 'tags is required for remove_tags action.' }
    end
    for _, tag in ipairs(action.tags) do
      if type(tag) ~= 'string' then
        return { error = 'each tag should be string type.' }
      end
    end
    local remove_tags = normalize_tags(action.tags)
    local remove_set = {}
    for _, t in ipairs(remove_tags) do
      remove_set[t] = true
    end
    local tags_line_idx = find_tags_line(lines)
    if not tags_line_idx then
      goto done
    end
    local existing = parse_tags(lines[tags_line_idx])
    local remaining = {}
    for _, t in ipairs(existing) do
      if not remove_set[t] then
        table.insert(remaining, t)
      end
    end
    if #remaining == 0 then
      table.remove(lines, tags_line_idx)
    else
      lines[tags_line_idx] = build_tags_line(remaining)
    end

  elseif action.update_action == 'replace_text' then
    if not action.old_text or type(action.old_text) ~= 'string' then
      return { error = 'old_text is required for replace_text action.' }
    end
    if type(action.new_text) ~= 'string' then
      return { error = 'new_text should be string type (use empty string to delete).' }
    end
    local found = false
    for i = 2, #lines do
      if lines[i]:find(action.old_text, 1, true) then
        lines[i] = plain_replace(lines[i], action.old_text, action.new_text)
        found = true
      end
    end
    if not found then
      return { error = 'old_text not found in note body.' }
    end

  elseif action.update_action == 'override_content' then
    if not action.content or type(action.content) ~= 'string' then
      return { error = 'content is required for override_content action.' }
    end
    if #lines == 0 then
      return { error = 'note file is empty.' }
    end
    local title_line = lines[1]
    lines = { title_line, '' }
    for _, line in ipairs(vim.split(action.content, '\n')) do
      table.insert(lines, line)
    end

  elseif action.update_action == 'append_content' then
    if not action.content or type(action.content) ~= 'string' then
      return { error = 'content is required for append_content action.' }
    end
    if #lines == 0 then
      return { error = 'note file is empty.' }
    end
    if lines[#lines] ~= '' then
      table.insert(lines, '')
    end
    for _, line in ipairs(vim.split(action.content, '\n')) do
      table.insert(lines, line)
    end

  elseif action.update_action == 'add_reference' then
    if not action.reference_id or type(action.reference_id) ~= 'string' then
      return { error = 'reference_id is required for add_reference action.' }
    end
    if #lines == 0 then
      return { error = 'note file is empty.' }
    end
    local ref_link = '[[' .. action.reference_id .. ']]'
    if action.reference_text and type(action.reference_text) == 'string' and action.reference_text ~= '' then
      ref_link = ref_link .. ' ' .. action.reference_text
    end
    if lines[#lines] ~= '' then
      table.insert(lines, '')
    end
    table.insert(lines, ref_link)
  end

  ::done::

  local ok = write_lines(file_path, lines)
  if not ok then
    return { error = 'failed to write note file: ' .. file_path }
  end

  local summary = string.format(
    'Note updated successfully!\n\nID: %s\nAction: %s\nPath: %s',
    action.id, action.update_action, file_path
  )

  if action.update_action == 'update_title' then
    summary = summary .. '\nNew title: ' .. action.title
  elseif action.update_action == 'add_tags' then
    summary = summary .. '\nAdded tags: ' .. table.concat(normalize_tags(action.tags), ', ')
  elseif action.update_action == 'remove_tags' then
    summary = summary .. '\nRemoved tags: ' .. table.concat(normalize_tags(action.tags), ', ')
  elseif action.update_action == 'replace_text' then
    summary = summary .. '\nReplaced: "' .. action.old_text .. '" -> "' .. action.new_text .. '"'
  elseif action.update_action == 'override_content' then
    summary = summary .. '\nContent length: ' .. #action.content .. ' characters'
  elseif action.update_action == 'append_content' then
    summary = summary .. '\nAppended content length: ' .. #action.content .. ' characters'
  elseif action.update_action == 'add_reference' then
    summary = summary .. '\nAdded reference: [[' .. action.reference_id .. ']]'
  end

  return { content = summary }
end

-- ===== Action: tags =====

local function handle_tags()
  local all_notes = browser.get_notes()
  local tag_counts = {}

  for _, note in ipairs(all_notes) do
    local seen = {}
    for _, tag in ipairs(note.tags) do
      if not seen[tag.name] then
        seen[tag.name] = true
        tag_counts[tag.name] = (tag_counts[tag.name] or 0) + 1
      end
    end
  end

  local tags_arr = {}
  for name, count in pairs(tag_counts) do
    table.insert(tags_arr, { name = name, count = count })
  end

  table.sort(tags_arr, function(a, b)
    if a.count ~= b.count then
      return a.count > b.count
    end
    return a.name < b.name
  end)

  return { content = vim.json.encode(tags_arr) }
end

-- ===== Main Entry =====

function M.zettelkasten(action)
  local valid_actions = {
    create = true,
    get = true,
    read = true,
    search = true,
    update = true,
    tags = true,
  }
  if not action.action or not valid_actions[action.action] then
    return {
      error = 'action is required and must be one of: create, get, read, search, update, tags.',
    }
  end

  if action.action == 'create' then
    return handle_create(action)
  elseif action.action == 'get' then
    return handle_get(action)
  elseif action.action == 'read' then
    return handle_read(action)
  elseif action.action == 'search' then
    return handle_search(action)
  elseif action.action == 'update' then
    return handle_update(action)
  elseif action.action == 'tags' then
    return handle_tags()
  end
end

function M.scheme()
  return {
    type = 'function',
    ['function'] = {
      name = 'zettelkasten',
      description = [==[
Unified zettelkasten note management tool. Use @zk command.

Actions:
1. create - Create a new zettelkasten note
   Required: title, content. Optional: tags (max 3, English)
   Example: @zk action="create" title="My Note" content="Note body" tags=["python"]

2. get - Retrieve notes by tags (pass empty tags array for all notes)
   Optional: tags
   Example: @zk action="get" tags=["python"]
   Returns: id, title, tags, file_name, references, back_references

3. read - Read full content of a note by ID
   Required: id
   Example: @zk action="read" id="2024-01-15-10-30-00"

4. search - Search notes by keyword in title and body (case-insensitive)
   Required: query. Optional: tags (filter scope)
   Example: @zk action="search" query="vim" tags=["programming"]
   Returns: id, title, tags, file_name, references, back_references, snippet

5. update - Update an existing note (partial updates)
   Required: id, update_action
   update_action options:
   - update_title: Change title (ID preserved). Required: title
   - add_tags: Add tags (dedup). Required: tags
   - remove_tags: Remove tags. Required: tags
   - replace_text: Find & replace in body (title skipped). Required: old_text, new_text
   - delete_note: Delete the note file permanently
   - override_content: Replace entire body (title preserved). Required: content
   - append_content: Append text to body. Required: content
   - add_reference: Add [[id]] link to body. Required: reference_id. Optional: reference_text
   Example: @zk action="update" id="2024-01-15-10-30-00" update_action="add_tags" tags=["web"]

6. tags - List all tags with note counts
   No parameters needed
   Example: @zk action="tags"
   Returns: array of { name, count } sorted by count desc, then alphabetically

⚠️ create and update should ONLY be called when the user explicitly requests.
]==],
      parameters = {
        type = 'object',
        properties = {
          action = {
            type = 'string',
            enum = { 'create', 'get', 'read', 'search', 'update', 'tags' },
            description = 'The operation to perform',
          },
          title = {
            type = 'string',
            description = 'Note title (for create, or update_title)',
          },
          content = {
            type = 'string',
            description = 'Note body content (for create, override_content, append_content)',
          },
          tags = {
            type = 'array',
            items = { type = 'string' },
            description = 'Tags array (for create, get, search, add_tags, remove_tags). Tags should be English.',
          },
          id = {
            type = 'string',
            description = 'Note ID (e.g., "2024-01-15-10-30-00") (for read, update)',
          },
          query = {
            type = 'string',
            description = 'Search keyword (for search)',
          },
          update_action = {
            type = 'string',
            enum = { 'update_title', 'add_tags', 'remove_tags', 'replace_text', 'delete_note', 'override_content', 'append_content', 'add_reference' },
            description = 'Update sub-action (for update action)',
          },
          old_text = {
            type = 'string',
            description = 'Text to find in note body (for replace_text)',
          },
          new_text = {
            type = 'string',
            description = 'Replacement text (for replace_text, use empty string to delete)',
          },
          reference_id = {
            type = 'string',
            description = 'Target note ID to reference (for add_reference)',
          },
          reference_text = {
            type = 'string',
            description = 'Optional display text for reference link (for add_reference)',
          },
        },
        required = { 'action' },
      },
    },
  }
end

return M

