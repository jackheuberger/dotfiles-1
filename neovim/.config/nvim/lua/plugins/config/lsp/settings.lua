local lspconfigplus = require "lspconfigplus"
local efm_cfg = require("lspconfigplus.extra")["efm"]
local utils = require "plugins.config.lsp.utils"
local lsp_installer = require "nvim-lsp-installer"

require "plugins.config.lsp.custom_servers"

local configs = {}

utils.define_signs { Error = "", Warn = "", Hint = "", Info = "" }

vim.diagnostic.config {
    virtual_text = {
        prefix = "",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
}

local on_attach = function(client, bufnr)
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end
    if client.resolved_capabilities.goto_definition == true then
        vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
    end

    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
    if client.resolved_capabilities.document_formatting then
        -- vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
        vim.cmd [[augroup Format]]
        vim.cmd [[autocmd! * <buffer>]]
        vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)]]
        vim.cmd [[augroup END]]
    end
end

-- pylance
configs.pylance = {
    on_attach = on_attach,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic",
                completeFunctionParens = true,
                indexing = true,
            },
        },
    },
    before_init = function(_, config)
        local stub_path = require("lspconfig/util").path.join(
            vim.fn.stdpath "data",
            "site",
            "pack",
            "packer",
            "opt",
            "python-type-stubs"
        )
        config.settings.python.analysis.stubPath = stub_path
    end,
    on_init = function(client)
        client.config.settings.python.pythonPath = utils.get_python_path(client.config.root_dir)
    end,
}

-- sumneko_lua config
configs.sumneko_lua = {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim", "use" } },
            workspace = {
                library = {
                    [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                    [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                },
                maxPreload = 10000,
            },
        },
    },
}

-- texlab config
configs.texlab = {
    flags = {
        allow_incremental_sync = false,
    },
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end,
    log_level = vim.lsp.protocol.MessageType.Log,
    message_level = vim.lsp.protocol.MessageType.Log,
    settings = {
        texlab = {
            diagnosticsDelay = 50,
            build = {
                executable = "latexmk",
                args = {
                    "-pdf",
                    "-interaction=nonstopmode",
                    "-pvc",
                    "-synctex=1",
                    "-shell-escape",
                    "%f",
                },
            },
            forwardSearch = {
                args = { "--synctex-forward", "%l:1:%f", "%p" },
                executable = "zathura",
            },
            chktex = { onOpenAndSave = true, onEdit = false },
            formatterLineLength = 120,
        },
    },
}

-- EFM config
local isort = lspconfigplus.formatters.isort.setup {}
local black = lspconfigplus.formatters.black.setup {}
local shfmt = lspconfigplus.formatters.shfmt.setup {}
local shellcheck = lspconfigplus.linters.shellcheck.setup {}
local markdownlint = lspconfigplus.linters.markdownlint.setup {}
local pandoc_markdown = lspconfigplus.formatters.pandoc_markdown.setup {}
local rst_lint = lspconfigplus.linters.rst_lint.setup {}
local pandoc_rst = lspconfigplus.formatters.pandoc_rst.setup {}
-- local cmakelang = lspconfigplus.formatters.cmakelang.setup {}
local stylua = lspconfigplus.formatters.stylua.setup {}
local flake8 = lspconfigplus.linters.flake8.setup {}

configs.efm = {
    root_dir = require("lspconfig").util.root_pattern { ".git/", "." },
    on_attach = on_attach,
    init_options = { documentFormatting = true },
    filetypes = {
        "lua",
        "python",
        "zsh",
        -- "javascript",
        "sh",
        "json",
        "yaml",
        "css",
        "html",
        "vim",
        "markdown",
        "rst",
        "tex",
    },
    settings = {
        rootMarkers = { ".git/" },
        languages = {
            rst = { rst_lint, pandoc_rst },
            python = { flake8, isort, black },
            markdown = { markdownlint, pandoc_markdown },
            lua = { stylua },
            tex = { efm_cfg.latexindent },
            sh = { shellcheck, shfmt },
            zsh = { shellcheck, shfmt },
            cmake = { efm_cfg.cmake_format },
            html = { efm_cfg.prettier },
            css = { efm_cfg.prettier },
            json = { efm_cfg.prettier },
            yaml = { efm_cfg.prettier },
        },
    },
}

configs.ltex = require "plugins.config.lsp.custom_servers.ltex"

lsp_installer.on_server_ready(function(server)
    local opts = configs[server.name] or { on_attach = on_attach }
    server:setup(opts)
end)
