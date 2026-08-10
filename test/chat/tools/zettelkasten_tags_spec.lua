--=============================================================================
-- zettelkasten_tags_spec.lua --- tests for chat tools zettelkasten_tags
--=============================================================================

local lu = require('luaunit')
local tags_tool = require('chat.tools.zettelkasten_tags')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenTags = {}

local test_notes_dir

function TestZettelkastenTags:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_tags_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenTags:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file with optional tags
---@param id string
---@param title string
---@param tags string[]|nil e.g. {"work", "important"}
---@return string file_path
local function create_note(id, title, tags)
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
  table.insert(lines, 'Some content')
  vim.fn.writefile(lines, path)
  return path
end

--- Helper: decode JSON result content
---@param result table
---@return table
local function decode_result(result)
  return vim.json.decode(result.content)
end

-- ============== basic listing ==============

function TestZettelkastenTags:test_list_all_tags()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python', 'web' })
  create_note('2024-01-02-12-00-00', 'Note B', { 'lua' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 3)
end

function TestZettelkastenTags:test_empty_notes_dir()
  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 0)
end

function TestZettelkastenTags:test_note_without_tags()
  create_note('2024-01-01-12-00-00', 'No Tags Note', nil)

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 0)
end

-- ============== count correctness ==============

function TestZettelkastenTags:test_tag_count_single_note()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 1)
  lu.assertEquals(tags[1].name, '#python')
  lu.assertEquals(tags[1].count, 1)
end

function TestZettelkastenTags:test_tag_count_multiple_notes()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })
  create_note('2024-01-02-12-00-00', 'Note B', { 'python' })
  create_note('2024-01-03-12-00-00', 'Note C', { 'python' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 1)
  lu.assertEquals(tags[1].count, 3)
end

function TestZettelkastenTags:test_different_tags_different_counts()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python', 'web' })
  create_note('2024-01-02-12-00-00', 'Note B', { 'python' })
  create_note('2024-01-03-12-00-00', 'Note C', { 'web' })
  create_note('2024-01-04-12-00-00', 'Note D', { 'web' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  -- #web: 3, #python: 2
  lu.assertEquals(tags[1].name, '#web')
  lu.assertEquals(tags[1].count, 3)
  lu.assertEquals(tags[2].name, '#python')
  lu.assertEquals(tags[2].count, 2)
end

-- ============== dedup within same note ==============

function TestZettelkastenTags:test_duplicate_tag_in_same_note_counted_once()
  -- Note with duplicate tag line: tags: #python #python
  local path = test_notes_dir .. '/2024-01-01-12-00-00.md'
  local lines = {
    '# 2024-01-01-12-00-00 Dup Note',
    'tags: #python #python',
    '',
    'Content',
  }
  vim.fn.writefile(lines, path)

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(#tags, 1)
  lu.assertEquals(tags[1].count, 1)
end

-- ============== sorting ==============

function TestZettelkastenTags:test_sorted_by_count_descending()
  create_note('2024-01-01-12-00-00', 'A', { 'rare' })
  create_note('2024-01-02-12-00-00', 'B', { 'common' })
  create_note('2024-01-03-12-00-00', 'C', { 'common' })
  create_note('2024-01-04-12-00-00', 'D', { 'common' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertEquals(tags[1].name, '#common')
  lu.assertEquals(tags[1].count, 3)
  lu.assertEquals(tags[2].name, '#rare')
  lu.assertEquals(tags[2].count, 1)
end

function TestZettelkastenTags:test_sorted_alphabetically_when_same_count()
  create_note('2024-01-01-12-00-00', 'A', { 'zebra' })
  create_note('2024-01-02-12-00-00', 'B', { 'apple' })
  create_note('2024-01-03-12-00-00', 'C', { 'mango' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  -- All count=1, so sorted alphabetically
  lu.assertEquals(tags[1].name, '#apple')
  lu.assertEquals(tags[2].name, '#mango')
  lu.assertEquals(tags[3].name, '#zebra')
end

-- ============== return format ==============

function TestZettelkastenTags:test_result_has_name_and_count()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertNotNil(tags[1].name)
  lu.assertNotNil(tags[1].count)
  lu.assertEquals(type(tags[1].name), 'string')
  lu.assertEquals(type(tags[1].count), 'number')
end

function TestZettelkastenTags:test_tag_name_includes_hash()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' })

  local result = tags_tool.zettelkasten_tags({})
  local tags = decode_result(result)

  lu.assertTrue(vim.startswith(tags[1].name, '#'))
end

-- ============== scheme ==============

function TestZettelkastenTags:test_scheme_returns_valid_structure()
  local scheme = tags_tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten_tags')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenTags:test_scheme_no_required_fields()
  local scheme = tags_tool.scheme()
  local required = scheme['function'].parameters.required
  lu.assertEquals(#required, 0)
end

-- Tests are collected and run by test/run.lua

