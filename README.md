# zettelkasten.nvim

[![Run Tests](https://github.com/wsdjeg/zettelkasten.nvim/actions/workflows/test.yml/badge.svg)](https://github.com/wsdjeg/zettelkasten.nvim/actions/workflows/test.yml)
[![GitHub License](https://img.shields.io/github/license/wsdjeg/zettelkasten.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/zettelkasten.nvim)](https://github.com/wsdjeg/zettelkasten.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/zettelkasten.nvim)](https://luarocks.org/modules/wsdjeg/zettelkasten.nvim)

A [Zettelkasten](https://zettelkasten.de) note-taking plugin for Neovim, written in Lua.

<!-- vim-markdown-toc GFM -->

- [📘 Intro](#-intro)
- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [🔧 Configuration](#-configuration)
- [⚙️ Commands](#-commands)
- [⌨️ Key Bindings](#-key-bindings)
    - [Browser Window](#browser-window)
    - [Tags Sidebar](#tags-sidebar)
    - [Note Buffer](#note-buffer)
- [🎨 Browser Format](#-browser-format)
- [🔍 Picker Integration](#-picker-integration)
- [🔭 Telescope Integration](#-telescope-integration)
- [📅 Calendar Extension](#-calendar-extension)
- [💬 Chat Integration](#-chat-integration)
- [🐞 Debug](#-debug)
- [📸 Screenshots](#-screenshots)
- [📣 Self-Promotion](#-self-promotion)
- [🙏 Credits](#-credits)
- [💬 Feedback](#-feedback)

<!-- vim-markdown-toc -->

## 📘 Intro

`zettelkasten.nvim` brings [Zettelkasten](https://zettelkasten.de)-style note-taking into Neovim.
Notes are stored as Markdown files with timestamp-based IDs, and the plugin provides a browser
window, tags sidebar, reference/backlink tracking, completion, and integrations with picker.nvim,
telescope.nvim, calendar.nvim, and chat.nvim.

## ✨ Features

- **📝 Zettelkasten Notes** — Create notes with timestamp-based IDs (`YYYY-MM-DD-HH-MM-SS.md`)
- **🗂️ Note Browser** — Browse all notes in a dedicated window with customizable format
- **🏷️ Tags Sidebar** — Foldable tag tree for visual tag-based filtering
- **🔗 References & Backlinks** — Automatic `[[note-id]]` reference detection and backlink tracking
- **✏️ Completion** — Note ID and tag completion via `completefunc` and `tagfunc`
- **📋 Quickfix Integration** — List back references in the quickfix/location window
- **🖼️ Clipboard Image Paste** — Paste images from clipboard directly into notes (macOS/Linux/Windows)
- **🔍 Multi-Picker Support** — Integrates with [picker.nvim](https://github.com/wsdjeg/picker.nvim) and [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- **📅 Calendar Integration** — Highlights dates with notes via [calendar.nvim](https://github.com/wsdjeg/calendar.nvim)
- **💬 Chat Integration** — Create and retrieve notes via [chat.nvim](https://github.com/wsdjeg/chat.nvim)
- **🧩 Note Templates** — Create notes from pre-defined templates

## 📦 Installation

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug):

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
        config = function()
            require('zettelkasten').setup({
                notes_path = '~/.zettelkasten',
                template_dir = '~/.zettelkasten_template',
                preview_command = 'pedit',
                browseformat = '%f - %h [%r Refs] [%b B-Refs] %t',
            })
            vim.keymap.set('n', '<leader>mzb', '<cmd>ZkBrowse<cr>', { silent = true })
            vim.keymap.set('n', '<leader>mzn', '<cmd>ZkNew<cr>', { silent = true })
        end,
    },
})
```

Using [LuaRocks](https://luarocks.org):

```sh
luarocks install zettelkasten.nvim
```

## 🔧 Configuration

All options are passed to `require('zettelkasten').setup({})`:

| Option               | Type   | Default                                    | Description                                          |
| -------------------- | ------ | ------------------------------------------ | ---------------------------------------------------- |
| `notes_path`         | string | `'~/.zettelkasten/'`                       | Directory where notes are stored                     |
| `template_dir`       | string | `'~/.zettelkasten_template'`               | Directory containing note templates                  |
| `preview_command`    | string | `'pedit'`                                  | Vim command used for note preview                    |
| `browseformat`       | string | `'%f - %h [%r Refs] [%b B-Refs] %t'`       | Format string for the browser window (see [Browser Format](#-browser-format)) |
| `completion_kind`    | string | `'[zettelkasten]'`                         | Kind label shown in completion menu                  |
| `browse_title_width` | number | `30`                                       | Max display width for note titles in the browser     |

## ⚙️ Commands

| Command                | Description                                              |
| ---------------------- | -------------------------------------------------------- |
| `:ZkNew`               | Create a new zettelkasten note                           |
| `:ZkBrowse [tags...]`  | Open the note browser; optional tag arguments to filter  |
| `:ZkHover [-preview] [-return-lines] [word]` | Show note info in a notification; `-preview` opens preview window, `-return-lines` returns full content |

## ⌨️ Key Bindings

### Browser Window

| Key              | Description                                      |
| ---------------- | ------------------------------------------------ |
| `F2`             | Open the zettelkasten tags sidebar               |
| `<LeftRelease>`  | Filter notes by the tag under cursor             |
| `<Enter>` / `gf` | Open the note under cursor                       |
| `Ctrl-l`         | Clear tag filter and reload all notes            |
| `Ctrl-]` / `K`   | Preview note via `keywordprg` (`:ZkHover -preview`) |
| `[I`             | List back references in the quickfix window      |
| `Ctrl-x Ctrl-u`  | Complete note ID or tags (insert mode)           |
| `q`              | Close the browser window                         |

### Tags Sidebar

| Key              | Description                                      |
| ---------------- | ------------------------------------------------ |
| `<Enter>`        | Filter browser notes by the tag under cursor     |
| `<LeftRelease>`  | Filter by tag, or toggle fold on fold markers    |
| `F2` / `q`       | Close the tags sidebar                           |

### Note Buffer

| Key         | Description                                          |
| ----------- | ---------------------------------------------------- |
| `<Leader>p` | Paste image from clipboard into the note             |
| `K`         | Hover note info (`:ZkHover`)                         |
| `[I`        | List back references in the quickfix window          |
| `Ctrl-]`    | Jump to `[[note-id]]` reference via `tagfunc`        |
| `Ctrl-x Ctrl-u` | Complete note ID or tags (insert mode)           |

## 🎨 Browser Format

The `browseformat` option controls how each note is displayed in the browser window.
The following modifiers are supported:

| Modifier | Description                                            |
| -------- | ------------------------------------------------------ |
| `%f`     | File name (e.g. `2024-01-15-10-30-00.md`)              |
| `%h`     | Note title (padded/truncated to `browse_title_width`)  |
| `%d`     | Note ID (timestamp)                                    |
| `%r`     | Number of references (outgoing `[[links]]`)            |
| `%b`     | Number of back references (incoming links)             |
| `%t`     | Space-separated tags                                   |

## 🔍 Picker Integration

zettelkasten.nvim provides sources for [picker.nvim](https://github.com/wsdjeg/picker.nvim):

```
:Picker zettelkasten
:Picker zettelkasten_tag
:Picker zettelkasten_template
```

| Source                | Description                                  |
| --------------------- | -------------------------------------------- |
| `zettelkasten`        | Fuzzy find notes, open or insert note ID     |
| `zettelkasten_tag`    | Fuzzy find tags, filter browser by selection |
| `zettelkasten_template` | Fuzzy find templates, create note from selection |

Key bindings in picker sources:

| Key       | Description                                   |
| --------- | --------------------------------------------- |
| `<Enter>` | Default action (open note / filter / create)  |
| `<C-y>`   | Insert selected note's ID at cursor position  |

## 🔭 Telescope Integration

zettelkasten.nvim also provides extensions for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim):

```lua
require('telescope').load_extension('zettelkasten')
require('telescope').load_extension('zettelkasten_tags')
require('telescope').load_extension('zettelkasten_template')
```

| Command                                    | Description                    |
| ------------------------------------------ | ------------------------------ |
| `:Telescope zettelkasten`                  | Find and open notes            |
| `:Telescope zettelkasten_tags`             | Find and filter by tags        |
| `:Telescope zettelkasten_template`         | Find and create from templates |

## 📅 Calendar Extension

zettelkasten.nvim provides an extension for [calendar.nvim](https://github.com/wsdjeg/calendar.nvim).
It highlights dates that have zettelkasten notes associated with them.

When pressing `<Enter>` on a date in the calendar, the following actions are available:

1. **Create a daily note** — Creates a new note with the selected date
2. **Browse daily notes** — Opens the browser filtered by the selected date

## 💬 Chat Integration

zettelkasten.nvim provides two tools for [chat.nvim](https://github.com/wsdjeg/chat.nvim):

### Create Notes

```
@zk create <title>
```

Creates a new zettelkasten note with automatic ID generation and tag support.

**Parameters:**

- `title` (string, required): The title of the note
- `content` (string, required): The main body content of the note
- `tags` (array of strings, optional): Tags for categorizing the note (e.g., `["programming", "vim"]`)

The note file is formatted as:

```
# <id> <title>

tags: #tag1 #tag2

<content>
```

### Retrieve Notes

```
@zk get <tags>
```

Retrieves zettelkasten notes by tags. Returns a JSON array of matching notes with `file_name` and `title` fields.

## 🐞 Debug

Debug zettelkasten.nvim with [logger.nvim](https://github.com/wsdjeg/logger.nvim):

```lua
require('plug').add({
    {
        'wsdjeg/zettelkasten.nvim',
        depends = { { 'wsdjeg/logger.nvim' } },
    },
})
```

## 📸 Screenshots

![](https://wsdjeg.net/images/zkbrowser.png)
![](https://wsdjeg.net/images/zettelkasten-tags-sidebar.png)
![](https://wsdjeg.net/images/zettelkasten-tags-filter.png)
![](https://wsdjeg.net/images/zettelkasten-complete-id.png)

## 📣 Self-Promotion

Like this plugin? Star the repository on
[GitHub](https://github.com/wsdjeg/zettelkasten.nvim).

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg).

## 🙏 Credits

This plugin is forked from [Furkanzmc/zettelkasten.nvim](https://github.com/Furkanzmc/zettelkasten.nvim).

Summary of differences from the upstream fork:

1. **New Features:**
   - Clipboard image pasting (macOS/Linux/Windows)
   - Tags completion support (`completefunc` & `tagfunc`)
   - Tags sidebar window with foldable tag tree
   - Configurable note browser title width
   - Calendar.nvim extension
   - Picker.nvim sources (notes, tags, templates)
   - Telescope.nvim extensions (notes, tags, templates)
   - LuaRocks support
   - Lua syntax files for browser and tags tree
   - `ZkHover` command for note preview
   - Chat.nvim integration (`@zk create` / `@zk get`)

2. **Improvements:**
   - Many bug fixes (note time, highlight range, default actions, etc.)
   - Consistent use of Lua API and `vim.cmd`
   - Cleaner setup via `setup()` function (moved from `vim.g` to module config)
   - Enhanced docs and README

3. **Other Changes:**
   - Release automation with release-please
   - Better Neovim integration (filetype detection, keybindings, etc.)

## 💬 Feedback

If you encounter any bugs or have suggestions, please file an issue in the
[issue tracker](https://github.com/wsdjeg/zettelkasten.nvim/issues).

