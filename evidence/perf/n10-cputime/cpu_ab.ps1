# Interleaved release riot at combo, three exports, measuring what wall-clock frame times cannot
# on a shared machine: the CPU seconds the process itself consumed (GetProcessTimes, read after exit)
# over one fixed run of 30 s of ticks at --fixed-fps 60. Same args as tools/perf/ab.mjs preset riotc.
# Holds gtai-n10/bench.lock (touched every run so it does not read as stale at 20 min).
param([int]$Rounds = 6, [string]$StopAt = "02:42", [string]$OutDir = "C:\Users\kazda\kiro\gtai-wt\n10-perf\evidence\perf\n10-cputime", [string]$ArmSpec = "main=windows-bench-main,head=windows-bench,twin=windows-bench-it6")
$ErrorActionPreference = "Stop"
$env:APPDATA = "C:/Users/kazda/kiro/gtai-n10/appdata/perf"
$env:TMP = "C:/Users/kazda/kiro/gtai-n10/tmp/perf"; $env:TEMP = $env:TMP
$lock = "C:\Users\kazda\kiro\gtai-n10\bench.lock"
$export = "C:\Users\kazda\kiro\gtai-wt\n10-perf\build\export"
$arms = @($ArmSpec.Split(",") | ForEach-Object { $kv = $_.Split("="); @{n = $kv[0]; d = $kv[1]} })
$stop = [datetime]::ParseExact((Get-Date -Format "yyyy-MM-dd") + " " + $StopAt, "yyyy-MM-dd HH:mm", $null)
if (Test-Path $lock) {
	$age = ((Get-Date) - (Get-Item $lock).LastWriteTime).TotalSeconds
	if ($age -lt 1200) { Write-Output "lock held ($([int]$age) s)"; exit 3 }
	Remove-Item $lock -Force
}
try { $f = [IO.File]::Open($lock, [IO.FileMode]::CreateNew); $b = [Text.Encoding]::ASCII.GetBytes("perf"); $f.Write($b, 0, 4); $f.Close() }
catch { Write-Output "lost lock race"; exit 3 }

function RunOne($arm, $round) {
	$out = "$OutDir/riotc-$($arm.n)-$round.json".Replace("\", "/")
	if (Test-Path $out) { Remove-Item $out -Force }
	$others = @(Get-Process | Where-Object { $_.ProcessName -match "godot|RTAI" }).Count
	(Get-Item $lock).LastWriteTime = Get-Date
	$psi = New-Object Diagnostics.ProcessStartInfo
	$psi.FileName = "$export\$($arm.d)\RTAI-bench.exe"
	$psi.WorkingDirectory = "$export\$($arm.d)"
	$psi.Arguments = "--screen 0 --rendering-driver d3d12 --disable-vsync --fixed-fps 60 --resolution 1920x1080 -- --scenario=riot --zoom=1.0 --view=combo --secs=30 --out=$out"
	$psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
	$t0 = Get-Date
	$p = [Diagnostics.Process]::Start($psi)
	$so = $p.StandardOutput.ReadToEndAsync(); $se = $p.StandardError.ReadToEndAsync()
	if (-not $p.WaitForExit(300000)) { & taskkill /F /T /PID $p.Id | Out-Null; return @{arm = $arm.n; round = $round; error = "timeout"} }
	$p.WaitForExit()
	$text = $so.Result + $se.Result
	return [ordered]@{
		arm = $arm.n; round = $round; exit = $p.ExitCode; others = $others
		user_s = $p.UserProcessorTime.TotalSeconds; kernel_s = $p.PrivilegedProcessorTime.TotalSeconds
		total_s = $p.TotalProcessorTime.TotalSeconds; wall_s = ((Get-Date) - $t0).TotalSeconds
		script_errors = ([regex]::Matches($text, "SCRIPT ERROR")).Count
	}
}

$rows = @()
try {
	for ($r = 0; $r -lt $Rounds; $r++) {
		if ((Get-Date) -gt $stop) { Write-Output "stop time reached before round $r"; break }
		$k = $r % 3
		$order = @($arms[$k], $arms[($k + 1) % 3], $arms[($k + 2) % 3])
		if ($r % 2 -eq 1) { [array]::Reverse($order) }
		foreach ($a in $order) {
			$row = RunOne $a $r
			$rows += $row
			Write-Output ($row | ConvertTo-Json -Compress)
			($rows | ConvertTo-Json) | Out-File -Encoding utf8 "$OutDir/cpu_runs.json"
		}
	}
} finally { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
