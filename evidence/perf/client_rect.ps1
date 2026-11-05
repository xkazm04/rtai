# client_rect.ps1: moves the newest RTAI window to 200,200 on the primary display, then prints "x y w h" of the RTAI exe window's client area in desktop pixels (newest RTAI process).
Add-Type @"
using System; using System.Runtime.InteropServices;
public struct RECT { public int L, T, R, B; }
public struct POINT { public int X, Y; }
public static class W {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
}
"@
[void][W]::SetProcessDPIAware()
$p = Get-Process RTAI -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Sort-Object StartTime -Descending | Select-Object -First 1
if ($null -eq $p) { exit 1 }
# onto the primary display (ddagrab output 0) at 200,200; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
[void][W]::SetWindowPos($p.MainWindowHandle, [IntPtr]::Zero, 200, 200, 0, 0, 0x0015)
Start-Sleep -Milliseconds 300
$r = New-Object RECT; [void][W]::GetClientRect($p.MainWindowHandle, [ref]$r)
$o = New-Object POINT; [void][W]::ClientToScreen($p.MainWindowHandle, [ref]$o)
"$($o.X) $($o.Y) $($r.R) $($r.B)"
