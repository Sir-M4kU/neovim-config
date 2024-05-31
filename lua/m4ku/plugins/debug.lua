local map = function(keys, command, desc)
  vim.keymap.set("n", keys, command, { desc = "Debug: " .. desc })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim"
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      handlers = {},
      ensure_installed = {}
    })

    dapui.setup({
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        }
      }
    })

    map("5", dap.continue, "Start/Continue")
    map("1", dap.step_into, "Step into")
    map("2", dap.step_over, "Step over")
    map("3", dap.step_out, "Step Out")
    map("<leader>b", dap.toggle_breakpoint, "Toggle breakpoint")
    map(
      "<leader>B",
      function()
        dap.set_breakpoint(vim.fn.input("Breakpoint Condition: "))
      end,
      "Set Breakpoint"
    )


    map("7", dapui.toggle, "See last session result")

    local dapui_config = "dapui_config"

    dap.listeners.after.event_initialized[dapui_config] = dapui.open
    dap.listeners.before.event_terminated[dapui_config] = dapui.close
    dap.listeners.before.event_exited[dapui_config] = dapui.close
  end
}
