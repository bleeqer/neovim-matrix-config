-- ========================
-- 기본 옵션
-- ========================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
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

  { "nvim-lualine/lualine.nvim" },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  { "akinsho/toggleterm.nvim", version = "*" },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "zbirenbaum/copilot.lua" },
    build = "make tiktoken",
    lazy = false,
    opts = {
      debug = false,
      window = {
        layout = "vertical",
        size = 0.25,
        position = "right",
      },
      mappings = {
        submit_prompt = { normal = "<CR>", insert = "<CR>" },
      },
    },
  },

  { "sindrets/winshift.nvim" }, -- 🔑 to move CopilotChat to the right

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
local function CopilotChatFunction()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()

  if not node then
    print("No syntax node at cursor")
    return
  end

  while node and node:type() ~= "function_definition" and node:type() ~= "function_declaration" do
    node = node:parent()
  end

  if not node then
    print("No function found at cursor")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local start_row, _, end_row, _ = node:range()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)

  vim.cmd("CopilotChat")

  local chat_buf = vim.api.nvim_get_current_buf()
  local last_line = vim.api.nvim_buf_line_count(chat_buf)
  vim.api.nvim_buf_set_lines(chat_buf, last_line, last_line, false, { "" })
  vim.api.nvim_buf_set_lines(chat_buf, last_line + 1, last_line + 1, false, lines)

  -- 맨 아래 + "Now my question:" + 줄 하나 더
  local line_count = vim.api.nvim_buf_line_count(chat_buf)
  vim.api.nvim_buf_set_lines(chat_buf, line_count, line_count, false, { "", "Now my question:", "" })
  vim.api.nvim_win_set_cursor(0, {line_count + 3, 0})

  -- 자동 인서트 모드 진입
  vim.cmd("startinsert")
end

-- 키맵핑: Ctrl+f
vim.keymap.set("n", "<C-f>", CopilotChatFunction, { noremap = true, silent = true })

-- ========================
-- Startup layout
-- ========================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local file_buf = nil
    for _, b in ipairs(vim.fn.getbufinfo()) do
      local name = b.name
      local is_file = (name ~= "" and vim.loop.fs_stat(name) ~= nil)
      if vim.bo[b.bufnr].buftype == "" and vim.bo[b.bufnr].buflisted and is_file then
        file_buf = b.bufnr
        break
      end
    end

    -- 1. File buffer (center anchor)
    if file_buf then
      vim.api.nvim_set_current_buf(file_buf)
    else
      vim.cmd("enew")
    end

    -- 2. File manager (left)
    vim.schedule(function()
      require("nvim-tree").setup({ view = { width = 40 } })
      require("nvim-tree.api").tree.open()
      vim.cmd("wincmd l") -- back to file
    end)

    -- 3. CopilotChat (right, moved with WinShift)
    vim.schedule(function()
      vim.cmd("CopilotChat")
      vim.cmd("WinShift far_right") -- force CopilotChat to the far right
      vim.cmd("wincmd h")           -- back to file
      vim.cmd("stopinsert")
    end)

    -- 4. Terminal (bottom)
    vim.schedule(function()
      vim.cmd("ToggleTerm")
      vim.cmd("wincmd k") -- back to file
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

