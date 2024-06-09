vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.termguicolors = true
vim.opt.guicursor = ""
vim.opt.showmode = false
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.hlsearch = true

function map(mode, keymap, command, desc)
	desc = desc or {}
	vim.keymap.set(mode, keymap, command, desc)
end

map("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file manager" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move and indent lines below" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move and indent lines up" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

map("n", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("m4ku-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end
})

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
	{
		spec = "m4ku.plugins"
	},
	{
		ui = {
			icons = vim.g.have_nerd_font and {} or {
				cmd = '⌘',
				config = '🛠',
				event = '📅',
				ft = '📂',
				init = '⚙',
				keys = '🗝',
				plugin = '🔌',
				runtime = '💻',
				require = '🌙',
				source = '📄',
				start = '🚀',
				task = '📌',
				lazy = '💤 ',
			}
		}
	}
)
