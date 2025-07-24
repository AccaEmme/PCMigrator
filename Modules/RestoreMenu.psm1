# Modules/RestoreMenu.psm1

Import-Module "$PSScriptRoot\Language.psm1"
Import-Module "$PSScriptRoot\BrowserBackup.psm1"
Import-Module "$PSScriptRoot\SystemBackup.psm1"

function Do-RestoreMenu {
    param ($BackupDir, $Lang)

    $browserPaths = Get-BrowserPaths
    $exitMenu = $false

    while (-Not $exitMenu) {
        Write-Host "`n--- 🔁 RIPRISTINO ---"
        Write-Host "1) Ripristina file hosts"
        Write-Host "2) Ripristina configurazioni di rete e Wi-Fi"
        Write-Host "3) Ripristina variabili d'ambiente"
        Write-Host "4) Visualizza programmi installati (backup)"
        Write-Host "5) Ripristina browser (preferiti, estensioni, password)"
        Write-Host "6) Esegui TUTTO il ripristino"
        Write-Host "-1) Torna al menù principale"
        Write-Host "0) Esci"
        $choice = Read-Host (Get-Text -Key "select_option" -Lang $Lang)

        switch ($choice) {
            '1' {
                Restore-HostsFile -BackupDir $BackupDir
            }
            '2' {
                Restore-NetworkConfig -BackupDir $BackupDir
            }
            '3' {
                Restore-EnvironmentVariables -BackupDir $BackupDir
            }
            '4' {
                Restore-InstalledPrograms -BackupDir $BackupDir
            }
            '5' {
                foreach ($browser in $browserPaths.Keys) {
                    Restore-BrowserSecrets -BrowserName $browser -BackupDir $BackupDir -BrowserPaths $browserPaths
                }
            }
            '6' {
                Restore-HostsFile -BackupDir $BackupDir
                Restore-NetworkConfig -BackupDir $BackupDir
                Restore-EnvironmentVariables -BackupDir $BackupDir
                Restore-InstalledPrograms -BackupDir $BackupDir
                foreach ($browser in $browserPaths.Keys) {
                    Restore-BrowserSecrets -BrowserName $browser -BackupDir $BackupDir -BrowserPaths $browserPaths
                }
                Write-Host "✅ Ripristino completo eseguito."
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
