; TimerManagement.ahk - Управление группой таймеров и скрытыми таймерами

ToggleAllTimers() {
    global ActiveTimers
    
    if (ActiveTimers.Count = 0) {
        return
    }
    
    ; Проверяем статус всех таймеров
    allPaused := true
    
    for timerID, timer in ActiveTimers {
        if (timer.IsTracking) {
            allPaused := false
            break
        }
    }
    
    if (allPaused) {
        ; Все на паузе - возобновляем все
        for timerID, timer in ActiveTimers {
            timer.IsTracking := true
            timer.StartTime := A_TickCount
            if (IsObject(timer.TimeGui) && !timer.IsHidden) {
                try {
                    timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime)
                    timer.StatusText.Value := "Статус: Активен"
                }
            }
        }
    } else {
        ; Есть активные - ставим все на паузу
        for timerID, timer in ActiveTimers {
            if (timer.IsTracking) {
                timer.IsTracking := false
                timer.ElapsedTime += (A_TickCount - timer.StartTime) // 1000
                if (IsObject(timer.TimeGui) && !timer.IsHidden) {
                    try {
                        timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime) . " ⏸️"
                        timer.StatusText.Value := "Статус: На паузе"
                    }
                }
            }
        }
    }
}

HideTimer(timerID) {
    global ActiveTimers, HiddenTimersGui, HiddenTimersControls
    
    if (!ActiveTimers.Has(timerID)) {
        return
    }
    
    timer := ActiveTimers[timerID]
    
    if (timer.IsHidden) {
        ; Восстанавливаем окно
        timer.IsHidden := false
        if (IsObject(timer.TimeGui)) {
            timer.TimeGui.Show()
            ; Обновляем отображение времени и статуса
            if (timer.IsTracking) {
                currentElapsed := timer.ElapsedTime + ((A_TickCount - timer.StartTime) // 1000)
                timer.TimeText.Value := FormatElapsedTime(currentElapsed)
                timer.StatusText.Value := "Статус: Активен"
            } else {
                timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime) . " ⏸️"
                timer.StatusText.Value := "Статус: На паузе"
            }
            ; Меняем текст кнопки
            timer.HideButton.Text := "👁️ Скрыть"
        }
        
        ; Удаляем таймер из списка в окне управления
        RemoveTimerFromHiddenList(timerID)
        
    } else {
        ; Скрываем окно
        timer.IsHidden := true
        if (IsObject(timer.TimeGui)) {
            timer.TimeGui.Hide()
            ; Меняем текст кнопки (будет обновлено при показе)
        }
    }
}

ShowAllTimers() {
    global ActiveTimers, HiddenTimersGui
    
    for timerID, timer in ActiveTimers {
        if (timer.IsHidden) {
            timer.IsHidden := false
            if (IsObject(timer.TimeGui)) {
                timer.TimeGui.Show()
                ; Обновляем отображение времени и статуса
                if (timer.IsTracking) {
                    currentElapsed := timer.ElapsedTime + ((A_TickCount - timer.StartTime) // 1000)
                    timer.TimeText.Value := FormatElapsedTime(currentElapsed)
                    timer.StatusText.Value := "Статус: Активен"
                } else {
                    timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime) . " ⏸️"
                    timer.StatusText.Value := "Статус: На паузе"
                }
                ; Меняем текст кнопки
                timer.HideButton.Text := "👁️ Скрыть"
            }
        }
    }
    
    ; Закрываем окно управления скрытыми таймерами
    if (IsObject(HiddenTimersGui)) {
        HiddenTimersGui.Destroy()
        HiddenTimersGui := ""
    }
}

; Функции для управления окном скрытых таймеров

