local M = {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
}

function M.config()
    require("peek").setup {
        theme = "dark",
    }
end

function M.init()
    vim.api.nvim_create_user_command("Peek", function()
        local peek = require "peek"
        if peek.is_open() then
            peek.close()
        else
            peek.open()
        end
    end, {})
end

return M