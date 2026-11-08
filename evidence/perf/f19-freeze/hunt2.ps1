# F19 hunt v2 (n9): quest 1 under --autostart, windowed D3D12, the editor binary; stdout+stderr kept per run.
# After -Settle s, 3 s of process CPU; a live run under 0.05 cores is a freeze (kind=frozen), a process gone by then is
# kind=exited (its exit code kept; it2: an exited run looked like a freeze); either log is copied as freeze-<tag>-<n>.log.
# -Exe <path> runs an exported exe instead (no --path). One JSON line per run.
param([int]$Runs = 10, [string]$Tag = 'x', [int]$Settle = 12, [string]$Exe = '', [string]$Extra = '',
  [switch]$NoAutostart, [string]$Driver = 'd3d12', [string]$EngineExtra = '', [switch]$PressStart)
# -PressStart (it2): no --autostart; 6 s in, a posted Enter (WM_KEYDOWN / WM_KEYUP VK_RETURN) to the game window presses
# the focused Start button through the real UI path (the release build ignores --autostart). `started` = the log says so.
Add-Type -Namespace F19 -Name W -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool PostMessage(System.IntPtr h, uint m, System.IntPtr w, System.IntPtr l);
[DllImport("user32.dll")] public static extern bool SetForegroundWindow(System.IntPtr h);
[DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, System.UIntPtr extra);
'@
if ($PressStart) { $NoAutostart = $true }
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $here '..\..\..')
$godot = 'C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n9/appdata/perf'
$tmp = 'C:\Users\kazda\kiro\gtai-n9\tmp\perf'
$frozen = 0
for ($n = 1; $n -le $Runs; $n++) {
  $a = @('--rendering-driver', $Driver, '--resolution', '1920x1080')
  if ($EngineExtra -ne '') { $a += $EngineExtra.Split(' ') }
  $bin = $godot
  if ($Exe -ne '') { $bin = $Exe } else { $a = @('--path', "$repo\project") + $a + @('res://boot/quest1.tscn') }
  $a += @('--')
  if (-not $NoAutostart) { $a += @('--autostart') }
  if ($Extra -ne '') { $a += $Extra.Split(' ') }
  $log = Join-Path $tmp "f19-$Tag-$n.log"
  $err = Join-Path $tmp "f19-$Tag-$n.err"
  # an exported exe IS the game window (no console wrapper): hiding it hides the game (it2: -PressStart never reached it)
  $style = if ($Exe -ne '') { 'Normal' } else { 'Hidden' }
  $p = Start-Process -FilePath $bin -ArgumentList $a -PassThru -WindowStyle $style -RedirectStandardOutput $log -RedirectStandardError $err
  Start-Sleep -Seconds 3
  $c = Get-CimInstance Win32_Process -Filter "ParentProcessId=$($p.Id)" | Where-Object { $_.Name -like 'Godot*' -or $_.Name -like 'RTAI*' } | Select-Object -First 1
  $gid = if ($c) { [int]$c.ProcessId } else { $p.Id }
  $g = Get-Process -Id $gid
  if ($PressStart) {
    Start-Sleep -Seconds 6; $g.Refresh(); $h = $g.MainWindowHandle
    $ws = New-Object -ComObject WScript.Shell
    [F19.W]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)  # an Alt tap lets a background process set the foreground
    $act = [F19.W]::SetForegroundWindow($h)
    [F19.W]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 300
    if ($act) { $ws.SendKeys('{ENTER}') } else {
      [void][F19.W]::PostMessage($h, 0x100, [IntPtr]0x0D, [IntPtr]0x001C0001)
      Start-Sleep -Milliseconds 80
      [void][F19.W]::PostMessage($h, 0x101, [IntPtr]0x0D, [IntPtr]0xC01C0001)
    }
  }
  Start-Sleep -Seconds $Settle
  $g.Refresh(); $c0 = $g.TotalProcessorTime.TotalSeconds; Start-Sleep -Seconds 3; $g.Refresh()
  $cores = [math]::Round(($g.TotalProcessorTime.TotalSeconds - $c0) / 3, 3)
  $exited = $g.HasExited
  $code = if ($exited) { $g.ExitCode } else { $null }
  $started = [bool](Select-String -Path $log -Pattern 'quest1: started' -SimpleMatch -Quiet)
  $line = [ordered]@{ tag = $Tag; run = $n; cores = $cores; responding = $g.Responding; pid = $gid; exited = $exited; exitCode = $code; started = $started }
  # a release build logs no INFO, so `started` is unknown there: a 0-CPU window still pumping messages is the idle
  # title (kind=idle, the press missed), a 0-CPU window that stopped responding is a freeze
  $idle = $cores -lt 0.05 -and -not $exited -and $g.Responding -and -not $started
  if ($exited) { $line.kind = 'exited' } elseif ($idle) { $line.kind = 'idle' } elseif ($cores -lt 0.05) { $line.kind = 'frozen' } else { $line.kind = 'ok' }
  if ($cores -lt 0.05 -and -not $exited -and -not $idle) {
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
