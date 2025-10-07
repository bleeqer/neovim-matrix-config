
-- ========================
-- 기본 옵션
-- ========================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.splitright = true     
vim.g.clipboard = {
  name = "xclip",
  copy = {
    ["+"] = "xclip -selection clipboard",
    ["*"] = "xclip -selection primary",
  },
  paste = {
    ["+"] = "xclip -selection clipboard -o",
    ["*"] = "xclip -selection primary -o",
  },
  cache_enabled = 0,
}
-- ========================
-- lazy.nvim 설치 확인
-- ========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================
-- 플러그인 목록
-- ========================
require("lazy").setup({
{
  -- 상태바
  "nvim-lualine/lualine.nvim",

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Tabout
  {
    "abecodes/tabout.nvim",
    dependencies = { "nvim-treesitter", "nvim-cmp" },
    config = function()
      require("tabout").setup({
        tabkey = "<Tab>",
        backwards_tabkey = "<S-Tab>",
        act_as_tab = true,
        enable_backwards = true,
        completion = false,
      })
    end,
  },

  -- 자동완성
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Surround
  { "kylechui/nvim-surround", version = "*" },

  -- Comment
  { "numToStr/Comment.nvim", opts = {} },

  -- Indent 가이드
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- 색상 하이라이트
  { "norcalli/nvim-colorizer.lua" },

  -- 심볼 아웃라인
  { "simrat39/symbols-outline.nvim" },

  -- Notify
  { "rcarriga/nvim-notify" },

  -- HTML/XML 자동 태그 닫기
  { "windwp/nvim-ts-autotag", opts = {} },

}
})

-- ========================
-- 해커 테마
-- ========================
vim.cmd("highlight Normal guibg=#000000 guifg=#00FF00")
vim.cmd("highlight LineNr guifg=#008800")
vim.cmd("highlight CursorLine guibg=#001100")
vim.cmd("highlight StatusLine guibg=#000000 guifg=#00FF00")
vim.cmd("highlight VertSplit guibg=#000000 guifg=#00AA00")
vim.cmd("highlight Comment guifg=#00AA00")
vim.cmd("highlight Constant guifg=#55FF55")
vim.cmd("highlight String guifg=#22FF22")
vim.cmd("highlight Identifier guifg=#33FF33")
vim.cmd("highlight Function guifg=#66FF66 gui=bold")
vim.cmd("highlight Statement guifg=#00FF88 gui=bold")
vim.cmd("highlight Keyword guifg=#00FFAA gui=bold")
vim.cmd("highlight Type guifg=#00FF44")
vim.cmd("highlight Special guifg=#00FF77")

-- ========================
-- Lualine
-- ========================
require("lualine").setup {
  options = {
    theme = "auto",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  }
}

-- ========================
-- Treesitter
-- ========================
require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "cpp", "lua", "vim", "bash", "python" },
  highlight = { enable = true }
}
local cmp = require('cmp')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
 mapping = cmp.mapping.preset.insert({   
    ['<CR>'] = cmp.mapping.confirm({select = true}),
  })
})
-- ========================
-- NvimEnter: nvim-tree, term
-- ========================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Terminal (bottom)
    vim.schedule(function()
      vim.cmd("wincmd k")
      vim.cmd("stopinsert")
    end)
  end
})
-- ========================
-- Cleanup quit
-- ========================
local function cleanup_and_quit()
  vim.cmd("wall")
  pcall(vim.cmd, "NvimTreeClose")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      local ok, jobid = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
      if ok and type(jobid) == "number" then
        pcall(vim.fn.jobstop, jobid)
      end
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  vim.cmd("qa")
end

vim.api.nvim_create_user_command("Xa", cleanup_and_quit, {})
vim.cmd([[
  cnoreabbrev <expr> xa   (getcmdtype() == ':' && getcmdline() ==# 'xa')   ? 'Xa' : 'xa'
  cnoreabbrev <expr> wqa  (getcmdtype() == ':' && getcmdline() ==# 'wqa')  ? 'Xa' : 'wqa'
]])


-- ========================
-- Memo buffer (scratchpad)
-- ========================
local memo_bufnr = nil
local memo_file = vim.fn.stdpath("config") .. "/memo.md"

-- 메모 열기
local function open_memo()
  if memo_bufnr and vim.api.nvim_buf_is_valid(memo_bufnr) then
    local win = vim.fn.bufwinid(memo_bufnr)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- 파일로 열기 (이제 buftype=normal)
  vim.cmd("vnew " .. memo_file)
  memo_bufnr = vim.api.nvim_get_current_buf()

  vim.bo[memo_bufnr].swapfile = false
  vim.bo[memo_bufnr].buflisted = false
  vim.bo[memo_bufnr].filetype = "markdown"

  -- 자동 저장
  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    buffer = memo_bufnr,
    callback = function()
      if vim.api.nvim_buf_is_valid(memo_bufnr) then
        vim.api.nvim_buf_call(memo_bufnr, function()
          vim.cmd("silent write! " .. memo_file)
        end)
      end
    end,
  })
end


-- 메모 닫기
local function close_memo()
  if memo_bufnr and vim.api.nvim_buf_is_valid(memo_bufnr) then
    local win = vim.fn.bufwinid(memo_bufnr)
    if win ~= -1 then
      vim.api.nvim_win_close(win, true)
    end
    memo_bufnr = nil
  end
end

-- 토글
local function toggle_memo()
  if memo_bufnr and vim.api.nvim_buf_is_valid(memo_bufnr) then
    local win = vim.fn.bufwinid(memo_bufnr)
    if win ~= -1 then
      close_memo()
      return
    end
  end
  open_memo()
end

-- Ctrl+m 으로 토글
vim.keymap.set("n", "<C-n>", toggle_memo, { desc = "Toggle memo buffer" })


