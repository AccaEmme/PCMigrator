# Modules/BackupMenu.psm1

Import-Module "$PSScriptRoot\Language.psm1"
Import-Module "$PSScriptRoot\BrowserBackup.psm1"
Import-Module "$PSScriptRoot\SystemBackup.psm1"

function Do-BackupMenu {
    param ($BackupDir, $Lang)

    $browserPaths = Get-BrowserPaths
    $exitMenu = $false

    while (-Not $exitMenu) {
        Write-Host "`n--- 📦 BACKUP ---"
        Write-Host "1) Backup file hosts"
        Write-Host "2) Backup configurazioni di rete e Wi-Fi"
        Write-Host "3) Backup variabili d'ambiente"
        Write-Host "4) Backup programmi installati"
        Write-Host "5) Backup browser (preferiti, estensioni, password)"
        Write-Host "6) Esegui TUTTI i backup"
        Write-Host "-1) Torna al menù principale"
        Write-Host "0) Esci"
        $choice = Read-Host (Get-Text -Key "select_option" -Lang $Lang)

        switch ($choice) {
            '1' {
                Export-HostsFile -BackupDir $BackupDir
            }
            '2' {
                Export-NetworkConfig -BackupDir $BackupDir
            }
            '3' {
                Export-EnvironmentVariables -BackupDir $BackupDir
            }
            '4' {
                Export-InstalledPrograms -BackupDir $BackupDir
            }
            '5' {
                foreach ($browser in $browserPaths.Keys) {
                    if (Test-Path $browserPaths[$browser]) {
                        Write-Host "🔎 $browser rilevato."
                        Export-BrowserData -BrowserName $browser -BackupDir $BackupDir
                        Export-BrowserSecrets -BrowserName $browser -BackupDir $BackupDir
                    } else {
                        Write-Host "⚠️ $browser non è installato."
                    }
                }
            }
            '6' {
                Export-HostsFile -BackupDir $BackupDir
                Export-NetworkConfig -BackupDir $BackupDir
                Export-EnvironmentVariables -BackupDir $BackupDir
                Export-InstalledPrograms -BackupDir $BackupDir
                foreach ($browser in $browserPaths.Keys) {
                    if (Test-Path $browserPaths[$browser]) {
                        Export-BrowserData -BrowserName $browser -BackupDir $BackupDir
                        Export-BrowserSecrets -BrowserName $browser -BackupDir $BackupDir
                    }
                }
                Write-Host "✅ Backup completo eseguito."
            }
            '-1' {
                $exitMenu = $true
            }
            '0' {
                Write-Host (Get-Text -Key "exit" -Lang $Lang)
                exit
            }
            default {
                Write-Host "❌ Scelta non valida."
            }
        }
    }
}
