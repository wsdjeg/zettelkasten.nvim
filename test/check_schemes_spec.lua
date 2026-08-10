-- Verify all zettelkasten tool schemes can be JSON-encoded
local lu = require('luaunit')

TestCheckSchemes = {}

function TestCheckSchemes:test_all_schemes_json_encode()
  local tools = {
    'chat.tools.zettelkasten_create',
    'chat.tools.zettelkasten_get',
    'chat.tools.zettelkasten_update',
    'chat.tools.zettelkasten_search',
    'chat.tools.zettelkasten_read',
    'chat.tools.zettelkasten_tags',
  }

  local all_schemes = {}

  for _, mod in ipairs(tools) do
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

    table.insert(all_schemes, scheme)
  end

  -- 5. all schemes together must be JSON-serializable
  local ok, all_json = pcall(vim.json.encode, all_schemes)
  lu.assertTrue(ok, 'JSON encode failed for all schemes: ' .. tostring(all_json))
  lu.assertEquals(#all_schemes, 6)
end

function TestCheckSchemes:test_no_chat_config_dependency()
  -- Ensure no zettelkasten tool requires chat.config at module level
  -- (this caused chat.nvim to fail when loading tools)
  local tools = {
    'chat.tools.zettelkasten_create',
    'chat.tools.zettelkasten_get',
    'chat.tools.zettelkasten_update',
    'chat.tools.zettelkasten_search',
    'chat.tools.zettelkasten_read',
    'chat.tools.zettelkasten_tags',
  }

  for _, mod in ipairs(tools) do
    -- If the module loads without chat.config installed, we're good
    local ok = pcall(require, mod)
    lu.assertTrue(ok, mod .. ' should load without chat.config dependency')
  end
end

return TestCheckSchemes

