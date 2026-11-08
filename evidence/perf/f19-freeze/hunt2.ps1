# F19 hunt v2 (n9): quest 1 under --autostart, windowed D3D12, the editor binary; stdout+stderr kept per run.
# After -Settle s, 3 s of process CPU; a run under 0.05 cores is a freeze: its log is copied as freeze-<tag>-<n>.log.
# -Exe <path> runs an exported exe instead (no --path). One JSON line per run.
param([int]$Runs = 10, [string]$Tag = 'x', [int]$Settle = 12, [string]$Exe = '', [string]$Extra = '',
  [switch]$NoAutostart, [string]$Driver = 'd3d12')
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here '..\..\..')
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n9/appdata/perf'
$tmp = 'C:\Users\kazda\kiro\gtai-n9\tmp\perf'
$frozen = 0
for ($n = 1; $n -le $Runs; $n++) {
  $a = @('--rendering-driver', $Driver, '--resolution', '1920x1080')
  $bin = $godot
  if ($Exe -ne '') { $bin = $Exe } else { $a = @('--path', "$repo\project") + $a + @('res://boot/quest1.tscn') }
  $a += @('--')
  if (-not $NoAutostart) { $a += @('--autostart') }
  if ($Extra -ne '') { $a += $Extra.Split(' ') }
  $log = Join-Path $tmp "f19-$Tag-$n.log"
  $err = Join-Path $tmp "f19-$Tag-$n.err"
  $p = Start-Process -FilePath $bin -ArgumentList $a -PassThru -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError $err
  Start-Sleep -Seconds 3
  $c = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' -or $_.Name -like 'RTAI*' } | Select-Object -First 1
  $gid = if ($c) { [int]$c.ProcessId } else { $p.Id }
  $g = Get-Process -Id $gid
  Start-Sleep -Seconds $Settle
  $g.Refresh(); $c0 = $g.TotalProcessorTime.TotalSeconds; Start-Sleep -Seconds 3; $g.Refresh()
  $cores = [math]::Round(($g.TotalProcessorTime.TotalSeconds - $c0) / 3, 3)
  $line = [ordered]@{ tag = $Tag; run = $n; cores = $cores; responding = $g.Responding; pid = $gid }
  if ($cores -lt 0.05) {
    $frozen++
    $tc = & (Join-Path $repo 'tools\perf\thread_cpu.ps1') -ProcessId $gid -Seconds 2
    $tc | Set-Content -Encoding utf8 (Join-Path $here "freeze-$Tag-$n.json")
    if ($env:F19_CDB -eq '1') {
      $cdb = 'C:\Users\kazda\kiro\gtai-n9\tools\windbg\cdb.exe'
      $sym = 'srv*C:\Users\kazda\kiro\gtai-n9\tools\symcache*https://msdl.microsoft.com/download/symbols'
      & $cdb -pv -p $gid -y $sym -c '~*kn 40; q' 2>&1 | Set-Content -Encoding utf8 (Join-Path $here "stacks-$Tag-$n.txt")
    }
    if ($env:F19_DUMP -eq '1') { & (Join-Path $here 'dump.ps1') -ProcessId $gid -Out (Join-Path $tmp "freeze-$Tag-$n.dmp") }
  }
  & taskkill /F /T /PID $p.Id | Out-Null
  Start-Sleep -Milliseconds 500
  if ($cores -lt 0.05) {
    Get-Content $log, $err | Set-Content -Encoding utf8 (Join-Path $here "freeze-$Tag-$n.log")
  }
  $line | ConvertTo-Json -Compress
}
"{""tag"":""$Tag"",""runs"":$Runs,""frozen"":$frozen}"
