# Zed 与 LazyVim 键位对齐

## 约定与范围

- Zed 启用 Vim mode，`Space` 是 leader；所有 leader 键位只在 Vim 普通/可视模式生效。
- Zed 原生会在多键序列等待时显示候选弹窗，作用相当于 WhichKey；截图中的 `g` 菜单正是
  该机制。它显示的是 Zed action 名称，不是 LazyVim 的自定义 description。
- 下表以 LazyVim 当前官方 `Keymaps` 页的默认项为基准。`已对齐` 表示按键和目标都相同，
  `近似` 表示按键保留但 Zed 的对象模型不同，`原生` 表示 Zed Vim mode 已提供同一能力，
  `无等价` 表示 Zed 没有相应的内置能力，因此不会绑定成貌似可用的空壳。
- LazyVim 的 extras 是可选插件，并非每个 LazyVim 安装都会启用；文末单列它们的处理。

## 基础、窗格与缓冲区

| LazyVim | Zed | 状态 | 说明 |
| --- | --- | --- | --- |
| `j` / `k` | `j` / `k` | 原生 | Vim navigation。 |
| `<C-h/j/k/l>` | `<C-h/j/k/l>` | 已对齐 | 左/下/上/右切换窗格。 |
| `<C-Up/Down/Left/Right>` | — | 无等价 | Zed 未提供稳定的 editor-pane resize action。 |
| `<A-j>` / `<A-k>` | `<A-j>` / `<A-k>` | 已对齐 | 下移/上移当前行或选择。 |
| `<S-h>` / `<S-l>` | `<S-h>` / `<S-l>` | 已对齐 | 前/后一个打开项。 |
| `[b` / `]b` | `[b` / `]b` | 已对齐 | 前/后一个打开项。 |
| `<leader>bb` / ``<leader>` `` | 相同 | 近似 | 切到前一个打开项；Zed 没有 Vim 的 alternate buffer。 |
| `<leader>bd` / `<leader>bD` | 相同 | 近似 | 关闭当前打开项；Zed 的 item/pane 不等同 Vim buffer/window。 |
| `<leader>bo` | 相同 | 已对齐 | 关闭其余打开项。 |
| `<leader>bi` | 相同 | 近似 | 关闭 clean items，替代“关闭不可见 buffer”。 |
| `<leader>bj` | 相同 | 已对齐 | 打开已打开文件切换器。 |
| `<Esc>` | `<Esc>` | 原生 | 退出 Vim 当前状态；Zed 不额外清理搜索高亮。 |
| `n` / `N` | `n` / `N` | 原生 | 下/上一个搜索匹配。 |
| `<C-s>` | `<Cmd-s>` | 原生 | 保存；Zed 保留系统平台快捷键。 |
| `<leader>-` / `<leader>|` | 相同 | 已对齐 | 下方 / 右侧分屏。 |
| `<leader>wd` | 相同 | 近似 | 关闭当前打开项，而非强制关闭 Vim window。 |
| `<leader>wm`、`<leader>uZ` | — | 无等价 | Zed 无 Snacks Zoom。 |
| `<leader>uz` | — | 无等价 | Zed 无 Snacks Zen。 |
| `<leader><tab>[` / `]` / `d` | 相同 | 近似 | 前/后/关闭打开项；Zed 没有 Neovim tabpage。 |

## 文件、搜索与面板

| LazyVim | Zed | 状态 | 动作 |
| --- | --- | --- | --- |
| `<leader><space>`、`<leader>ff` | 相同 | 已对齐 | 查找工作区文件。 |
| `<leader>,`、`<leader>fb`、`<leader>fB` | 相同 | 近似 | 已打开文件切换器；没有“全部 buffer”层级。 |
| `<leader>e`、`<leader>E`、`<leader>fe`、`<leader>fE` | 相同的 `e` / `E` | 近似 | 切换 Project Explorer；Zed 的 explorer 不区分 root/cwd。 |
| `<leader>fn` | 相同 | 已对齐 | 新建文件。 |
| `<leader>fF` | 相同 | 近似 | Zed file finder 是 workspace 级，不区分 cwd。 |
| `<leader>fg` | — | 无等价 | Zed 无 Git-files picker。 |
| `<leader>fr` / `<leader>fR` | — | 无等价 | Zed 无 LazyVim recent picker。 |
| `<leader>fc` | — | 无等价 | Zed 无 Neovim config picker。 |
| `<leader>fp` | — | 无等价 | Zed 无 Snacks projects picker。 |
| `<leader>/`、`<leader>sg`、`<leader>sG` | 相同 | 近似 | 打开项目搜索；Zed 不区分 root/cwd。 |
| `<leader>sb` | 相同 | 已对齐 | 当前缓冲区搜索。 |
| `<leader>sr` | 相同 | 已对齐 | 当前缓冲区搜索并打开替换。 |
| `<leader>ss` | 相同 | 近似 | 打开 Outline，替代当前文件 LSP symbols。 |
| `<leader>sS` | 相同 | 已对齐 | 工作区符号。 |
| `<leader>sd` / `<leader>sD` | 相同 | 近似 | 诊断面板；Zed 不区分工作区/当前 buffer 面板。 |
| `<leader>sc` / `<leader>sC` / `<leader>:` | 相同 | 近似 | Command Palette；Zed 不区分 command history/all commands。 |
| `<leader>sk` / `<leader>?` | 相同 | 近似 | 打开 Zed Keymap，而非当前 buffer 的 WhichKey。 |
| `<leader>s\"`、`s/`、`sa`、`sh`、`sH`、`si`、`sj`、`sl`、`sm`、`sM`、`sp`、`sq`、`sR`、`su`、`sw`、`sW` | — | 无等价 | 这些是 Snacks picker 数据源。 |
| `<leader>w o` | `Space w o` | Zed 扩展 | 收起/恢复所有停靠面板，便于专注编辑。 |

