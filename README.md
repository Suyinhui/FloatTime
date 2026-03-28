# FloatTime - 桌面浮动时间窗口

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v1.0+-green.svg)](https://www.autohotkey.com/)
[![Platform](https://img.shields.io/badge/platform-Windows-blue.svg)](https://www.microsoft.com/windows)

> 一个轻量级的桌面浮动时间工具，支持拖拽移动、透明度调节、点击穿透。

---

## ✨ 功能特性

- 🕐 **桌面浮动显示** - 始终置顶显示当前时间（HH:mm 格式）
- 🖱️ **拖拽移动** - 按住左键即可移动窗口，位置自动保存
- 🔆 **透明度调节** - 鼠标滚轮调整透明度（30%-100%）
- 🎯 **点击穿透** - 可穿透窗口操作下层程序，不影响工作
- ⌨️ **键盘微调** - 方向键精准调整窗口位置
- 💾 **位置记忆** - 自动保存窗口位置，下次启动自动恢复

---

## 🚀 快速开始

### 下载运行

1. 点击右上角 **Code** → **Download ZIP**，解压
2. 双击 `FloatTime.ahk` 即可运行（需安装 [AutoHotkey v1.0+](https://www.autohotkey.com/)）
3. 系统托盘出现绿色 **H** 图标，表示运行成功

### 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Alt+0` | 显示/隐藏窗口 |
| `右键` | 切换拖拽模式 / 点击穿透模式 |
| `左键拖拽` | 移动窗口（需拖拽模式） |
| `滚轮` | 调整透明度（需点击穿透模式） |
| `↑ ↓ ← →` | 微调窗口位置（10像素/次） |
| `Esc / 中键` | 关闭窗口 |

### 模式说明

| 模式 | 功能 |
|------|------|
| **拖拽模式** | 可按住左键移动窗口，适合调整位置 |
| **点击穿透模式** | 鼠标可穿透窗口操作下层程序，滚轮调透明度，适合全屏游戏/视频时使用 |

---

## 📸 效果预览

![1](https://github.com/Suyinhui/FloatTime/blob/main/%E6%95%88%E6%9E%9C%E9%A2%84%E8%A7%88.gif)


*（运行后效果：桌面显示一个深色半透明的时间小窗）*

---

## ⚙️ 自定义配置

用记事本打开 `FloatTime.ahk`，修改顶部配置项即可个性化：

```autohotkey
FontSize = 12                    ; 字体大小
FontColor = F9F9F9               ; 字体颜色（十六进制）
FontName = Microsoft YaHei Mono  ; 字体名称
BackgroundColor = 302E2C         ; 背景颜色（十六进制）
InitialTransparency = 200        ; 初始透明度（30-255）
WindowWidth = 65                 ; 窗口宽度
WindowHeight = 25                ; 窗口高度
RefreshInterval = 1000           ; 刷新间隔（毫秒）
```
---

## 💾 配置文件说明
运行脚本后，会自动在脚本所在目录生成 `ClockPos.ini` 文件，内容如下：


```ClockPos.ini
[Position]
X=960
Y=540
```
X - 窗口水平位置（像素）
Y - 窗口垂直位置（像素）

无需手动编辑，每次关闭窗口或拖拽结束后，位置会自动保存。下次启动时会自动恢复到上次关闭时的位置。

如果删除 ClockPos.ini 文件，下次启动会自动重新创建并使用默认位置（屏幕居中偏上）。

