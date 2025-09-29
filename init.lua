-- =============
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
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ========================
-- 플러그인 목록
-- ========================
require("lazy").setup({
  { "nvim-lualine/lualine.nvim" }, -- 상태라인
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- 파일 탐색기
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } }, -- Fuzzy Finder
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- 문법 하이라이트
  { "akinsho/toggleterm.nvim", version = "*" }, -- 터미널
})

-- ========================
-- 해커 테마 (네온 초록)
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
-- NvimTree
-- ========================


-- ========================
-- ToggleTerm (터미널)
-- ========================
require("toggleterm").setup {
  size = 15,
  open_mapping = [[<leader>t]], -- 스페이스+t
  direction = "horizontal",
  start_in_insert = true,
  persist_size = true,
  close_on_exit = true,
}

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local file_buf = nil
    local bufs = vim.fn.getbufinfo()
    for _, b in ipairs(bufs) do
      local name = b.name
      local is_file = (name ~= "" and vim.loop.fs_stat(name) ~= nil)
      if vim.bo[b.bufnr].buftype == "" and vim.bo[b.bufnr].buflisted and is_file then
        file_buf = b.bufnr
        vim.api.nvim_out_write("Detected file buffer: " .. name .. "\n")
        break
      end
    end

    vim.cmd("ToggleTerm")
    require("nvim-tree").setup({
      view = { width = 40 },
    })
    require("nvim-tree.api").tree.open()

    if file_buf then
      vim.schedule(function()
        vim.api.nvim_set_current_buf(file_buf)
        -- schedule 한 번 더 감싸서 확실히 이동
        vim.schedule(function()
          vim.cmd("stopinsert | normal! G")
        end)
      end)
    end
  end
})

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
  highlight = { enable = false }
}

-- 터미널 모드에서 ESC 누르면 normal 모드 전환
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- 모든 버퍼 저장 + 특수 버퍼 정리 + 종료
local function cleanup_and_quit()
  -- 1) 저장 가능한 버퍼 전부 저장
  vim.cmd("wall")

  -- 2) nvim-tree 닫기
  pcall(vim.cmd, "NvimTreeClose")

  -- 3) 터미널 job 정리
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "terminal" then
      local ok, jobid = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
      if ok and type(jobid) == "number" then
        pcall(vim.fn.jobstop, jobid)
      end
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end

  -- 4) 종료
  vim.cmd("qa")
end

-- 안전 종료 명령 정의
vim.api.nvim_create_user_command("Xa", cleanup_and_quit, {})

-- 빌트인 명령어 치환 (:xa, :wqa, :qa)
vim.cmd([[
  cnoreabbrev <expr> xa   (getcmdtype() == ':' && getcmdline() ==# 'xa')   ? 'Xa' : 'xa'
  cnoreabbrev <expr> wqa  (getcmdtype() == ':' && getcmdline() ==# 'wqa')  ? 'Xa' : 'wqa'
D]])
