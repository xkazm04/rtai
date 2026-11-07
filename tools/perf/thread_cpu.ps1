# thread_cpu.ps1: where a process's CPU goes, per thread (perf lane, L11). Samples every thread's CPU time twice,
# -Seconds apart, and prints JSON: per thread the CPU in cores over the window, its name (GetThreadDescription: Godot
# names its threads) and the module its start address sits in (unnamed driver threads land on their DLL), plus the
# totals grouped by name-or-module. Read-only: it opens threads with query rights only.
#   powershell -NoProfile -File tools/perf/thread_cpu.ps1 -ProcessId <pid> [-Seconds 10] [-Delay 0]
param([Parameter(Mandatory = $true)][int]$ProcessId, [double]$Seconds = 10, [double]$Delay = 0)
Add-Type @"
using System; using System.Runtime.InteropServices;
public static class TD {
  [DllImport("kernel32.dll")] public static extern IntPtr OpenThread(uint access, bool inherit, uint id);
  [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
  [DllImport("kernel32.dll")] public static extern int GetThreadDescription(IntPtr h, out IntPtr desc);
  [DllImport("kernel32.dll")] public static extern IntPtr LocalFree(IntPtr p);
  [DllImport("ntdll.dll")] public static extern int NtQueryInformationThread(IntPtr h, int cls, out IntPtr info, int len, IntPtr ret);
  public static long Start(uint tid) {
    IntPtr h = OpenThread(0x0040, false, tid); // THREAD_QUERY_INFORMATION
    if (h == IntPtr.Zero) return 0;
    IntPtr a;
    long r = NtQueryInformationThread(h, 9, out a, IntPtr.Size, IntPtr.Zero) == 0 ? a.ToInt64() : 0; // Win32StartAddress
    CloseHandle(h);
    return r;
  }
  public static string Name(uint tid) {
    IntPtr h = OpenThread(0x0800, false, tid); // THREAD_QUERY_LIMITED_INFORMATION
    if (h == IntPtr.Zero) return "";
    string s = "";
    IntPtr p;
    if (GetThreadDescription(h, out p) >= 0 && p != IntPtr.Zero) { s = Marshal.PtrToStringUni(p); LocalFree(p); }
    CloseHandle(h);
    return s;
  }
}
"@
function Snap([System.Diagnostics.Process]$p) {
  $p.Refresh()
  $m = @{}
  foreach ($t in $p.Threads) {
    try { $m[$t.Id] = @{ cpu = $t.TotalProcessorTime.TotalMilliseconds; start = [TD]::Start([uint32]$t.Id) } } catch { }
  }
  return $m
}
if ($Delay -gt 0) { Start-Sleep -Milliseconds ([int]($Delay * 1000)) }
$proc = Get-Process -Id $ProcessId -ErrorAction Stop
$mods = @($proc.Modules | ForEach-Object { @{ name = $_.ModuleName; lo = [int64]$_.BaseAddress; hi = [int64]$_.BaseAddress + $_.ModuleMemorySize } })
$a = Snap $proc
$t0 = [Diagnostics.Stopwatch]::GetTimestamp()
Start-Sleep -Milliseconds ([int]($Seconds * 1000))
$b = Snap $proc
$wall = ([Diagnostics.Stopwatch]::GetTimestamp() - $t0) / [Diagnostics.Stopwatch]::Frequency * 1000.0
$rows = @()
foreach ($id in $b.Keys) {
  $before = 0.0
  if ($a.ContainsKey($id)) { $before = $a[$id].cpu }
  $d = $b[$id].cpu - $before
  if ($d -le 0) { continue }
  $mod = '?'
  foreach ($m in $mods) { if ($b[$id].start -ge $m.lo -and $b[$id].start -lt $m.hi) { $mod = $m.name; break } }
  $rows += [pscustomobject]@{ tid = $id; name = [TD]::Name([uint32]$id); module = $mod; cores = [math]::Round($d / $wall, 4) }
}
$rows = @($rows | Sort-Object cores -Descending)
$groups = @($rows | Group-Object { if ($_.name) { ($_.name -replace '\d+$', '#') } else { '[' + $_.module + ']' } } |
  ForEach-Object { [pscustomobject]@{ group = $_.Name; threads = $_.Count; cores = [math]::Round(($_.Group | Measure-Object cores -Sum).Sum, 4) } } |
  Sort-Object cores -Descending)
[pscustomobject]@{ schema = 'gtai.thread-cpu/1'; pid = $ProcessId; wallMs = [math]::Round($wall, 1)
  totalCores = [math]::Round(($rows | Measure-Object cores -Sum).Sum, 4); groups = $groups; threads = $rows } | ConvertTo-Json -Depth 4
