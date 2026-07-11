--=============================================================================
-- zettelkasten_spec.lua --- tests for main zettelkasten module
--=============================================================================

local lu = require('luaunit')
local zk = require('zettelkasten')
local config = require('zettelkasten.config')
local browser = require('zettelkasten.browser')

TestZettelkasten = {}

local test_notes_dir

--- Helper: write lines to a note file (uses vim.fn.writefile for reliability)
local function write_note(dir, id, lines)
  local path = dir .. '/' .. id .. '.md'
  vim.fn.writefile(lines, path)
  return path
end

function TestZettelkasten:setUp()
  -- Clear browser cache to avoid stale data between tests
  browser.clear_cache()
  -- Use tempname for cross-platform compatibility
  test_notes_dir = vim.fn.tempname() .. '_zk_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestZettelkasten:tearDown()
  -- Clean up test notes
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Test generate_note_id with default (current time)
function TestZettelkasten:test_generate_note_id_default()
  local id = zk.generate_note_id()
  -- Should match pattern YYYY-MM-DD-HH-MM-SS
  lu.assertTrue(string.match(id, '^%d+%-%d+%-%d+%-%d+%-%d+%-%d+$') ~= nil)
end

--- Test generate_note_id with specific date
function TestZettelkasten:test_generate_note_id_with_date()
  local id = zk.generate_note_id({
    year = 2024,
    month = 6,
    day = 15,
    hour = 10,
    min = 30,
    sec = 0,
  })
  lu.assertEquals(id, '2024-06-15-10-30-00')
end

--- Test generate_note_id with partial date
function TestZettelkasten:test_generate_note_id_partial_date()
  local id = zk.generate_note_id({ year = 2025, month = 1, day = 1 })
  -- hour, min, sec should come from current time
  -- use %- to escape hyphens in Lua pattern
  lu.assertTrue(string.match(id, '^2025%-01%-01%-%d+%-%d+%-%d+$') ~= nil)
end

--- Test generate_note_id with empty table
function TestZettelkasten:test_generate_note_id_empty_table()
  local id = zk.generate_note_id({})
  lu.assertTrue(string.match(id, '^%d+%-%d+%-%d+%-%d+%-%d+%-%d+$') ~= nil)
end

--- Test setup function sets notes_path
function TestZettelkasten:test_setup_sets_notes_path()
  local custom_path = vim.fn.tempname() .. '_custom_notes'
  zk.setup({ notes_path = custom_path })
  lu.assertEquals(config.notes_path, custom_path)
  -- restore
  config._set({ notes_path = test_notes_dir })
end

--- Test setup with nil opts preserves existing notes_path
function TestZettelkasten:test_setup_with_nil()
  local before = config.notes_path
  zk.setup(nil)
  lu.assertEquals(config.notes_path, before)
end

