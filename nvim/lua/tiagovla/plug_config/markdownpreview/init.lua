return {
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
        local css_path = "$HOME/.config/nvim/lua/tiagovla/plug_config/markdownpreview/styles/github.css"
        vim.g.mkdp_markdown_css = vim.fn.expand(css_path)
        vim.g.mkdp_browser = "vimb"
    end,
}
