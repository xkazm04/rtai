"""Floor sampling helpers (n28). Stills are 1920x1080 at 32 px/m; everything here runs on a 2x box-reduced copy
(960x540, so 16 px/m) because the shared machine fails 24 MB allocations: the floor_warmth.py mask rule (n27) with its
sizes halved: no pixel within 3 px of one that is dark (L* < 30), saturated (C* > 48) or more than 14 L* from the 11 px
local median, inside the yard rect (x 68..868, y 10..440), the front frame also world y > 0.6 m."""
import numpy as np
from PIL import Image
from scipy import ndimage as ndi
KY = 32 * np.sin(np.radians(70)) / 2        # ground px per metre in y at half resolution
KX = 16.0

def lab(rgb):
    c = rgb.astype(np.float32) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4).astype(np.float32)
    m = np.array([[0.4124564, 0.3575761, 0.1804375], [0.2126729, 0.7151522, 0.0721750], [0.0193339, 0.1191920, 0.9503041]], dtype=np.float32)
    xyz = c @ m.T / np.array([0.95047, 1.0, 1.08883], dtype=np.float32)
    f = np.where(xyz > 216 / 24389, np.cbrt(xyz), (24389 / 27 * xyz + 16) / 116)
    return 116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])

def load_half(path):
    img = Image.open(path).convert("RGB")
    return np.asarray(img.reduce(2), dtype=np.uint8)

def world(cx, cy, ky=KY):
    """World x, y (m) of every half-res pixel for a still centred on (cx, cy); ky = px/m in y (half res)."""
    xs = (cx + (np.arange(960, dtype=np.float32) - 480) / KX)[None, :]
    ys = (cy + (np.arange(540, dtype=np.float32) - 270) / ky)[:, None]
    return xs, ys

def floor_mask(L, C, wy, place):
    med = ndi.median_filter(L, size=11)
    obstacle = ndi.binary_dilation((np.abs(L - med) > 14) | (C > 48) | (L < 30), iterations=3)
    py, px = np.arange(L.shape[0])[:, None], np.arange(L.shape[1])[None, :]
    inside = (px > 68) & (px < 868) & (py > 10) & (py < 440)
    if place == "front":
        inside = inside & (wy > 0.6)
    return inside & ~obstacle
