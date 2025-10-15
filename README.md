# zettelkasten.nvim

> A [Zettelkasten](https://zettelkasten.de) note taking plugin for Neovim

<!-- vim-markdown-toc GFM -->

- [Installation](#installation)
- [Usage](#usage)
- [Picker sources](#picker-sources)
- [Debug](#debug)
- [Screenshots](#screenshots)
- [Self-Promotion](#self-promotion)
- [Credits](#credits)
- [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Installation

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug):

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
        end,
    },
})
```

## Usage

**Commands:**

| Command     | description                 |
| ----------- | --------------------------- |
| `:ZkNew`    | create new note             |
| `:ZkBrowse` | list note in browser window |

**Key bindings in browser window:**

| key bindings    | description                        |
| --------------- | ---------------------------------- |
| `F2`            | open zettelkasten tags sidebar     |
| `<LeftRelease>` | filter notes based on cursor tag   |
| `gf`            | open the note                      |
| `Ctrl-l`        | clear tags filter pattarn          |
| `Ctrl-] / K`    | preview note in vim preview-window |
| `[I`            | list references in quickfix-window |

## Picker sources

zettelkasten.nvim also provides zettelkasten sources for [picker.nvim](https://github.com/wsdjeg/picker.nvim),
which can be opened by following command:

```
:Picker <source_name>
```

| source name      | description                   |
| ---------------- | ----------------------------- |
| zettelkasten     | fuzzy find zettelkasten notes |
| zettelkasten_tag | fuzzy find zettelkasten tags  |

## Debug

debug zettelkasten.nvim with logger.nvim:

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
        config_before = function()
            vim.g.zettelkasten_directory = 'D:/zettelkasten'
            vim.g.zettelkasten_template_directory = 'D:/zettelkasten_template'
        end,
        depends = { { 'wsdjeg/logger.nvim' } },
    },
})
```

## Screenshots

![](https://wsdjeg.net/images/zkbrowser.png)
![](https://wsdjeg.net/images/zettelkasten-tags-sidebar.png)
![](https://wsdjeg.net/images/zettelkasten-tags-filter.png)
![](https://wsdjeg.net/images/zettelkasten-complete-id.png)

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg).

## Credits

- [Furkanzmc/zettelkasten.nvim](https://github.com/Furkanzmc/zettelkasten.nvim)

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/zettelkasten.nvim/issues)
