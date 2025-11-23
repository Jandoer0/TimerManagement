; TimerCore.ahk - Основная логика работы таймеров

StartNewTask() {
    global NextTimerID
    
    ; Создаем InputBox и обрабатываем результат
    result := InputBox("Введите название задачи:", "Новый таймер",, "Название задачи")
    
    ; Проверяем, была ли нажата кнопка "Отмена" или поле пустое
    if (result.Result = "Cancel" || result.Value = "") {
        return  ; Закрываем окно без создания таймера
    }
    
    StartTimer(result.Value, NextTimerID)
    NextTimerID++
}

StartTimer(taskName, timerID) {
    global ActiveTimers, historyFile
    
    ; Создаем объект таймера
    timer := {
        TaskName: taskName,
        StartTime: A_TickCount,
        ElapsedTime: 0,
        TimeGui: "",
        TimeText: "",
        IsTracking: true,
        IsHidden: false,
        ID: timerID
    }
    
    ActiveTimers[timerID] := timer
    
    ; Создаем окно счетчика
    CreateTimerWindow(timer)
    
    SetTimer(TimerTick, 1000)
    
    ; Логируем запуск
    now := A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec
    entry := now " | " taskName " | STARTED`n"
    FileAppend(entry, historyFile)
}

FormatElapsedTime(seconds) {
    hours := seconds // 3600
    minutes := (seconds // 60) - (hours * 60)
    secs := Mod(seconds, 60)
    return Format("{1:02}:{2:02}:{3:02}", hours, minutes, secs)
}

ToggleTimer(timerID) {
    global ActiveTimers
    
    if (!ActiveTimers.Has(timerID)) {
        return
    }
    
    timer := ActiveTimers[timerID]
    
    if (timer.IsTracking) {
        ; Переход в режим паузы
        timer.IsTracking := false
        timer.ElapsedTime += (A_TickCount - timer.StartTime) // 1000
        
        if (IsObject(timer.TimeGui) && !timer.IsHidden) {
            try {
                timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime) . " ⏸️"
                timer.StatusText.Value := "Статус: На паузе"
            }
        }
    } else {
        ; Возобновление отсчета
        timer.IsTracking := true
        timer.StartTime := A_TickCount
        
        if (IsObject(timer.TimeGui) && !timer.IsHidden) {
            try {
                timer.TimeText.Value := FormatElapsedTime(timer.ElapsedTime)
                timer.StatusText.Value := "Статус: Активен"
            }
        }
    }
}

RestartTimer(timerID) {
    global ActiveTimers
    
    if (!ActiveTimers.Has(timerID)) {
        return
    }
    
    timer := ActiveTimers[timerID]
    
    ; Сбрасываем время
    timer.StartTime := A_TickCount
    timer.ElapsedTime := 0
    timer.IsTracking := true
    
    if (IsObject(timer.TimeGui) && !timer.IsHidden) {
        try {
            timer.TimeText.Value := "00:00:00"
            timer.StatusText.Value := "Статус: Активен"
        }
    }
}

StopTimer(timerID) {
    global ActiveTimers, HiddenTimersGui, HiddenTimersControls, historyFile
    
    if (!ActiveTimers.Has(timerID)) {
        return
    }
    
    timer := ActiveTimers[timerID]
    
    ; Вычисляем общее время
    if (timer.IsTracking) {
        timer.ElapsedTime += (A_TickCount - timer.StartTime) // 1000
    }
    
    totalTime := timer.ElapsedTime
    taskName := timer.TaskName
    
    ; Закрываем окно
    if (IsObject(timer.TimeGui)) {
        try timer.TimeGui.Destroy()
    }
    
    ; Удаляем из активных таймеров
    ActiveTimers.Delete(timerID)
    
    ; Удаляем из списка скрытых таймеров
    RemoveTimerFromHiddenList(timerID)
    
    ; Логируем завершение
    now := A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec
    entry := now " | " taskName " | " FormatElapsedTime(totalTime) " | COMPLETED`n"
    FileAppend(entry, historyFile)
}

TimerTick() {
    global ActiveTimers, HiddenTimersGui, HiddenTimersControls
    
    if (ActiveTimers.Count = 0) {
        SetTimer(TimerTick, 0)
        return
    }
    
    ; Обновляем все активные таймеры
    for timerID, timer in ActiveTimers {
        if (timer.IsTracking && IsObject(timer.TimeGui) && !timer.IsHidden) {
            ; Вычисляем прошедшее время
            currentElapsed := timer.ElapsedTime + ((A_TickCount - timer.StartTime) // 1000)
            
            ; Обновляем окно счетчика
            try {
                timer.TimeText.Value := FormatElapsedTime(currentElapsed)
            }
        }
    }
    
    ; Обновляем счетчики в окне скрытых таймеров
    UpdateHiddenTimersDisplay()
}