[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9._-]+$')]
    [string]$DistributionName = 'NixOS',

    [string]$InstallLocation = (Join-Path $env:LOCALAPPDATA 'WSL\NixOS'),

    [switch]$SetDefault,

    [switch]$KeepInstaller
)

$ErrorActionPreference = 'Stop'

$releaseUrl = 'https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos.wsl'
$installLocation = [System.IO.Path]::GetFullPath($InstallLocation)

function Fail([string]$Message) {
    throw "NixOS-WSL installation failed: $Message"
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Fail 'wsl.exe was not found. Install or update WSL first: wsl --install'
}

$existingDistributions = @(& wsl.exe --list --quiet 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($existingDistributions -contains $DistributionName) {
    Fail "a WSL distribution named '$DistributionName' already exists"
}

if (Test-Path -LiteralPath $installLocation) {
    Fail "the installation location already exists: $installLocation"
}

$parentLocation = Split-Path -Parent $installLocation
if (-not (Test-Path -LiteralPath $parentLocation)) {
    New-Item -ItemType Directory -Path $parentLocation -Force | Out-Null
}

$temporaryDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "nixos-wsl-$([guid]::NewGuid())"
$bundlePath = Join-Path $temporaryDirectory 'nixos.wsl'
New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null

try {
    Write-Host "Downloading the latest NixOS-WSL release..."
    Invoke-WebRequest -Uri $releaseUrl -OutFile $bundlePath
    if (-not (Test-Path -LiteralPath $bundlePath) -or (Get-Item -LiteralPath $bundlePath).Length -eq 0) {
        Fail 'the downloaded nixos.wsl bundle is empty'
    }

    $supportsFromFile = (& wsl.exe --help 2>&1 | Out-String) -match '--from-file'
    if ($supportsFromFile) {
        Write-Host "Installing '$DistributionName' at '$installLocation' with wsl --install --from-file..."
        & wsl.exe --install --from-file $bundlePath --name $DistributionName --location $installLocation
    }
    else {
        Write-Host "This WSL version does not support --from-file; using wsl --import..."
        & wsl.exe --import $DistributionName $installLocation $bundlePath --version 2
    }
    if ($LASTEXITCODE -ne 0) {
        Fail "wsl.exe exited with code $LASTEXITCODE"
    }

    if ($SetDefault) {
        & wsl.exe --set-default $DistributionName
        if ($LASTEXITCODE -ne 0) {
            Fail "could not set '$DistributionName' as the default distribution (exit code $LASTEXITCODE)"
        }
    }
}
finally {
    if (-not $KeepInstaller -and (Test-Path -LiteralPath $temporaryDirectory)) {
        Remove-Item -LiteralPath $temporaryDirectory -Recurse -Force
    }
}

Write-Host ''
Write-Host "NixOS-WSL '$DistributionName' is installed."
Write-Host "Start it with: wsl -d $DistributionName"
Write-Host 'Then run the NixOS bootstrap command from the repository README.'
