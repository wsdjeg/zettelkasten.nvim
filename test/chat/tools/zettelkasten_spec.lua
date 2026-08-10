--=============================================================================
-- zettelkasten_spec.lua --- tests for unified chat tool zettelkasten
--=============================================================================

local lu = require('luaunit')
local tool = require('chat.tools.zettelkasten')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenTool = {}

local test_notes_dir

function TestZettelkastenTool:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_unified_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenTool:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file
---@param id string
---@param title string
---@param tags string[]|nil
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

--- Helper: read note file content directly from disk (bypasses browser cache)
---@param id string
---@return string|nil
local function read_note_content(id)
  local path = test_notes_dir .. '/' .. id .. '.md'
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*a')
  file:close()
  return content
end

--- Helper: decode JSON result content
---@param result table
---@return table
local function decode_result(result)
  return vim.json.decode(result.content)
end

-- ============== invalid action ==============

function TestZettelkastenTool:test_missing_action()
  local result = tool.zettelkasten({})
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_invalid_action()
  local result = tool.zettelkasten({ action = 'invalid' })
  lu.assertNotNil(result.error)
end

-- ============== create ==============

function TestZettelkastenTool:test_create_basic()
  local result = tool.zettelkasten({
    action = 'create',
    title = 'Test Note',
    content = 'Hello world',
  })
  lu.assertNotNil(result.content)
  lu.assertTrue(string.find(result.content, 'Test Note') ~= nil)
end

function TestZettelkastenTool:test_create_with_tags()
  local result = tool.zettelkasten({
    action = 'create',
    title = 'Tagged Note',
    content = 'Body',
    tags = { 'python', 'web' },
  })
  lu.assertNotNil(result.content)
  lu.assertTrue(string.find(result.content, 'Tagged Note') ~= nil)
end

function TestZettelkastenTool:test_create_missing_title()
  local result = tool.zettelkasten({ action = 'create', content = 'body' })
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_create_creates_file()
  tool.zettelkasten({
    action = 'create',
    title = 'File Check',
    content = 'Content here',
  })
  browser.clear_cache()
  local notes = browser.get_notes()
  local found = false
  for _, note in ipairs(notes) do
    if note.title == 'File Check' then
      found = true
      break
    end
  end
  lu.assertTrue(found)
end

-- ============== get ==============

