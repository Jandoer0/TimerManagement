#Requires AutoHotkey v2.0.19
#SingleInstance Force
#Warn All, Off

; Импорт модулей
#Include TimerManager\TimerCore.ahk
#Include TimerManager\TimerGUI.ahk
#Include TimerManager\TimerManagement.ahk
#Include TimerManager\HistoryManager.ahk

; Основные глобальные переменные
global historyFile := A_ScriptDir "\TimerManager\time_tracker_history.txt"
global ActiveTimers := Map()
global NextTimerID := 1
global HiddenTimersGui := ""
global HiddenTimersControls := Map()

; Горячие клавиши
^!F9::StartNewTask()      ; Новый таймер
^!F10::ToggleAllTimers()  ; Пауза/возобновление всех
^!F11::ShowHistory()      ; История
^!F12::ShowActiveTimers() ; Список активных таймеров

; Функция выхода
ExitScript() {
    global ActiveTimers
    
    if (ActiveTimers.Count > 0) {
        result := MsgBox("Есть активные таймеры (" ActiveTimers.Count "). Вы уверены, что хотите выйти?", "Подтверждение выхода", "YesNo Icon!")
        if (result = "No") {
            return
        }
        
        ; Останавливаем все таймеры перед выходом
        timersToStop := []
        for timerID, timer in ActiveTimers {
            timersToStop.Push(timerID)
        }
        
        for timerID in timersToStop {
            StopTimer(timerID)
        }
    }
    
    ExitApp()
}