## 代码、LSP、诊断与 Git

| LazyVim | Zed | 状态 | 动作 |
| --- | --- | --- | --- |
| `gd` / `gD` / `gI` / `gy` | 相同 | 原生 | 定义 / 声明 / 实现 / 类型定义。 |
| `gr` | 相同 | 已对齐 | 查找引用。 |
| `K` | `K` | 原生 | Hover。 |
| `gK` | 相同 | 已对齐 | Signature Help。 |
| `<leader>ca` | 相同 | 已对齐 | Code Action。 |
| `<leader>cr` | 相同 | 已对齐 | Rename symbol。 |
| `<leader>cf` | 相同 | 已对齐 | Format。 |
| `<leader>cd` | 相同 | 已对齐 | 当前行诊断。 |
| `<leader>co` | 相同 | 已对齐 | Organize Imports。 |
| `]d` / `[d` | 相同 | 已对齐 | 下/上一个诊断。 |
| `]e` / `[e` | 相同 | 近似 | 下/上一个诊断；Zed 没有按 error severity 跳转的公开 action。 |
| `]w` / `[w` | — | 无等价 | Zed 没有按 warning severity 跳转的公开 action。 |
| `]]` / `[[`、`<A-n>` / `<A-p>` | — | 无等价 | Zed 无 LSP reference-cycle action。 |
| `<leader>cl`、`cc`、`cC`、`cR`、`cA` | — | 无等价 | LSP Info、CodeLens、Rename File、Source Action 是 LazyVim/LSP 插件层能力。 |
| `gai` / `gao` | — | 无等价 | Zed 无调用层级 picker。 |
| `<leader>gg` / `<leader>gs` | 相同 | 近似 | 打开 Git Panel，替代 LazyGit/Git Status。 |
| `<leader>gL`、`gb`、`gf`、`gl`、`gB`、`gY`、`gd`、`gD`、`gi`、`gI`、`gp`、`gP`、`gS` | — | 无等价 | 这些依赖 LazyGit、Snacks Git picker 或 GitHub integration。 |
| `<leader>xx` / `<leader>xX` | 相同 | 近似 | 打开 diagnostics；Zed 无 Trouble 的 buffer-only view。 |
| `<leader>xl`、`xq`、`xL`、`xQ`、`[q`、`]q` | — | 无等价 | Zed 无 Vim location list/quickfix/Trouble。 |

## 终端、UI 与 LazyVim 专属项

| LazyVim | Zed | 状态 | 动作 |
| --- | --- | --- | --- |
| `<leader>ft` / `<leader>fT` | 相同 | 近似 | 切换 Zed integrated terminal；Zed 不区分 root/cwd 浮动终端。 |
| `<C-/>` | 相同 | 近似 | 在 Vim normal 或 terminal 中切换 integrated terminal。 |
| `<leader>ub` | 相同 | 近似 | 切换主题明暗，替代 `background`。 |
| `<leader>uf`、`uF`、`us`、`uw`、`uL`、`ud`、`ul`、`uc`、`uA`、`uT`、`uD`、`ua`、`ug`、`uS`、`uh` | — | 无等价 | 这些是 Neovim/Snacks option toggles；应在 Zed Settings 中配置。 |
| `<leader>ur`、`ui`、`uI` | — | 无等价 | Neovim redraw/inspect。 |
| `<leader>qq`、`qd`、`ql`、`qs`、`qS` | — | 无等价 | Zed 没有 Persistence session 对等物。 |
| `<leader>l` / `<leader>L` / `<leader>cm` | — | 无等价 | Lazy/Mason/LazyVim 维护操作。 |
| `<leader>.` / `<leader>S` | — | 无等价 | Snacks scratch buffer。 |
| `gco` / `gcO` | — | 无等价 | Zed Vim 原生支持 `gcc`/`gc`，但没有 LazyVim 的上下插入 comment helper。 |
| Flash、Noice、Grug-far、Todo-comments、Bufferline、Conform 的其余映射 | — | 无等价 | 插件能力，不应映射成普通 Zed action。 |
| Avante、Claude Code、CopilotChat、Sidekick 等 AI extras | `Space a a` | 近似 | 切换 Zed Agent；各 AI 插件的会话、provider、diff 操作无一对一映射。 |

## Zed 侧新增但有意保留的助记键

`Space w h/j/k/l` 是对 `<C-h/j/k/l>` 的 leader 版本，`Space w s/v` 是下方/右侧分屏，
`Space w o` 收起所有 docks。这些不是 LazyVim 默认项，但与其 window 分组一致；保留它们能让
Zed 的弹窗在 `Space w` 下形成完整、可发现的窗格操作菜单。

若 Zed 更新后某个键位不触发，可在命令面板打开 `dev: open key context view` 确认当前 context，
并在 `zed: open keymap` 中检查冲突。
