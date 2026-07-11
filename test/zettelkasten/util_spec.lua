--=============================================================================
-- util_spec.lua --- tests for zettelkasten.util module
--=============================================================================

local lu = require('luaunit')
local util = require('zettelkasten.util')

TestUtil = {}

function TestUtil:test_is_float_returns_false_for_normal_win()
  -- In headless test, the current window should not be floating
  lu.assertEquals(util.is_float(0), false)
end

function TestUtil:test_is_last_win_in_headless()
  -- In headless test, there should be at least one window
  lu.assertEquals(util.is_last_win(), true)
end

function TestUtil:test_group2dict_returns_table()
  local result = util.group2dict('Normal')
  lu.assertNotNil(result)
  lu.assertEquals(type(result), 'table')
end

function TestUtil:test_group2dict_nonexistent_returns_empty()
  local result = util.group2dict('NonExistentGroup12345')
  lu.assertNotNil(result)
  lu.assertEquals(result.name, '')
end

-- Tests are collected and run by test/run.lua

