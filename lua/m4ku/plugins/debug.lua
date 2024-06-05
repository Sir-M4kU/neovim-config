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
    local mason_registry = require("mason-registry")
    mason_registry.refresh()
    local js_debug = mason_registry.get_package("js-debug-adapter")
    local dap = require("dap")
    local dapui = require("dapui")
    local js_debug_path = js_debug:get_install_path() .. "/js-debug/src/dapDebugServer.js"

    require("mason-nvim-dap").setup({
      ensure_installed = { "js-debug-adapter", "codelldb" },
      automatic_installation = true,
      handlers = {}
    })

    if not dap.adapters["pwa-node"] then
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { js_debug_path, "-p", "${port}" }
        }
      }
    end
    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end

        local native_adapter = dap.adapters["pwa-node"]
        if type(native_adapter) == "function" then
          native_adapter(cb, config)
        else
          cb(native_adapter)
        end
      end
    end

    for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      if not dap.configurations[lang] then
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}"
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}"
          }
        }
      end
    end

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
