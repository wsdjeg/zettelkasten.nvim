--=============================================================================
-- sidebar_spec.lua --- tests for zettelkasten.sidebar module
--=============================================================================

local lu = require('luaunit')
local sidebar = require('zettelkasten.sidebar')
local browser = require('zettelkasten.browser')
local config = require('zettelkasten.config')

TestSidebar = {}

local test_notes_dir

function TestSidebar:setUp()
  browser.clear_cache()
  test_notes_dir = vim.fn.tempname() .. '_zk_sidebar'
  config._set({ notes_path = test_notes_dir })
  vim.fn.mkdir(test_notes_dir, 'p')
end

function TestSidebar:tearDown()
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
end

--- Test that sidebar module loads without error
function TestSidebar:test_module_loads()
  lu.assertNotNil(sidebar)
  lu.assertEquals(type(sidebar.open_tag_tree), 'function')
  lu.assertEquals(type(sidebar.toggle_folded_key), 'function')
end

--- Test tags are collected from notes for sidebar
function TestSidebar:test_tags_collected()
  create_note('2024-01-01-12-00-00', 'Note A', 'Content #alpha')
  create_note('2024-01-02-12-00-00', 'Note B', 'Content #beta #alpha')

  local tags = browser.get_tags()
  lu.assertEquals(#tags, 3)
end

-- Tests are collected and run by test/run.lua

