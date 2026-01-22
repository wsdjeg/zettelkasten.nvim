local re = [[\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d\.md]]

if not vim.regex(re):match_str(vim.api.nvim_buf_get_name(0)) then
  return
end

vim.opt_local.tagfunc = 'v:lua.zettelkasten.tagfunc'

vim.opt_local.completefunc = 'v:lua.zettelkasten.completefunc'

vim.opt.isfname:append(':')
vim.opt.isfname:append('-')
vim.opt_local.iskeyword:append(':')
vim.opt_local.iskeyword:append('-')
vim.opt_local.suffixesadd:append('.md')
vim.opt_local.errorformat = '%f:%l: %m'
vim.opt_local.include = '[[\\s]]'
vim.opt_local.define = '^# \\s*'

vim.opt_local.keywordprg = ':ZkHover'

if vim.fn.mapcheck('[I', 'n') == '' then
  vim.api.nvim_buf_set_keymap(
    0,
    'n',
    '[I',
    '<CMD>lua require("zettelkasten").show_back_references(vim.fn.expand("<cword>"))<CR>',
    { noremap = true, silent = true, nowait = true }
  )
end

vim.api.nvim_buf_set_keymap(0, 'n', '<leader>p', '', {
  silent = true,
  noremap = true,
  callback = function()
    require('zettelkasten').paste_image()
  end,
})

require('zettelkasten').add_hover_command()
