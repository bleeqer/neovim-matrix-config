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

  -- 파일 매니저 (neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        window = {
          width = 40,
          position = "left",
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
      })

      -- 단축키
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle NeoTree" })
      vim.keymap.set("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus NeoTree" })

      -- nvim 시작할 때 자동 실행
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.cmd("Neotree show")
        end,
      })
    end,
  },

  -- Telescope + fzf-native
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({})
      require("telescope").load_extension("fzf")
      -- 단축키
      vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })
    end,
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- ToggleTerm
  { "akinsho/toggleterm.nvim", version = "*" },

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
-- ToggleTerm
-- ========================
require("toggleterm").setup {
  size = 15,
  open_mapping = [[<C-t>]],
  direction = "horizontal",
  start_in_insert = true,
  persist_size = true,
  close_on_exit = true,
}

-- ========================
-- Telescope
-- ========================
require("telescope").setup{}
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })

-- ========================
-- Treesitter
-- ========================
require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "cpp", "lua", "vim", "bash", "python" },
  highlight = { enable = true }
}

-- ========================
-- NvimEnter: nvim-tree, term
-- ========================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Terminal (bottom)
    vim.schedule(function()
      vim.cmd("ToggleTerm")
      vim.cmd("wincmd k")
      vim.cmd("stopinsert")
    end)
  end
})

-- ========================
-- Terminal keymaps
-- ========================
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

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
vim.api.nvim_create_user_command("Memo", function()
  vim.cmd("vnew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.bo.buflisted = false
  vim.bo.filetype = "memo"
end, {})


