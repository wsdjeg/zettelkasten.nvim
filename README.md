# zettelkasten.nvim

A [Zettelkasten](https://zettelkasten.de) note taking plugin for Neovim

[![GitHub License](https://img.shields.io/github/license/wsdjeg/zettelkasten.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/zettelkasten.nvim)](https://luarocks.org/modules/wsdjeg/zettelkasten.nvim)

<!-- vim-markdown-toc GFM -->

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Picker sources](#picker-sources)
- [Calendar extension](#calendar-extension)
- [Debug](#debug)
- [Screenshots](#screenshots)
- [Self-Promotion](#self-promotion)
- [Credits](#credits)
- [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Features

- Zettelkasten-style note taking in Neovim
- Create and browse notes efficiently
- Tag-based filtering and navigation
- Reference and backlink support
- Daily notes and calendar integration
- Optional picker integration

## Installation

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug):

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
        config = function()
            require('zettelkasten').setup({
                notes_path = '~/.zettelkasten',
                templates_path = '~/.zettelkasten_template',
                preview_command = 'pedit',
                browseformat = '%f - %h [%r Refs] [%b B-Refs] %t',
            })
            vim.keymap.set('n', '<leader>mzb', '<cmd>ZkBrowse<cr>', { silent = true })
            vim.keymap.set('n', '<leader>mzn', '<cmd>ZkNew<cr>', { silent = true })
        end,
    },
})
```

Using [luarocks](https://luarocks.org/)

```
luarocks install zettelkasten.nvim
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

key bindings in zettelkasten source:

| key binding | description                                  |
| ----------- | -------------------------------------------- |
| `<Enter>`   | open selected note                           |
| `<C-y>`     | insert selected note's id to cursor position |

## Calendar extension

zettelkasten.nvim also provides an extension for [calendar.nvim](https://github.com/wsdjeg/calendar.nvim).
It highlights dates that have Zettelkasten notes associated with them.

When pressing `<Enter>` on a date in the calendar, the following actions are available:

1. Create a daily note
2. Browse daily notes

## Debug

debug zettelkasten.nvim with logger.nvim:

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
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
