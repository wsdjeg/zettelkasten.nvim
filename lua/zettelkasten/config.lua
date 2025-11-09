--=============================================================================
-- config.lua --- the config module for zettelkasten
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================
local M = {}

M.zettel_dir = '~/.zettelkasten/'

M.templete_dir = '~/.zettelkasten_template'

M.browseformat = '%f - %h [%r Refs] [%b B-Refs] %t'
M.preview_command = 'pedit'
M.completion_kind = '[zettelkasten]'

M._set = function(opts)
    opts = opts or {}
    M.zettel_dir = opts.notes_path or M.zettel_dir
    M.preview_command = opts.preview_command or M.preview_command
    M.browseformat = opts.browseformat or M.browseformat
    M.completion_kind = opts.completion_kind or M.completion_kind
end

return M
