--=============================================================================
-- minimal_init.lua --- minimal init for testing
--=============================================================================

print('Initializing test environment...')

-- Set up essential settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false
vim.opt.verbose = 1

-- Set up package path for:
-- 1. lua/?.lua - Main plugin source code
-- 2. test/?.lua - Test helper modules
-- 3. test/deps/?.lua - Test dependencies (luaunit)
package.path = 'lua/?.lua;test/?.lua;test/deps/?.lua;' .. package.path
vim.opt.runtimepath:prepend('.')

-- Create temporary test directory
local test_dir = vim.fn.tempname() .. '_zettelkasten_nvim_test'
vim.fn.mkdir(test_dir, 'p')

-- Load plugin with test configuration
local ok, err = pcall(function()
  require('zettelkasten').setup({
    notes_path = test_dir .. '/notes',
    templates_path = test_dir .. '/templates',
    preview_command = 'pedit',
    browseformat = '%f - %h [%r Refs] [%b B-Refs] %t',
  })
end)

if not ok then
  print('Error initializing test environment: ' .. err)
else
  print('Test environment initialized successfully')
  print('Test directory: ' .. test_dir)
end

