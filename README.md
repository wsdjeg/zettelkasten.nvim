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
- [Picker Integration](#picker-integration)
- [Calendar extension](#calendar-extension)
- [Chat Integration](#chat-integration)
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
| `Ctrl-x Ctrl-u` | complete note id or tags           |

**Key bindings in zettelkasten notes buffer:**

| key bindings | description                |
| ------------ | -------------------------- |
| `<Leader>p`  | paste image from clipboard |

## Picker Integration

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

## Chat Integration

zettelkasten.nvim also provides a `zettelkasten_create` tool for [chat.nvim](https://github.com/wsdjeg/chat.nvim),
which is used to create new zettelkasten notes with automatic ID generation and tag support. This tool is particularly useful for knowledge management and note-taking workflows within Neovim. It integrates with the `zettelkasten.nvim` plugin to create properly formatted notes in your zettelkasten system.

**Usage:**

```
@zk create <title>
```

**Parameters:**

- `title` (string, required): The title of the zettelkasten note
- `content` (string, required): The main body content of the note
- `tags` (array of strings, optional): Optional tags for categorizing the note (e.g., `["programming", "vim"]`). Tags should be in English.

**Examples:**

1. **Basic note creation**:

   ```
   Create a note about Vim tips: @zk create "Vim Productivity Tips" content="Here are some useful Vim tips..."
   ```

2. **Note with tags**:

   ```
   Document this Lua pattern: @zk create "Lua Metatable Patterns" content="Metatables allow..." tags=["lua", "patterns"]
   ```

3. **Natural language integration**:
   ```
   I want to save this idea about AI: @zk create "AI Assistant Design" content="The architecture should include..." tags=["ai", "design"]
   ```

**How it works:**

1. Generates a unique ID for the note using `zettelkasten`'s ID generation system
2. Creates a markdown file at `notes_path/<id>.md` (where `notes_path` is configured in your zettelkasten setup)
3. Formats the content with:
   - First line: `# <id> <title>`
   - Empty line
   - Tags line (if provided): `tags: #tag1 #tag2`
   - Another empty line (if tags are present)
   - The note content
4. Returns success information including the note ID, title, and file path

**Notes:**

- This tool requires the `zettelkasten.nvim` plugin to be installed and configured
- The `notes_path` should be properly set in your zettelkasten configuration
- Tags are automatically prefixed with `#` when written to the file
- The tool validates all input types and returns descriptive error messages if validation fails
- Only creates notes when explicitly invoked with `@zk create` instruction

**Error handling:**

The tool provides clear error messages for common issues:

- Missing required parameters (title or content)
- Invalid parameter types (e.g., non-string title)
- File creation failures
- Invalid tag formats

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

This plugin is forked from [Furkanzmc/zettelkasten.nvim](https://github.com/Furkanzmc/zettelkasten.nvim), which is still in active development.
here is Summary of Differences:

1. New Features Added:

   - Clipboard image pasting
   - Tags completion support
   - Tags Sidebar window
   - Option to set note browser title width
   - Calendar.nvim extension
   - Picker custom note templates
   - luarocks support
   - Use of Lua syntax file
   - Improved notifications and ZkHover command
   - Zettelkasten tags preview and new picker source

2. Improvements:

   - Many bug fixes (e.g., for note time, highlight range, default actions)
   - Use of Lua API and vim.cmd for consistency
   - More readable setup and configuration (moved from vim.g to setup function)
   - Enhanced docs and README updates

3. Other Changes:

   - Release automation and tagging with release-please
   - Small tweaks for better Neovim integration (e.g., file type detection, keybindings, etc.)

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/zettelkasten.nvim/issues)
