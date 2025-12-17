-- Minimal Neovim Configuration
-- Sources shared vim settings and adds neovim-specific options

-- Load vimrc for shared settings
vim.cmd('source ~/.vimrc')

-- Neovim-specific settings
vim.opt.termguicolors = true      -- True color support
vim.opt.updatetime = 250          -- Faster completion
vim.opt.timeoutlen = 300          -- Faster key sequence completion
vim.opt.signcolumn = "yes"        -- Always show sign column
vim.opt.undofile = true           -- Persistent undo

-- Better completion experience
vim.opt.completeopt = { "menuone", "noselect" }

-- Disable some built-in plugins we don't need
local disabled_plugins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
}

for _, plugin in pairs(disabled_plugins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})
