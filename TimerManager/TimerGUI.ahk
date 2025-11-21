; TimerGUI.ahk - Функции для работы с интерфейсом

CreateTimerWindow(timer) {
    global ActiveTimers
    
    ; Создаем новое окно
    timer.TimeGui := Gui("+AlwaysOnTop +ToolWindow", "Таймер " timer.ID ": " timer.TaskName)
    timer.TimeGui.SetFont("s10", "Arial")
    
    ; Заголовок
    timer.TimeGui.Add("Text", "w280 Center", "Задача: " timer.TaskName)
    timer.TimeGui.Add("Text", "w280 Center", "Затраченное время:")
    
    ; Большой счетчик времени
    timer.TimeGui.SetFont("s20 Bold", "Arial")
    timer.TimeText := timer.TimeGui.Add("Text", "w280 h40 Center vTimeText", "00:00:00")
    timer.TimeGui.SetFont("s9", "Arial")
    
    ; Информация
    timer.StatusText := timer.TimeGui.Add("Text", "w280 Center", "Статус: Активен")
    timer.TimeGui.Add("Text", "w280 Center", "ID: " timer.ID)
    timer.TimeGui.Add("Text", "w280 Center", "Начало: " A_Hour ":" A_Min ":" A_Sec)
    
    ; Кнопки управления
    btnStop := timer.TimeGui.Add("Button", "w65", "⏹️ Стоп")
    btnStop.OnEvent("Click", (*) => StopTimer(timer.ID))
    
    btnPause := timer.TimeGui.Add("Button", "x+5 w65", "⏸️ Пауза")
    btnPause.OnEvent("Click", (*) => ToggleTimer(timer.ID))
    
    btnRestart := timer.TimeGui.Add("Button", "x+5 w65", "🔄 Рест")
    btnRestart.OnEvent("Click", (*) => RestartTimer(timer.ID))
    
    ; Сохраняем ссылку на кнопку скрытия
    timer.HideButton := timer.TimeGui.Add("Button", "x+5 w65", "👁️ Скрыть")
    timer.HideButton.OnEvent("Click", (*) => HideTimer(timer.ID))
    
    ; Позиционируем окна в шахматном порядке
    xPos := 50 + ((timer.ID - 1) * 20)
    yPos := 50 + ((timer.ID - 1) * 20)
    timer.TimeGui.Show("x" xPos " y" yPos)
}