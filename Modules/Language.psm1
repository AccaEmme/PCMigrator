# Modules/Language.psm1

function Get-Language {
    Write-Host "🌍 Seleziona una lingua:"
    Write-Host "1) Italiano (default)"
    Write-Host "2) English"
    Write-Host "3) Français"
    Write-Host "4) Deutsch"
    $langChoice = Read-Host "Scegli (1-4)"
    switch ($langChoice) {
        '2' { return 'en' }
        '3' { return 'fr' }
        '4' { return 'de' }
        default { return 'it' }
    }
}

function Get-Text {
    param (
        [string]$Key,
        [string]$Lang
    )

    $TextMap = @{
        "welcome" = @{
            "it" = "🗂️ Benvenuto nello script di Backup/Ripristino - AccaEmme"
            "en" = "🗂️ Welcome to the Backup/Restore script - AccaEmme"
            "fr" = "🗂️ Bienvenue dans le script de sauvegarde/restauration - AccaEmme"
            "de" = "🗂️ Willkommen im Backup-/Wiederherstellungsskript - AccaEmme"
        }
        "select_option" = @{
            "it" = "Scegli un'opzione"
            "en" = "Select an option"
            "fr" = "Choisissez une option"
            "de" = "Wähle eine Option"
        }
        "exit" = @{
            "it" = "Uscita dallo script."
            "en" = "Exiting the script."
            "fr" = "Quitter le script."
            "de" = "Das Skript wird beendet."
        }
        # ↪️ Puoi aggiungere altre frasi chiave qui
    }

    return $TextMap[$Key][$Lang]
}
