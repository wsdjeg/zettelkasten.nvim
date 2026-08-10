-- Verify zettelkasten tool scheme can be JSON-encoded
local lu = require('luaunit')

TestCheckSchemes = {}

function TestCheckSchemes:test_scheme_json_encode()
  local mod = 'chat.tools.zettelkasten'

  -- 1. require must succeed
  local ok, tool = pcall(require, mod)
  lu.assertTrue(ok, 'require failed for ' .. mod .. ': ' .. tostring(tool))

  -- 2. scheme() must succeed
  local ok2, scheme = pcall(tool.scheme)
  lu.assertTrue(ok2, 'scheme() failed for ' .. mod .. ': ' .. tostring(scheme))

  -- 3. must have correct structure
  lu.assertEquals(scheme.type, 'function')
  lu.assertNotNil(scheme['function'])
  lu.assertEquals(type(scheme['function'].name), 'string')
  lu.assertEquals(type(scheme['function'].description), 'string')
  lu.assertNotNil(scheme['function'].parameters)

  -- 4. must be JSON-serializable
  local ok3, json = pcall(vim.json.encode, scheme)
  lu.assertTrue(ok3, 'JSON encode failed for ' .. mod .. ': ' .. tostring(json))

  -- 5. action property must have all 6 enum values
  local action_prop = scheme['function'].parameters.properties.action
  lu.assertNotNil(action_prop)
  lu.assertEquals(#action_prop.enum, 6)
end

function TestCheckSchemes:test_no_chat_config_dependency()
  -- Ensure the tool loads without chat.config installed
  local ok = pcall(require, 'chat.tools.zettelkasten')
  lu.assertTrue(ok, 'chat.tools.zettelkasten should load without chat.config dependency')
end

return TestCheckSchemes

