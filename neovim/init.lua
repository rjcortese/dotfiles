-- a peachy nvim config


-- bootstrap lazy.nvim package manager
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", -- latest stable release
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)

-- -- setup our plugins
-- require("lazy").setup("plugins")


-- simpler movement between splits
vim.keymap.set("n","<C-J>","<C-W><C-J>")
vim.keymap.set("n","<C-K>","<C-W><C-K>")
vim.keymap.set("n","<C-H>","<C-W><C-H>")
vim.keymap.set("n","<C-L>","<C-W><C-L>")
