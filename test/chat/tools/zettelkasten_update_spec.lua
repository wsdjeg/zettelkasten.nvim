--=============================================================================
-- zettelkasten_update_spec.lua --- tests for chat tools zettelkasten_update
--=============================================================================

local lu = require('luaunit')
local update_tool = require('chat.tools.zettelkasten_update')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenUpdate = {}

local test_notes_dir

function TestZettelkastenUpdate:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_update_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenUpdate:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file with optional tags line
---@param id string
---@param title string
---@param tags string[]|nil e.g. {"work", "important"}
---@param body string|nil
---@return string file_path
local function create_note(id, title, tags, body)
  local path = test_notes_dir .. '/' .. id .. '.md'
  local lines = { '# ' .. id .. ' ' .. title }
  if tags and #tags > 0 then
    local tags_str = 'tags:'
    for _, tag in ipairs(tags) do
      tags_str = tags_str .. ' #' .. tag
    end
    table.insert(lines, tags_str)
  end
  table.insert(lines, '')
  if body then
    for _, line in ipairs(vim.split(body, '\n')) do
      table.insert(lines, line)
    end
  end
  vim.fn.writefile(lines, path)
  return path
end

--- Helper: read file content as lines
---@param path string
---@return string[]
local function read_file_lines(path)
  return vim.fn.readfile(path)
end

-- ============== update_title ==============

function TestZettelkastenUpdate:test_update_title_basic()
  create_note('2024-01-01-12-00-00', 'Old Title', nil, 'Some content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'update_title',
    title = 'New Title',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 New Title')
end

function TestZettelkastenUpdate:test_update_title_preserves_body()
  create_note('2024-01-01-12-00-00', 'Old Title', nil, 'Line 1\nLine 2')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'update_title',
    title = 'New Title',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 New Title')
  lu.assertEquals(lines[3], 'Line 1')
  lu.assertEquals(lines[4], 'Line 2')
end

function TestZettelkastenUpdate:test_update_title_missing_title()
  create_note('2024-01-01-12-00-00', 'Old Title')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'update_title',
  })

  lu.assertNotNil(result.error)
end

-- ============== add_tags ==============

function TestZettelkastenUpdate:test_add_tags_to_note_without_tags()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_tags',
    tags = { 'python', 'web' },
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- line 1: title, line 2: tags, line 3: empty, line 4: content
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[2], 'tags: #python #web')
end

function TestZettelkastenUpdate:test_add_tags_to_note_with_existing_tags()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'existing' }, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_tags',
    tags = { 'new-tag' },
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[2], 'tags: #existing #new-tag')
end

function TestZettelkastenUpdate:test_add_tags_skip_duplicates()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'work' }, 'Content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_tags',
    tags = { 'work', 'new' },
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- 'work' should not be duplicated
  lu.assertEquals(lines[2], 'tags: #work #new')
end

function TestZettelkastenUpdate:test_add_tags_with_hash_prefix()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_tags',
    tags = { '#already-hashed', 'plain' },
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[2], 'tags: #already-hashed #plain')
end

function TestZettelkastenUpdate:test_add_tags_missing_tags()
  create_note('2024-01-01-12-00-00', 'Test Note')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_tags',
  })

  lu.assertNotNil(result.error)
end

-- ============== remove_tags ==============

function TestZettelkastenUpdate:test_remove_tags_basic()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'keep', 'remove' }, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'remove_tags',
    tags = { 'remove' },
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[2], 'tags: #keep')
end

function TestZettelkastenUpdate:test_remove_all_tags_removes_tags_line()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'tag1', 'tag2' }, 'Content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'remove_tags',
    tags = { 'tag1', 'tag2' },
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- tags line should be entirely removed
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[2], '')
  lu.assertEquals(lines[3], 'Content')
end

function TestZettelkastenUpdate:test_remove_tags_not_present()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'keep' }, 'Content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'remove_tags',
    tags = { 'nonexistent' },
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- existing tag should remain unchanged
  lu.assertEquals(lines[2], 'tags: #keep')
end

function TestZettelkastenUpdate:test_remove_tags_no_tags_line()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'remove_tags',
    tags = { 'anything' },
  })

  -- should not error, just do nothing
  lu.assertFalse(result.error ~= nil, 'should not return error')
end

-- ============== replace_text ==============

function TestZettelkastenUpdate:test_replace_text_basic()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Hello world')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'replace_text',
    old_text = 'Hello',
    new_text = 'Hi',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[3], 'Hi world')
end

function TestZettelkastenUpdate:test_replace_text_multiple_occurrences()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'foo bar foo')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'replace_text',
    old_text = 'foo',
    new_text = 'baz',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[3], 'baz bar baz')
end

function TestZettelkastenUpdate:test_replace_text_delete_with_empty_new()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Hello world')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'replace_text',
    old_text = 'Hello ',
    new_text = '',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[3], 'world')
