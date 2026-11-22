# Run from any directory with this worktree imported and GODOT_BIN set.
param(
    [Parameter(Mandatory)][string]$Movie,
    [ValidateSet('first_kill', 'guard_lesson', 'pistol_pickup', 'mulroney_order')][string]$Clip
)

$ErrorActionPreference = 'Stop'
if (-not $env:GODOT_BIN) { throw 'Set GODOT_BIN to the pinned Godot console executable.' }
if (-not [IO.Path]::IsPathRooted($Movie) -or [IO.Path]::GetExtension($Movie) -ne '.avi') {
    throw 'Movie must be an absolute .avi path.'
}

# The native writer reads its quality during module startup, before scene scripts run.
# Give it a local project profile and the same imported resources as the pilot.
$project = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$capture = Join-Path (Split-Path $project) 'build/prologue-film'
$null = New-Item -ItemType Directory -Force -Path $capture
foreach ($entry in Get-ChildItem -LiteralPath $project -Force) {
    $target = Join-Path $capture $entry.Name
    if ($entry.PSIsContainer) {
        if (-not (Test-Path -LiteralPath $target)) {
            $null = New-Item -ItemType Junction -Path $target -Target $entry.FullName
        } elseif ((Get-Item -LiteralPath $target -Force).Target -ne $entry.FullName) {
            throw "Unexpected resource target at $target"
        }
    } elseif ($entry.Name -ne 'override.cfg') {
        Copy-Item -LiteralPath $entry.FullName -Destination $target -Force
    }
}
$profile = @'
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/window_width_override=1920
window/size/window_height_override=1080
[editor]
movie_writer/video_quality=0.32
'@
[IO.File]::WriteAllText((Join-Path $capture 'override.cfg'), $profile)
$flags = @('--bot', '--seed=7', '--view=tilt70')
if ($Clip) { $flags += "--clip=$Clip" }
# Windows PowerShell represents redirected native stderr (including engine warnings)
# as error records. The engine exit code determines whether the movie was written.
$ErrorActionPreference = 'Continue'
& $env:GODOT_BIN --path $capture --windowed --rendering-driver d3d12 --position '0,1440' `
    --resolution 1920x1080 --fixed-fps 60 --write-movie $Movie `
    res://dev/prologue/prologue_film.tscn -- @flags
exit $LASTEXITCODE
