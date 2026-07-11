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

-- Tests are collected and run by test/run.lua

