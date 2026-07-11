--=============================================================================
-- config_spec.lua --- tests for zettelkasten.config module
--=============================================================================

local lu = require('luaunit')
local config = require('zettelkasten.config')

TestConfig = {}

function TestConfig:setUp()
  -- Reset config to default values before each test
  config.notes_path = '~/.zettelkasten/'
  config.template_dir = '~/.zettelkasten_template'
  config.browseformat = '%f - %h [%r Refs] [%b B-Refs] %t'
  config.preview_command = 'pedit'
  config.completion_kind = '[zettelkasten]'
  config.browse_title_width = 30
end

function TestConfig:test_default_notes_path()
  lu.assertEquals(config.notes_path, '~/.zettelkasten/')
end

function TestConfig:test_default_browseformat()
  lu.assertEquals(
    config.browseformat,
    '%f - %h [%r Refs] [%b B-Refs] %t'
  )
end

function TestConfig:test_default_preview_command()
  lu.assertEquals(config.preview_command, 'pedit')
end

function TestConfig:test_default_completion_kind()
  lu.assertEquals(config.completion_kind, '[zettelkasten]')
end

function TestConfig:test_default_browse_title_width()
  lu.assertEquals(config.browse_title_width, 30)
end

function TestConfig:test_set_updates_notes_path()
  config._set({ notes_path = '/tmp/test_notes' })
  lu.assertEquals(config.notes_path, '/tmp/test_notes')
end

function TestConfig:test_set_updates_browseformat()
  config._set({ browseformat = '%t - %d' })
  lu.assertEquals(config.browseformat, '%t - %d')
end

function TestConfig:test_set_updates_preview_command()
  config._set({ preview_command = 'split' })
  lu.assertEquals(config.preview_command, 'split')
end

function TestConfig:test_set_with_nil_opts()
  -- should not crash and should keep existing values
  local before = config.notes_path
  config._set(nil)
  lu.assertEquals(config.notes_path, before)
end

function TestConfig:test_set_with_empty_opts()
  -- should not crash and should keep existing values
  local before = config.browseformat
  config._set({})
  lu.assertEquals(config.browseformat, before)
end

-- Tests are collected and run by test/run.lua

