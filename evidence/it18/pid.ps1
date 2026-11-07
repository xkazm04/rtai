param([string]$Dev)
$p = Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'Godot*' -and $_.Name -notlike '*console*' -and $_.CommandLine -match ("--device=" + $Dev + "(\s|$|"")") } | Select-Object -First 1
$p.ProcessId
