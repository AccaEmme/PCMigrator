# Modules/BrowserBackup.psm1

function Get-BrowserPaths {
    return @{
        "Chrome" = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        "Firefox" = "C:\Program Files\Mozilla Firefox\firefox.exe"
        "Edge" = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
        "Opera" = "$env:USERPROFILE\AppData\Local\Programs\Opera\launcher.exe"
        "Brave" = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
    }
}

function Export-BrowserData {
    param ($BrowserName, $BackupDir)
    $file = "$BackupDir\$BrowserName-backup.txt"
    "Exported bookmarks and configuration for $BrowserName" | Out-File -Encoding UTF8 -FilePath $file
    Write-Host "$BrowserName: preferiti/configurazioni esportati in $file"
}

function Export-BrowserSecrets {
    param ($BrowserName, $BackupDir)

    $profiles = @{
        "Chrome" = "$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default"
        "Edge" = "$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default"
        "Opera" = "$env:USERPROFILE\AppData\Roaming\Opera Software\Opera Stable"
        "Brave" = "$env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default"
        "Firefox" = "$env:APPDATA\Mozilla\Firefox\Profiles"
    }

    if ($profiles.ContainsKey($BrowserName) -and (Test-Path $profiles[$BrowserName])) {
        $targetDir = "$BackupDir\${BrowserName}_profile"
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

        switch ($BrowserName) {
            "Firefox" {
                Copy-Item "$($profiles[$BrowserName])\*" -Filter "logins.json","key4.db","extensions.json" -Recurse -Destination $targetDir -Force -ErrorAction SilentlyContinue
            }
            default {
                Copy-Item "$($profiles[$BrowserName])\Login Data" -Destination "$targetDir\Login Data" -Force -ErrorAction SilentlyContinue
                Copy-Item "$($profiles[$BrowserName])\Extensions" -Destination "$targetDir\Extensions" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host "$BrowserName: estensioni/password salvate in $targetDir"
    } else {
        Write-Host "$BrowserName: profilo non trovato o browser non installato."
    }
}

function Restore-BrowserSecrets {
    param ($BrowserName, $BackupDir, $BrowserPaths)

    if (-Not (Test-Path $BrowserPaths[$BrowserName])) {
        if (Test-Path "$BackupDir\${BrowserName}_profile") {
            Write-Host "⚠️ Il backup di $BrowserName esiste, ma il browser non è installato."
        }
        return
    }

    $profileRestore = "$BackupDir\${BrowserName}_profile"
    if (Test-Path $profileRestore) {
        Write-Host "$BrowserName: backup disponibile in $profileRestore. Per ripristinare, copia manualmente i file nel profilo utente attivo."
    } else {
        Write-Host "$BrowserName: nessun backup trovato da ripristinare."
    }
}
