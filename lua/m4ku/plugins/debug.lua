local map = function(keys, command, desc)
  vim.keymap.set("n", keys, command, { desc = "Debug: " .. desc })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    {
      "Joakker/lua-json5",
      build = "./install.sh"
    }
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    map("<leader>td", dapui.toggle, "Toggle UI")
    map("<F5>", dap.continue, "Start/Continue")
    map("<F1>", dap.step_into, "Step into")
    map("<F2>", dap.step_over, "Step over")
    map("<F3>", dap.step_out, "Step Out")
    map("<leader>b", dap.toggle_breakpoint, "Toggle breakpoint")
    map(
      "<leader>B",
      function()
        dap.set_breakpoint(vim.fn.input("Breakpoint Condition: "))
      end,
      "Set Breakpoint"
    )


    map("<F7>", dapui.toggle, "See last session result")

    local dapui_config = "dapui_config"

    dap.listeners.after.event_initialized[dapui_config] = dapui.open
    dap.listeners.before.event_terminated[dapui_config] = dapui.close
    dap.listeners.before.event_exited[dapui_config] = dapui.close
  end
}
