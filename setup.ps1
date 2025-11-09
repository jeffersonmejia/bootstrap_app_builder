# READ STUDENT NAME AND PARTIAL NUMBER FROM ENV
function Get-EnvValues {
    $envFile = ".\.env.development"
    if (-Not (Test-Path $envFile)) {
        Write-Host "ERROR: .env.development file not found!" -ForegroundColor Red
        exit
    }

    $lines = Get-Content $envFile | Where-Object { $_ -match "=" }
    $studentName = ""
    $partialNumber = ""

    foreach ($line in $lines) {
        $parts = $line -split "=", 2
        switch ($parts[0].Trim()) {
            "STUDENT_NAME" { $studentName = $parts[1].Trim() }
            "PARTIAL_NUMBER" { $partialNumber = $parts[1].Trim() }
        }
    }

    if (-not $studentName) {
        Write-Host "ERROR: STUDENT_NAME not found in .env.development" -ForegroundColor Red
        exit
    }
    if (-not $partialNumber) {
        Write-Host "ERROR: PARTIAL_NUMBER not found in .env.development" -ForegroundColor Red
        exit
    }

    return @($studentName, $partialNumber)
}

# ASK TYPE AND ACTIVITY NUMBER
function Get-ProjectInfo {
    Write-Host "Select activity type:" -ForegroundColor Cyan
    Write-Host "1. Tarea" -ForegroundColor Yellow
    Write-Host "2. Lab" -ForegroundColor Yellow
    $typeOption = Read-Host "Option"
    switch ($typeOption) {
        1 { $typeStr = "Tarea" }
        2 { $typeStr = "Lab" }
        default { Write-Host "Opción inválida" -ForegroundColor Red; exit }
    }

    $activityNumber = Read-Host "Enter activity number"

    return @($typeStr, $activityNumber)
}

# CREATE FOLDERS (HIDE OUTPUT)
function Create-Folders {
    param([string]$projectName)
    cls
    New-Item -Path . -Name $projectName -ItemType Directory -Force | Out-Null
    New-Item -Path ".\$projectName\scripts" -ItemType Directory -Force | Out-Null
    New-Item -Path ".\$projectName\src\assets" -ItemType Directory -Force | Out-Null
    New-Item -Path ".\$projectName\src\js" -ItemType Directory -Force | Out-Null
    Write-Host "[SUCCESS] Folder structure for $projectName created" -ForegroundColor Green
}

# COPY TEMPLATES
function Copy-Templates {
    param([string]$projectName)
    Copy-Item -Path ".\templates\deployment.ps1" -Destination ".\$projectName\scripts\deployment.ps1" -Force
    Copy-Item -Path ".\templates\main.js" -Destination ".\$projectName\src\js\main.js" -Force
    Copy-Item -Path ".\templates\index.html" -Destination ".\$projectName\index.html" -Force
    Copy-Item -Path ".\templates\.gitignore" -Destination ".\$projectName\.gitignore" -Force
    Copy-Item -Path ".\templates\package.json" -Destination ".\$projectName\package.json" -Force
    Copy-Item -Path ".\templates\vite.config.js" -Destination ".\$projectName\vite.config.js" -Force
    Write-Host "[SUCCESS] Templates copied successfully" -ForegroundColor Green
}

# MODIFY VITE CONFIG
function Update-ViteConfig {
    param([string]$projectName)
    $vitePath = ".\$projectName\vite.config.js"
    (Get-Content $vitePath) -replace "base: '/restaurant_app_1/',", "base: '/$projectName/'," | Set-Content $vitePath
    Write-Host "[INFO] Vite config updated for $projectName" -ForegroundColor Cyan
}

#SETUP NPM
function Setup-NpmAndCode {
    param([string]$projectName)
    Set-Location ".\$projectName"
    Write-Host "[MESSAGE] Project $projectName created" -ForegroundColor Magenta
    Write-Host "[MESSAGE] Installing npm packages... wait for it." -ForegroundColor Magenta
    npm install
    cls
    Write-Host "[SUCCESS] Packages installed successfully." -ForegroundColor Green
    Write-Host "[INFO] Starting VS Code in 5s..." -ForegroundColor Cyan

    # TIME VS CODE OPEN
    Start-Job {
        $seconds = 5
        while ($seconds -gt 0) {
            Write-Host "[INFO] Opening VS Code in $seconds s" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            Write-Host "`r" -NoNewline
            $seconds--
        }
       code ".\$projectName\index.html"
    } | Out-Null

    # Ejecutar npm run dev attached
    npm run dev
}

# MAIN EXECUTION FUNCTION
function Main {
    $envValues = Get-EnvValues
    $studentName = $envValues[0]
    $partialNumber = $envValues[1]

    $projectInfo = Get-ProjectInfo
    $typeStr = $projectInfo[0]
    $activityNumber = $projectInfo[1]

    $projectName = "P$partialNumber$studentName$typeStr$activityNumber`_web"

    Create-Folders $projectName
    Copy-Templates $projectName
    Update-ViteConfig $projectName
    Setup-NpmAndCode $projectName
}

# RUN MAIN
Main
