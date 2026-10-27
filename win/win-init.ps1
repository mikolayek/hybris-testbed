$ErrorActionPreference = "Stop"

choco install temurin21 git eclipse -y --no-progress
if ($LASTEXITCODE -ne 0) {
    throw "Software installation failed."
}

$projectRoot = "C:\Projects"
$repositoryPath = Join-Path $projectRoot "hybris-commerce-eclipse-plugin"
$gitExecutable = "C:\Program Files\Git\cmd\git.exe"

New-Item -ItemType Directory -Force -Path $projectRoot | Out-Null

if (-not (Test-Path (Join-Path $repositoryPath ".git"))) {
    & $gitExecutable clone `
        "https://github.com/SAP/hybris-commerce-eclipse-plugin.git" `
        $repositoryPath

    if ($LASTEXITCODE -ne 0) {
        throw "Repository clone failed."
    }
}
