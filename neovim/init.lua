-- a peachy nvim config

-- identify the os
-- result will be:
--   "Darwin" on MacOS
--   "Linux" on Linux
if not vim.fn.exists(vim.g.os) then
  vim.g.os = vim.fn.substitute(vim.fn.system("uname"), "\n", "", "")
end


-- bootstrap lazy.nvim package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- setup our plugins
require("lazy").setup("plugins")

-- disable all providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- allow cursor to move one spot past end of line
vim.opt.virtualedit:append { "onemore" }

-- status line looks like:
-- vim.o.statusline = %<%f%m%r%y=%b\ 0x%B\ \ %l,%c%V\ %P

-- split below and right
vim.o.splitbelow = true
vim.o.splitright = true

-- use system clipboard
vim.o.clipboard = "unnamedplus"
-- if g:os == "Darwin"
--     set clipboard=unnamed
-- elseif g:os == "Linux"
--     set clipboard=unnamedplus
-- end

-- keep the cursor line centered vertically 
vim.keymap.set({ "n", "x" }, "j", "jzz")
vim.keymap.set({ "n", "x" }, "k", "kzz")
vim.keymap.set({ "n", "x" }, "G", "Gzz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "%", "%zz")
