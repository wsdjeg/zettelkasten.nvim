--=============================================================================
-- zettelkasten_get_spec.lua --- tests for chat tools zettelkasten_get
--=============================================================================

local lu = require('luaunit')
local get_tool = require('chat.tools.zettelkasten_get')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenGet = {}

local test_notes_dir

function TestZettelkastenGet:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_get_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenGet:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file with optional tags line and body
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

--- Helper: decode JSON result content
---@param result table
---@return table
local function decode_result(result)
  return vim.json.decode(result.content)
end

-- ============== basic retrieval ==============

function TestZettelkastenGet:test_get_all_notes_with_empty_tags()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content A')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content B')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 2)
end

function TestZettelkastenGet:test_get_with_specific_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Content A')
  create_note('2024-01-02-12-00-00', 'Note B', { 'lua' }, 'Content B')

  local result = get_tool.zettelkasten_get({ tags = { 'python' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Note A')
end

function TestZettelkastenGet:test_get_with_non_matching_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Content A')

  local result = get_tool.zettelkasten_get({ tags = { 'nonexistent' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 0)
end

function TestZettelkastenGet:test_get_with_hash_prefixed_tag()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'Content A')

  local result = get_tool.zettelkasten_get({ tags = { '#python' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Note A')
end

-- ============== return fields ==============

function TestZettelkastenGet:test_result_includes_id()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(notes[1].id, '2024-01-01-12-00-00')
end

function TestZettelkastenGet:test_result_includes_title()
  create_note('2024-01-01-12-00-00', 'My Title', nil, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(notes[1].title, 'My Title')
end

function TestZettelkastenGet:test_result_includes_tags()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python', 'web' }, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(#notes[1].tags, 2)
  lu.assertTrue(vim.tbl_contains(notes[1].tags, '#python'))
  lu.assertTrue(vim.tbl_contains(notes[1].tags, '#web'))
end

function TestZettelkastenGet:test_result_includes_file_name()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertNotNil(notes[1].file_name)
  lu.assertNotNil(string.find(notes[1].file_name, '2024-01-01-12-00-00', 1, true))
end

function TestZettelkastenGet:test_result_includes_references()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'See [[2024-01-02-12-00-00]]')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  -- Find Note A
  local note_a = nil
  for _, note in ipairs(notes) do
    if note.id == '2024-01-01-12-00-00' then
      note_a = note
      break
    end
  end

  lu.assertNotNil(note_a)
  lu.assertEquals(#note_a.references, 1)
  lu.assertEquals(note_a.references[1], '2024-01-02-12-00-00')
end

function TestZettelkastenGet:test_result_includes_back_references()
  -- Note A references Note B
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'See [[2024-01-02-12-00-00]]')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  -- Find Note B
  local note_b = nil
  for _, note in ipairs(notes) do
    if note.id == '2024-01-02-12-00-00' then
      note_b = note
      break
    end
  end

  lu.assertNotNil(note_b)
  lu.assertEquals(#note_b.back_references, 1)
  lu.assertEquals(note_b.back_references[1].id, '2024-01-01-12-00-00')
  lu.assertEquals(note_b.back_references[1].title, 'Note A')
end

function TestZettelkastenGet:test_result_no_references_returns_empty_array()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'No links here')

  local result = get_tool.zettelkasten_get({ tags = {} })
  local notes = decode_result(result)

  lu.assertEquals(#notes[1].references, 0)
  lu.assertEquals(#notes[1].back_references, 0)
end

-- ============== scheme ==============

function TestZettelkastenGet:test_scheme_returns_valid_structure()
  local scheme = get_tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten_get')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenGet:test_scheme_required_fields()
  local scheme = get_tool.scheme()
  local required = scheme['function'].parameters.required
  lu.assertTrue(vim.tbl_contains(required, 'tags'))
end

function TestZettelkastenGet:test_scheme_tags_param()
  local scheme = get_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.tags)
  lu.assertEquals(scheme['function'].parameters.properties.tags.type, 'array')
end

-- Tests are collected and run by test/run.lua

