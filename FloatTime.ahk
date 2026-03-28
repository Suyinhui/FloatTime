; ============================================
; FloatTime
; 浮动时间窗口 - 桌面时间工具
; ============================================
; 【功能说明】
; 1. 在桌面显示一个浮动的时间窗口（HH:mm格式）
; 2. 支持拖拽移动窗口位置（可记忆）
; 3. 支持鼠标滚轮调整窗口透明度
; 4. 支持点击穿透模式（滚轮调透明度时不会干扰下层窗口）
; 5. 自动保存窗口位置，下次启动自动恢复
;
; 【快捷键】
; Alt+0          - 显示/隐藏时间窗口
; 右键单击窗口    - 切换拖拽模式/点击穿透模式
; 左键按住拖动    - 移动窗口位置（需在拖拽模式下）
; 鼠标滚轮        - 调整透明度（需在点击穿透模式下）
; 方向键↑↓←→     - 微调窗口位置（1像素/10像素）
; Esc / 鼠标中键  - 关闭窗口并保存位置
;
; 【使用场景】
; - 全屏游戏/视频时查看时间（点击穿透模式，鼠标可穿透窗口）
; - 多显示器环境，将时间放在副屏
; - 需要随时看时间的任何场景
;
; 【待完善】拖拽功能不跟手
;
; ============================================
; 【作者】Suyinhui提供想法及测试，KIMI、Deepseek提供代码支持
; 【版本】v1.0 
; ============================================


#SingleInstance Force
#NoEnv
SetBatchLines -1

; ========== 配置文件 ==========
; 窗口位置保存在脚本同目录下的 ClockPos.ini 文件中
ConfigFile := A_ScriptDir "\ClockPos.ini"

; ========== 外观配置（可自行修改） ==========
FontSize = 12                    ; 字体大小
FontColor = F9F9F9               ; 字体颜色（浅灰）
FontName = Microsoft YaHei Mono  ; 字体名称（微软雅黑等宽）
BackgroundColor = 302E2C         ; 背景颜色（深灰色）
InitialTransparency = 200        ; 初始透明度（0=全透明，255=不透明）
WindowWidth = 65                 ; 窗口宽度
WindowHeight = 25                ; 窗口高度
RefreshInterval = 1000           ; 时间刷新间隔（毫秒）

; ========== 全局变量 ==========
global TimeGuiHwnd               ; 窗口句柄
global IsVisible := false        ; 窗口是否可见
global CurrentTransparency       ; 当前透明度
global DragEnabled := false      ; 拖拽模式是否启用
global WinX, WinY                ; 窗口位置坐标
global Dragging := false         ; 是否正在拖拽
global DragStartX, DragStartY    ; 拖拽起始鼠标坐标
global DragWinX, DragWinY        ; 拖拽起始窗口坐标

CurrentTransparency := InitialTransparency

; ========== 读取上次保存的位置 ==========
IniRead, SavedX, %ConfigFile%, Position, X, %A_Space%
IniRead, SavedY, %ConfigFile%, Position, Y, %A_Space%

if (SavedX = "" || SavedY = "") {
    ; 首次运行，默认位置：屏幕居中偏上
    SysGet, ScreenWidth, 0
    SysGet, ScreenHeight, 1
    WinX := (ScreenWidth - WindowWidth) // 2
    WinY := ScreenHeight // 6
} else {
    WinX := SavedX
    WinY := SavedY
}

; ========== 热键 ==========
!0::ToggleTimeWindow()   ; Alt+0 显示/隐藏窗口

