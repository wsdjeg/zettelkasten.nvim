local M = {}
M.group2dict = function(name)
	local id = vim.fn.hlID(name)
	if id == 0 then
		return {
			name = "",
			ctermbg = "",
			ctermfg = "",
			bold = "",
			italic = "",
			reverse = "",
			underline = "",
			guibg = "",
			guifg = "",
		}
	end
	local rst = {
		name = vim.fn.synIDattr(id, "name"),
		ctermbg = vim.fn.synIDattr(id, "bg", "cterm"),
		ctermfg = vim.fn.synIDattr(id, "fg", "cterm"),
		bold = vim.fn.synIDattr(id, "bold"),
		italic = vim.fn.synIDattr(id, "italic"),
		reverse = vim.fn.synIDattr(id, "reverse"),
		underline = vim.fn.synIDattr(id, "underline"),
		guibg = vim.fn.tolower(vim.fn.synIDattr(id, "bg#", "gui")),
		guifg = vim.fn.tolower(vim.fn.synIDattr(id, "fg#", "gui")),
	}
	return rst
end

M.hi = function(info)
	if vim.fn.empty(info) == 1 or vim.fn.get(info, "name", "") == "" then
		return
	end
	vim.cmd("silent! hi clear " .. info.name)
	local cmd = "silent hi! " .. info.name
	if vim.fn.empty(info.ctermbg) == 0 then
		cmd = cmd .. " ctermbg=" .. info.ctermbg
	end
	if vim.fn.empty(info.ctermfg) == 0 then
		cmd = cmd .. " ctermfg=" .. info.ctermfg
	end
	if vim.fn.empty(info.guibg) == 0 then
		cmd = cmd .. " guibg=" .. info.guibg
	end
	if vim.fn.empty(info.guifg) == 0 then
		cmd = cmd .. " guifg=" .. info.guifg
	end
	local style = {}

	for _, sty in ipairs({ "bold", "italic", "underline", "reverse" }) do
		if info[sty] == 1 then
			table.insert(style, sty)
		end
	end

	if vim.fn.empty(style) == 0 then
		cmd = cmd .. " gui=" .. vim.fn.join(style, ",") .. " cterm=" .. vim.fn.join(style, ",")
	end
	if info.blend then
		cmd = cmd .. " blend=" .. info.blend
	end
	pcall(vim.cmd, cmd)
end
-- neovim winnr('$') includes floating windows
function M.is_last_win()
	local win_list = vim.api.nvim_tabpage_list_wins(0)
	local num = #win_list
	for _, v in ipairs(win_list) do
		if M.is_float(v) then
			num = num - 1
		end
	end
	return num == 1
end

local function get_color(name)
	local c = vim.api.nvim_get_hl(0, { name = name })

	if c.link then
		return get_color(c.link)
	else
		return c
	end
end

function M.syntax_at(...)
	local lnum = select(1, ...) or vim.fn.line(".")
	local col = select(2, ...) or vim.fn.col(".")
	local inspect = vim.inspect_pos(0, lnum - 1, col - 1)
	local name, hl
	if #inspect.semantic_tokens > 0 then
		local token, priority = {}, 0
		for _, semantic_token in ipairs(inspect.semantic_tokens) do
			if semantic_token.opts.priority > priority then
				priority = semantic_token.opts.priority
				token = semantic_token
			end
		end
		if token then
			name = token.opts.hl_group_link
			hl = vim.api.nvim_get_hl(0, { name = token.opts.hl_group_link })
		end
	elseif #inspect.treesitter > 0 then
		for i = #inspect.treesitter, 1, -1 do
			name = inspect.treesitter[i].hl_group_link
			hl = vim.api.nvim_get_hl(0, { name = name })
			if hl.fg then
				break
			end
		end
	else
		name = vim.fn.synIDattr(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1), "name", "gui")
		hl = get_color(name)
	end
	return name, hl
end
return M
