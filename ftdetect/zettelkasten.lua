local augroup = vim.api.nvim_create_augroup('zettelkasten_ft', {clear = true})

vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
    group = augroup,
    pattern = {'zk:browser'},
    callback = function(ev)
        vim.api.nvim_buf_set_option(ev.buf, 'filetype', 'zkbrowser')
    end
})
