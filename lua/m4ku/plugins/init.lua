return {
  "tpope/vim-sleuth",
  { "numToStr/Comment.nvim", opts = {} },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    opts = {
      signs = false
    }
  },
  {
    "rose-pine/neovim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("rose-pine")

      vim.cmd.hi("Comment gui=none")
    end
  },
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()

      local statusline = require("mini.statusline")
      statusline.setup({ use_icons = vim.g.have_nerd_font })
      statusline.section_location = function()
        return "%21:%-2v"
      end
    end
  }
}
