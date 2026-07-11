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
    - [Module Structure](#module-structure)
    - [Config](#config)
    - [Main Module (`zettelkasten.lua`)](#main-module-zettelkastenlua)
    - [Browser](#browser)
    - [Formatter](#formatter)
    - [Log](#log)
    - [Plugin](#plugin)
    - [ftplugin](#ftplugin)
    - [Summary of New Features](#summary-of-new-features)
    - [Summary of Improvements](#summary-of-improvements)
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

The fork has diverged significantly from the upstream. Below is a detailed module-by-module comparison.

### Module Structure

| Module | Upstream | Fork | Notes |
| ------ | -------- | ---- | ----- |
| `lua/zettelkasten.lua` | Public API | Public API (expanded) | See [Main Module](#main-module-zettelkastenlua) |
| `lua/zettelkasten/config.lua` | Private table + `get()` | Module-level fields | See [Config](#config) |
| `lua/zettelkasten/browser.lua` | Note parsing + caching | Note parsing + caching + browser window | See [Browser](#browser) |
| `lua/zettelkasten/formatter.lua` | Format strings | Format strings + title truncation | See [Formatter](#formatter) |
| `lua/zettelkasten/log.lua` | `vim.notify` wrapper | `logger.nvim` + `nvim-notify` | See [Log](#log) |
| `lua/zettelkasten/sidebar.lua` | — | **New** Tags sidebar window | — |
| `lua/zettelkasten/types.lua` | — | **New** Type definitions | — |
| `lua/zettelkasten/util.lua` | — | **New** Highlight, clipboard image, syntax utils | — |
| `lua/calendar/extensions/zettelkasten.lua` | — | **New** Calendar.nvim extension | — |
| `lua/chat/tools/zettelkasten_create.lua` | — | **New** Chat.nvim create tool | — |
| `lua/chat/tools/zettelkasten_get.lua` | — | **New** Chat.nvim get tool | — |
| `lua/picker/sources/zettelkasten*.lua` | — | **New** Picker.nvim sources (3 files) | — |
| `lua/telescope/_extensions/zettelkasten*.lua` | — | **New** Telescope extensions (3 files) | — |
| `ftplugin/zktagstree.lua` | — | **New** Tags sidebar buffer settings | — |
| `syntax/zktagstree.lua` | — | **New** Tags sidebar syntax | — |
| `plugin/zettelkasten.lua` | Commands + BufReadCmd autocmd | Simplified command registration | See [Plugin](#plugin) |

### Config

**Upstream** uses a private `s_config` table accessed via `config.get()`:

```lua
-- Upstream
local s_config = {
    notes_path = "",
    preview_command = "pedit",
    browseformat = "%f - %h [%r Refs] [%b B-Refs] %t",
    id_inference_location = M.TITLE,  -- TITLE (0) or FILENAME (1)
    id_pattern = "%d+-%d+-%d+-%d+-%d+-%d+",
    id_format = "%Y-%m-%d-%H-%M-%S",
    filename_pattern = "%d+-%d+-%d+-%d+-%d+-%d+.md",
    title_pattern = "# %d+-%d+-%d+-%d+-%d+-%d+ .+",
}
M.get = function() return s_config end
```

**Fork** uses module-level fields accessed directly:

```lua
-- Fork
M.notes_path = '~/.zettelkasten/'
M.template_dir = '~/.zettelkasten_template'
M.browseformat = '%f - %h [%r Refs] [%b B-Refs] %t'
M.preview_command = 'pedit'
M.completion_kind = '[zettelkasten]'
M.browse_title_width = 30
```

Key differences:

| Aspect | Upstream | Fork |
| ------ | -------- | ---- |
| Access pattern | `config.get().notes_path` | `config.notes_path` |
| `id_inference_location` | Configurable: `TITLE` (0) or `FILENAME` (1) | Hardcoded to title-based only |
| `id_pattern` / `id_format` / `filename_pattern` / `title_pattern` | Configurable | Hardcoded as module-level locals in `browser.lua` and `zettelkasten.lua` |
| Unknown key validation | Warns on unknown config keys | Silently ignores |
| `template_dir` | — | **New** |
| `completion_kind` | — | **New** |
| `browse_title_width` | — | **New** |
| `notes_path` default | `""` (empty string) | `'~/.zettelkasten/'` |

### Main Module (`zettelkasten.lua`)

| Function | Upstream | Fork | Details |
| -------- | -------- | ---- | ------- |
| `generate_note_id` | `(parent_id)` — uses `config.get().id_format`, supports string or function | `(date)` — uses hardcoded `NOTE_ID_STRFTIME_FORMAT`, supports custom date table | Fork allows creating notes with a specific date |
| `set_note_id` | Checks `id_inference_location` for TITLE vs FILENAME | Always title-based; checks for duplicate IDs before writing | Fork adds duplicate ID guard |
| `completefunc` | Note ID/title completion only | Note ID/title **and** tag completion (detects `#` prefix context) | Fork adds `complete_tags` flag and tag deduplication |
| `get_note_browser_content` | No parameters | `(opt)` — supports `opt.tags` filter and `opt.date` filter | Fork enables tag/date-based browsing |
| `add_hover_command` | `(bufnr)` — takes buffer number | `()` — operates on current buffer (`0`); adds shell completion for `-preview`/`-return-lines` flags | Fork uses `fargs` instead of `args` string |
| `_internal_execute_hover_cmd` | Parses string args with `vim.split` | Iterates `fargs` table directly | Fork is cleaner with Neovim's `nargs = "*"` |
| `zknew` | — | **New** Programmatic note creation with template support and custom date | Fork: `vim.api.nvim_create_buf` + `nvim_open_win` instead of `vim.cmd("new")` |
| `paste_image` | — | **New** Clipboard image paste (macOS/Linux/Windows) | Fork uses `util.save_clipboard_image` |
| `contains` | `(filename)` — checks if file is within `notes_path` | Removed | Not needed in fork's architecture |
| `setup` | `opts.notes_path = opts.notes_path or ""` | `opts.notes_path = opts.notes_path or config.notes_path` | Fork preserves existing config as default |
| Config access | `config.get().xxx` | `config.xxx` | Fork uses direct module fields |
| Log calls | `log.notify(msg, log_levels.ERROR, {})` | `log.notify(msg, log_highlights.WARN)` | Fork uses string highlight names |

### Browser

| Aspect | Upstream | Fork |
| ------ | -------- | ---- |
| `get_files` | `(folder, filename_pattern)` — parameterized pattern | `(folder)` — hardcoded `ZK_FILE_NAME_PATTERN` |
| `extract_id_and_title` | `(line, file_path, title_pattern, id_pattern, id_inference_location)` — 5 params, supports TITLE and FILENAME modes | `(line)` — no parameters, title-only mode, hardcoded patterns |
| `get_note_information` | `(file_path, id_config)` — takes ID config table | `(file_path)` — no config parameter |
| `get_notes` | Checks `fn.isdirectory(folder)` before listing | No directory check (relies on `globpath` returning empty) |
| `browse` | — | **New** Opens browser window with tag/date filtering, sets buffer options |
| `clear_cache` | — | **New** Clears note cache for testing |
| File handle | Does not close file on empty read | Closes file on empty read (`file:close()`) |
| Nil check | `file:read(0) == nil` without nil guard on `file` itself | `if file == nil then return nil end` before `file:read(0)` |
| Tag regex | `(%#%a[%w-_]+)` | `(%#%a[%w-]+)` — removed underscore from second+ char class |

### Formatter

| Aspect | Upstream | Fork |
| ------ | -------- | ---- |
| `%h` (title) | Returns `line.title` as-is | Pads to `browse_title_width` or truncates with `...` |
| Truncation | — | Uses `str2chars()` for proper CJK character width handling |
| Line trimming | `vim.trim(cmps)` on each formatted line | No trimming |
| Config dependency | None | Depends on `config.browse_title_width` |
| Nil safety | `s_formatters[modifier](line)` may error on nil | `s_formatters[modifier](line) or ''` fallback |

### Log

| Aspect | Upstream | Fork |
| ------ | -------- | ---- |
| Backend | `vim.notify` | `logger.nvim` (lazy-loaded) for `info/debug/warn/error` |
| Notification | `vim.notify(tag .. msg, level, opts)` | `nvim-notify` (lazy-loaded) via `notify(msg, highlight)` |
| Log levels | `vim.log.levels` (numeric) | String highlight names (`'Normal'`, `'Error'`, `'WarningMsg'`) |
| `set_level` | Configurable log level threshold | Not available (uses logger.nvim's own config) |
| Tag/prefix | `opts.tag or "[zettelkasten]"` | Handled by logger.nvim's `derive('zettelkasten')` |

### Plugin

| Aspect | Upstream | Fork |
| ------ | -------- | ---- |
| `ZkNew` | `vim.cmd("new \| setlocal filetype=markdown")` + `lcd` + `normal ggI# New Note` + `set_note_id` | Calls `M.zknew({})` — programmatic buffer creation with `nvim_create_buf` + `nvim_open_win` |
| `ZkBrowse` | `vim.cmd("edit zk://browser")` + `BufReadCmd` autocmd | Calls `browser.browse(opts)` directly; supports `nargs = "*"` for tag filtering |
| `BufReadCmd` autocmd | Yes — fills browser content via autocmd | Removed — browser content handled by `browser.browse()` |
| `_G.zettelkasten` | `tagfunc`, `completefunc` | `tagfunc`, `completefunc`, `zknew`, `zkbrowse` |

### ftplugin

| Aspect | Upstream `markdown.lua` | Fork `markdown.lua` |
| ------ | ----------------------- | ------------------- |
| Guard | Sets options unconditionally | Only applies to buffers matching zettelkasten ID pattern (`\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d\.md`) |
| `tagfunc` / `completefunc` | Conditional (`if == ""`) | Always set (no conditional check) |
| `keywordprg` | Conditional (`if == ""`) | Always set to `:ZkHover` |
| `<leader>p` (paste image) | — | **New** keymap for clipboard image paste |
| `add_hover_command` | `(bufnr)` | `()` (current buffer) |

| Aspect | Upstream `zkbrowser.lua` | Fork `zkbrowser.lua` |
| ------ | ------------------------ | -------------------- |
| `modifiable` | `true` | `false` (read-only browser) |
| `buflisted` | `true` | `false` |
| `q` key | — | **New** Close browser (`b#` fallback to `bd`) |
| `<C-l>` | — | **New** Clear tag filter and reload |
| `<LeftRelease>` | — | **New** Filter notes by tag under cursor |
| `<F2>` | — | **New** Open tags sidebar |
| `<Enter>` | — | **New** Open note (`normal 0gf`) |
| `BufEnter` autocmd | — | **New** Force `buflisted = false` (workaround) |
| `util` import | — | **New** For `syntax_at()` and `is_last_win()` |
| `lcd` notes_path | Conditional on `isdirectory` | Conditional on `notes_path ~= ""` |

### Summary of New Features

1. **Tags Sidebar** (`sidebar.lua`) — Foldable tag tree window for visual tag-based filtering
2. **Tag Completion** — `completefunc` detects `#` prefix and completes tags instead of note IDs
3. **Clipboard Image Paste** — `paste_image()` with platform-specific commands (macOS/Linux/Windows)
4. **Note Templates** — `zknew(opt)` supports `opt.template` for pre-defined note content
5. **Custom Date Notes** — `zknew(opt)` supports `opt.date` for creating notes with a specific date
6. **Calendar Integration** — `calendar/extensions/zettelkasten.lua` highlights dates with notes
7. **Picker.nvim Sources** — 3 sources: notes, tags, templates
8. **Telescope.nvim Extensions** — 3 extensions: notes, tags, templates
9. **Chat.nvim Integration** — `@zk create` and `@zk get` tools
10. **Configurable Title Width** — `browse_title_width` for browser column alignment
11. **LuaRocks Support** — Installable via `luarocks install zettelkasten.nvim`
12. **Release Automation** — release-please for automated changelog and versioning

### Summary of Improvements

1. **Nil safety** — Added nil checks for file handles and note titles
2. **Resource cleanup** — File handles are closed on empty reads
3. **Duplicate ID guard** — `set_note_id` checks for existing notes before writing
4. **Browser read-only** — Browser buffer is `modifiable = false` and `buflisted = false`
5. **Richer keybindings** — `q`, `<Enter>`, `<C-l>`, `<F2>`, `<LeftRelease>` in browser
6. **Title truncation** — Browser titles padded/truncated with CJK-aware width calculation
7. **Richer logging** — Integration with `logger.nvim` and `nvim-notify`
8. **Test suite** — Comprehensive unit tests with `luaunit`

## 💬 Feedback

If you encounter any bugs or have suggestions, please file an issue in the
[issue tracker](https://github.com/wsdjeg/zettelkasten.nvim/issues).

