

-- TODO: kitty_window_id没用



-- https://gist.github.com/galaxia4Eva/9e91c4f275554b4bd844b6feece16b3d
return function(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN, kitty_window_id)
  -- local kitty_window_id = vim.loop.os_getenv("KITTY_WINDOW_ID")

  -- local kitty_window_id = vim.loop.os_getenv("KITTY_PID")
  -- 构建 lockfile 路径
  -- local lockfile_path = vim.fn.stdpath('state') .. '/' .. kitty_window_id .. '_kitty_page.lock'
  local lockfile_path = vim.fn.stdpath('state') .. '/kitty_page.lock'

  -- 检查lock文件是否存在
  if vim.loop.fs_stat(lockfile_path) then
    vim.cmd "quit!"
  end

  -- 创建lock文件
  local lockfile = vim.loop.fs_open(lockfile_path, "w", 438)
  if lockfile then
    vim.loop.fs_write(lockfile, "lock", -1)
    vim.loop.fs_close(lockfile)
  end

  print('kitty sent:', INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN, kitty_window_id)
  vim.opt.encoding='utf-8'
  vim.opt.clipboard = 'unnamed'
  vim.opt.compatible = false
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.termguicolors = true
  vim.opt.showmode = false
  vim.opt.ruler = false
  vim.opt.laststatus = 0
  vim.o.cmdheight = 0
  vim.opt.showcmd = false
  vim.opt.scrollback = INPUT_LINE_NUMBER + CURSOR_LINE
  -- vim.opt.virtualedit = "block"
  vim.opt.virtualedit = "all"

  -- 设置背景为透明
  vim.cmd([[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight NonText guibg=NONE ctermbg=NONE
  ]])

  local term_buf = vim.api.nvim_create_buf(true, false);
  local term_io = vim.api.nvim_open_term(term_buf, {})
  vim.api.nvim_buf_set_keymap(term_buf, 'n', 'q', '<Cmd>q<CR>', { })
  vim.api.nvim_buf_set_keymap(term_buf, 'x', 'q', '<Cmd>q<CR>', { })
  vim.api.nvim_buf_set_keymap(term_buf, 'n', '<ESC>', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 'i', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 'i', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 'I', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 'I', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 'a', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 'a', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 'A', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 'A', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 's', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 's', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'n', 'S', '<Cmd>q<CR>', { })
  -- vim.api.nvim_buf_set_keymap(term_buf, 'x', 'S', '<Cmd>q<CR>', { })
  -- 交换 / 和 ?
  vim.api.nvim_set_keymap('n', '/', '?', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '?', '/', { noremap = true, silent = true })
  local group = vim.api.nvim_create_augroup('kitty+page', {})

  local setCursor = function()
    vim.api.nvim_feedkeys(tostring(INPUT_LINE_NUMBER) .. [[ggzt]], 'n', true)
    local line = vim.api.nvim_buf_line_count(term_buf)
    if (CURSOR_LINE <= line) then
      line = CURSOR_LINE
    end
    vim.api.nvim_feedkeys(tostring(line - 1) .. [[j]], 'n', true)
    vim.api.nvim_feedkeys([[0]], 'n', true)
    vim.api.nvim_feedkeys(tostring(CURSOR_COLUMN - 1) .. [[l]], 'n', true)
  end

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    buffer = term_buf,
    callback = function()
      local mode = vim.fn.mode()
      if mode == 't' then
        vim.cmd.stopinsert()
        vim.schedule(setCursor)
      end
    end,
  })

  vim.api.nvim_create_autocmd('QuitPre', {
    pattern = '*',
    callback = function()
      vim.loop.fs_unlink(lockfile_path)
    end
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    pattern = '*',
    once = true,
    callback = function(ev)
        local current_win = vim.fn.win_getid()
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, 0, -2, false)) do
          vim.api.nvim_chan_send(term_io, line)
          vim.api.nvim_chan_send(term_io, '\r\n')
        end
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, -2, -1, false)) do
          vim.api.nvim_chan_send(term_io, line)
        end
        vim.api.nvim_win_set_buf(current_win, term_buf)
        vim.api.nvim_buf_delete(ev.buf, { force = true } )
        vim.schedule(setCursor)
    end
  })
end
