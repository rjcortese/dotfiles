return {
  {
    "yggdroot/duoduo",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme duoduo]])
    end,
  },
  "tpope/vim-commentary",
  "tpope/vim-abolish",
  "tpope/vim-surround",
  "tpope/vim-obsession",
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateRight",
      "TmuxNavigateUp",
      "TmuxNavigateDown",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    },
  },
  {
    "solarnz/thrift.vim",
    ft = "thrift",
  },
}
