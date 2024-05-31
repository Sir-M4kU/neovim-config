return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim",       opts = {} },
    { "folke/neodev.nvim",       opts = {} }
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("m4ku-lsp-attach", { clear = true }),
      callback = function(event)
        local builtin = require("telescope.builtin")
        local lsp_map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        lsp_map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
        lsp_map("gr", builtin.lsp_references, "[G]oto [R]eferences")
        lsp_map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
        lsp_map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
        lsp_map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
        lsp_map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        lsp_map("<leader>rn", vim.lsp.buf.rename, "[R]e[N]ame")
        lsp_map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        lsp_map("K", vim.lsp.buf.hover, "Hover Documentation")
        lsp_map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup(
            "m4ku-lsp-highlight",
            { clear = false }
          )
          local lsp_detach_augroup = vim.api.nvim_create_augroup(
            "m4ku-lsp-detach",
            { clear = true }
          )

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references
          })
          vim.api.nvim_create_autocmd({ "LspDetach" }, {
            group = lsp_detach_augroup,
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({
                group = "m4ku-lsp-detach",
                buffer = event2.buf
              })
            end
          })
        end

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          lsp_map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "[T]oggle Inlay [H]int")
        end
      end
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("cmp_nvim_lsp").default_capabilities()
    )

    local servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace"
            }
          }
        }
      }
    }

    require("mason").setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua"
    })
    require("mason-tool-installer").setup({ ensure_installed })
    require("mason-lspconfig").setup({
      automatic_installation = true,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend(
            "force",
            {},
            capabilities,
            server.capabilities or {}
          )
          require("lspconfig")[server_name].setup(server)
        end
      }
    })
  end
}
