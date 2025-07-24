# Author: Acca Emme
# Created on 23 July 2025
# Last update: 24 July 2025


$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BackupDir = Join-Path $ScriptPath "PCMigrator_bkp"

function Export-BrowserData {
    param ($BrowserName)
    $file = "$BackupDir\$BrowserName-backup.txt"
    "Exported bookmarks and configurations for $BrowserName" | Out-File -Encoding UTF8 -FilePath $file
    Write-Host "${BrowserName}: dati esportati in $file"
}

function Export-HostsFile {
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    Copy-Item $hostsPath -Destination "$BackupDir\hosts_backup.txt" -Force
    Write-Host "File hosts salvato in $BackupDir\hosts_backup.txt"
}

function Export-NetworkConfig {
    $netFile = "$BackupDir\rete_config.txt"
    netsh interface ip dump > $netFile
    Write-Host "Configurazioni di rete salvate in $netFile"
}

function Export-WiFiProfiles {
    netsh wlan export profile key=clear folder=$BackupDir
    Write-Host "Profili Wi-Fi esportati in $BackupDir"
}

function Export-EnvironmentVariables {
    $envFile = "$BackupDir\variabili_ambiente.txt"
    Get-ChildItem Env: > $envFile
    Write-Host "Variabili d'ambiente salvate in $envFile"
}

function Export-InstalledPrograms {
    $programsFile = "$BackupDir\programmi_installati.txt"
    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
        Select-Object DisplayName, DisplayVersion, Publisher |
        Where-Object { $_.DisplayName } |
        Sort-Object DisplayName |
        Format-Table -AutoSize |
        Out-String |
        Set-Content $programsFile
    Write-Host "Elenco programmi salvato in $programsFile"
}

function Do-Backup {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    $browsers = @{
        "Chrome"  = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        "Firefox" = "C:\Program Files\Mozilla Firefox\firefox.exe"
        "Edge"    = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        "Opera"   = "$env:USERPROFILE\AppData\Local\Programs\Opera\launcher.exe"
    }

    foreach ($browser in $browsers.Keys) {
        if (Test-Path $browsers[$browser]) {
            $response = Read-Host "$browser è installato. Vuoi esportare preferiti e configurazioni? (s/n)"
            if ($response -eq 's') {
                Export-BrowserData -BrowserName $browser
            }
        }
    }

    if ((Read-Host "Vuoi salvare il file hosts? (s/n)") -eq 's') { Export-HostsFile }

    if ((Read-Host "Vuoi salvare le configurazioni di rete? (s/n)") -eq 's') {
        if ((Read-Host "Vuoi visualizzarle prima? (s/n)") -eq 's') {
            netsh interface ip show config
        }
        Export-NetworkConfig
        Export-WiFiProfiles
    }

    Export-EnvironmentVariables
    Export-InstalledPrograms
    Write-Host "Backup completato. File salvati in $BackupDir"
}

function Do-Restore {
    if (-Not (Test-Path $BackupDir)) {
        Write-Host "Cartella di backup non trovata. Impossibile procedere con il ripristino."
        return
    }

    $backToMainMenu = $false
    while (-Not $backToMainMenu) {
        Write-Host "`n--- Menù Ripristino ---"
        Write-Host "1) Ripristina profili Wi-Fi"
        Write-Host "2) Ripristina file hosts"
        Write-Host "3) Ripristina variabili d'ambiente"
        Write-Host "4) Ripristina configurazioni di rete"
        Write-Host "-1) Torna al menù principale"
        Write-Host "0) Esci"
        $choice = Read-Host "Scegli un'opzione"

        switch ($choice) {
            '1' {
                $wifiProfiles = Get-ChildItem -Path $BackupDir -Filter *.xml
                if ($wifiProfiles.Count -eq 0) {
                    Write-Host "Nessun profilo Wi-Fi trovato da ripristinare."
                } else {
                    foreach ($profile in $wifiProfiles) {
                        netsh wlan add profile filename="$($profile.FullName)" user=all | Out-Null
                        Write-Host "Importato: $($profile.Name)"
                    }
                    Write-Host "Profili Wi-Fi ripristinati."
                }
            }
            '2' {
                $hostsBackup = Join-Path $BackupDir "hosts_backup.txt"
                if (Test-Path $hostsBackup) {
                    Copy-Item $hostsBackup -Destination "$env:SystemRoot\System32\drivers\etc\hosts" -Force
                    Write-Host "File hosts ripristinato."
                } else {
                    Write-Host "Backup del file hosts non trovato."
                }
            }
            '3' {
                $envFile = Join-Path $BackupDir "variabili_ambiente.txt"
                if (Test-Path $envFile) {
                    Get-Content $envFile
                    Write-Host "Variabili visualizzate."
                } else {
                    Write-Host "File non trovato."
                }
            }
            '4' {
                $netFile = Join-Path $BackupDir "rete_config.txt"
                if (Test-Path $netFile) {
                    Write-Host "Per ripristinare manualmente esegui:"
                    Write-Host "`nnetsh -f `"$netFile`"`n"
                } else {
                    Write-Host "File configurazioni non trovato."
                }
            }
            '-1' { 
                $backToMainMenu = $true  # Esce dal ciclo del sottomenù
             }
            '0' {
                Write-Host "👋 Ciao!"
                exit
            }
            default {
                Write-Host "Scelta non valida."
            }
        }
    }
}

# ========== MAIN ==========
do {
    Write-Host "`n🗂️ Benvenuto nello script di Backup/Ripristino configurazioni PC - AccaEmme"
    Write-Host "1) Esegui Backup"
    Write-Host "2) Esegui Ripristino"
    Write-Host "0) Esci"
    $mainChoice = Read-Host "Scegli un'opzione"

    switch ($mainChoice) {
        '1' { Do-Backup }
        '2' { Do-Restore }
        default { Write-Host "Scelta non valida." }
    }
} while ($mainChoice -ne '0')
Write-Host "👋 Ciao!"
