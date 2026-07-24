if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
$ErrorActionPreference = 'SilentlyContinue'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseUrl = "https://github.com/misanteaa/checker/releases/download/v1.0"

$tools = @(
    @{ Name = "Everything (Poisk fajlov)";              File = "everything.exe" },
    @{ Name = "JournalTrace (Trassirovka NTFS)";        File = "JournalTrace.exe" },
    @{ Name = "LastActivityView (Poslednyaya aktivnost)"; File = "LastActivityView.exe" },
    @{ Name = "MeowClientFucker";                       File = "MeowClientFucker.1.exe" },
    @{ Name = "MeowDoomsdayFucker";                     File = "MeowDoomsdayFucker.1.exe" },
    @{ Name = "Process Hacker 2.39 (Monitoring)";      File = "processhacker-2.39-setup.exe" },
    @{ Name = "ShellBag Analyzer/Cleaner";              File = "shellbag_analyzer_cleaner.exe" },
    @{ Name = "USBDeview (USB ustrojstva)";             File = "USBDeview.exe" },
    @{ Name = "WinPrefetchView (Prefetch)";             File = "WinPrefetchView.exe" }
)

function Download-Tools {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Downloading tools from GitHub     " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    $missing = @()
    foreach ($tool in $tools) {
        $path = Join-Path $scriptDir $tool.File
        if (-not (Test-Path $path)) {
            $missing += $tool
        }
    }
    if ($missing.Count -eq 0) {
        Write-Host "All tools already downloaded!" -ForegroundColor Green
        return
    }
    Write-Host "Need to download $($missing.Count) file(s):" -ForegroundColor Yellow
    foreach ($m in $missing) { Write-Host "  - $($m.File)" -ForegroundColor Gray }
    Write-Host ""
    $progressPreference = 'SilentlyContinue'
    foreach ($m in $missing) {
        $url = "$baseUrl/$([Uri]::EscapeDataString($m.File))"
        $dest = Join-Path $scriptDir $m.File
        Write-Host "Downloading $($m.File)... " -NoNewline
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
            Write-Host "OK" -ForegroundColor Green
        } catch {
            Write-Host "FAILED" -ForegroundColor Red
        }
    }
    $progressPreference = 'Continue'
    Write-Host ""
    Write-Host "Done!" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         CHECKER - Launcher Menu         " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $num = $i + 1
        $exists = Test-Path (Join-Path $scriptDir $tools[$i].File)
        if ($exists) {
            Write-Host "  [$num] " -ForegroundColor Yellow -NoNewline
            Write-Host $tools[$i].Name
        } else {
            Write-Host "  [$num] " -ForegroundColor Yellow -NoNewline
            Write-Host $tools[$i].Name -ForegroundColor DarkGray
            Write-Host "       (not downloaded)" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "  [D] " -ForegroundColor Yellow -NoNewline
    Write-Host "Download missing tools"
    Write-Host "  [0] " -ForegroundColor Yellow -NoNewline
    Write-Host "Exit"
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
}

Download-Tools

while ($true) {
    Show-Menu
    $choice = Read-Host "Select number"

    if ($choice -eq '0') {
        Write-Host "`nExiting..." -ForegroundColor Green
        break
    }

    if ($choice -eq 'D' -or $choice -eq 'd') {
        Download-Tools
        continue
    }

    $index = 0
    if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $tools.Count) {
        $tool = $tools[$index - 1]
        $path = Join-Path $scriptDir $tool.File

        if (Test-Path $path) {
            Write-Host "`nLaunching: $($tool.Name)..." -ForegroundColor Green
            try {
                Start-Process -FilePath $path -WorkingDirectory $scriptDir
                Write-Host "Launched!" -ForegroundColor Green
            } catch {
                Write-Host "Launch error: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "`nFile not found: $($tool.File)" -ForegroundColor Red
            Write-Host "Press [D] to download it." -ForegroundColor Yellow
        }

        Write-Host ""
        Pause
    } else {
        Write-Host "`nInvalid choice!" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}