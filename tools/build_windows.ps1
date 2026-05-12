# Opciones:
# 1. Definir $env:GODOT_EXE con la ruta al ejecutable consola de Godot.
# 2. Tener `godot` disponible en PATH.
$GodotCandidates = @(
    $env:GODOT_EXE,
    "godot"
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$Godot = $null
foreach ($Candidate in $GodotCandidates) {
    if ($Candidate -eq "godot") {
        $Command = Get-Command $Candidate -ErrorAction SilentlyContinue
        if ($Command) {
            $Godot = $Command.Source
            break
        }
        continue
    }
    if (Test-Path -LiteralPath $Candidate) {
        $Godot = $Candidate
        break
    }
}

if (-not $Godot) {
    throw "No se encontro Godot. Define GODOT_EXE o ajusta tools/build_windows.ps1."
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "builds/windows"
$Output = Join-Path $BuildDir "KabboLike.exe"

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

Push-Location $ProjectRoot
try {
    & $Godot --headless --path . --export-release "KabboLike Demo" $Output
}
finally {
    Pop-Location
}
