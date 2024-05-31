local map = function(mode, keys, command, desc)
  opts = opts or {}
  opts.buffer = bufnr
  vim.keymap.set(mode, keys, command, { desc = "Git: " .. desc })
end

return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" }
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Jump to the next git [c]hange")
      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Jump to the previous git [c]hange")

      map("v", "<leader>hs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage git hunk")
      map("v", "<leader>hr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset git hunk")

      map("n", "<leader>hs", gitsigns.stage_hunk, "[s]tage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "[r]eset hunk")
      map("n", "<leader>hS", gitsigns.stage_buffer, "[S]tage buffer")
      map("n", "<leader>hu", gitsigns.undo_stage_hunk, "[u]ndo stage hunk")
      map("n", "<leader>hR", gitsigns.reset_buffer, "[R]eset buffer")
      map("n", "<leader>hp", gitsigns.preview_hunk, "[p]review hunk")
      map("n", "<leader>hb", gitsigns.blame_line, "[b]lame line")
      map("n", "<leader>hd", gitsigns.diffthis, "[d]iff against index")
      map("n", "<leader>hD", function()
        gitsigns.diffthis("@")
      end, "[D]iff against last commit")
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "[T]oggle git show [b]lame line")
      map("n", "<leader>tD", gitsigns.toggle_deleted, "[T]oggle git show [D]eleted")
    end
  }
}