; ========== 主函数：显示/隐藏窗口 ==========
ToggleTimeWindow()
{
    global IsVisible, TimeGuiHwnd
    if (IsVisible) {
        ; 隐藏窗口
        SavePosition()
        Gui, TimeWindow:Destroy
        IsVisible := false
        SetTimer, UpdateTime, Off
        ToolTip, 时间窗口已关闭
        SetTimer, RemoveToolTip, -1000
    } else {
        ; 显示窗口
        CreateTimeWindow()
        IsVisible := true
        ToolTip, 时间窗口已显示`n右键切换拖拽模式
        SetTimer, RemoveToolTip, -2000
    }
    return
}

; ========== 保存窗口位置到配置文件 ==========
SavePosition()
{
    global TimeGuiHwnd, WinX, WinY, ConfigFile
    if (!TimeGuiHwnd)
        return
    WinGetPos, CurrX, CurrY,,, ahk_id %TimeGuiHwnd%
    IniWrite, %CurrX%, %ConfigFile%, Position, X
    IniWrite, %CurrY%, %ConfigFile%, Position, Y
    WinX := CurrX
    WinY := CurrY
    return
}

; ========== 创建时间窗口 ==========
CreateTimeWindow()
{
    global TimeGuiHwnd, CurrentTransparency
    global FontSize, FontColor, FontName, BackgroundColor, WindowWidth, WindowHeight
    global WinX, WinY

    ; 创建窗口：置顶、无标题栏、工具窗口、无系统菜单
    Gui, TimeWindow:New, +AlwaysOnTop -Caption +ToolWindow -SysMenu +LastFound
    TimeGuiHwnd := WinExist()
    
    ; 设置背景色和透明度
    Gui, TimeWindow:Color, %BackgroundColor%
    WinSet, Transparent, %CurrentTransparency%, ahk_id %TimeGuiHwnd%

    ; 添加时间文本
    Gui, TimeWindow:Font, s%FontSize% c%FontColor%, %FontName%
    timeStr := GetCurrentTime()
    textHeight := FontSize * 15 // 10
    yOffset := (WindowHeight - textHeight) // 2
    Gui, TimeWindow:Add, Text, x0 y%yOffset% w%WindowWidth% h%textHeight% Center, %timeStr%
    
    ; 添加透明度提示文本（初始隐藏，调整透明度时短暂显示）
    Gui, TimeWindow:Font, s12 cFFFFFF
    Gui, TimeWindow:Add, Text, x10 y55 w100 Hidden, 透明度: %CurrentTransparency%

    ; 显示窗口
    Gui, TimeWindow:Show, x%WinX% y%WinY% w%WindowWidth% h%WindowHeight% NoActivate, FloatingClock
    
    ; 启动时间更新定时器
    SetTimer, UpdateTime, %RefreshInterval%
    return
}

; ========== 更新时间显示 ==========
UpdateTime:
{
    global TimeGuiHwnd
    if (!TimeGuiHwnd || !WinExist("ahk_id " . TimeGuiHwnd))
        return
    newTime := GetCurrentTime()
    ; Static1 是第一个 Text 控件的默认类名
    ControlSetText, Static1, %newTime%, ahk_id %TimeGuiHwnd%
    return
}

; ========== 获取当前时间（HH:mm格式） ==========
GetCurrentTime()
{
    FormatTime, CurrentTime,, HH:mm
    return CurrentTime
}

; ========== 调整窗口透明度 ==========
AdjustTransparency(delta)
{
    global TimeGuiHwnd, CurrentTransparency
    if (!TimeGuiHwnd || !WinExist("ahk_id " . TimeGuiHwnd))
        return
    
    CurrentTransparency += delta
    ; 限制透明度范围 30-255（太透明会看不见）
    if (CurrentTransparency > 255)
        CurrentTransparency := 255
    if (CurrentTransparency < 30)
        CurrentTransparency := 30
    
    WinSet, Transparent, %CurrentTransparency%, ahk_id %TimeGuiHwnd%
    
    ; 显示透明度百分比提示
    Percent := Round(CurrentTransparency/255*100)
    ControlSetText, Static2, 透明度: %Percent%`%, ahk_id %TimeGuiHwnd%
    Control, Show,, Static2, ahk_id %TimeGuiHwnd%
    SetTimer, HideAlphaText, -1500
    return
}

; ========== 隐藏透明度提示 ==========
HideAlphaText:
    global TimeGuiHwnd
    Control, Hide,, Static2, ahk_id %TimeGuiHwnd%
    return

; ========== 滚轮调整透明度（仅在点击穿透模式下生效） ==========
#IfWinActive ahk_class AutoHotkeyGUI
WheelUp::
    AdjustTransparency(10)
    return
WheelDown::
    AdjustTransparency(-10)
    return
#IfWinActive

; ========== 切换拖拽模式 / 点击穿透模式 ==========
ToggleDrag()
{
    global TimeGuiHwnd, DragEnabled
    if (!TimeGuiHwnd)
        return
    
    DragEnabled := !DragEnabled
    
    if (DragEnabled) {
        ; 拖拽模式：移除点击穿透样式，窗口可被拖动
        WinSet, ExStyle, -0x20, ahk_id %TimeGuiHwnd%
        ToolTip, 拖拽模式: 启用`n按住左键拖动窗口`n右键切换模式
        SetTimer, RemoveToolTip, -2000
    } else {
        ; 点击穿透模式：添加点击穿透样式，鼠标可穿透窗口操作下层程序
        WinSet, ExStyle, +0x20, ahk_id %TimeGuiHwnd%
        ToolTip, 点击穿透模式: 启用`n鼠标滚轮调透明度`n右键切换模式
        SetTimer, RemoveToolTip, -2000
    }
    return
}

RemoveToolTip:
    ToolTip
    return

; ========== 拖拽功能（使用定时器，流畅移动） ==========
#If DragEnabled
LButton::
{
    if (!WinActive("ahk_id " . TimeGuiHwnd))
        return
    
    ; 记录拖拽起始位置
    MouseGetPos, DragStartX, DragStartY
    WinGetPos, DragWinX, DragWinY,,, ahk_id %TimeGuiHwnd%
    Dragging := true
    SetTimer, DragMove, 5      ; 每5毫秒更新一次位置
    return
}

LButton Up::
{
    global Dragging
    if (Dragging) {
        SetTimer, DragMove, Off
        Dragging := false
        SavePosition()          ; 拖拽结束保存位置
    }
    return
}

DragMove:
    global Dragging, DragStartX, DragStartY, DragWinX, DragWinY, TimeGuiHwnd
    if (!Dragging)
        return
    
    MouseGetPos, CurrX, CurrY
    ; 计算窗口新位置
    NewX := DragWinX + (CurrX - DragStartX)
    NewY := DragWinY + (CurrY - DragStartY)
    
    ; 移动窗口
    WinMove, ahk_id %TimeGuiHwnd%,, %NewX%, %NewY%
    
    ; 更新基准点，保证连续移动的平滑性
    DragStartX := CurrX
    DragStartY := CurrY
    WinGetPos, DragWinX, DragWinY,,, ahk_id %TimeGuiHwnd%
    return
#If

; ========== 窗口内快捷键 ==========
#IfWinActive ahk_class AutoHotkeyGUI
RButton::
    ToggleDrag()                ; 右键切换拖拽模式
    return

MButton::
    SavePosition()              ; 鼠标中键关闭窗口
    ToggleTimeWindow()
    return

Esc::
    SavePosition()              ; Esc键关闭窗口
    ToggleTimeWindow()
    return

Up::
    NudgeWindow(0, -10)         ; 上方向键：向上移动10像素
    return
Down::
    NudgeWindow(0, 10)          ; 下方向键：向下移动10像素
    return
Left::
    NudgeWindow(-10, 0)         ; 左方向键：向左移动10像素
    return
Right::
    NudgeWindow(10, 0)          ; 右方向键：向右移动10像素
    return
#IfWinActive

; ========== 微调窗口位置 ==========
NudgeWindow(dx, dy)
{
    global TimeGuiHwnd
    if (!TimeGuiHwnd)
        return
    WinGetPos, X, Y,,, ahk_id %TimeGuiHwnd%
    WinMove, ahk_id %TimeGuiHwnd%,, X+dx, Y+dy
    SavePosition()              ; 微调后保存位置
    return
}

; ========== 启动提示 ==========
TrayTip, 桌面时间工具, 已启动`nAlt+0: 显示/隐藏时间窗口`n右键窗口切换拖拽模式, 8