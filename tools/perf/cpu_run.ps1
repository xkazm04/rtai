# One run of an exe with its process CPU seconds read after exit (GetProcessTimes through the
# Process handle this script holds), the instrument of n10's cpu_ab.ps1 for a single run. Prints the
# child's pid as `PID <n>` first (the caller's run ledger), then one JSON line. The exe's stdout and
# stderr go to -Log. A run past -TimeoutS is tree-killed and reported as {"error":"timeout"}.
param([string]$Exe, [string]$ArgLine, [string]$Cwd, [string]$Log, [int]$TimeoutS = 300)
$ErrorActionPreference = "Stop"
# The whole machine's busy CPU over the run (GetSystemTimes: kernel includes idle), so the caller can
# tell how many cores OTHER processes took, Godot or not (the run ledger only sees Godot).
Add-Type -Namespace N12 -Name Sys -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern bool GetSystemTimes(out long idle, out long kernel, out long user);
'@
function BusyS() { $i = 0L; $k = 0L; $u = 0L; [void][N12.Sys]::GetSystemTimes([ref]$i, [ref]$k, [ref]$u); return ($k + $u - $i) / 1e7 }
$busy0 = BusyS
$psi = New-Object Diagnostics.ProcessStartInfo
$psi.FileName = $Exe
$psi.WorkingDirectory = $Cwd
$psi.Arguments = $ArgLine
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$t0 = Get-Date
$p = [Diagnostics.Process]::Start($psi)
[Console]::Out.WriteLine("PID $($p.Id)")
[Console]::Out.Flush()
$so = $p.StandardOutput.ReadToEndAsync()
$se = $p.StandardError.ReadToEndAsync()
if (-not $p.WaitForExit($TimeoutS * 1000)) {
	& taskkill /F /T /PID $p.Id | Out-Null
	[IO.File]::WriteAllText($Log, $so.Result + $se.Result)
	[Console]::Out.WriteLine('{"error":"timeout"}')
	exit 0
}
$p.WaitForExit()
$busy = (BusyS) - $busy0
[IO.File]::WriteAllText($Log, $so.Result + $se.Result)
$wall = ((Get-Date) - $t0).TotalSeconds
$row = [ordered]@{
	others_cores = ($busy - $p.TotalProcessorTime.TotalSeconds) / $wall
	exit = $p.ExitCode
	user_s = $p.UserProcessorTime.TotalSeconds
	kernel_s = $p.PrivilegedProcessorTime.TotalSeconds
	total_s = $p.TotalProcessorTime.TotalSeconds
	wall_s = $wall
}
[Console]::Out.WriteLine(($row | ConvertTo-Json -Compress))