function TestZettelkastenTool:test_get_all_notes()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content A')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content B')

  local result = tool.zettelkasten({ action = 'get', tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 2)
end

function TestZettelkastenTool:test_get_by_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })
  create_note('2024-01-02-12-00-00', 'Note B', { 'lua' })

  local result = tool.zettelkasten({ action = 'get', tags = { 'python' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Note A')
end

function TestZettelkastenTool:test_get_by_hash_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })

  local result = tool.zettelkasten({ action = 'get', tags = { '#python' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
end

function TestZettelkastenTool:test_get_non_matching_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })

  local result = tool.zettelkasten({ action = 'get', tags = { 'nonexistent' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 0)
end

function TestZettelkastenTool:test_get_result_fields()
  create_note('2024-01-01-12-00-00', 'My Title', { 'python' }, 'Content')

  local result = tool.zettelkasten({ action = 'get', tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(notes[1].id, '2024-01-01-12-00-00')
  lu.assertEquals(notes[1].title, 'My Title')
  lu.assertTrue(vim.tbl_contains(notes[1].tags, '#python'))
  lu.assertNotNil(notes[1].file_name)
end

function TestZettelkastenTool:test_get_references_and_back_refs()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'See [[2024-01-02-12-00-00]]')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content')

  local result = tool.zettelkasten({ action = 'get', tags = {} })
  local notes = decode_result(result)

  local note_a, note_b
  for _, n in ipairs(notes) do
    if n.id == '2024-01-01-12-00-00' then note_a = n end
    if n.id == '2024-01-02-12-00-00' then note_b = n end
  end

  lu.assertEquals(#note_a.references, 1)
  lu.assertEquals(note_a.references[1], '2024-01-02-12-00-00')
  lu.assertEquals(#note_b.back_references, 1)
  lu.assertEquals(note_b.back_references[1].id, '2024-01-01-12-00-00')
end

-- ============== read ==============

function TestZettelkastenTool:test_read_basic()
  create_note('2024-01-01-12-00-00', 'Read Me', nil, 'Hello world')

  local result = tool.zettelkasten({ action = 'read', id = '2024-01-01-12-00-00' })
  lu.assertNotNil(result.content)
  lu.assertTrue(string.find(result.content, 'Hello world') ~= nil)
end

function TestZettelkastenTool:test_read_not_found()
  local result = tool.zettelkasten({ action = 'read', id = 'nonexistent' })
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_read_missing_id()
  local result = tool.zettelkasten({ action = 'read' })
  lu.assertNotNil(result.error)
end

-- ============== search ==============

function TestZettelkastenTool:test_search_title_match()
  create_note('2024-01-01-12-00-00', 'Vim Tips', nil, 'Some content')

  local result = tool.zettelkasten({ action = 'search', query = 'vim' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Vim Tips')
end

function TestZettelkastenTool:test_search_body_match()
  create_note('2024-01-01-12-00-00', 'Random Title', nil, 'I love neovim plugins')

  local result = tool.zettelkasten({ action = 'search', query = 'neovim' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertNotNil(notes[1].snippet)
end

function TestZettelkastenTool:test_search_case_insensitive()
  create_note('2024-01-01-12-00-00', 'Vim Tips', nil, 'Content')

  local result = tool.zettelkasten({ action = 'search', query = 'VIM' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
end

function TestZettelkastenTool:test_search_with_tag_filter()
  create_note('2024-01-01-12-00-00', 'Vim Note', { 'editor' })
  create_note('2024-01-02-12-00-00', 'Vim Other', { 'cooking' })

  local result = tool.zettelkasten({ action = 'search', query = 'vim', tags = { 'editor' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Vim Note')
end

function TestZettelkastenTool:test_search_no_match()
  create_note('2024-01-01-12-00-00', 'Hello', nil, 'World')

  local result = tool.zettelkasten({ action = 'search', query = 'nonexistent' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 0)
end

function TestZettelkastenTool:test_search_missing_query()
  local result = tool.zettelkasten({ action = 'search' })
  lu.assertNotNil(result.error)
end

-- ============== update: update_title ==============

function TestZettelkastenTool:test_update_title()
  create_note('2024-01-01-12-00-00', 'Old Title', nil, 'Body')

  local result = tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'update_title',
    title = 'New Title',
  })
  lu.assertNotNil(result.content)

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertNotNil(content)
  lu.assertEquals(type(content), 'string')
  lu.assertNotNil(string.find(content, 'New Title', 1, true))
  lu.assertNotNil(string.find(content, '2024-01-01-12-00-00', 1, true))
end

-- ============== update: add_tags ==============

function TestZettelkastenTool:test_add_tags_new()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Body')

  local result = tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'add_tags',
    tags = { 'python' },
  })
  lu.assertNotNil(result.content)

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, '#python') ~= nil)
end

function TestZettelkastenTool:test_add_tags_merge_existing()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Body')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'add_tags',
    tags = { 'web' },
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, '#python') ~= nil)
  lu.assertTrue(string.find(content, '#web') ~= nil)
end

function TestZettelkastenTool:test_add_tags_dedup()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Body')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'add_tags',
    tags = { 'python' },
  })

  local content = read_note_content('2024-01-01-12-00-00')
  local count = select(2, string.gsub(content, '#python', ''))
  lu.assertEquals(count, 1)
end

-- ============== update: remove_tags ==============

function TestZettelkastenTool:test_remove_tags()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python', 'web' }, 'Body')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'remove_tags',
    tags = { 'python' },
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, '#web') ~= nil)
  lu.assertTrue(string.find(content, '#python') == nil)
end

function TestZettelkastenTool:test_remove_all_tags_removes_line()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Body')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'remove_tags',
    tags = { 'python' },
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, 'tags:') == nil)
end

-- ============== update: replace_text ==============

function TestZettelkastenTool:test_replace_text()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'old code here')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'replace_text',
    old_text = 'old',
    new_text = 'new',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, 'new code') ~= nil)
  lu.assertTrue(string.find(content, 'old code') == nil)
end

function TestZettelkastenTool:test_replace_text_not_found()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'some content')

  local result = tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'replace_text',
    old_text = 'nonexistent',
    new_text = 'replaced',
  })
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_replace_text_delete()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'hello world content')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'replace_text',
    old_text = 'world ',
    new_text = '',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, 'hello content') ~= nil)
end

-- ============== update: delete_note ==============

function TestZettelkastenTool:test_delete_note()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Body')

  local result = tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'delete_note',
  })
  lu.assertNotNil(result.content)

  browser.clear_cache()
  local notes = decode_result(tool.zettelkasten({ action = 'get', tags = {} }))
  lu.assertEquals(#notes, 0)
end

-- ============== update: override_content ==============

function TestZettelkastenTool:test_override_content()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'old content')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'override_content',
    content = 'brand new content',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, 'brand new content') ~= nil)
  lu.assertTrue(string.find(content, 'old content') == nil)
  -- title preserved
  lu.assertTrue(string.find(content, 'Note A') ~= nil)
end

-- ============== update: append_content ==============

