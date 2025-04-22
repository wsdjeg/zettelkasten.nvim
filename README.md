# zettelkasten.nvim

> _zettelkasten.nvim_ is a [Zettelkasten](https://zettelkasten.de) note taking plugin, which is forked from [zettelkasten.nvim@fe174666](https://github.com/Furkanzmc/zettelkasten.nvim/tree/fe1746666e27c2fcc0e60dc2786cb9983b994759).

<!-- vim-markdown-toc GFM -->

* [Install](#install)
* [Usage](#usage)
* [Debug](#debug)
* [Screenshots](#screenshots)
* [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Install

1. Using `zettelkasten.nvim` in SpaceVim:

```toml
[[layers]]
  name = 'zettelkasten'
  zettel_dir = 'D:\me\zettelkasten'
  zettel_template_dir = 'D:\me\zettelkasten_template'
```

2. Using `zettelkasten.nvim` without SpaceVim:

```vim
Plug 'wsdjeg/zettelkasten.nvim'
let g:zettelkasten_directory = 'D:\me\zettelkasten'
let g:zettelkasten_template_directory = 'D:\me\zettelkasten_template'
```

3. Using [nvim-plug](https://github.com/wsdjeg/nvim-plug):

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
        config_before = function()
            vim.g.zettelkasten_directory = 'D:/zettelkasten'
            vim.g.zettelkasten_template_directory = 'D:/zettelkasten_template'
        end,
        config = function()
            vim.keymap.set('n', '<leader>mzb', '<cmd>ZkBrowse<cr>', { silent = true })
            vim.keymap.set('n', '<leader>mzn', '<cmd>ZkNew<cr>', { silent = true })
            vim.keymap.set('n', '<leader>mzf', '<cmd>ZkListNotes<cr>', { silent = true })
            vim.keymap.set('n', '<leader>mzt', '<cmd>ZkListTags<cr>', { silent = true })
        end,
    },
})
```

## Usage

**Commands:**

| Command           | description                       |
| ----------------- | --------------------------------- |
| `:ZkNew`          | create new note                   |
| `:ZkBrowse`       | list note in browser window       |
| `:ZkListTags`     | filter tags in telescope          |
| `:ZkListTemplete` | filte note templates in telescope |
| `:ZkListNotes`    | filte note title in telescope     |

**Key bindings in browser window:**

| key bindings    | description                        |
| --------------- | ---------------------------------- |
| `F2`            | open zettelkasten tags sidebar     |
| `<LeftRelease>` | filter notes based on cursor tag   |
| `gf`            | open the note                      |
| `Ctrl-l`        | clear tags filter pattarn          |
| `Ctrl-] / K`    | preview note in vim preview-window |
| `[I`            | list references in quickfix-window |

## Debug

debug zettelkasten.nvim with logger.nvim:

```lua
require('plug').add({
    { 'wsdjeg/zettelkasten.nvim', depends = { { 'wsdjeg/logger.nvim' } } },
})
```

## Screenshots

![](https://wsdjeg.net/images/zkbrowser.png)
![](https://wsdjeg.net/images/zettelkasten-tags-sidebar.png)
![](https://wsdjeg.net/images/zettelkasten-tags-filter.png)
![](https://wsdjeg.net/images/zettelkasten-complete-id.png)

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/zettelkasten.nvim/issues)
