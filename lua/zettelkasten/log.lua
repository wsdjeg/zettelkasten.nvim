local M = {}
local logger
for _, f in ipairs({ 'info', 'debug', 'warn', 'error' }) do
    M[f] = function(msg)
        if not logger then
            pcall(function()
                logger = require('logger').derive('zettelkasten')
                logger[f](msg)
            end)
        else
            logger[f](msg)
        end
    end
end

local nt

function M.notify(msg, highlight)
	if not nt then
		pcall(function()
			nt = require("notify")
		end)
	end
	if not nt then
		return
	end
	nt.notify(msg, highlight)
end

return M
