require("tokyonight").setup({
    -- use the night style
    style = "night",
    -- disable italic for functions
    transparent = true,
    terminal_colors = false,
    styles = {
        functions = {},
        sidebars = "transparent",
        floats = "transparent"
    },
    sidebars = { "qf" },
})

function ColorMyPencils(color)
    color = color or "tokyonight"
    vim.cmd("colorscheme " .. color)

    -- Setting background to 'none' for Normal and NormalFloat highlight groups
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    vim.opt.fillchars = { eob = " " }
end

-- Apply the Tokyo Night color scheme
ColorMyPencils()
