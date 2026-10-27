-- Keep foldmethod = "manual" (options.lua) in every file: LazyVim otherwise
-- switches to Tree-sitter or LSP folds in any buffer that supports them.
return {
  { "nvim-treesitter/nvim-treesitter", opts = { folds = { enable = false } } },
  { "neovim/nvim-lspconfig", opts = { folds = { enabled = false } } },
}
