-- Function to configure plugins after they're loaded
local function configure_plugins()
    -- Execute Vimscript within Lua
    vim.api.nvim_exec([[
    " Initialize glaive
    call glaive#Install()

    " Set up formatting for Python using yapf
    Glaive codefmt plugin[mappings]
    Glaive codefmt yapf_executable='yapf'
  ]], false)
end

-- Run the configuration function after plugins are loaded
vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    callback = function()
        configure_plugins()
    end
})

-- Setting up autocmd for automatic formatting on file save for specific file types
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.proto', '*.toml', '*.bazel' }, -- Formats .proto, .toml, and .bazel files
    callback = function()
        vim.cmd('FormatCode')                     -- Invokes codefmt to format the file
    end
})
