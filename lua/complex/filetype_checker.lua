local supported_filetypes = {
	"typescript",
}

local M = {}

---@param fn function
M.with_check_filetype = function(fn)
	local protected_fn = function()
		for _, f in ipairs(supported_filetypes) do
			if vim.bo.filetype == f then
				fn()
				return
			end
		end
		print("Buffer filetype is not supported.")
	end
	return protected_fn
end

return M
