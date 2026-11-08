# Writes a full-memory minidump of a running process (dbghelp MiniDumpWriteDump), no procdump needed.
param([Parameter(Mandatory)][int]$ProcessId, [Parameter(Mandatory)][string]$Out)
Add-Type @"
using System; using System.Runtime.InteropServices; using Microsoft.Win32.SafeHandles;
public static class Dbg {
  [DllImport("dbghelp.dll", SetLastError = true)]
  public static extern bool MiniDumpWriteDump(IntPtr hProcess, uint pid, SafeFileHandle hFile, uint type,
    IntPtr exc, IntPtr user, IntPtr cb);
}
"@
$p = Get-Process -Id $ProcessId
$fs = [System.IO.File]::Create($Out)
# MiniDumpWithFullMemory | MiniDumpWithHandleData | MiniDumpWithThreadInfo | MiniDumpWithUnloadedModules
$ok = [Dbg]::MiniDumpWriteDump($p.Handle, [uint32]$ProcessId, $fs.SafeFileHandle, [uint32](0x2 -bor 0x4 -bor 0x1000 -bor 0x20), [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero)
$fs.Close()
"dump $ok $Out $((Get-Item $Out).Length)"
