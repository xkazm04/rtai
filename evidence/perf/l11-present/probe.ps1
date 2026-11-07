# L11 mechanism probe: one riot60 run per arm (editor binary, the ab.mjs riot60 preset), thread_cpu.ps1 sampled
# 12 s into the run for 10 s. Writes probe-<arm>.json beside this file. Run while holding bench.lock.
param([string]$Arm = 'v60', [string]$Extra = '')
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here '..\..\..')
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-d9x/appdata/perf'
$out = Join-Path $env:TEMP "l11-probe-$Arm.json"
$a = @('--path', "$repo\project", '--screen', '0', '--rendering-driver', 'd3d12', '--max-fps', '60', '--resolution', '1920x1080',
  'res://dev/bench/city_bench.tscn', '--', '--scenario=riot', '--zoom=1.0', '--view=tilt70', '--secs=30', '--vsync=enabled', "--out=$out")
if ($Extra) { $a += $Extra.Split(' ') }
$p = Start-Process -FilePath $godot -ArgumentList $a -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3
$child = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' } | Select-Object -First 1
$target = if ($child) { [int]$child.ProcessId } else { $p.Id }
& (Join-Path $repo 'tools\perf\thread_cpu.ps1') -ProcessId $target -Seconds 10 -Delay 9 | Set-Content -Encoding utf8 (Join-Path $here "probe-$Arm.json")
$p.WaitForExit(120000) | Out-Null
