$ProjectRoot = Split-Path -Parent $PSScriptRoot
$VersionName = "KabboLike_Demo_0.1.0"
$ReleaseRoot = Join-Path $ProjectRoot "release"
$PackageDir = Join-Path $ReleaseRoot $VersionName
$BuildExe = Join-Path $ProjectRoot "builds/windows/KabboLike.exe"
$ZipPath = Join-Path $ReleaseRoot "KabboLike_Demo_0.1.0_Windows.zip"

if (-not (Test-Path -LiteralPath $BuildExe)) {
    throw "No existe $BuildExe. Ejecuta tools/build_windows.ps1 primero."
}

if (Test-Path -LiteralPath $PackageDir) {
    Remove-Item -LiteralPath $PackageDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $PackageDir | Out-Null

Copy-Item -LiteralPath $BuildExe -Destination (Join-Path $PackageDir "KabboLike.exe") -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot "VERSION.txt") -Destination (Join-Path $PackageDir "VERSION.txt") -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot "docs/TESTER_GUIDE.md") -Destination (Join-Path $PackageDir "README_TESTERS.txt") -Force

$LicensePath = Join-Path $ProjectRoot "LICENSE.txt"
if (Test-Path -LiteralPath $LicensePath) {
    Copy-Item -LiteralPath $LicensePath -Destination (Join-Path $PackageDir "LICENSE.txt") -Force
}

if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}
Compress-Archive -LiteralPath $PackageDir -DestinationPath $ZipPath -Force
Write-Host "Paquete creado: $ZipPath"
