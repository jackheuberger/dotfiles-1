local keymap = vim.keymap
keymap.set("n", "<space>gd", "<cmd>Neogen<cr>")

return {
    config = function()
        require("neogen").setup {
            enabled = true,
        }
    end,
    requires = "nvim-treesitter/nvim-treesitter",
}