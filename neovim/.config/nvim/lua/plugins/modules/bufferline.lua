local M = { "akinsho/nvim-bufferline.lua", lazy = false }

function M.config()
    require("bufferline").setup {
        options = {
            view = "multiwindow",
            numbers = function(opts)
                return string.format("%s", opts.ordinal)
            end,
            modified_icon = "●",
            max_prefix_length = 5,
            tab_size = 18,
            diagnostics = "nvim_lsp",
            separator_style = { "|", "" },
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    text_align = "center",
                },
            },
        },
    }
    vim.cmd.colorscheme "tokyodark" -- there should be a better fix for this
end

return M
