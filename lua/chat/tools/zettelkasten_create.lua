local M = {}

local config = require('chat.config')

local zk_config = require('zettelkasten.config')
local zk = require('zettelkasten')

---@class ChatToolsZettelkastenCreateAction
---@field title string
---@field content string
---@field tags? string[]

---@param action ChatToolsZettelkastenCreateAction
function M.zettelkasten_create(action)
  if not action.title then
    return {
      error = 'failed to create zettelkasten note, title is required.',
    }
  end
  if type(action.title) ~= 'string' then
    return {
      error = 'the type of title should be string.',
    }
  end

  if type(action.content) ~= 'string' then
    return {
      error = 'the type of content should be string.',
    }
  end

  local id = zk.generate_note_id()
  local filename = zk_config.notes_path .. '/' .. id .. '.md'

  local content_lines = {
    string.format('# %s %s', id, action.title),
    '', -- 空行
    action.content,
  }

  -- 添加标签（如果存在）
  if action.tags and #action.tags > 0 then
    -- 验证 tags 类型
    if type(action.tags) ~= 'table' then
      return {
        error = 'the type of tags should be table/array.',
      }
    end

    local tags_str = 'tags:'
    for _, tag in ipairs(action.tags) do
      if type(tag) ~= 'string' then
        return {
          error = 'each tag should be string type.',
        }
      end
      tags_str = tags_str .. ' #' .. tag
    end
    table.insert(content_lines, 3, tags_str)
    table.insert(content_lines, 4, '')
  end

  -- 写入文件
  local ok, err = pcall(function()
    local file = io.open(filename, 'w')
    if not file then
      error('failed to open file: ' .. filename)
    end

    file:write(table.concat(content_lines, '\n'))
    file:close()
  end)

  if ok then
    return {
      content = string.format(
        'zettelkasten note created successfully!\n\nID: %s\nTitle: %s\nPath: %s',
        id,
        action.title,
        filename
      ),
    }
  else
    return {
      error = string.format(
        'failed to create zettelkasten note:\n%s',
        tostring(err)
      ),
    }
  end
end

function M.scheme()
  return {
    type = 'function',
    ['function'] = {
      name = 'zettelkasten_create',
      description = [[
Create a new zettelkasten note. Use @zk create command.

⚠️ CRITICAL RESTRICTIONS - READ CAREFULLY:

This tool MUST ONLY be called when the user EXPLICITLY requests to create a note.

VALID triggers (user MUST say something like):
- "创建笔记" / "新建笔记" / "记录笔记"
- "保存为笔记" / "保存这个想法"  
- "@zk create" or "zk create"

🚫 FORBIDDEN uses - DO NOT CALL THIS TOOL FOR:
- Generating code snippets
- Storing conversation summaries  
- Saving answers or explanations
- ANY automated or proactive purposes
- ANY purpose other than explicit user request to create a note

If you are unsure whether to call this tool, DO NOT call it.

Rules:
1. Execute ONLY when user explicitly mentions creating a note
2. Tags: maximum 3 tags, avoid synonyms, use English
3. Title and content are required
]],
      parameters = {
        type = 'object',
        properties = {
          title = {
            type = 'string',
            description = 'The title of zettelkasten note',
          },
          content = {
            type = 'string',
            description = 'the note body of zettelkasten',
          },
          tags = {
            type = 'array',
            items = {
              type = 'string',
            },
            description = 'Optional tags for the note (e.g., ["programming", "vim"]), the tag should be english.',
          },
        },
        required = { 'title', 'content' },
      },
    },
  }
end

return M
