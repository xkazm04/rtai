# F19 hunt: quest 1 under --autostart (head, editor binary, windowed D3D12, pinned TOPMOST); after 14 s, 3 s of process CPU;
# a run under 0.05 cores is a freeze: IsHungAppWindow + thread_cpu.ps1 (3 s) are written as freeze-<n>.json. Up to -Runs runs.
param([int]$Runs = 5)
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class W { [DllImport("user32.dll")] public static extern bool IsHungAppWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int cx, int cy, uint f); }
"@
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here '..\..\..')
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-d9x/appdata/perf'
for ($n = 1; $n -le $Runs; $n++) {
  $a = @('--path', "$repo\project", '--screen', '0', '--rendering-driver', 'd3d12', '--resolution', '1920x1080', 'res://boot/quest1.tscn', '--', '--autostart')
  $log = Join-Path $env:TEMP "f19-$n.log"
  $p = Start-Process -FilePath $godot -ArgumentList $a -PassThru -WindowStyle Hidden -RedirectStandardOutput $log
  Start-Sleep -Seconds 3
  $c = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' } | Select-Object -First 1
  $g = Get-Process -Id ([int]$c.ProcessId)
  for ($i = 0; $i -lt 20 -and $g.MainWindowHandle -eq 0; $i++) { Start-Sleep -Milliseconds 250; $g.Refresh() }
  [void][W]::SetWindowPos($g.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0013)
  Start-Sleep -Seconds 11
  $g.Refresh(); $c0 = $g.TotalProcessorTime.TotalSeconds; Start-Sleep -Seconds 3; $g.Refresh()
  $cores = [math]::Round(($g.TotalProcessorTime.TotalSeconds - $c0) / 3, 3)
  $hung = [W]::IsHungAppWindow($g.MainWindowHandle)
  $line = [ordered]@{ run = $n; cores = $cores; hung = $hung; responding = $g.Responding }
  if ($cores -lt 0.05) {
    $tc = & (Join-Path $repo 'tools\perf\thread_cpu.ps1') -ProcessId $g.Id -Seconds 3
    $tc | Set-Content -Encoding utf8 (Join-Path $here "freeze-$n.json")
    Copy-Item $log (Join-Path $here "freeze-$n.log")
  }
  & taskkill /F /T /PID $p.Id | Out-Null
  $line | ConvertTo-Json -Compress
  if ($cores -lt 0.05) { break }
}
