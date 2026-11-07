# Handheld suspend simulator (docs/handheld/LEDGER.md): a Deck's sleep freezes the game process
# without telling it. This finds the Godot process whose command line contains -Tag, waits
# -AfterS seconds, freezes it (NtSuspendProcess) for -ForS seconds, resumes it, and prints one JSON
# line with the wall times. The game's own frame log then shows what the resume did.
param([string]$Tag, [int]$AfterS = 12, [int]$ForS = 20)
$ErrorActionPreference = 'Stop'
Add-Type -Name Nt -Namespace HandheldSim -MemberDefinition @'
[DllImport("ntdll.dll")] public static extern int NtSuspendProcess(IntPtr h);
[DllImport("ntdll.dll")] public static extern int NtResumeProcess(IntPtr h);
'@
$deadline = (Get-Date).AddSeconds(60)
$p = $null
while (-not $p) {
  $c = Get-CimInstance Win32_Process -Filter "Name like 'Godot%'" | Where-Object { $_.CommandLine -like "*$Tag*" } | Select-Object -First 1
  if ($c) { $p = Get-Process -Id $c.ProcessId; break }
  if ((Get-Date) -gt $deadline) { exit 2 }
  Start-Sleep -Milliseconds 200
}
Start-Sleep -Seconds $AfterS
$t0 = Get-Date
$s = [HandheldSim.Nt]::NtSuspendProcess($p.Handle)
Start-Sleep -Seconds $ForS
$r = [HandheldSim.Nt]::NtResumeProcess($p.Handle)
$o = [ordered]@{ pid = $p.Id; suspend_status = $s; resume_status = $r; suspended_at = $t0.ToString('o'); suspended_s = $ForS }
$o | ConvertTo-Json -Compress
