# L13 A/B probe: the slice (boot/quest1.tscn, editor binary, windowed D3D12 1920x1080, vsync on, screen 0).
# -Mode title: the title card, process CPU over 8 s after 8 s of boot. -Mode pause: --autostart, 14 s of play,
# CPU in play over 6 s (the window pinned TOPMOST, F19), then Esc (PostMessage WM_KEYDOWN/UP to the window), 3 s, CPU paused over 8 s.
# -Extra "--menu-idle=off" = the before. -Project = the project dir. Writes one JSON line on stdout + a still.
param([string]$Mode = 'title', [string]$Extra = '', [string]$Project, [string]$Tag = 'a')
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class W {
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [StructLayout(LayoutKind.Sequential)] public struct R { public int L, T, Rr, B; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint f);
}
"@
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-d9x/appdata/perf'
$a = @('--path', $Project, '--screen', '0', '--rendering-driver', 'd3d12', '--resolution', '1920x1080', 'res://boot/quest1.tscn', '--')
if ($Mode -eq 'pause') { $a += '--autostart' }
if ($Extra) { $a += $Extra.Split(' ') }
$log = Join-Path $env:TEMP "l13-$Tag.log"
$p = Start-Process -FilePath $godot -ArgumentList $a -PassThru -WindowStyle Hidden -RedirectStandardOutput $log
Start-Sleep -Seconds 3
$child = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' } | Select-Object -First 1
$g = Get-Process -Id ([int]$child.ProcessId)
# F19: a window covered by another lane's game idles (~0.005 cores): pin ours on top before any number.
for ($i = 0; $i -lt 20 -and $g.MainWindowHandle -eq 0; $i++) { Start-Sleep -Milliseconds 250; $g.Refresh() }
[void][W]::SetWindowPos($g.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0013)
function Cores([double]$sec) {
  $g.Refresh(); $c0 = $g.TotalProcessorTime.TotalSeconds; $t0 = [DateTime]::UtcNow
  Start-Sleep -Milliseconds ([int]($sec * 1000))
  $g.Refresh(); return [math]::Round(($g.TotalProcessorTime.TotalSeconds - $c0) / ([DateTime]::UtcNow - $t0).TotalSeconds, 3)
}
function Still([string]$name) {
  $r = New-Object W+R; [void][W]::GetWindowRect($g.MainWindowHandle, [ref]$r)
  $bmp = New-Object System.Drawing.Bitmap ($r.Rr - $r.L), ($r.B - $r.T)
  $gr = [System.Drawing.Graphics]::FromImage($bmp); $gr.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
  $bmp.Save((Join-Path $here "$name.png")); $gr.Dispose(); $bmp.Dispose()
}
$others = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'Godot*' -and $_.ProcessId -ne $g.Id -and $_.ProcessId -ne $p.Id }).Count
$res = [ordered]@{ tag = $Tag; mode = $Mode; extra = $Extra; others = $others }
if ($Mode -eq 'title') {
  Start-Sleep -Seconds 5
  $res.title = Cores 8
  Still "still-$Tag-title"
} else {
  Start-Sleep -Seconds 11
  $res.play = Cores 6
  $h = $g.MainWindowHandle
  [void][W]::PostMessage($h, 0x0100, [IntPtr]0x1B, [IntPtr]0x00010001)
  Start-Sleep -Milliseconds 60
  [void][W]::PostMessage($h, 0x0101, [IntPtr]0x1B, [IntPtr]0xC0010001)
  Start-Sleep -Seconds 3
  $res.paused = Cores 8
  Still "still-$Tag-paused"
}
$res.ws_mb = [math]::Round($g.WorkingSet64 / 1MB)
$res.started = [bool](Select-String -Path $log -Pattern 'started: Rivet' -Quiet)
& taskkill /F /T /PID $p.Id | Out-Null
$res | ConvertTo-Json -Compress
