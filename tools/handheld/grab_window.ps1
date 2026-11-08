# Handheld simulator window grab (docs/handheld/LEDGER.md): waits for the Godot process whose
# command line contains -Tag, then -AfterSec seconds later copies its window's client area from the
# screen to -Out (PNG): what the panel shows, after the engine's stretch (Movie Maker records the
# project's base size instead, and the arena's --shot grabs the drawn viewport before the scale-up).
# Read-only on the game. The window is read with PrintWindow (not occluded by others), else the screen. Exit 0 written, 2 no process / window.
param([string]$Tag, [double]$AfterSec = 12, [string]$Out)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class HhWin {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
}
'@
[void][HhWin]::SetProcessDPIAware()
$deadline = (Get-Date).AddSeconds(60)
$procId = $null
while (-not $procId) {
  $p = Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Where-Object { $_.CommandLine -like "*$Tag*" } | Select-Object -First 1
  if ($p) { $procId = $p.ProcessId; break }
  if ((Get-Date) -gt $deadline) { exit 2 }
  Start-Sleep -Milliseconds 200
}
Start-Sleep -Milliseconds ([int]($AfterSec * 1000))
$h = (Get-Process -Id $procId).MainWindowHandle
if ($h -eq [IntPtr]::Zero) { exit 2 }
$r = New-Object HhWin+RECT
[void][HhWin]::GetClientRect($h, [ref]$r)
$pt = New-Object HhWin+POINT
[void][HhWin]::ClientToScreen($h, [ref]$pt)
$w = $r.R - $r.L; $hh = $r.B - $r.T
$bmp = New-Object System.Drawing.Bitmap $w, $hh
$g = [System.Drawing.Graphics]::FromImage($bmp)
# PrintWindow (PW_CLIENTONLY 1 | PW_RENDERFULLCONTENT 2) reads the window itself, so another window
# lying over it (other lanes' Godot runs share the monitor) is not captured; the screen copy is the fallback.
$hdc = $g.GetHdc()
$ok = [HhWin]::PrintWindow($h, $hdc, 3)
$g.ReleaseHdc($hdc)
if (-not $ok) { $g.CopyFromScreen($pt.X, $pt.Y, 0, 0, (New-Object System.Drawing.Size $w, $hh)) }
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "grab $($w)x$($hh) at $($pt.X),$($pt.Y) -> $Out"
