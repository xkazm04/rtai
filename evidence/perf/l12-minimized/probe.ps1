# L12 probe: what the game costs while minimized (the alt-tabbed player). One riot60 run (editor binary, the ab.mjs
# riot60 preset, vsync on, 60 s of sim): thread_cpu.ps1 for 10 s with the window shown, then the window is minimized
# (ShowWindow SW_MINIMIZE) and sampled again for 10 s. Writes probe-<tag>-shown.json / -min.json beside this file.
param([string]$Tag = 'a', [string]$Extra = '')
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class SW { [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd); }
"@
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here '..\..\..')
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-d9x/appdata/perf'
$out = Join-Path $env:TEMP "l12-probe-$Tag.json"
$a = @('--path', "$repo\project", '--screen', '0', '--rendering-driver', 'd3d12', '--resolution', '1920x1080',
  'res://dev/bench/city_bench.tscn', '--', '--scenario=riot', '--zoom=1.0', '--view=tilt70', '--secs=60', '--vsync=enabled', "--out=$out")
if ($Extra) { $a += $Extra.Split(' ') }
$p = Start-Process -FilePath $godot -ArgumentList $a -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3
$child = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' } | Select-Object -First 1
$target = [int]$child.ProcessId
$tool = Join-Path $repo 'tools\perf\thread_cpu.ps1'
& $tool -ProcessId $target -Seconds 10 -Delay 9 | Set-Content -Encoding utf8 (Join-Path $here "probe-$Tag-shown.json")
$h = (Get-Process -Id $target).MainWindowHandle
[void][SW]::ShowWindow($h, 6) # SW_MINIMIZE
& $tool -ProcessId $target -Seconds 10 -Delay 2 | Set-Content -Encoding utf8 (Join-Path $here "probe-$Tag-min.json")
[void][SW]::ShowWindow($h, 9) # SW_RESTORE
$p.WaitForExit(180000) | Out-Null
Copy-Item $out (Join-Path $here "bench-$Tag.json") -ErrorAction SilentlyContinue
