local M = {}

local zk_config = require('zettelkasten.config')
local browser = require('zettelkasten.browser')

--- Read all lines from a note file
---@param file_path string
---@return string[]|nil lines
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

--- Write lines back to a note file
---@param file_path string
---@param lines string[]
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
---@return integer|nil line index of tags line
local function find_tags_line(lines)
  for i, line in ipairs(lines) do
    if line:match('^tags:') or line:match('^tags :') then
      return i
    end
  end
  return nil
end

--- Extract existing tags from a tags line
---@param tags_line string
---@return string[] tags e.g. {"#tag1", "#tag2"}
local function parse_tags(tags_line)
  local tags = {}
  for tag in tags_line:gmatch('(#[%w-]+)') do
    table.insert(tags, tag)
  end
  return tags
end

--- Build a tags line from a list of tag strings
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

---@param action table
function M.zettelkasten_update(action)
  if not action.id then
    return { error = 'note id is required.' }
  end
  if type(action.id) ~= 'string' then
    return { error = 'the type of id should be string.' }
  end

  local valid_actions = {
    update_title = true,
    add_tags = true,
    remove_tags = true,
    replace_text = true,
  }
  if not action.action or not valid_actions[action.action] then
    return {
      error = 'action is required and must be one of: update_title, add_tags, remove_tags, replace_text.',
    }
  end

  -- find the note by id
  local note = browser.get_note(action.id)
  if note == nil then
    return { error = 'note not found: ' .. action.id }
  end

  local file_path = note.file_name
  local lines = read_lines(file_path)
  if lines == nil then
    return { error = 'failed to read note file: ' .. file_path }
  end

  -- clear browser cache so next get_notes() re-reads from disk
  browser.clear_cache()

  if action.action == 'update_title' then
    if not action.title or type(action.title) ~= 'string' then
      return { error = 'title is required for update_title action.' }
    end

    -- line 1: # {id} {old_title} -> # {id} {new_title}
    if #lines == 0 then
      return { error = 'note file is empty.' }
    end
    lines[1] = string.format('# %s %s', action.id, action.title)

  elseif action.action == 'add_tags' then
    if not action.tags or type(action.tags) ~= 'table' or #action.tags == 0 then
      return { error = 'tags is required for add_tags action.' }
    end

    -- validate each tag is string
    for _, tag in ipairs(action.tags) do
      if type(tag) ~= 'string' then
        return { error = 'each tag should be string type.' }
      end
    end

    local new_tags = normalize_tags(action.tags)
    local tags_line_idx = find_tags_line(lines)

    if tags_line_idx then
      -- merge with existing tags, avoid duplicates
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
      -- no tags line yet, insert after line 1 (the title line)
      table.insert(lines, 2, build_tags_line(new_tags))
    end

  elseif action.action == 'remove_tags' then
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
      -- no tags line, nothing to remove
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
      -- remove the tags line entirely
      table.remove(lines, tags_line_idx)
    else
      lines[tags_line_idx] = build_tags_line(remaining)
    end

  elseif action.action == 'replace_text' then
    if not action.old_text or type(action.old_text) ~= 'string' then
      return { error = 'old_text is required for replace_text action.' }
    end
    if type(action.new_text) ~= 'string' then
      return { error = 'new_text should be string type (use empty string to delete).' }
    end

    local found = false
    -- skip line 1 (title line) when replacing text
    for i = 2, #lines do
      if lines[i]:find(action.old_text, 1, true) then
        lines[i] = plain_replace(lines[i], action.old_text, action.new_text)
        found = true
      end
    end

    if not found then
      return { error = 'old_text not found in note body.' }
    end
  end

  ::done::

  local ok = write_lines(file_path, lines)
  if not ok then
    return { error = 'failed to write note file: ' .. file_path }
  end

  -- build summary
  local summary = string.format(
    'Note updated successfully!\n\nID: %s\nAction: %s\nPath: %s',
    action.id,
    action.action,
    file_path
  )

  if action.action == 'update_title' then
    summary = summary .. '\nNew title: ' .. action.title
  elseif action.action == 'add_tags' then
    summary = summary .. '\nAdded tags: ' .. table.concat(normalize_tags(action.tags), ', ')
  elseif action.action == 'remove_tags' then
    summary = summary .. '\nRemoved tags: ' .. table.concat(normalize_tags(action.tags), ', ')
  elseif action.action == 'replace_text' then
    summary = summary .. '\nReplaced: "' .. action.old_text .. '" -> "' .. action.new_text .. '"'
  end

  return { content = summary }
end

function M.scheme()
  return {
    type = 'function',
    ['function'] = {
      name = 'zettelkasten_update',
      description = [[
Update an existing zettelkasten note. Use @zk update command.

Supports partial updates without needing to pass the full note content:

1. update_title - Change the note title (ID is preserved)
   Example: @zk update id="2024-01-15-10-30-00" action="update_title" title="New Title"

2. add_tags - Add new tags to the note (duplicates are skipped)
   Example: @zk update id="2024-01-15-10-30-00" action="add_tags" tags=["python", "web"]

3. remove_tags - Remove specific tags from the note
   Example: @zk update id="2024-01-15-10-30-00" action="remove_tags" tags=["old-tag"]

4. replace_text - Find and replace text in the note body (title line is skipped)
   Example: @zk update id="2024-01-15-10-30-00" action="replace_text" old_text="old code" new_text="new code"

Tags can be provided with or without # prefix. Use empty new_text to delete text.

⚠️ Only call this tool when the user explicitly requests to update a note.
]],
      parameters = {
        type = 'object',
        properties = {
          id = {
            type = 'string',
            description = 'The note ID (e.g., "2024-01-15-10-30-00")',
          },
          action = {
            type = 'string',
            enum = { 'update_title', 'add_tags', 'remove_tags', 'replace_text' },
            description = 'The update action to perform',
          },
          title = {
            type = 'string',
            description = 'New title (required for update_title action)',
          },
          tags = {
            type = 'array',
            items = { type = 'string' },
            description = 'Tags to add or remove (required for add_tags/remove_tags actions)',
          },
          old_text = {
            type = 'string',
            description = 'Text to find in the note body (required for replace_text action)',
          },
          new_text = {
            type = 'string',
            description = 'Replacement text (required for replace_text action, use empty string to delete)',
          },
        },
        required = { 'id', 'action' },
      },
    },
  }
end

return M

