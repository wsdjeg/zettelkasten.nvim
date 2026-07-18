--=============================================================================
-- example_spec.lua --- example test file for zettelkasten.nvim
--=============================================================================

local lu = require('luaunit')

TestExample = {}

function TestExample:test_basic_assertion()
  lu.assertEquals(1 + 1, 2)
end

function TestExample:test_string_operations()
  local s = 'hello world'
  lu.assertEquals(s:upper(), 'HELLO WORLD')
  lu.assertEquals(#s, 11)
end

function TestExample:test_table_operations()
  local t = { 1, 2, 3 }
  table.insert(t, 4)
  lu.assertEquals(#t, 4)
  lu.assertEquals(t[4], 4)
end

function TestExample:test_zettelkasten_module_loaded()
  local ok = pcall(require, 'zettelkasten')
  lu.assertTrue(ok)
end

return TestExample