--- Test get_note_browser_content returns empty for empty notes dir
function TestZettelkasten:test_get_note_browser_content_empty_dir()
  -- Ensure directory is empty
  vim.fn.delete(test_notes_dir, 'rf')
  vim.fn.mkdir(test_notes_dir, 'p')

  local content = zk.get_note_browser_content({ tags = {} })
  lu.assertEquals(#content, 0)
end

--- Test get_note_browser_content with a note
function TestZettelkasten:test_get_note_browser_content_with_note()
  -- Create a test note
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Test Note',
    '',
    'This is a test note. #test',
  })

  local content = zk.get_note_browser_content({ tags = {} })
  lu.assertTrue(#content > 0)
  lu.assertTrue(string.find(content[1], '2024-01-01-12-00-00', 1, true) ~= nil)
end

--- Test get_note_browser_content with tag filter
function TestZettelkasten:test_get_note_browser_content_tag_filter()
  -- Create test notes
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Note One',
    '',
    'Content #work',
  })
  write_note(test_notes_dir, '2024-01-02-12-00-00', {
    '# 2024-01-02-12-00-00 Note Two',
    '',
    'Content #personal',
  })

  -- Filter by #work tag
  local content = zk.get_note_browser_content({ tags = { '#work' } })
  lu.assertTrue(#content >= 1)
  for _, line in ipairs(content) do
    lu.assertTrue(string.find(line, '2024-01-01-12-00-00', 1, true) ~= nil)
  end
end

--- Test get_note_browser_content with date filter
function TestZettelkasten:test_get_note_browser_content_date_filter()
  -- Create test notes
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Note One',
    '',
    'Content',
  })
  write_note(test_notes_dir, '2024-06-15-12-00-00', {
    '# 2024-06-15-12-00-00 Note Two',
    '',
    'Content',
  })

  -- Filter by year 2024, month 1
  local content = zk.get_note_browser_content({
    tags = {},
    date = { year = 2024, month = 1 },
  })
  lu.assertTrue(#content >= 1)
  for _, line in ipairs(content) do
    lu.assertTrue(string.find(line, '2024-01-01-12-00-00', 1, true) ~= nil)
  end
end

--- Test get_back_references returns empty for non-existent note
function TestZettelkasten:test_get_back_references_nonexistent()
  local refs = zk.get_back_references('nonexistent-id')
  lu.assertEquals(#refs, 0)
end

--- Test get_back_references with actual back references
function TestZettelkasten:test_get_back_references_with_refs()
  -- Create a note that references another
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Note One',
    '',
    'See [[2024-01-02-12-00-00]]',
  })
  write_note(test_notes_dir, '2024-01-02-12-00-00', {
    '# 2024-01-02-12-00-00 Note Two',
    '',
    'Content',
  })

  local refs = zk.get_back_references('2024-01-02-12-00-00')
  lu.assertTrue(#refs >= 1)
  lu.assertEquals(refs[1].id, '2024-01-01-12-00-00')
end

--- Test get_back_references includes title and file_name
function TestZettelkasten:test_get_back_references_includes_fields()
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Note One',
    '',
    'See [[2024-01-02-12-00-00]]',
  })
  write_note(test_notes_dir, '2024-01-02-12-00-00', {
    '# 2024-01-02-12-00-00 Note Two',
    '',
    'Content',
  })

  local refs = zk.get_back_references('2024-01-02-12-00-00')
  lu.assertTrue(#refs >= 1)
  lu.assertEquals(refs[1].title, 'Note One')
  lu.assertNotNil(refs[1].file_name)
  lu.assertNotNil(refs[1].linenr)
end

--- Test setup with empty table preserves existing notes_path
function TestZettelkasten:test_setup_with_empty_table()
  local before = config.notes_path
  zk.setup({})
  lu.assertEquals(config.notes_path, before)
end

--- Test get_toc returns formatted lines
function TestZettelkasten:test_get_toc_returns_lines()
  write_note(test_notes_dir, '2024-01-01-12-00-00', {
    '# 2024-01-01-12-00-00 Note One',
    '',
    'See [[2024-01-02-12-00-00]]',
  })
  write_note(test_notes_dir, '2024-01-02-12-00-00', {
    '# 2024-01-02-12-00-00 Note Two',
    '',
    'Content',
  })

  local toc = zk.get_toc('2024-01-02-12-00-00')
  lu.assertTrue(#toc >= 1)
  -- default format is '- [%h](%d)', should contain the title and id
  lu.assertTrue(string.find(toc[1], 'Note One', 1, true) ~= nil)
  lu.assertTrue(string.find(toc[1], '2024-01-01-12-00-00', 1, true) ~= nil)
end

--- Test get_note_browser_content returns empty when notes_path is empty
function TestZettelkasten:test_get_note_browser_content_empty_path()
  local saved_path = config.notes_path
  config._set({ notes_path = '' })
  local content = zk.get_note_browser_content({ tags = {} })
  lu.assertEquals(#content, 0)
  config._set({ notes_path = saved_path })
end

-- Tests are collected and run by test/run.lua

