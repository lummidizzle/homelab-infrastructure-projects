# Set the path to the auto-screenshots folder
$folderPath = "D:\GitHub\homelab-infrastructure-projects\assets\screenshots\auto-screenshots"
$readmePath = Join-Path $folderPath "README.md"

# Content for the README file
$readmeContent = @"
# Auto-Screenshots Folder

This folder contains automatically captured screenshots related to the Homelab Infrastructure Projects.

Each image here was renamed using a standardized naming convention (Auto_Screenshot_###.png) for clarity and sorting.

## File Naming Convention

All files follow the format:

    Auto_Screenshot_001.png
    Auto_Screenshot_002.png
    ...
    Auto_Screenshot_###.png

## Purpose

These screenshots visually document tasks, errors, fixes, logs, or configurations captured during system builds, hardening, automation, and daily operations. They are referenced across various parts of this repository.

"@

# Write the content to the README.md file
Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8

# Confirm completion
Write-Host "`n✅ README.md file created successfully at: $readmePath" -ForegroundColor Green
