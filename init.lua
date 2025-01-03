-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local lazyvim_root = require("lazyvim.util.root")
local Path = require("plenary.path")

local function get_relative_path()
  local workspace_root = lazyvim_root.get()
  local buf_path = vim.api.nvim_buf_get_name(0)

  return Path:new(buf_path):make_relative(workspace_root)
end

local function get_relative_path_and_line()
  local relative_path = get_relative_path()
  local line = vim.fn.line(".")

  return relative_path .. ":" .. line
end

local function make_copier(getter)
  local copier = function()
    vim.fn.setreg("+", getter())
  end

  return copier
end

vim.keymap.set("n", "<Leader>pf", make_copier(get_relative_path), { noremap = true, desc = "Copy file path" })
vim.keymap.set(
  "n",
  "<Leader>pl",
  make_copier(get_relative_path_and_line),
  { noremap = true, desc = "Copy file path and line number" }
)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method("textDocument/foldingRange") then
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})
