# Handheld simulator sampler (tools/handheld/sim.mjs): once per interval, the Godot process whose
# command line contains -Tag: CPU % (of the whole machine and of its pinned threads), working set,
# private bytes, and the GPU process memory counters (dedicated = VRAM, shared = system RAM the
# GPU maps; an integrated GPU lives in shared). One JSON line per sample on stdout; exits when the
# process is gone (or never appears within 60 s).
param([string]$Tag, [int]$IntervalMs = 1000, [int]$Threads = 16)
$ErrorActionPreference = 'SilentlyContinue'
$logical = [Environment]::ProcessorCount
$deadline = (Get-Date).AddSeconds(60)
$procId = $null
while (-not $procId) {
  $p = Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Where-Object { $_.CommandLine -like "*$Tag*" } | Select-Object -First 1
  if ($p) { $procId = $p.ProcessId; break }
  if ((Get-Date) -gt $deadline) { exit 2 }
  Start-Sleep -Milliseconds 200
}
$last = $null
$lastT = $null
while ($true) {
  $proc = Get-Process -Id $procId
  if (-not $proc) { break }
  $now = Get-Date
  $cpu = $proc.TotalProcessorTime.TotalMilliseconds
  if ($last -ne $null) {
    $wall = ($now - $lastT).TotalMilliseconds
    $used = $cpu - $last
    $ded = 0; $sh = 0
    $c = Get-Counter -Counter "\GPU Process Memory(pid_$($procId)_*)\Dedicated Usage", "\GPU Process Memory(pid_$($procId)_*)\Shared Usage" -MaxSamples 1
    foreach ($s in $c.CounterSamples) {
      if ($s.Path -like '*dedicated usage') { $ded += $s.CookedValue } else { $sh += $s.CookedValue }
    }
    $o = [ordered]@{
      t_ms = [int]($now - $deadline.AddSeconds(-60)).TotalMilliseconds
      cpu_machine_pct = [math]::Round(100 * $used / $wall / $logical, 2)
      cpu_pinned_pct = [math]::Round(100 * $used / $wall / $Threads, 2)
      ws_mb = [math]::Round($proc.WorkingSet64 / 1MB, 1)
      private_mb = [math]::Round($proc.PrivateMemorySize64 / 1MB, 1)
      gpu_dedicated_mb = [math]::Round($ded / 1MB, 1)
      gpu_shared_mb = [math]::Round($sh / 1MB, 1)
      affinity = [long]$proc.ProcessorAffinity
    }
    $o | ConvertTo-Json -Compress
  }
  $last = $cpu
  $lastT = $now
  Start-Sleep -Milliseconds $IntervalMs
}