ShowActiveTimers() {
    global ActiveTimers, HiddenTimersGui, HiddenTimersControls
    
    ; Считаем только скрытые таймеры
    hiddenCount := 0
    for timerID, timer in ActiveTimers {
        if (timer.IsHidden) {
            hiddenCount++
        }
    }
    
    if (hiddenCount = 0) {
        ; Закрываем окно если оно было открыто
        if (IsObject(HiddenTimersGui)) {
            HiddenTimersGui.Destroy()
            HiddenTimersGui := ""
        }
        MsgBox("Нет скрытых таймеров.", "Скрытые таймеры", "Iconi")
        return
    }
    
    ; Очищаем предыдущие контролы
    HiddenTimersControls := Map()
    
    ; Создаем новое GUI для управления
    HiddenTimersGui := Gui("+AlwaysOnTop", "Скрытые таймеры (" hiddenCount ")")
    HiddenTimersGui.SetFont("s9", "Arial")
    
    HiddenTimersGui.Add("Text", "w300", "Скрытые таймеры:")
    
    ; Добавляем только скрытые таймеры
    yPos := 30
    for timerID, timer in ActiveTimers {
        if (timer.IsHidden) {
            ; Вычисляем текущее время
            if (timer.IsTracking) {
                currentElapsed := timer.ElapsedTime + ((A_TickCount - timer.StartTime) // 1000)
            } else {
                currentElapsed := timer.ElapsedTime
            }
            
            ; Создаем контролы для этого таймера
            controls := Map()
            
            ; Разделитель
            controls.Separator1 := HiddenTimersGui.Add("Text", "x10 y" yPos " w280", "---")
            yPos += 20
            
            ; Название задачи
            controls.TaskText := HiddenTimersGui.Add("Text", "x10 y" yPos " w280", "Задача: " timer.TaskName)
            yPos += 20
            
            ; Время (будет обновляться)
            controls.TimeText := HiddenTimersGui.Add("Text", "x10 y" yPos " w280", "Время: " FormatElapsedTime(currentElapsed))
            yPos += 20
            
            ; Статус (будет обновляться)
            statusText := timer.IsTracking ? "Статус: Активен" : "Статус: На паузе"
            controls.StatusText := HiddenTimersGui.Add("Text", "x10 y" yPos " w280", statusText)
            yPos += 20
            
            ; Кнопка показать
            controls.ShowButton := HiddenTimersGui.Add("Button", "x10 y" yPos " w120", "👁️ Показать таймер")
            controls.ShowButton.OnEvent("Click", ShowTimerBtn.Bind(timerID))
            yPos += 30
            
            ; Сохраняем ссылки на контролы
            HiddenTimersControls[timerID] := controls
        }
    }
    
    btnShowAll := HiddenTimersGui.Add("Button", "x10 y" yPos " w140", "👁️ Показать все")
    btnShowAll.OnEvent("Click", (*) => ShowAllTimers())
    
    btnClose := HiddenTimersGui.Add("Button", "x160 y" yPos " w140", "Закрыть")
    btnClose.OnEvent("Click", (*) => HiddenTimersGui.Destroy())
    
    HiddenTimersGui.Show()
    
    ; Запускаем обновление счетчиков в окне скрытых таймеров
    SetTimer(UpdateHiddenTimersDisplay, 1000)
}

; Функция-обертка для кнопки показа таймера
ShowTimerBtn(timerID, *) {
    HideTimer(timerID)
}

; Функция для обновления отображения в окне скрытых таймеров
UpdateHiddenTimersDisplay() {
    global ActiveTimers, HiddenTimersGui, HiddenTimersControls
    
    if (!IsObject(HiddenTimersGui) || !WinExist(HiddenTimersGui)) {
        return
    }
    
    ; Создаем временный список таймеров для удаления
    timersToRemove := []
    
    for timerID, controls in HiddenTimersControls {
        ; Проверяем, существует ли еще таймер и скрыт ли он
        if (!ActiveTimers.Has(timerID) || !ActiveTimers[timerID].IsHidden) {
            timersToRemove.Push(timerID)
            continue
        }
        
        timer := ActiveTimers[timerID]
        
        ; Вычисляем текущее время
        if (timer.IsTracking) {
            currentElapsed := timer.ElapsedTime + ((A_TickCount - timer.StartTime) // 1000)
        } else {
            currentElapsed := timer.ElapsedTime
        }
        
        ; Обновляем отображение времени
        try {
            controls.TimeText.Value := "Время: " FormatElapsedTime(currentElapsed)
            if (timer.IsTracking) {
                controls.StatusText.Value := "Статус: Активен"
            } else {
                controls.StatusText.Value := "Статус: На паузе"
            }
        }
    }
    
    ; Удаляем таймеры, которые больше не скрыты
    for timerID in timersToRemove {
        RemoveTimerFromHiddenList(timerID)
    }
}

; Функция для удаления таймера из списка в окне управления
RemoveTimerFromHiddenList(timerID) {
    global HiddenTimersGui, HiddenTimersControls
    
    if (!HiddenTimersControls.Has(timerID)) {
        return
    }
    
    ; Удаляем контролы из GUI
    controls := HiddenTimersControls[timerID]
    for controlType, control in controls.OwnProps() {
        if (IsObject(control)) {
            try control.Destroy()
        }
    }
    
    ; Удаляем из карты контролов
    HiddenTimersControls.Delete(timerID)
    
    ; Если окно управления существует и скрытых таймеров не осталось, закрываем его
    if (IsObject(HiddenTimersGui) && HiddenTimersControls.Count = 0) {
        HiddenTimersGui.Destroy()
        HiddenTimersGui := ""
    } else if (IsObject(HiddenTimersGui) && HiddenTimersControls.Count > 0) {
        ; Пересоздаем окно с обновленным списком
        RecreateHiddenTimersWindow()
    }
}

; Функция для пересоздания окна скрытых таймеров с обновленным списком
RecreateHiddenTimersWindow() {
    global HiddenTimersGui, HiddenTimersControls
    
    if (!IsObject(HiddenTimersGui)) {
        return
    }
    
    ; Сохраняем позицию окна
    try {
        winPos := HiddenTimersGui.GetPos()
        HiddenTimersGui.Destroy()
    } catch {
        winPos := ""
    }
    
    ; Очищаем контролы и пересоздаем окно
    HiddenTimersControls := Map()
    ShowActiveTimers()
    
    ; Восстанавливаем позицию окна
    if (winPos != "" && IsObject(HiddenTimersGui)) {
        HiddenTimersGui.Show("x" winPos.X " y" winPos.Y)
    }
}