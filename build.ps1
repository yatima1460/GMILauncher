#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build script for GMILauncher Windows package
.DESCRIPTION
    This script creates a Windows executable package for GMILauncher.
    It can run on Windows, Mac, or Linux with PowerShell installed.
.PARAMETER LoveVersion
    The version of LOVE2D to use (default: 11.5)
.PARAMETER OutputDir
    The output directory for the built package (default: dist)
.PARAMETER SkipDownload
    Skip downloading LOVE2D if it already exists
.EXAMPLE
    ./build.ps1
    ./build.ps1 -LoveVersion "11.4" -OutputDir "release"
#>

param(
    [string]$LoveVersion = "11.5",
    [string]$OutputDir = "dist",
    [switch]$SkipDownload = $false
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Step {
    param([string]$Message)
    Write-Host "===> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor Red
}

# Main build process
try {
    Write-Step "Starting GMILauncher Windows build process"
    Write-Host "LOVE2D Version: $LoveVersion"
    Write-Host "Output Directory: $OutputDir"
    Write-Host ""

    # Check if we're in the correct directory
    if (-not (Test-Path "main.lua")) {
        throw "main.lua not found. Please run this script from the project root directory."
    }

    # Download LOVE2D for Windows
    $loveDir = "love2d"
    $loveZip = "love.zip"

    if (-not $SkipDownload -or -not (Test-Path $loveDir)) {
        Write-Step "Downloading LOVE2D $LoveVersion for Windows"

        $loveUrl = "https://github.com/love2d/love/releases/download/$LoveVersion/love-$LoveVersion-win64.zip"

        try {
            Invoke-WebRequest -Uri $loveUrl -OutFile $loveZip -ErrorAction Stop
            Write-Success "Downloaded LOVE2D"
        } catch {
            throw "Failed to download LOVE2D from $loveUrl. Error: $_"
        }

        Write-Step "Extracting LOVE2D"
        if (Test-Path $loveDir) {
            Remove-Item $loveDir -Recurse -Force
        }
        Expand-Archive -Path $loveZip -DestinationPath . -Force
        Move-Item "love-$LoveVersion-win64" $loveDir -Force
        Remove-Item $loveZip -Force
        Write-Success "Extracted LOVE2D"
    } else {
        Write-Step "Skipping LOVE2D download (already exists)"
    }

    # Create .love file
    Write-Step "Creating .love file"

    $buildDir = "build"
    if (Test-Path $buildDir) {
        Remove-Item $buildDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

    # Copy all .lua files from root directory
    Write-Host "  Copying Lua files..."
    Get-ChildItem -Path "." -Filter "*.lua" -File | ForEach-Object {
        Copy-Item $_.FullName -Destination "build/$($_.Name)" -Force
    }

    # Copy directories that exist (preserving structure)
    # Note: games folder is excluded and will be copied to dist separately
    $dirs = @("assets", "ui", "utils", "vendor", "docs")
    foreach ($dir in $dirs) {
        if (Test-Path $dir) {
            Write-Host "  Copying directory: $dir"
            Copy-Item -Path $dir -Destination $buildDir -Recurse -Force
        }
    }

    Write-Success "Copied all files to build directory"

    # Create .love file (which is just a ZIP with .love extension)
    Write-Host "  Creating GMILauncher.love..."
    $loveFile = "GMILauncher.love"
    $tempZip = "GMILauncher.temp.zip"
    if (Test-Path $loveFile) {
        Remove-Item $loveFile -Force
    }
    if (Test-Path $tempZip) {
        Remove-Item $tempZip -Force
    }
    Compress-Archive -Path "build/*" -DestinationPath $tempZip -Force
    Move-Item $tempZip $loveFile -Force
    Write-Success "Created .love file"

    # Fuse .love file with LOVE2D
    Write-Step "Creating standalone executable"

    $loveExe = "$loveDir/love.exe"
    $outputExe = "GMILauncher.exe"

    if (-not (Test-Path $loveExe)) {
        throw "love.exe not found at $loveExe"
    }

    
    # Set custom icon if available
    Write-Host "Setting custom icon"
    try {
        Write-Host "  Setting icon using rcedit..."
        Write-Host "    Icon file: assets/gmi_logo.ico"
        Write-Host "    Target EXE: $loveExe"
        $result = & "vendor/rcedit-x64.exe" $loveExe --set-icon "assets/gmi_logo.ico" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "rcedit completed successfully"
        } else {
            Write-Host "  Warning: rcedit returned exit code $LASTEXITCODE" -ForegroundColor Yellow
            if ($result) {
                Write-Host "  Output: $result" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Warning "  Warning: Failed to set custom icon: $_" -ForegroundColor Yellow
    }
    

    # Concatenate love.exe and .love file
    $loveBytes = [System.IO.File]::ReadAllBytes($loveExe)
    $gameBytes = [System.IO.File]::ReadAllBytes($loveFile)
    $combined = $loveBytes + $gameBytes
    [System.IO.File]::WriteAllBytes($outputExe, $combined)
    Write-Success "Created GMILauncher.exe"

    # Package Windows distribution
    Write-Step "Packaging Windows distribution"

    if (Test-Path $OutputDir) {
        Remove-Item $OutputDir -Recurse -Force
        Write-Success "Cleared existing $OutputDir directory"
    }
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

    # Copy the fused executable
    Copy-Item $outputExe -Destination "$OutputDir/" -Force


    # Copy all necessary DLLs from LOVE2D
    Write-Host "  Copying LOVE2D DLLs..."
    Get-ChildItem "$loveDir/*.dll" | ForEach-Object {
        Copy-Item $_.FullName -Destination "$OutputDir/" -Force
    }

    # Copy games folder to distribution (not bundled in .exe)
    if (Test-Path "games") {
        Write-Host "  Copying games folder..."
        Copy-Item -Path "games" -Destination "$OutputDir/" -Recurse -Force
        Write-Success "Copied games folder to distribution"
    }

    # Copy license files
    if (Test-Path "LICENSE") {
        Copy-Item "LICENSE" -Destination "$OutputDir/" -Force
    }
    if (Test-Path "README.md") {
        Copy-Item "README.md" -Destination "$OutputDir/" -Force
    }
    if (Test-Path "CREDITS.md") {
        Copy-Item "CREDITS" -Destination "$OutputDir/" -Force
    }
    if (Test-Path "$loveDir/license.txt") {
        Copy-Item "$loveDir/license.txt" -Destination "$OutputDir/LOVE2D-LICENSE.txt" -Force
    }

    Write-Success "Packaged all files to $OutputDir/"

    # Create ZIP archive
    Write-Step "Creating distribution archive"
    $zipFile = "GMILauncher-Windows.zip"
    if (Test-Path $zipFile) {
        Remove-Item $zipFile -Force
    }
    Compress-Archive -Path "$OutputDir/*" -DestinationPath $zipFile -Force
    Write-Success "Created $zipFile"

    # Cleanup temporary files
    Write-Step "Cleaning up temporary files"
    Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $loveFile -Force -ErrorAction SilentlyContinue
    Remove-Item $outputExe -Force -ErrorAction SilentlyContinue
    Write-Success "Cleanup complete"

    Write-Host ""
    Write-Success "Build completed successfully!"
    Write-Host "To test the build, run: ./$OutputDir/GMILauncher.exe" -ForegroundColor Yellow

} catch {
    Write-Host ""
    Write-Error-Custom "Build failed: $_"
    Write-Host ""
    exit 1
}
