My Neovim config
=================

我的个人neovim配置，初始模版来自[Nvchad](https://nvchad.com)

![预览](example.png)


[[toc]]

## 配置参考

- [BrunoKrugel/dotfiles](https://github.com/BrunoKrugel/dotfiles/blob/master/lua/)
- [kickstart](https://github.com/nvim-lua/kickstart.nvim/tree/master/lua/kickstart)
- [Lazyvim](http://www.lazyvim.org/plugins) 
- [corintho/nvchad-custom](https://github.com/corintho/nvchad-custom/tree/main/lua)
- [mgastonportillo/nvchad-config](https://github.com/mgastonportillo/nvchad-config/blob/main/lua/)
- [kiyoon/dotfiles](https://github.com/kiyoon/dotfiles/tree/master/nvim)
- [yutkat/dotfiles](https://github.com/yutkat/dotfiles/blob/main/.config/nvim/lua/rc/pluginlist.lua)
- [nvchad](https://github.com/NvChad/NvChad)
- [Reddit社区](https://www.reddit.com/r/neovim/)
- Stackoverflow 
- [dotfyle](https://dotfyle.com/) 

## 目录结构

```text




```

## 整合

- [x] Neovide
- [ ] WSL环境
- [x] kitty


## 插件列表


### 核心功能增强

- trouble
- nvim-bqf 为quickfix提供一个小的快速预览窗口，类似vscode
- marks 可视化marks
- ufo 代码fold增强
- nvim-surround
- winresize.nvim 更符合逻辑的窗口resize

### AI

- Avante 提供类似cursor编辑器体验的ai工具
- Copilot 

### Debug

- dap
- dapui
- nvim-dap-virtual-text
- mason-nvim-dap.nvim

### Markdown

- image.nvim 显示图片
- markdown-preview.nvim
- markdown-render.nvim
- ~~markview.nvim~~

### 编辑增强

- flash.nvim
- treej 智能join和split代码的插件

### Session 管理

- persists 

### UI 优化相关
- bg.nvim
- treesitter-textobject-context
- dressing
- noice

### Git
- lazygit

### 其他
- pomo
- todo-comments
- icon-picker.nvim
- twilight
- obsidian 
- showkeys 显示按键
- codesnap.nvim 代码截图 
- clipboard-history 非常轻量级的剪贴板历史


## ✅ Todo

- [ ] tailwindcss支持
- [x] 配置bash lsp识别zshrc
- [ ] 可视化jumplist
- [ ] 使用commander并把一些小工具放在那里
- [ ] 调整nvim-tree快捷键
- [ ] telescope 批量删除buffers
- [ ] 优化luasnip（友好的node可视化、模式切换后的jumpnode保留）
- [ ] macro插件
- [ ] 优化markdown heading bg高亮（在有些深色主题中太亮了）
- [ ] 宏插件
- [ ] 添加Markdown局部快捷键（render，preview，生成语法等）
- [ ] 更详尽的 LSP 配置
  - [x] go
  - [x] python
  - [ ] js/ts
  - [ ] c/cpp
  - [x] bash
  - [ ] SQL
- [ ] 集成 Copilot
- [ ] ~~命令行补全替换成nvim-cmp~~
- [ ] Jupyter 支持
- [ ] 添加更多git功能 (nvim/lua/plugins/init.lua中注释部分)
  - [ ] neogit
  - [ ] git-conflict.nvim
  - [ ] diffview.nvim
- [ ] 添加操作数据库功能
- [ ] 配置Neotest
- [ ] 为常用语言配置Debug
  - [x] go
  - [ ] python
  - [ ] js/ts
  - [ ] c/cpp
  - [ ] bash
  - [x] 完善Icon
  - [x] 启动时的延迟问题
  - [x] 分组
- [ ] Nvcheatsheet
- [ ] Latex snippets
- [ ] 尝试yanky
- [ ] 更好的menu（Hover、CodeAction等）
- [ ] 快捷键或Snippet添加TODO
- [ ] 添加一些自己常用的snippets
- [ ] 添加查看noice 消息的功能
- [ ] 添加部分格式化功能
- [ ] 插件分类
- [ ] 分离核心组件和额外的模块
- [ ] 使用自动配置lsp的插件
- [x] Obsidian支持
- [x] 图片支持
- [x] 完善插件lazyload配置
- [x] 优化按键映射，使用Lazyvim风格
- [x] Debug 功能
- [x] 更多 UI 优化
- [x] 优化Avante配置
- [x] 尝试zen mode插件（忘记名字了）
- [x] 代码fold插件
- [x] 默认打开dashboard
- [x] 完善Which key配置
- [x] 修复Flash高亮
- [x] 为noice添加更多routes


## 🐞FIXME

- [x] 复制高亮的autocmd不起作用
- [x] markdown-render 的标题不能正确渲染
- [x] http treesitter 高亮不工作
- [ ] kulala创建response结果窗口后，如果想关闭它，会导致bufline的错误
- [x] 有未保存的buffer时，自动关闭nvim-tree的autocmd会报错
- [ ] neovim刚进入时如果lazy.nvim自动打开安装插件的窗口，会报错
- [ ] cmp补全时的文档不会被渲染，可能是filetype原因


## 插件
- [How to write neovim plugins in Lua](https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua) 
取消colorizer插件的颜色高亮
