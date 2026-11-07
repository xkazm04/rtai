# The perf lane's process sampler (tools/perf/ab.mjs): every second, the CPU time, working set and
# thread count of every Godot process under `-Root` (the runner's own node pid: the console Godot
# spawns the real engine as a child), one JSON line per sample on stdout; the runner kills it. One PowerShell process for
# the whole run, so the sampler's own cost is one CIM query a second (labelled in the LEDGER).
param([int]$Root, [int]$EveryMs = 1000)
$ErrorActionPreference = 'SilentlyContinue'
while ($true) {
  $all = Get-CimInstance Win32_Process -Property Name, ProcessId, ParentProcessId, KernelModeTime, UserModeTime, WorkingSetSize, ThreadCount
  $ids = @{ $Root = $true }
  $grew = $true
  while ($grew) {
    $grew = $false
    foreach ($p in $all) { if ($ids.ContainsKey([int]$p.ParentProcessId) -and -not $ids.ContainsKey([int]$p.ProcessId)) { $ids[[int]$p.ProcessId] = $true; $grew = $true } }
  }
  $mine = @($all | Where-Object { $ids.ContainsKey([int]$_.ProcessId) -and ($_.Name -like 'Godot*' -or $_.Name -like 'RTAI*') })
  $cpu = 0; $ws = 0; $th = 0
  foreach ($p in $mine) { $cpu += [double]$p.KernelModeTime + [double]$p.UserModeTime; $ws += [double]$p.WorkingSetSize; $th += [int]$p.ThreadCount }
  $t = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  Write-Output ('{{"t":{0},"cpu100ns":{1},"ws":{2},"threads":{3},"procs":{4}}}' -f $t, $cpu, $ws, $th, $mine.Count)
  Start-Sleep -Milliseconds $EveryMs
}