end

function TestZettelkastenUpdate:test_replace_text_not_found()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Hello world')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'replace_text',
    old_text = 'nonexistent',
    new_text = 'replacement',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_replace_text_skips_title_line()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Test Note body')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'replace_text',
    old_text = 'Test Note',
    new_text = 'Changed',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- title line should be unchanged
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  -- body line should be changed
  lu.assertEquals(lines[3], 'Changed body')
end

-- ============== delete_note ==============

function TestZettelkastenUpdate:test_delete_note_basic()
  local path = create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'delete_note',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  lu.assertNotNil(result.content)
  -- file should no longer exist
  lu.assertEquals(vim.fn.filereadable(path), 0)
end

function TestZettelkastenUpdate:test_delete_note_with_tags()
  local path = create_note('2024-01-01-12-00-00', 'Test Note', { 'tag1', 'tag2' }, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'delete_note',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  lu.assertEquals(vim.fn.filereadable(path), 0)
end

function TestZettelkastenUpdate:test_delete_note_not_found()
  local result = update_tool.zettelkasten_update({
    id = '9999-99-99-99-99-99',
    action = 'delete_note',
  })

  lu.assertNotNil(result.error)
end

-- ============== override_content ==============

function TestZettelkastenUpdate:test_override_content_basic()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'old-tag' }, 'Old content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'override_content',
    content = 'New content here',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- line 1: title preserved, line 2: empty, line 3: new content
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[2], '')
  lu.assertEquals(lines[3], 'New content here')
end

function TestZettelkastenUpdate:test_override_content_preserves_title()
  create_note('2024-01-01-12-00-00', 'Original Title', nil, 'Old body')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'override_content',
    content = 'Completely new body',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Original Title')
  lu.assertEquals(lines[3], 'Completely new body')
end

function TestZettelkastenUpdate:test_override_content_multiline()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Old content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'override_content',
    content = 'Line A\nLine B\nLine C',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[2], '')
  lu.assertEquals(lines[3], 'Line A')
  lu.assertEquals(lines[4], 'Line B')
  lu.assertEquals(lines[5], 'Line C')
end

function TestZettelkastenUpdate:test_override_content_empty_string()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'tag' }, 'Old content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'override_content',
    content = '',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- title line preserved, plus empty separator line
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(#lines, 2)
end

function TestZettelkastenUpdate:test_override_content_missing_content()
  create_note('2024-01-01-12-00-00', 'Test Note')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'override_content',
  })

  lu.assertNotNil(result.error)
end

-- ============== append_content ==============

function TestZettelkastenUpdate:test_append_content_basic()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Original body')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = 'Appended text',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- line 1: title, line 2: empty, line 3: original body, line 4: empty separator, line 5: appended
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[3], 'Original body')
  lu.assertEquals(lines[4], '')
  lu.assertEquals(lines[5], 'Appended text')
end

function TestZettelkastenUpdate:test_append_content_multiline()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Original')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = 'Line A\nLine B',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[3], 'Original')
  lu.assertEquals(lines[4], '')
  lu.assertEquals(lines[5], 'Line A')
  lu.assertEquals(lines[6], 'Line B')
end

function TestZettelkastenUpdate:test_append_content_preserves_title_and_tags()
  create_note('2024-01-01-12-00-00', 'Test Note', { 'tag1' }, 'Body content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = 'More content',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- title and tags should be unchanged
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  lu.assertEquals(lines[2], 'tags: #tag1')
  -- original body preserved
  lu.assertEquals(lines[4], 'Body content')
  -- appended content
  lu.assertEquals(lines[5], '')
  lu.assertEquals(lines[6], 'More content')
end

function TestZettelkastenUpdate:test_append_content_no_existing_body()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, nil)

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = 'First content',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Test Note')
  -- line 2 is the empty line from create_note
  -- last line is empty already, so no extra separator needed
  lu.assertEquals(lines[#lines], 'First content')
end

function TestZettelkastenUpdate:test_append_content_empty_string()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Body')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = '',
  })

  -- empty content still valid - appends a blank line separator + empty
  lu.assertFalse(result.error ~= nil, 'should not return error')
end

function TestZettelkastenUpdate:test_append_content_missing_content()
  create_note('2024-01-01-12-00-00', 'Test Note')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_append_content_summary()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'Body')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'append_content',
    content = 'Added text',
  })

  lu.assertNotNil(result.content)
  lu.assertTrue(result.content:find('append_content') ~= nil)
  lu.assertTrue(result.content:find('Added text') == nil) -- summary doesn't include content
  lu.assertTrue(result.content:find('10 characters') ~= nil) -- "Added text" is 10 chars
end

-- ============== add_reference ==============

