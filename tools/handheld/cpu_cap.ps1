# Handheld slower-core simulator (docs/handheld/LEDGER.md, E18): a Deck's Zen 2 core does less per
# thread than this PC's. This finds the process whose command line contains -Tag (or takes -ProcessId),
# puts it in a job object with a CPU-rate HARD cap of -Pct percent of ONE logical CPU (the game's CPU
# side is one main thread, E15), and prints one JSON line. Caveat: Windows enforces the cap by
# throttling in slices (the process stops when its budget for the interval is spent), so it models
# a slower core's throughput, not its latency: read the frame log's tail as well as its median.
param([string]$Tag = '', [int]$ProcessId = 0, [double]$Pct = 100)
$ErrorActionPreference = 'Stop'
Add-Type -Name Job -Namespace HandheldSim -MemberDefinition @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr CreateJobObject(IntPtr a, string name);
[DllImport("kernel32.dll")] public static extern bool SetInformationJobObject(IntPtr job, int cls, ref UInt64 info, int len);
[DllImport("kernel32.dll")] public static extern bool AssignProcessToJobObject(IntPtr job, IntPtr proc);
'@
$p = $null
if ($ProcessId -gt 0) { $p = Get-Process -Id $ProcessId }
$deadline = (Get-Date).AddSeconds(60)
while (-not $p) {
  $c = Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Where-Object { $_.CommandLine -like "*$Tag*" } | Select-Object -First 1
  if ($c) { $p = Get-Process -Id $c.ProcessId; break }
  if ((Get-Date) -gt $deadline) { exit 2 }
  Start-Sleep -Milliseconds 200
}
$logical = [Environment]::ProcessorCount
# CpuRate is in 1/100 % of every logical CPU together: one logical CPU at 100 % = 10000 / logical.
$rate = [uint32][math]::Max(1, [math]::Round($Pct * 100.0 / $logical))
$job = [HandheldSim.Job]::CreateJobObject([IntPtr]::Zero, $null)
# JOBOBJECT_CPU_RATE_CONTROL_INFORMATION: ControlFlags (ENABLE 0x1 | HARD_CAP 0x4), then CpuRate.
[UInt64]$info = ([UInt64]$rate -shl 32) -bor 0x5
$set = [HandheldSim.Job]::SetInformationJobObject($job, 15, [ref]$info, 8)
$assigned = [HandheldSim.Job]::AssignProcessToJobObject($job, $p.Handle)
$o = [ordered]@{ pid = $p.Id; pct_of_one_cpu = $Pct; cpu_rate = $rate; logical = $logical; set = $set; assigned = $assigned }
$o | ConvertTo-Json -Compress
# The job lives while this script holds its handle: stay until the process exits.
if ($set -and $assigned) { $p.WaitForExit() }
