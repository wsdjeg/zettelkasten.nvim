--=============================================================================
-- browser_spec.lua --- tests for zettelkasten.browser module
--=============================================================================

local lu = require('luaunit')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestBrowser = {}

local test_notes_dir

function TestBrowser:setUp()
  -- Clear browser cache to avoid stale data between tests
  browser.clear_cache()
  -- Use tempname for cross-platform compatibility
  test_notes_dir = vim.fn.tempname() .. '_zk_notes'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestBrowser:tearDown()
  vim.fn.delete(test_notes_dir, 'rf')
end

--- Helper: create a test note file
local function create_note(id, title, body)
  local path = test_notes_dir .. '/' .. id .. '.md'
  local lines = { '# ' .. id .. ' ' .. title }
  if body then
    table.insert(lines, '')
    table.insert(lines, body)
  end
  vim.fn.writefile(lines, path)
  return path
end

--- Test get_notes returns empty for empty directory
function TestBrowser:test_get_notes_empty_dir()
  local notes = browser.get_notes()
  lu.assertEquals(#notes, 0)
end

--- Test get_notes returns notes from files
function TestBrowser:test_get_notes_returns_notes()
  create_note('2024-01-01-12-00-00', 'First Note')
  create_note('2024-01-02-12-00-00', 'Second Note')

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 2)
end

--- Test get_notes parses note id and title correctly
function TestBrowser:test_get_notes_parses_id_and_title()
  create_note('2024-06-15-10-30-00', 'My Test Title')

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].id, '2024-06-15-10-30-00')
  lu.assertEquals(notes[1].title, 'My Test Title')
end

--- Test get_notes ignores non-matching files
function TestBrowser:test_get_notes_ignores_non_matching_files()
  create_note('2024-01-01-12-00-00', 'Valid Note')
  -- Create a file that doesn't match the pattern
  vim.fn.writefile({ '# This is not a zk note' }, test_notes_dir .. '/random_file.md')

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].id, '2024-01-01-12-00-00')
end

--- Test get_notes extracts references
function TestBrowser:test_get_notes_extracts_references()
  create_note(
    '2024-01-01-12-00-00',
    'Note With Ref',
    'See [[2024-01-02-12-00-00]] and [[2024-01-03-12-00-00]]'
  )

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 1)
  lu.assertEquals(#notes[1].references, 2)
  lu.assertEquals(notes[1].references[1].id, '2024-01-02-12-00-00')
  lu.assertEquals(notes[1].references[2].id, '2024-01-03-12-00-00')
end

--- Test get_notes extracts tags
function TestBrowser:test_get_notes_extracts_tags()
  create_note(
    '2024-01-01-12-00-00',
    'Note With Tags',
    'This note has tags #work #important'
  )

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 1)
  lu.assertEquals(#notes[1].tags, 2)
  lu.assertEquals(notes[1].tags[1].name, '#work')
  lu.assertEquals(notes[1].tags[2].name, '#important')
end

--- Test get_notes computes back_references
function TestBrowser:test_get_notes_back_references()
  -- Note A references Note B
  create_note(
    '2024-01-01-12-00-00',
    'Note A',
    'See [[2024-01-02-12-00-00]]'
  )
  create_note('2024-01-02-12-00-00', 'Note B', 'Content here')

  local notes = browser.get_notes()

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

--- Test get_note returns nil for non-existent id
function TestBrowser:test_get_note_nonexistent()
  local note = browser.get_note('nonexistent-id')
  lu.assertNil(note)
end

--- Test get_note returns note by id
function TestBrowser:test_get_note_by_id()
  create_note('2024-06-15-10-30-00', 'Find Me')

  local note = browser.get_note('2024-06-15-10-30-00')
  lu.assertNotNil(note)
  lu.assertEquals(note.title, 'Find Me')
end

--- Test get_tags returns all tags from all notes
function TestBrowser:test_get_tags()
  create_note('2024-01-01-12-00-00', 'Note A', 'Tag A #work')
  create_note('2024-01-02-12-00-00', 'Note B', 'Tag B #personal #work')

  local tags = browser.get_tags()
  -- Should have 3 tag entries (1 from note A + 2 from note B)
  lu.assertEquals(#tags, 3)
end

--- Test get_tags returns empty for empty directory
function TestBrowser:test_get_tags_empty_dir()
  local tags = browser.get_tags()
  lu.assertEquals(#tags, 0)
end

--- Test note with no title (malformed first line)
function TestBrowser:test_malformed_note_no_title()
  local path = test_notes_dir .. '/2024-01-01-12-00-00.md'
  vim.fn.writefile({ 'This has no proper header' }, path)

  local notes = browser.get_notes()
  -- The note should still be returned, but with empty id/title
  lu.assertEquals(#notes, 1)
  lu.assertEquals(notes[1].id, '')
  lu.assertEquals(notes[1].title, '')
end

--- Test note with tags in middle of text (not preceded by space at line start)
function TestBrowser:test_tag_not_at_line_start()
  create_note(
    '2024-01-01-12-00-00',
    'Note',
    'word#notatag should not be a tag'
  )

  local notes = browser.get_notes()
  lu.assertEquals(#notes, 1)
  -- #notatag is preceded by 'd' so should not be extracted
  lu.assertEquals(#notes[1].tags, 0)
end

-- Tests are collected and run by test/run.lua

