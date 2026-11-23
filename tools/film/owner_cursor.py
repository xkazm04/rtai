"""Record the real Win32 cursor and its game window, one acknowledged simulation tick at a time."""
import ctypes
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

import psutil
import win32api
import win32con
import win32gui
import win32process
import win32ui
from PIL import Image, ImageStat

ctypes.windll.user32.SetProcessDPIAware()
FIRST, LAST = 60, 1019
SIZE = (960, 1080)
AIM = (615, 450)  # client crop, 135 px right and 90 px up from its centre


def game_window(process):
    mine = {child.pid for child in [process, *process.children(recursive=True)]}
    windows = []

    def check(hwnd, _):
        if not win32gui.IsWindowVisible(hwnd):
            return
        if win32process.GetWindowThreadProcessId(hwnd)[1] not in mine:
            return
        left, top = win32gui.ClientToScreen(hwnd, (0, 0))
        if top >= 1440 and win32gui.GetClientRect(hwnd)[2:] == (1920, 1080):
            windows.append((hwnd, left, top))

    win32gui.EnumWindows(check, None)
    return windows[0] if windows else None


def grab(handle, origin=None):
    """BitBlt omits the hardware cursor. Draw the current HCURSOR with its actual hotspot."""
    width, height = SIZE if origin else (96, 96)
    raw = win32gui.GetDC(0)
    src = win32ui.CreateDCFromHandle(raw)
    mem = src.CreateCompatibleDC()
    bmp = win32ui.CreateBitmap()
    bmp.CreateCompatibleBitmap(src, width, height)
    old = mem.SelectObject(bmp)
    try:
        if origin:
            mem.BitBlt((0, 0), SIZE, src, origin, win32con.SRCCOPY)
        else:
            mem.FillSolidRect((0, 0, width, height), 0x808080)
        _, hx, hy, mask, color = win32gui.GetIconInfo(handle)
        ax, ay = AIM if origin else (32, 32)
        try:
            win32gui.DrawIconEx(mem.GetSafeHdc(), ax - hx, ay - hy, handle, 0, 0, 0, 0, win32con.DI_NORMAL)
        finally:
            win32gui.DeleteObject(mask)
            if color:
                win32gui.DeleteObject(color)
        return Image.frombytes('RGB', (width, height), bmp.GetBitmapBits(True), 'raw', 'BGRX', 0, 1)
    finally:
        mem.SelectObject(old)
        mem.DeleteDC()
        win32gui.DeleteObject(bmp.GetHandle())
        win32gui.ReleaseDC(0, raw)


def record(game, dest):
    dest.mkdir(parents=True, exist_ok=False)
    ready, ack = dest / 'ready', dest / 'ack'
    scene = Path(__file__).resolve().with_name('owner_cursor.tscn')
    args = [os.environ['GODOT_BIN'], '--path', str(game / 'project'), '--rendering-driver', 'd3d12',
            '--resolution', '1920x1080', '--position', '0,1440', '--fixed-fps', '60', str(scene),
            '--', '--loadout=katana,chainsaw,pistol', '--seed=20261109', '--view=tilt70', '--ppm=32',
            '--rigs', '--silent', '--clean', '--feel=off']
    previous = win32api.GetCursorPos()
    with (dest / 'godot.log').open('w', encoding='utf8') as log:
        child = subprocess.Popen(args, cwd=game, env=dict(os.environ, GTAI_MELEE_CURSOR=str(dest)),
                                 stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
        proc = psutil.Process(child.pid)
        try:
            deadline = time.monotonic() + 100
            while time.monotonic() < deadline and child.poll() is None:
                window = game_window(proc)
                if window and ready.exists():
                    break
                time.sleep(.15)
            else:
                raise RuntimeError('window or initial game tick missing: ' + str(dest))
            hwnd, left, top = window
            win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0,
                                  win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_NOACTIVATE)
            origin = (left + 480, top)
            point = (origin[0] + AIM[0], origin[1] + AIM[1])
            win32api.SetCursorPos(point)
            time.sleep(.4)
            arrow = grab(win32gui.LoadCursor(0, win32con.IDC_ARROW)).tobytes()
            samples = []
            for tick in range(FIRST, LAST + 1):
                deadline = time.monotonic() + 15
                while time.monotonic() < deadline:
                    parts = ready.read_text().split()
                    if len(parts) == 2 and parts[0] == str(tick):
                        break
                    if child.poll() is not None:
                        raise RuntimeError('game exited at tick ' + str(tick))
                    time.sleep(.004)
                else:
                    raise TimeoutError('no rendered tick ' + str(tick))
                for _ in range(20):
                    flags, cur, pos = win32gui.GetCursorInfo()
                    if pos == point and flags & 1 and win32gui.WindowFromPoint(point) == hwnd:
                        break
                    win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0,
                                          win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_NOACTIVATE)
                    win32api.SetCursorPos(point)
                    win32gui.SendMessage(hwnd, win32con.WM_SETCURSOR, hwnd,
                                         win32con.HTCLIENT | (win32con.WM_MOUSEMOVE << 16))
                    time.sleep(.05)
                else:
                    raise RuntimeError(f'cursor at tick {tick}: position={pos}, target={point}, '
                                       f'visible={flags}, hwnd={hwnd}, over={win32gui.WindowFromPoint(point)}')
                if tick == FIRST or tick % 60 == 0:
                    for x in range(6, SIZE[0], 120):
                        for y in range(6, SIZE[1], 120):
                            if win32gui.WindowFromPoint((origin[0]+x, origin[1]+y)) != hwnd:
                                raise RuntimeError('game is occluded at tick ' + str(tick))
                frame = grab(cur, origin)
                if tick == FIRST and min(ImageStat.Stat(frame).stddev) < 5:
                    raise RuntimeError('blank game capture')
                frame.save(dest / f'{tick:04d}.jpg', quality=95)
                icon = grab(cur).tobytes()
                samples.append([tick, parts[1], icon == arrow, hashlib.sha256(icon).hexdigest()])
                ack.write_text(str(tick))
            child.wait(timeout=15)
            if child.returncode:
                raise RuntimeError('game exit ' + str(child.returncode))
            (dest / 'pointers.json').write_text(json.dumps(samples))
        finally:
            win32api.SetCursorPos(previous)
            if child.poll() is None:
                for p in reversed([proc, *proc.children(recursive=True)]):
                    if p.is_running():
                        p.terminate()


if __name__ == '__main__':
    record(Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve())
