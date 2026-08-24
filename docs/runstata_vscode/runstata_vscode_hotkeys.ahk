; ============================================================================
; runstata_oema_hotkeys.ahk   -  AutoHotkey v2
; OEMA — Stata run hotkeys for VS Code
;
; Replaces the VS Code task/keybinding layer (which showed the task picker on
; every second run). AutoHotkey intercepts the keys, copies the selection, and
; calls runstata_oema.exe directly — no VS Code task system, so no picker, ever.
;
; The exe is unchanged: it reads the selection off the clipboard, writes a temp
; .do, sends do/run/include to your open Stata, and restores the clipboard.
;
;   Ctrl+D / Ctrl+R / Ctrl+I        = do / run / include  the SELECTION
;   Ctrl+Shift+D / Shift+R / Shift+I = do / run / include  the WHOLE FILE
;   (With nothing selected, Ctrl+D runs the current line — VS Code copies the
;    whole line when there's no selection.)
;
; SETUP
;   1. Install AutoHotkey v2 (autohotkey.com) on one machine.
;   2. Either run this .ahk directly, or compile it to .exe with Ahk2Exe for
;      machines without AHK installed (same model as your AutoIt exe).
;   3. To start it automatically, drop the .ahk (or compiled .exe) — or a
;      shortcut to it — in the Startup folder:  shell:startup
;   4. Remove the old VS Code Stata keybindings and the .vscode\tasks.json Stata
;      tasks so nothing competes (AHK consumes the keys before VS Code anyway).
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; ---- path to the sender exe -------------------------------------------------
; Found relative to THIS script's folder, so the whole folder is portable:
; drop it anywhere on any VM (any username) and it just works, as long as
; runstata_oema.exe sits beside this file.
exe := A_ScriptDir "\runstata_vscode.exe"

; ---- hotkeys: active only while VS Code is the focused window ----------------
; OPTIONAL: limit the hotkeys to .do files only.
; VS Code's title bar normally shows "<filename> - <folder> - Visual Studio Code",
; so you can gate on ".do" being in the title.
#HotIf WinActive("ahk_exe Code.exe") and InStr(WinGetTitle("A"), ".do")

^d::  RunStata("do",      false)
^r::  RunStata("run",     false)
^i::  RunStata("include", false)
^+d:: RunStata("do",      true)
^+r:: RunStata("run",     true)
^+i:: RunStata("include", true)

#HotIf

; ---- core --------------------------------------------------------------------
RunStata(mode, wholeFile) {
    global exe

    if (wholeFile)
        Send("^a")                 ; select the entire document first

    Sleep(20)
    A_Clipboard := ""              ; clear so ClipWait can detect the fresh copy
    Send("^c")                     ; copy selection (or current line if none)

    if !ClipWait(1) {              ; wait up to 1s for the clipboard to fill
        if (wholeFile)
            Send("{Right}")        ; collapse the select-all so a stray key can't wipe the file
        return                     ; nothing copied -> do nothing
    }

    if (wholeFile)
        Send("{Right}")            ; collapse the select-all back to a caret

    ; Hand off to the proven exe; it writes the temp file and drives Stata.
    Run('"' exe '" ' mode ' CLIP')
}

; ============================================================================
; Tradeoff: this restores .do-only scoping (so Ctrl+D keeps its multi-cursor
; behavior in other files), but depends on the filename showing in the title,
; which a customized window.title setting could change.
;
; This is the "applies everywhere in VS Code (not just .do files)" scope.
; To restrict to .do files instead, see the OPTIONAL guard above.
#HotIf WinActive("ahk_exe Code.exe")
; ============================================================================