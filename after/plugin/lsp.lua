-- ALE Configuration
vim.g.ale_linters = {
    proto = { 'buf-lint' },
}
vim.g.ale_lint_on_text_changed = 'never'
vim.g.ale_linters_explicit = 1

local ih = require('lsp-inlayhints')
ih.setup()

local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
    'rust_analyzer',
    'gopls',
    'kotlin_language_server',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

local lsp_status = require('lsp-status')
lsp_status.register_progress()

local lspconfig = require('lspconfig')
lspconfig.rust_analyzer.setup({
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
            },
            checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = {
                    "--",
                    "--no-deps",
                    "-Dclippy::correctness",
                    "-Dclippy::complexity",
                    "-Wclippy::perf",
                    "-Wclippy::pedantic",
                },
            }
        }
    }
})

local api = require("typescript-tools.api")
require("typescript-tools").setup {
    handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
        -- Ignore 'This may be converted to an async function' diagnostics.
            { 80006 }
        ),
        ['textDocument/definition'] = function(err, result, method, ...)
            -- In order to debug uncomment:
            -- local result_str = vim.inspect(result)
            -- vim.notify("LSP definition result: " .. result_str, vim.log.levels.INFO)

            if vim.islist(result) and #result > 1 then
                local filtered_result = {}
                for _, v in pairs(result) do
                    if (
                            (v.uri and string.match(v.uri, '%@types/react/index.d.ts') == nil)
                            or (v.targetUri and string.match(v.targetUri, '%@types/react/index.d.ts') == nil)
                        ) then
                        table.insert(filtered_result, v)
                    end
                end

                return vim.lsp.handlers['textDocument/definition'](err, filtered_result, method, ...)
            end

            vim.lsp.handlers['textDocument/definition'](err, result, method, ...)
        end
    },
}

lspconfig.gopls.setup({
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})


require("lualine").setup {
    sections = {
        lualine_c = {
            'filename',
            function()
                local status = lsp_status.status()
                -- Replace undesired character(s) here
                status = status:gsub("🇻", "")
                if (status == "") then
                    return "S"
                end
                return status
            end,
        },
    }
}

-- Add Pyright configuration
lspconfig.pyright.setup({
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "strict",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            }
        }
    }
})

-- This should be in the end of the file
lsp.on_attach(function(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)
lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
    command = 'silent! EslintFixAll',
    group = vim.api.nvim_create_augroup('MyAutocmdsJavaScripFormatting', {}),
})

require("flutter-tools").setup {} -- use defaults
