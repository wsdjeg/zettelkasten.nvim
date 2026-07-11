--=============================================================================
-- formatter_spec.lua --- tests for zettelkasten.formatter module
--=============================================================================

local lu = require('luaunit')
local formatter = require('zettelkasten.formatter')
local config = require('zettelkasten.config')

TestFormatter = {}

function TestFormatter:setUp()
  -- Reset config to default values before each test
  config.browseformat = '%f - %h [%r Refs] [%b B-Refs] %t'
  config.browse_title_width = 30
end

local function make_note(opts)
  opts = opts or {}
  return {
    file_name = opts.file_name or '/tmp/2024-01-01-12-00-00.md',
    id = opts.id or '2024-01-01-12-00-00',
    title = opts.title or 'Test Note',
    references = opts.references or {},
    back_references = opts.back_references or {},
    tags = opts.tags or {},
  }
end

function TestFormatter:test_format_filename()
  local lines = { make_note() }
  local result = formatter.format(lines, '%f')
  lu.assertEquals(result[1], '2024-01-01-12-00-00.md')
end

function TestFormatter:test_format_id()
  local lines = { make_note({ id = '2024-06-15-10-30-00' }) }
  local result = formatter.format(lines, '%d')
  lu.assertEquals(result[1], '2024-06-15-10-30-00')
end

function TestFormatter:test_format_title()
  local lines = { make_note({ title = 'Hello World' }) }
  local result = formatter.format(lines, '%h')
  -- title is padded to browse_title_width (default 30)
  lu.assertEquals(result[1], 'Hello World' .. string.rep(' ', 30 - 11))
end

function TestFormatter:test_format_references_count()
  local refs = { { id = '2024-01-02-00-00-00', linenr = 1 } }
  local lines = { make_note({ references = refs }) }
  local result = formatter.format(lines, '%r')
  lu.assertEquals(result[1], '1')
end

function TestFormatter:test_format_back_references_count()
  local brefs = {
    {
      id = '2024-01-02-00-00-00',
      title = 'Ref',
      file_name = '/tmp/2024-01-02-00-00-00.md',
      linenr = 1,
    },
  }
  local lines = { make_note({ back_references = brefs }) }
  local result = formatter.format(lines, '%b')
  lu.assertEquals(result[1], '1')
end

function TestFormatter:test_format_tags()
  local tags = {
    { name = '#tag1', linenr = 1 },
    { name = '#tag2', linenr = 2 },
  }
  local lines = { make_note({ tags = tags }) }
  local result = formatter.format(lines, '%t')
  lu.assertEquals(result[1], '#tag1 #tag2')
end

function TestFormatter:test_format_multiple_modifiers()
  local tags = { { name = '#test', linenr = 1 } }
  local refs = { { id = '2024-01-02-00-00-00', linenr = 1 } }
  local lines = { make_note({ tags = tags, references = refs }) }
  local result = formatter.format(lines, '%d - %r - %t')
  lu.assertEquals(result[1], '2024-01-01-12-00-00 - 1 - #test')
end

function TestFormatter:test_format_full_browseformat()
  local tags = { { name = '#work', linenr = 1 } }
  local refs = { { id = '2024-01-02-00-00-00', linenr = 1 } }
  local brefs = {
    {
      id = '2024-01-03-00-00-00',
      title = 'Back',
      file_name = '/tmp/2024-01-03-00-00-00.md',
      linenr = 2,
    },
  }
  local lines = { make_note({
    tags = tags,
    references = refs,
    back_references = brefs,
    title = 'My Note',
  }) }
  local result = formatter.format(lines, config.browseformat)
  -- %f - %h [%r Refs] [%b B-Refs] %t
  lu.assertTrue(string.find(result[1], '2024-01-01-12-00-00.md', 1, true) ~= nil)
  lu.assertTrue(string.find(result[1], '1 Refs', 1, true) ~= nil)
  lu.assertTrue(string.find(result[1], '1 B-Refs', 1, true) ~= nil)
  lu.assertTrue(string.find(result[1], '#work', 1, true) ~= nil)
end

function TestFormatter:test_format_title_truncation()
  -- Set a small title width for testing
  local original_width = config.browse_title_width
  config.browse_title_width = 10

  local lines = { make_note({ title = 'This is a very long title' }) }
  local result = formatter.format(lines, '%h')
  lu.assertTrue(#result[1] == 10)
  lu.assertTrue(string.find(result[1], '%.%.%.') ~= nil)

  -- restore
  config.browse_title_width = original_width
end

function TestFormatter:test_format_empty_lines()
  local result = formatter.format({}, '%f - %t')
  lu.assertEquals(#result, 0)
end

function TestFormatter:test_format_multiple_lines()
  local lines = {
    make_note({ id = '2024-01-01-00-00-00', title = 'Note A' }),
    make_note({ id = '2024-01-02-00-00-00', title = 'Note B' }),
  }
  local result = formatter.format(lines, '%d')
  lu.assertEquals(#result, 2)
  lu.assertEquals(result[1], '2024-01-01-00-00-00')
  lu.assertEquals(result[2], '2024-01-02-00-00-00')
end

-- Tests are collected and run by test/run.lua

