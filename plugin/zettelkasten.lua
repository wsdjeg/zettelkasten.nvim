--=============================================================================
-- zettelkasten.lua --- init plugin for zk
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================
vim.api.nvim_create_user_command('ZkNew', function(opt)
  require('zettelkasten').zknew({})
end, {})

vim.api.nvim_create_user_command('ZkBrowse', function(opt)
  require('zettelkasten.browser').browse(opt.fargs)
end, { nargs = '*' })
_G.zettelkasten = {
  tagfunc = require('zettelkasten').tagfunc,
  completefunc = require('zettelkasten').completefunc,
  zknew = require('zettelkasten').zknew,
  zkbrowse = function()
    vim.cmd('edit zk://browser')
  end,
}
