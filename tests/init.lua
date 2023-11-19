-- Credit to https://github.com/folke for the test init.lua
local root = function(root)
	local f = debug.getinfo(1, "S").source:sub(2)
	return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

local load = function(plugin)
	local name = plugin:match(".*/(.*)")
	local package_root = root(".tests/site/pack/deps/start/")
	if not vim.loop.fs_stat(package_root .. name) then
		print("Installing " .. plugin)
		vim.fn.mkdir(package_root, "p")
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			"https://github.com/" .. plugin .. ".git",
			package_root .. "/" .. name,
		})
	end
end

local setup = function()
	vim.cmd([[set runtimepath=$VIMRUNTIME]])
	vim.opt.runtimepath:append(root())
	vim.opt.packpath = { root(".tests/site") }
	load("nvim-lua/plenary.nvim")
	load("nvim-treesitter/nvim-treesitter")
	vim.env.XDG_CONFIG_HOME = root(".tests/config")
	vim.env.XDG_DATA_HOME = root(".tests/data")
	vim.env.XDG_STATE_HOME = root(".tests/state")
	vim.env.XDG_CACHE_HOME = root(".tests/cache")

	-- No need all fields because setup() merges options with a set of defaults
	---@diagnostic disable-next-line: missing-fields
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "typescript" }, -- needed to parse mock typescript files
		sync_install = true, -- ensure parsers are installed before starting any tests
	})
end

setup()
