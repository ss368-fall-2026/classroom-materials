<#
    startup.ps1  -  Setup for Stata-in-VS-Code hotkeys

    Run once per machine - puts the hotkeys in startup process

    It:
      1. creates a Startup-folder shortcut so the hotkeys load at every login,
      2. launches the hotkey exe now so it works this session too.

    Assumes that the folder runstata_vscode is copied into C:\
#>

# --- location of folder and exe files ----------------------
$InstallDir   = "C:\runstata_vscode"
$HotkeyExe    = Join-Path $InstallDir "runstata_vscode_hotkeys.exe"
$SenderExe    = Join-Path $InstallDir "runstata_vscode.exe"
$ProcName     = [IO.Path]::GetFileNameWithoutExtension($HotkeyExe)

# --- 1. validate ------------------------------------------------------------
foreach ($f in @($HotkeyExe, $SenderExe)) {
    if (-not (Test-Path -LiteralPath $f)) {
        Write-Error "Missing: $f  -- copy the folder to C:\ first."
        exit 1
    }
}

# --- 2. create the Startup-folder shortcut -----------------------------------
$Startup  = [Environment]::GetFolderPath('Startup')
$Shortcut = Join-Path $Startup "Stata Hotkeys.lnk"

$wsh = New-Object -ComObject WScript.Shell
$lnk = $wsh.CreateShortcut($Shortcut)
$lnk.TargetPath       = $HotkeyExe
$lnk.WorkingDirectory = $InstallDir
$lnk.Description       = "Stata run hotkeys for VS Code"
$lnk.Save()

# --- 3. start it now ----------------------------------------------------------
# Stop any existing instance first so we don't stack copies.
Get-Process -Name "runstata_vscode_hotkeys" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process $HotkeyExe

Write-Host "Installed to $InstallDir and added to Startup. Hotkeys are live." -ForegroundColor Green