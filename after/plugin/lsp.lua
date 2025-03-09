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
    'clangd',
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

lspconfig.clangd.setup({
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=verbose' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_dir = lspconfig.util.root_pattern('compile_commands.json', '.git'),
    init_options = {
        clangdFileStatus = true,
        fallbackFlags = { '-std=c++17' },
    }
})

-- setup your go.nvim
-- make sure lsp_cfg is disabled
require("mason").setup()
require("mason-lspconfig").setup()
require('go').setup {
    lsp_cfg = false
    -- other setups...
}
local cfg = require 'go.lsp'.config() -- config() return the go.nvim gopls setup

require('lspconfig').gopls.setup(cfg)

lspconfig.sourcekit.setup {
    root_dir = lspconfig.util.root_pattern(
        '.git',
        'Package.swift',
        'compile_commands.json'
    ),
    cmd = { 'sourcekit-lsp' }
}

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

lspconfig.eslint.setup({
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
})

lspconfig.ts_ls.setup {
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
    cmd = { "typescript-language-server", "--stdio" },
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.server_capabilities.documentFormattingProvider = false
        lsp_status.on_attach(client, bufnr)
    end,
    provideFormatter = false,
}

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

-- vim.api.nvim_create_autocmd('BufWritePre', {
--     pattern = { '*.tsx', '*.ts', '*.jsx', '*.js' },
--     command = 'silent! EslintFixAll',
--     group = vim.api.nvim_create_augroup('MyAutocmdsJavaScripFormatting', {}),
-- })

-- require("flutter-tools").setup {} -- use defaults
