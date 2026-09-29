param(
    [string]$Godot = 'godot',
    [string[]]$GodotArgs = @()
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'project.godot') -PathType Leaf)) {
    throw "No Godot project found in '$PSScriptRoot'."
}

if (-not (Get-Command -Name $Godot -ErrorAction SilentlyContinue)) {
    throw "Godot executable '$Godot' was not found. Install Godot or pass its path with -Godot."
}

& $Godot --path $PSScriptRoot @GodotArgs
exit $LASTEXITCODE
