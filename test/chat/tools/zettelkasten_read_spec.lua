--=============================================================================
-- zettelkasten_read_spec.lua --- tests for chat tools zettelkasten_read
--=============================================================================

local lu = require('luaunit')
local read_tool = require('chat.tools.zettelkasten_read')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenRead = {}

local test_notes_dir

function TestZettelkastenRead:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_read_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenRead:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file
---@param id string
---@param title string
---@param body string|nil
---@return string file_path
local function create_note(id, title, body)
  local path = test_notes_dir .. '/' .. id .. '.md'
  local lines = { '# ' .. id .. ' ' .. title, '' }
  if body then
    for _, line in ipairs(vim.split(body, '\n')) do
      table.insert(lines, line)
    end
  end
  vim.fn.writefile(lines, path)
  return path
end

-- ============== basic read ==============

function TestZettelkastenRead:test_read_basic()
  create_note('2024-01-01-12-00-00', 'Test Note', 'Hello world')

  local result = read_tool.zettelkasten_read({ id = '2024-01-01-12-00-00' })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  lu.assertNotNil(result.content)
  lu.assertTrue(string.find(result.content, 'Hello world', 1, true) ~= nil)
end

function TestZettelkastenRead:test_read_includes_title()
  create_note('2024-01-01-12-00-00', 'My Title', 'Body content')

  local result = read_tool.zettelkasten_read({ id = '2024-01-01-12-00-00' })

  lu.assertTrue(string.find(result.content, '# 2024-01-01-12-00-00 My Title', 1, true) ~= nil)
end

function TestZettelkastenRead:test_read_multiline_content()
  local body = 'Line 1\nLine 2\nLine 3'
  create_note('2024-01-01-12-00-00', 'Multi Note', body)

  local result = read_tool.zettelkasten_read({ id = '2024-01-01-12-00-00' })

  lu.assertTrue(string.find(result.content, 'Line 1', 1, true) ~= nil)
  lu.assertTrue(string.find(result.content, 'Line 2', 1, true) ~= nil)
  lu.assertTrue(string.find(result.content, 'Line 3', 1, true) ~= nil)
end

function TestZettelkastenRead:test_read_note_with_tags()
  local path = test_notes_dir .. '/2024-01-01-12-00-00.md'
  local lines = {
    '# 2024-01-01-12-00-00 Tagged Note',
    'tags: #python #web',
    '',
    'Some content',
  }
  vim.fn.writefile(lines, path)

  local result = read_tool.zettelkasten_read({ id = '2024-01-01-12-00-00' })

  lu.assertFalse(result.error ~= nil, 'should not return error')
  lu.assertTrue(string.find(result.content, 'tags: #python #web', 1, true) ~= nil)
end

function TestZettelkastenRead:test_read_note_with_references()
  create_note('2024-01-01-12-00-00', 'Note A', 'See [[2024-01-02-12-00-00]] for details')
  create_note('2024-01-02-12-00-00', 'Note B', 'Content')

  local result = read_tool.zettelkasten_read({ id = '2024-01-01-12-00-00' })

  lu.assertTrue(string.find(result.content, '[[2024-01-02-12-00-00]]', 1, true) ~= nil)
end

-- ============== error cases ==============

function TestZettelkastenRead:test_read_missing_id()
  local result = read_tool.zettelkasten_read({})

  lu.assertNotNil(result.error)
end

function TestZettelkastenRead:test_read_nonexistent_note()
  local result = read_tool.zettelkasten_read({ id = '9999-99-99-99-99-99' })

  lu.assertNotNil(result.error)
end

function TestZettelkastenRead:test_read_non_string_id()
  local result = read_tool.zettelkasten_read({ id = 123 })

  lu.assertNotNil(result.error)
end

-- ============== scheme ==============

function TestZettelkastenRead:test_scheme_returns_valid_structure()
  local scheme = read_tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten_read')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenRead:test_scheme_required_fields()
  local scheme = read_tool.scheme()
  local required = scheme['function'].parameters.required
  lu.assertTrue(vim.tbl_contains(required, 'id'))
end

function TestZettelkastenRead:test_scheme_id_param()
  local scheme = read_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.id)
  lu.assertEquals(scheme['function'].parameters.properties.id.type, 'string')
end

-- Tests are collected and run by test/run.lua

