-- Adapters
local node_adapter = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = vim.fn.exepath("js-debug-adapter"),
    args = { "${port}" }
  }
}
local codelldb_adapter = {
  id = "codelldb",
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.exepath("codelldb"),
    args = { "--port", "${port}" }
  }
}
local gdb_adapter = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}
local cppdbg_adapter = {
  id = "cppdbg",
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.exepath("OpenDebugAD7"),
    args = { "--server", "${port}" }
  }
}

-- Configurations
local codelldb_config = {
  name = "CodeLLDB: Launch file",
  type = "codelldb",
  request = "launch",
  program = function()
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false
}
local gdb_config = {
  name = "GDB: Launch file",
  type = "gdb",
  request = "launch",
  program = function()
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end,
  cwd = "${workspaceFolder}",
  stopAtBeginningOfMainSubprogram = false
}
local cppdbg_config = {
  name = "CPPDBG: Launch file",
  type = "cppdbg",
  request = "launch",
  MIMode = "gdb",
  miDebuggerServerAddress = "localhost:1234",
  miDebuggerPath = vim.fn.exepath("gdb"),
  program = function()
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end,
  cwd = "${workspaceFolder}",
}

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
    "williamboman/mason.nvim",
    "theHamsta/nvim-dap-virtual-text"
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
    local vscode = require("dap.ext.vscode")

    if not dap.adapters["pwa-node"] then
      dap.adapters["pwa-node"] = node_adapter
    end
    if not dap.adapters.node then
      dap.adapters.node = function(cb, config)
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
    if not dap.adapters.codelldb then
      dap.adapters.codelldb = codelldb_adapter
    end
    if not dap.adapters.gdb then
      dap.adapters.gdb = gdb_adapter
    end
    if not dap.adapters.cppdbg then
      dap.adapters.cppdbg = cppdbg_adapter
    end
    if not dap.configurations.cpp then
      dap.configurations.cpp = { codelldb_config, gdb_config, cppdbg_config }
    end
    if not dap.configurations.c then
      dap.configurations.c = dap.configurations.cpp
    end
    if not dap.configurations.rust then
      dap.configurations.rust = dap.configurations.cpp
    end

    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    for _, lang in ipairs(js_filetypes) do
      if not dap.configurations[lang] then
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true
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