function TestZettelkastenTool:test_append_content()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'original')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'append_content',
    content = 'appended text',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, 'original') ~= nil)
  lu.assertTrue(string.find(content, 'appended text') ~= nil)
end

-- ============== update: add_reference ==============

function TestZettelkastenTool:test_add_reference()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Target')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, '%[%[2024%-01%-02%-12%-00%-00%]%]') ~= nil)
end

function TestZettelkastenTool:test_add_reference_with_text()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')

  tool.zettelkasten({
    action = 'update',
    id = '2024-01-01-12-00-00',
    update_action = 'add_reference',
    reference_id = '2024-01-02-12-00-00',
    reference_text = 'See also',
  })

  local content = read_note_content('2024-01-01-12-00-00')
  lu.assertTrue(string.find(content, '%[%[2024%-01%-02%-12%-00%-00%]%] See also') ~= nil)
end

-- ============== update: validation ==============

function TestZettelkastenTool:test_update_missing_id()
  local result = tool.zettelkasten({ action = 'update', update_action = 'update_title' })
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_update_missing_update_action()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Body')
  local result = tool.zettelkasten({ action = 'update', id = '2024-01-01-12-00-00' })
  lu.assertNotNil(result.error)
end

function TestZettelkastenTool:test_update_not_found()
  local result = tool.zettelkasten({
    action = 'update',
    id = 'nonexistent',
    update_action = 'update_title',
    title = 'X',
  })
  lu.assertNotNil(result.error)
end

-- ============== tags ==============

function TestZettelkastenTool:test_tags_list()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python', 'web' })
  create_note('2024-01-02-12-00-00', 'Note B', { 'lua' })

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(#tags, 3)
end

function TestZettelkastenTool:test_tags_empty()
  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(#tags, 0)
end

function TestZettelkastenTool:test_tags_count()
  create_note('2024-01-01-12-00-00', 'A', { 'python' })
  create_note('2024-01-02-12-00-00', 'B', { 'python' })
  create_note('2024-01-03-12-00-00', 'C', { 'python' })

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(#tags, 1)
  lu.assertEquals(tags[1].name, '#python')
  lu.assertEquals(tags[1].count, 3)
end

function TestZettelkastenTool:test_tags_sort_by_count()
  create_note('2024-01-01-12-00-00', 'A', { 'rare' })
  create_note('2024-01-02-12-00-00', 'B', { 'common' })
  create_note('2024-01-03-12-00-00', 'C', { 'common' })

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(tags[1].name, '#common')
  lu.assertEquals(tags[1].count, 2)
  lu.assertEquals(tags[2].name, '#rare')
  lu.assertEquals(tags[2].count, 1)
end

function TestZettelkastenTool:test_tags_sort_alphabetical_same_count()
  create_note('2024-01-01-12-00-00', 'A', { 'zebra' })
  create_note('2024-01-02-12-00-00', 'B', { 'apple' })
  create_note('2024-01-03-12-00-00', 'C', { 'mango' })

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(tags[1].name, '#apple')
  lu.assertEquals(tags[2].name, '#mango')
  lu.assertEquals(tags[3].name, '#zebra')
end

function TestZettelkastenTool:test_tags_dedup_within_note()
  local path = test_notes_dir .. '/2024-01-01-12-00-00.md'
  vim.fn.writefile({
    '# 2024-01-01-12-00-00 Dup',
    'tags: #python #python',
    '',
    'Content',
  }, path)

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertEquals(#tags, 1)
  lu.assertEquals(tags[1].count, 1)
end

function TestZettelkastenTool:test_tags_name_has_hash()
  create_note('2024-01-01-12-00-00', 'A', { 'python' })

  local result = tool.zettelkasten({ action = 'tags' })
  local tags = decode_result(result)

  lu.assertTrue(vim.startswith(tags[1].name, '#'))
end

-- ============== scheme ==============

function TestZettelkastenTool:test_scheme_structure()
  local scheme = tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenTool:test_scheme_action_required()
  local scheme = tool.scheme()
  lu.assertTrue(vim.tbl_contains(scheme['function'].parameters.required, 'action'))
end

function TestZettelkastenTool:test_scheme_action_enum()
  local scheme = tool.scheme()
  local action_prop = scheme['function'].parameters.properties.action
  lu.assertNotNil(action_prop)
  lu.assertEquals(action_prop.type, 'string')
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'create'))
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'get'))
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'read'))
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'search'))
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'update'))
  lu.assertTrue(vim.tbl_contains(action_prop.enum, 'tags'))
end

function TestZettelkastenTool:test_scheme_json_encode()
  local scheme = tool.scheme()
  local ok, json = pcall(vim.json.encode, scheme)
  lu.assertTrue(ok)
  lu.assertNotNil(json)
end

-- Tests are collected and run by test/run.lua

return TestZettelkastenTool

