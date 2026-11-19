"""Fit drawn launcher lefts to their own equipped east cell, preserving the boot line.

Each strip starts with the original 165px cut. Protected polygons are the
launcher's silhouette in that cut; the saturated orange collar is also excluded.
"""
import cv2
import numpy as np
from PIL import Image

from cell_metrics import cells, figure


def fit_left(target, gun_polygons):
    east = cells(target.with_stem(target.stem.removesuffix("_left")), 8)[2]
    east_h, east_rgb, _ = figure(east, 165)
    frames = cells(target, 3)
    h, w = frames[0].shape[:2]
    output = Image.new("RGBA", (w*3, h))
    transforms = []
    for i, (frame, polygon) in enumerate(zip(frames, gun_polygons, strict=True)):
        old_h, old_rgb, _ = figure(frame, 165)
        protected = np.zeros((h, w), np.uint8)
        cv2.fillPoly(protected, [np.int32([pt.split(",") for pt in polygon.split()])], 255)
        rgb = frame[:, :, :3].astype(float)
        r, g, b = rgb.transpose(2, 0, 1)
        # Blend the edit into ink and specular highlights. Leave hazard paint,
        # yellow hardware, the bright visor, and the complete launcher intact.
        warm = np.clip((r-g)/12, 0, 1) * np.clip((g-b)/6, 0, 1)
        neutral = np.clip((.78-(r-b)/np.maximum(r, 1))/.14, 0, 1)
        weight = warm * neutral * (1-protected/255)
        # A midtone shift with fixed black and white endpoints keeps drawn seams.
        bell = rgb * (255-rgb) / (old_rgb * (255-old_rgb))
        graded = frame.copy()
        graded[:, :, :3] = np.clip(rgb + weight[:, :, None]*bell*(east_rgb-5-old_rgb), 0, 255).round()
        scale = .975 * east_h / old_h
        cw, ch = round(w*scale), round(h*scale)
        dx, dy = (w-cw)//2, h-ch
        im = Image.fromarray(graded).convert("RGBa").resize((cw, ch), Image.Resampling.LANCZOS)
        output.paste(im.convert("RGBA"), (w*i+dx, dy))
        transforms.append((cw/w, ch/h, dx, dy))
    output.save(target, optimize=True)
    return transforms
