$ErrorActionPreference = "Stop"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "WinGet is missing. Install Microsoft App Installer first."
}

$packages = @(
    "EclipseAdoptium.Temurin.21.JDK"
    "Git.Git"
    "EclipseFoundation.Eclipse.Java"
    "Microsoft.VisualStudioCode"
)

foreach ($packageId in $packages) {
    winget list --id $packageId --exact --source winget `
        --accept-source-agreements --disable-interactivity

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Already installed: $packageId"
        continue
    }

    winget install --id $packageId --exact --source winget `
        --silent --accept-package-agreements `
        --accept-source-agreements --disable-interactivity

    if ($LASTEXITCODE -ne 0) {
        throw "Installation failed for $packageId (exit $LASTEXITCODE)."
    }
}

$env:Path = (
    [Environment]::GetEnvironmentVariable("Path", "Machine"),
    [Environment]::GetEnvironmentVariable("Path", "User"),
    $env:Path
) -join ";"

$gitExecutable = (Get-Command git -ErrorAction Stop).Source
$projectRoot = "C:\Projects"
$repositoryPath = Join-Path $projectRoot "hybris-commerce-eclipse-plugin"

New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null

if (-not (Test-Path $repositoryPath)) {
    & $gitExecutable clone `
        "https://github.com/SAP/hybris-commerce-eclipse-plugin.git" `
        $repositoryPath

    if ($LASTEXITCODE -ne 0) {
        throw "Repository clone failed."
    }
} elseif (-not (Test-Path (Join-Path $repositoryPath ".git"))) {
    throw "Destination exists but is not a Git checkout: $repositoryPath"
} else {
    Write-Host "Existing checkout preserved: $repositoryPath"
}
