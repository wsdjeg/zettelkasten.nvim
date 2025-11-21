if vim.b.current_syntax == 'zktagstree' then
    return
end
vim.cmd([[
" syntax match ZettelKastenID '[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+-[0-9]\+\.md'
" syntax match ZettelKastenDash '\s-\s'
syntax match zktagstreeOrg '[▼▶]\+ .*'
syntax match zktagstreeTags '#\<\k\+\>'

" highlight default link ZettelKastenID String
" highlight default link ZettelKastenDash Comment
highlight default link zktagstreeOrg Number
highlight default link zktagstreeTags Tag
]])

vim.b.current_syntax = 'zktagstree'
