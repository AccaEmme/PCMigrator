# Author: Acca Emme
# Created on 23 July 2025
# Last update: 24 July 2025

# PCMigrator.ps1

# Carica i moduli
Import-Module "$PSScriptRoot\Modules\Language.psm1"
Import-Module "$PSScriptRoot\Modules\BrowserBackup.psm1"
Import-Module "$PSScriptRoot\Modules\SystemBackup.psm1"
Import-Module "$PSScriptRoot\Modules\BackupMenu.psm1"
Import-Module "$PSScriptRoot\Modules\RestoreMenu.psm1"

# Imposta cartella di backup
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BackupDir = Join-Path $ScriptPath "PCMigrator_bkp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

# Selezione lingua
$Lang = Get-Language

# Menu principale
do {
    Write-Host "`n" + (Get-Text -Key "welcome" -Lang $Lang)
    Write-Host "1) Backup"
    Write-Host "2) Ripristino"
    Write-Host "0) Esci"
    $mainChoice = Read-Host (Get-Text -Key "select_option" -Lang $Lang)

    switch ($mainChoice) {
        '1' { Do-BackupMenu -BackupDir $BackupDir -Lang $Lang }
        '2' { Do-RestoreMenu -BackupDir $BackupDir -Lang $Lang }
        '0' { Write-Host (Get-Text -Key "exit" -Lang $Lang) }
        default { Write-Host "❌ Scelta non valida." }
    }
} while ($mainChoice -ne '0')
