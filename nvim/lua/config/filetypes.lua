-- helm-ls.nvim tags every templates/*.yml as helm, which makes GitLab CI
-- template repos fail against the Kubernetes schema. Only trust it when a
-- Chart.yaml sits above the file. Keys differ from the plugin's so its ftdetect
-- cannot overwrite these.
local function helm_if_chart(chart_ft, plain_ft)
  return function(path)
    if vim.fs.root(path, { "Chart.yaml", "Chart.yml" }) then
      return chart_ft
    end
    return plain_ft
  end
end

vim.filetype.add({
  pattern = {
    [".*/templates/.+%.ya?ml"] = { helm_if_chart("helm", "yaml"), { priority = 10 } },
    [".*/templates/.+%.tpl"] = { helm_if_chart("helm", "smarty"), { priority = 10 } },
    [".*/templates/.+%.txt"] = { helm_if_chart("helm", "text"), { priority = 10 } },
    ["values.-%.ya?ml"] = { helm_if_chart("yaml.helm-values", "yaml"), { priority = 10 } },
  },
})
