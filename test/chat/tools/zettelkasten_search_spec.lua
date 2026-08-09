--=============================================================================
-- zettelkasten_search_spec.lua --- tests for chat tools zettelkasten_search
--=============================================================================

local lu = require('luaunit')
local search_tool = require('chat.tools.zettelkasten_search')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestZettelkastenSearch = {}

local test_notes_dir

function TestZettelkastenSearch:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_search_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkastenSearch:tearDown()
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

--- Helper: decode JSON result
local function decode_result(result)
  return vim.json.decode(result.content)
end

-- ============== title search ==============

function TestZettelkastenSearch:test_search_matches_title()
  create_note('2024-01-01-12-00-00', 'Lua Tutorial', nil, 'Some content')

  local result = search_tool.zettelkasten_search({ query = 'Tutorial' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].title, 'Lua Tutorial')
end

function TestZettelkastenSearch:test_search_case_insensitive_title()
  create_note('2024-01-01-12-00-00', 'Python Guide', nil, 'Content')

  local result = search_tool.zettelkasten_search({ query = 'python' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
end

-- ============== body search ==============

function TestZettelkastenSearch:test_search_matches_body()
  create_note('2024-01-01-12-00-00', 'Some Title', nil, 'Learn neovim plugins here')

  local result = search_tool.zettelkasten_search({ query = 'neovim' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].id, '2024-01-01-12-00-00')
end

function TestZettelkastenSearch:test_search_case_insensitive_body()
  create_note('2024-01-01-12-00-00', 'Title', nil, 'Docker container setup')

  local result = search_tool.zettelkasten_search({ query = 'DOCKER' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
end

-- ============== no match ==============

function TestZettelkastenSearch:test_search_no_match()
  create_note('2024-01-01-12-00-00', 'Note A', nil, 'Content about cats')

  local result = search_tool.zettelkasten_search({ query = 'dogs' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 0)
end

-- ============== multiple results ==============

function TestZettelkastenSearch:test_search_multiple_results()
  create_note('2024-01-01-12-00-00', 'Vim Tips', nil, 'Use vim efficiently')
  create_note('2024-01-02-12-00-00', 'Emacs Guide', nil, 'Not about vim')
  create_note('2024-01-03-12-00-00', 'Editor Wars', nil, 'vim vs emacs debate')

  local result = search_tool.zettelkasten_search({ query = 'vim' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 3)
end

-- ============== tag filter ==============

function TestZettelkastenSearch:test_search_with_tag_filter()
  create_note('2024-01-01-12-00-00', 'Vim Note', { 'editor' }, 'vim is great')
  create_note('2024-01-02-12-00-00', 'Vim Note 2', { 'tools' }, 'vim is great')

  local result = search_tool.zettelkasten_search({ query = 'vim', tags = { 'editor' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].id, '2024-01-01-12-00-00')
end

function TestZettelkastenSearch:test_search_with_hash_tag_filter()
  create_note('2024-01-01-12-00-00', 'Vim Note', { 'editor' }, 'vim is great')

  local result = search_tool.zettelkasten_search({ query = 'vim', tags = { '#editor' } })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
end

-- ============== snippet ==============

function TestZettelkastenSearch:test_result_includes_snippet()
  create_note('2024-01-01-12-00-00', 'Test Note', nil, 'This is important content here')

  local result = search_tool.zettelkasten_search({ query = 'important' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertNotNil(notes[1].snippet)
  lu.assertNotNil(string.find(notes[1].snippet, 'important', 1, true))
end

function TestZettelkastenSearch:test_snippet_for_title_match()
  create_note('2024-01-01-12-00-00', 'Special Title', nil, 'body text')

  local result = search_tool.zettelkasten_search({ query = 'Special' })
  local notes = decode_result(result)

  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].snippet, 'Special Title')
end

-- ============== return fields ==============

function TestZettelkastenSearch:test_result_includes_all_fields()
  create_note('2024-01-01-12-00-00', 'Note A', { 'python' }, 'See [[2024-01-02-12-00-00]]')
  create_note('2024-01-02-12-00-00', 'Note B', nil, 'Content')

  local result = search_tool.zettelkasten_search({ query = 'Note' })
  local notes = decode_result(result)

  lu.assertTrue(#notes >= 1)
  local note = notes[1]
  lu.assertNotNil(note.id)
  lu.assertNotNil(note.title)
  lu.assertNotNil(note.tags)
  lu.assertNotNil(note.file_name)
  lu.assertNotNil(note.references)
  lu.assertNotNil(note.back_references)
  lu.assertNotNil(note.snippet)
end

-- ============== error cases ==============

function TestZettelkastenSearch:test_search_missing_query()
  local result = search_tool.zettelkasten_search({})

  lu.assertNotNil(result.error)
end

function TestZettelkastenSearch:test_search_non_string_query()
  local result = search_tool.zettelkasten_search({ query = 123 })

  lu.assertNotNil(result.error)
end

-- ============== scheme ==============

function TestZettelkastenSearch:test_scheme_returns_valid_structure()
  local scheme = search_tool.scheme()
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(scheme['function'].name, 'zettelkasten_search')
  lu.assertNotNil(scheme['function'].parameters)
  lu.assertEquals(scheme['function'].parameters.type, 'object')
end

function TestZettelkastenSearch:test_scheme_required_fields()
  local scheme = search_tool.scheme()
  local required = scheme['function'].parameters.required
  lu.assertTrue(vim.tbl_contains(required, 'query'))
end

function TestZettelkastenSearch:test_scheme_query_param()
  local scheme = search_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.query)
  lu.assertEquals(scheme['function'].parameters.properties.query.type, 'string')
end

function TestZettelkastenSearch:test_scheme_tags_param_optional()
  local scheme = search_tool.scheme()
  lu.assertNotNil(scheme['function'].parameters.properties.tags)
  local required = scheme['function'].parameters.required
  lu.assertFalse(vim.tbl_contains(required, 'tags'))
end

-- Tests are collected and run by test/run.lua

