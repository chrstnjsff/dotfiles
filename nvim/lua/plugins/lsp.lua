return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            if config.settings.python.pythonPath then
              return
            end
            local environments = {}
            if vim.env.VIRTUAL_ENV then
              environments[#environments + 1] = vim.env.VIRTUAL_ENV
            end
            if config.root_dir then
              for _, name in ipairs({ ".venv", "venv" }) do
                environments[#environments + 1] = vim.fs.joinpath(config.root_dir, name)
              end
            end
            for _, environment in ipairs(environments) do
              local python = vim.fs.joinpath(environment, "bin", "python")
              if vim.fn.executable(python) == 1 then
                config.settings.python.pythonPath = python
                return
              end
            end
          end,
        },
        -- OpenTofu, not Terraform: tofu-ls wants tofu, terraform-ls wants a terraform binary
        terraformls = { enabled = false },
        tofu_ls = {},
        bashls = {},
        -- otherwise it formats PHP on save as the fallback when pint is skipped
        intelephense = { settings = { intelephense = { format = { enable = false } } } },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      -- the terraform extra lints with `terraform validate`, which needs a terraform binary
      opts.linters_by_ft.terraform = { "tflint" }
      opts.linters_by_ft.tf = { "tflint" }
    end,
  },
}
