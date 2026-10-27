-- GitLens-style blame: the author, how long ago, and the commit message of the
-- current line, shown at the end of the line. Space u B turns it off and on.
-- For more: Space g h b (full commit for this line), Space g h B (whole file).
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = { delay = 300 },
  },
  keys = {
    { "<leader>uB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Line Blame" },
  },
}
