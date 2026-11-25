import sys, numpy as np
from PIL import Image
def stats(f, y0, y1, x0=0, x1=1920):
    a = np.asarray(Image.open(f).convert('RGB')).astype(float)[y0:y1, x0:x1] / 255
    mx, mn = a.max(2), a.min(2); s = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]; d = np.maximum(mx - mn, 1e-6)
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    red = ((h < 18) | (h > 342)) & (s > 0.5) & (mx > 0.5)
    blue = (h > 160) & (h < 260) & (s > 0.3) & (mx > 0.2)
    return dict(mean_rgb=[round(v * 255, 1) for v in a.reshape(-1, 3).mean(0)], red_pct=round(red.mean() * 100, 3), teal_blue_pct=round(blue.mean() * 100, 3), mean_hue_lit=round(float(np.median(h[mx > 0.15])) if (mx > 0.15).any() else -1, 1))
for f in sys.argv[1:]:
    print(f.split('/')[-1], 'void y0-165:', stats(f, 0, 165), '| yard y430-1080:', stats(f, 430, 1080)['mean_rgb'])