function TestZettelkastenUpdate:test_add_reference_basic()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Some content')
  create_note('2024-01-02-12-00-00', 'Note B')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- title preserved
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Note A')
  -- original body preserved
  lu.assertEquals(lines[3], 'Some content')
  -- reference link appended at the end
  lu.assertEquals(lines[#lines], '[[2024-01-02-12-00-00]]')
end

function TestZettelkastenUpdate:test_add_reference_with_display_text()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')
  create_note('2024-01-02-12-00-00', 'Note B')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
    reference_text = 'See Note B',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[#lines], '[[2024-01-02-12-00-00]] See Note B')
end

function TestZettelkastenUpdate:test_add_reference_preserves_title_and_tags()
  create_note('2024-01-01-12-00-00', 'Note A', { 'important' }, 'Body')
  create_note('2024-01-02-12-00-00', 'Note B')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Note A')
  lu.assertEquals(lines[2], 'tags: #important')
  lu.assertEquals(lines[#lines], '[[2024-01-02-12-00-00]]')
end

function TestZettelkastenUpdate:test_add_reference_no_existing_body()
  create_note('2024-01-01-12-00-00', 'Note A', nil, nil)

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
  })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  lu.assertEquals(lines[1], '# 2024-01-01-12-00-00 Note A')
  lu.assertEquals(lines[#lines], '[[2024-01-02-12-00-00]]')
end

function TestZettelkastenUpdate:test_add_reference_missing_reference_id()
  create_note('2024-01-01-12-00-00', 'Note A')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_add_reference_empty_reference_text_ignored()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')

  update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
    reference_text = '',
  })

  local lines = read_file_lines(test_notes_dir .. '/2024-01-01-12-00-00.md')
  -- empty reference_text should be ignored, no trailing space
  lu.assertEquals(lines[#lines], '[[2024-01-02-12-00-00]]')
end

function TestZettelkastenUpdate:test_add_reference_summary()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
  })

  lu.assertNotNil(result.content)
  lu.assertTrue(result.content:find('add_reference') ~= nil)
  lu.assertTrue(result.content:find('%[%[2024%-01%-02%-12%-00%-00%]%]') ~= nil)
end

-- ============== error cases ==============

function TestZettelkastenUpdate:test_missing_id()
  local result = update_tool.zettelkasten_update({
    action = 'update_title',
    title = 'New Title',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_invalid_action()
  create_note('2024-01-01-12-00-00', 'Test Note')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
    action = 'invalid_action',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_note_not_found()
  local result = update_tool.zettelkasten_update({
    id = '9999-99-99-99-99-99',
    action = 'update_title',
    title = 'New Title',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_id_not_string()
  local result = update_tool.zettelkasten_update({
    id = 12345,
    action = 'update_title',
    title = 'New Title',
  })

  lu.assertNotNil(result.error)
end

function TestZettelkastenUpdate:test_missing_action()
  create_note('2024-01-01-12-00-00', 'Test Note')

  local result = update_tool.zettelkasten_update({
    id = '2024-01-01-12-00-00',
  })

  lu.assertNotNil(result.error)
end

-- ============== scheme ==============

function TestZettelkastenUpdate:test_scheme_returns_valid_structure()
  local scheme = update_tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten_update')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenUpdate:test_scheme_required_fields()
  local scheme = update_tool.scheme()
  local required = scheme['function'].parameters.required
  lu.assertTrue(vim.tbl_contains(required, 'id'))
  lu.assertTrue(vim.tbl_contains(required, 'action'))
end

function TestZettelkastenUpdate:test_scheme_includes_all_actions()
  local scheme = update_tool.scheme()
  local enum = scheme['function'].parameters.properties.action.enum
  lu.assertTrue(vim.tbl_contains(enum, 'update_title'))
  lu.assertTrue(vim.tbl_contains(enum, 'add_tags'))
  lu.assertTrue(vim.tbl_contains(enum, 'remove_tags'))
  lu.assertTrue(vim.tbl_contains(enum, 'replace_text'))
  lu.assertTrue(vim.tbl_contains(enum, 'delete_note'))
  lu.assertTrue(vim.tbl_contains(enum, 'override_content'))
  lu.assertTrue(vim.tbl_contains(enum, 'append_content'))
  lu.assertTrue(vim.tbl_contains(enum, 'add_reference'))
end

function TestZettelkastenUpdate:test_scheme_includes_content_param()
  local scheme = update_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.content)
  lu.assertEquals(scheme['function'].parameters.properties.content.type, 'string')
end

function TestZettelkastenUpdate:test_scheme_includes_reference_params()
  local scheme = update_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.reference_id)
  lu.assertEquals(scheme['function'].parameters.properties.reference_id.type, 'string')
  lu.assertNotNil(scheme['function'].parameters.properties.reference_text)
  lu.assertEquals(scheme['function'].parameters.properties.reference_text.type, 'string')
end

-- Tests are collected and run by test/run.lua


