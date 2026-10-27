local prettier_has_config = LazyVim.memoize(function(filename)
  vim.fn.system({ "prettier", "--find-config-path", filename })
  return vim.v.shell_error == 0
end)

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "yamlfmt" }, -- Replace default with K8s-friendly formatter
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        python = { "isort", "black" },
        php = { "pint" },
        blade = { "blade-formatter" },
        -- tofu instead of the LazyVim default terraform_fmt, no terraform binary here
        terraform = { "tofu_fmt" },
        tf = { "tofu_fmt" },
        ["terraform-vars"] = { "tofu_fmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      formatters = {
        -- Next.js repos here have no Prettier config and no semicolons; defaults would
        -- rewrite nearly every file, so they fall back to the LSP formatter instead
        prettier = {
          condition = function(_, ctx)
            return prettier_has_config(ctx.filename)
          end,
        },
        -- only run Pint where a project opts in with a pint.json
        pint = {
          condition = function(_, ctx)
            return vim.fs.root(ctx.filename, "pint.json") ~= nil
          end,
        },
        yamlfmt = {
          -- the built-in args keep "-", so yamlfmt formats this buffer, not the whole folder.
          -- indentless lists (as kubectl writes them) only for k8s manifests: GitLab CI and
          -- compose files use indented lists, and the flag would rewrite every list in them
          prepend_args = function(_, ctx)
            local opts = "retain_line_breaks_single=true"
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, 30, false)) do
              if line:match("^apiVersion:") then
                opts = opts .. ",indentless_arrays=true"
                break
              end
            end
            return { "-formatter", opts }
          end,
        },
      },
    },
  },
  -- Mason installs the formatters itself, so they work without Homebrew
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "yamlfmt", "prettier", "black", "isort", "pint", "blade-formatter" } },
  },
}
