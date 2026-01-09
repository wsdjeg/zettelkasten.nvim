--=============================================================================
-- config.lua --- the config module for zettelkasten
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================
local M = {}

M.notes_path = '~/.zettelkasten/'

M.template_dir = '~/.zettelkasten_template'

M.browseformat = '%f - %h [%r Refs] [%b B-Refs] %t'
M.preview_command = 'pedit'
M.completion_kind = '[zettelkasten]'

M._set = function(opts)
  opts = opts or {}
  M.notes_path = opts.notes_path or M.notes_path
  M.preview_command = opts.preview_command or M.preview_command
  M.browseformat = opts.browseformat or M.browseformat
  M.completion_kind = opts.completion_kind or M.completion_kind
  M.templates_path = opts.templates_path or M.templates_path
end

return M
