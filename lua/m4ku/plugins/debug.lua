local map = function(keys, command, desc)
  vim.keymap.set("n", keys, command, { desc = "Debug: " .. desc })
end

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" }
    },
    {
      "mxsdev/nvim-dap-vscode-js",
      dependencies = {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
      },
      opts = {
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extension-host" }
      }
    },
    "williamboman/mason.nvim",
    "theHamsta/nvim-dap-virtual-text"
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local debug_type_preferred = { ["node"] = "pwa-node" }

    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, cfg)
        cfg.type = debug_type_preferred[cfg.type] or cfg.type
        local native_adapter = dap.adapters["pwa-node"]
        if type(native_adapter) == "function" then
          native_adapter(cb, cfg)
        else
          cb(native_adapter)
        end
      end
    end

    dapui.setup()

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
    map("<leader>de", dapui.eval, "Evaluate expression")

    map("<F7>", dapui.toggle, "See last session result")

    local dapui_config = "dapui_config"

    dap.listeners.after.event_initialized[dapui_config] = dapui.open
    dap.listeners.before.event_terminated[dapui_config] = dapui.close
    dap.listeners.before.event_exited[dapui_config] = dapui.close
  end
}
