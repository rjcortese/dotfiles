-- a peachy nvim config

-- shortcuts for common things
local map = vim.keymap.set
local fn = vim.fn

-- identify the os
-- result will be:
--   "Darwin" on MacOS
--   "Linux" on Linux
if not fn.exists(vim.g.os) then
  vim.g.os = fn.substitute(fn.system("uname"), "\n", "", "")
end

-- bootstrap lazy.nvim package manager
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
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
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
    },
  },
})
require("mason-lspconfig").setup()
require("lspconfig").lua_ls.setup({
  on_init = function (client)
    local path = client.workspace_folders[1].name
    if vim.loop.fs_stat(path.."/.luarc.json") or vim.loop.fs_stat(path.."/.luarc.jsonc") then
      return
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT"
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
        }
      },
    })
  end,
  settings = {
    Lua = {}
  }
})
require("lspconfig").pyright.setup({})

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

-- default tab / space settings
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- filetypes specific tab / space settings
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = {
      "*.lua",
      "*.yml",
      "*.yaml",
      "*.js",
      "*.ts",
      "*.html",
      "*.css",
      "*.json",
      "*.svelte",
      "*.xml",
      "*.c",
      "*.cc",
      "*.cxx",
      "*.h",
      "*.cpp",
      "*.hpp",
      "CMakeLists.txt",
      "*.tf",
      "*.tofu",
    },
    callback = function()
      vim.o.tabstop = 2
      vim.o.expandtab = true
      vim.o.softtabstop = 2
      vim.o.shiftwidth = 2
    end,
  }
)

-- idk what it does, cargo culted -- maybe it disables builtin
-- omnifunc since we use a plugin for autocomplete instead
vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

-- keep the cursor line centered vertically 
map({ "n", "x" }, "j", "jzz")
map({ "n", "x" }, "k", "kzz")
map({ "n", "x" }, "G", "Gzz")
map("n", "{", "{zz")
map("n", "}", "}zz")
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("n", "%", "%zz")

-- See `:help vim.diagnostic.*` for documentation on any of the
-- below functions
map("n", "<leader>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
-- buffer diagnostics only
map("n", "<leader>d", vim.diagnostic.setloclist)
-- all workspace diagnostics
map("n", "<leader>aa", vim.diagnostic.setqflist)
-- all workspace errors
map("n", "<leader>ae", function()
  vim.diagnostic.setqflist({ severity = "E" })
end)
-- all workspace warnings
map("n", "<leader>aw", function()
  vim.diagnostic.setqflist({ severity = "W" })
end)
map("n", "[c", function()
  vim.diagnostic.goto_prev({ wrap = false })
end)
map("n", "]c", function()
  vim.diagnostic.goto_next({ wrap = false })
end)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below
    -- functions
    local opts = { buffer = ev.buf }
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gds", vim.lsp.buf.document_symbol, opts)
    map("n", "gws", vim.lsp.buf.workspace_symbol, opts)
    map("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
    map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>cl", vim.lsp.codelens.run)
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    map("n", "<leader>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
