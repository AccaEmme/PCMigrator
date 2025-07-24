# Modules/SystemBackup.psm1

function Export-HostsFile {
    param ($BackupDir)
    $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
    Copy-Item $hostsPath -Destination "$BackupDir\hosts_backup.txt" -Force
    Write-Host "File hosts salvato in $BackupDir\hosts_backup.txt"
}

function Restore-HostsFile {
    param ($BackupDir)
    $src = "$BackupDir\hosts_backup.txt"
    $dest = "$env:SystemRoot\System32\drivers\etc\hosts"
    if (Test-Path $src) {
        Copy-Item $src -Destination $dest -Force
        Write-Host "File hosts ripristinato."
    } else {
        Write-Host "⚠️ Backup hosts non trovato."
    }
}

function Export-NetworkConfig {
    param ($BackupDir)
    $netFile = "$BackupDir\rete_config.txt"
    netsh interface ip dump > $netFile
    netsh wlan export profile key=clear folder=$BackupDir
    Write-Host "Configurazioni di rete salvate in $netFile e profili Wi-Fi esportati."
}

function Restore-NetworkConfig {
    param ($BackupDir)
    $netFile = "$BackupDir\rete_config.txt"
    if (Test-Path $netFile) {
        Write-Host "✳️ Per ripristinare manualmente le configurazioni di rete, esegui:"
        Write-Host "`nnetsh -f `"$netFile`"`n"
    } else {
        Write-Host "⚠️ Nessun file di configurazione rete trovato."
    }

    $wifiProfiles = Get-ChildItem -Path $BackupDir -Filter *.xml
    if ($wifiProfiles.Count -gt 0) {
        foreach ($profile in $wifiProfiles) {
            netsh wlan add profile filename="$($profile.FullName)" user=all | Out-Null
            Write-Host "✅ Importato: $($profile.Name)"
        }
        Write-Host "Profili Wi-Fi ripristinati."
    } else {
        Write-Host "⚠️ Nessun profilo Wi-Fi da ripristinare."
    }
}

function Export-EnvironmentVariables {
    param ($BackupDir)
    $envFile = "$BackupDir\variabili_ambiente.txt"
    Get-ChildItem Env: > $envFile
    Write-Host "Variabili d'ambiente salvate in $envFile"
}

function Restore-EnvironmentVariables {
    param ($BackupDir)
    $envFile = "$BackupDir\variabili_ambiente.txt"
    if (Test-Path $envFile) {
        Get-Content $envFile
        Write-Host "✅ Variabili visualizzate. Ripristino manuale consigliato."
    } else {
        Write-Host "⚠️ File variabili d'ambiente non trovato."
    }
}

function Export-InstalledPrograms {
    param ($BackupDir)
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

function Restore-InstalledPrograms {
    param ($BackupDir)
    $programsFile = "$BackupDir\programmi_installati.txt"
    if (Test-Path $programsFile) {
        Get-Content $programsFile
        Write-Host "✅ Programmi installati (backup visualizzato)"
    } else {
        Write-Host "⚠️ File programmi non trovato."
    }
}
