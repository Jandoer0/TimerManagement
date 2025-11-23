; HistoryManager.ahk - Управление историей задач

ShowHistory() {
    global historyFile
    if FileExist(historyFile) {
        history := FileRead(historyFile)
        MsgBox(history, "История задач", "Iconi")
    } else {
        MsgBox("История пуста.", "История задач", "Iconi")
    }
}