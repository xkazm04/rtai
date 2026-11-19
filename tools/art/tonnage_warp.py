"""Single-silhouette warps used by the Tonnage midpoint atlas packer."""

import cv2
import numpy as np
from PIL import Image


def warp_rows(image, dx, dy):
    """Inverse displacements of each horizontal scan line, in cell pixels."""
    width, height = image.size
    mesh = []
    for y in range(height):
        a, b = y + dy[y], y + 1 + dy[y + 1]
        start_x, end_x = dx[y], dx[y + 1]
        mesh.append(((0, y, width, y + 1), (start_x, a, end_x, b, width + end_x, b, width + start_x, a)))
    return image.transform(
        image.size, Image.Transform.MESH, mesh, Image.Resampling.BILINEAR
    )


def warp_pads(key, pins, body):
    h, w = key.height, key.width
    pad = h - 230
    yy, xx = np.indices((h, w), dtype=np.float32)
    mx, my = xx.copy(), yy.copy()
    pins = np.array(pins)
    half_travel = (pins[:, 2] - pins[:, 0]) / 2
    stance = np.argmax(pins[:, 1])
    for y in range(h):
        # At the pad rim, shift each sole as a rigid piece. Interpolate only
        # between pads; the piston shafts bend between the socket and rim.
        gain = np.clip((y - (176 + pad)) / (pins[:, 1] - 12 - (176 + pad)), 0, 1)
        dx = body[0] + gain * (half_travel - body[0])
        # Below a raised pad only the planted leg occupies the scanline.
        # Fade its neighbour's influence out smoothly across the rim.
        weight = np.clip((pins[:, 1] + 9 - y) / 9, 0, 1)
        plant_dx = dx[stance]
        dx = plant_dx + weight * (dx - plant_dx)
        centres = pins[:, 0] + dx
        gaps = np.diff(centres)
        rim = np.minimum(16, 0.46 * np.minimum(np.r_[100, gaps], np.r_[gaps, 100]))
        rails = np.column_stack((centres - rim, centres + rim)).ravel()
        mx[y] -= np.interp(xx[y], rails, np.repeat(dx, 2))
        my[y] -= body[1] * np.clip((212 + pad - y) / 36, 0, 1)
    return remap_ink(key, mx, my)


def register_crown(key, neighbour):
    # Register the top casing, excluding pistons, alpha fringe and empty margins.
    def gray(im):
        return cv2.cvtColor(np.asarray(im), cv2.COLOR_RGBA2GRAY)

    top = key.height - 153
    patch = gray(key)[top:top + 57, 39:123]
    score = cv2.matchTemplate(gray(neighbour), patch, cv2.TM_CCOEFF_NORMED)
    return np.array(cv2.minMaxLoc(score)[3]) - [39, top]


def articulated_pose(key, soles, crown, fraction, style=""):
    """One source silhouette. Keep each sole rigid and bend its shaft at the socket."""
    h, w = key.height, key.width
    yy, xx = np.indices((h, w + 8), dtype=np.float32)
    xx -= 4  # transparent gutters keep adjacent poses out of the linear-filtered outline
    mx, my = xx.copy(), yy.copy()
    start, end = soles
    delta = fraction * (end - start)
    dst = start + delta
    for y in range(h):
        gain = np.clip((y - dst[:, 1] + 50) / 36, 0, 1)[:, None]
        shift = crown * fraction + gain * (delta - crown * fraction)
        if style == "separate":
            # Past a lifted sole the lower scan lines carry only the stance
            # foot. Its entire rim must travel with that foot.
            planted = shift[dst[:, 1].argmax()]
            clear = np.maximum(dst[:, 1], start[:, 1] + planted[1]) + 2
            keep = np.clip((clear + 12 - y) / 12, 0, 1)[:, None]
            shift = planted + keep * (shift - planted)
        centres = start[:, 0] + shift[:, 0]
        gaps = np.diff(centres)
        rim = np.minimum(13, .44 * np.minimum(np.r_[100, gaps], np.r_[gaps, 100]))
        rails = np.column_stack((centres - rim, centres + rim)).ravel()
        dx = np.interp(xx[y], rails, np.repeat(shift[:, 0], 2))
        dy = np.interp(xx[y], rails, np.repeat(shift[:, 1], 2))
        if len(centres) == 2:
            # The front/rear sill spans the space between shafts. Keep its
            # centre rigid and taper the displacement beside each ankle.
            distance = np.abs(xx[y, :, None] - centres).min(axis=1)
            local = np.clip((28 - distance) / 8, 0, 1)
            dx = crown[0] * fraction + local * (dx - crown[0] * fraction)
            dy = crown[1] * fraction + local * (dy - crown[1] * fraction)
        mx[y] -= dx
        my[y] -= dy
    if style == "sill":
        return rigid_sill(key, (mx, my), (xx, yy), crown * fraction)
    return remap_ink(key, mx, my)


def rigid_sill(key, inverse, grid, body):
    """Move the armour between the front pistons as one rigid plate."""
    pixels = np.asarray(key)
    h, w = pixels.shape[:2]
    y = np.arange(h)[:, None]
    bottom = np.where(pixels[..., 3] > 128, y, -1).max(axis=0)
    low = int(np.median(bottom[w // 2 - 4 : w // 2 + 5]))
    gray = cv2.cvtColor(pixels, cv2.COLOR_RGBA2GRAY).astype(float)
    edge = np.abs(np.gradient(gray, axis=1))[low - 16 : low - 8].mean(axis=0)
    bounds = []
    for centre in (w * 0.32, w * 0.68):
        search = np.arange(round(centre) - 6, round(centre) + 8)
        bounds.append(search[np.argmax(edge[search])] + (1 if centre > w / 2 else -1))
    xx, yy = grid
    bx, by = xx - np.float32(body[0]), yy - np.float32(body[1])
    dx = np.maximum.reduce([bounds[0] - bx, bx - bounds[1], np.zeros_like(bx)])
    dy = np.maximum(by - low, 0)
    # The plate follows the crown; only the exposed parts of the legs move
    # independently. A smooth inverse map keeps the riveted edge connected.
    blend = np.clip(np.hypot(dx, dy) / 18, 0, 1).astype("float32")
    mx, my = inverse
    return remap_ink(key, bx + blend * (mx - bx), by + blend * (my - by))


def remap_ink(key, mx, my):
    pixels = cv2.remap(np.asarray(key.convert("RGBa")), mx, my, cv2.INTER_LINEAR)
    return Image.frombytes("RGBa", (mx.shape[1], mx.shape[0]), pixels.tobytes()).convert("RGBA")


def midpoint(landing):
    pixels = np.asarray(landing)
    y, x = np.indices(pixels.shape[:2])
    # Cut the two near shafts at their visible boundaries below the belly.
    # The two far pads stay behind them.
    edge = np.interp(y, [185, 194, 203, 211], [49, 44, 37, 36])
    trailing = (y >= 185) & (x < edge)
    leading = (y >= 190) & (x >= 112)
    body = pixels.copy()
    body[trailing | leading] = 0
    result = Image.fromarray(body)
    rows = np.arange(landing.height + 1)
    zero = np.zeros_like(rows)
    # Stance centre C6 = 62, C7 = 17.5: put the landing pad 22.25 px
    # forward and lift the approaching pad, keeping both pad widths.
    swing = np.interp(rows, [190, 208], [0, 5])
    stance = np.interp(rows, [185, 211], [0, -22.25])
    for mask, dx, dy in [(leading, zero, swing), (trailing, stance, zero)]:
        layer = pixels.copy()
        layer[~mask] = 0
        result.alpha_composite(warp_rows(Image.fromarray(layer), dx, dy))
    # In the keys the housing moves 1.4 px right and 6 px down. Place it
    # halfway through that dip. The displacement fades out along the shafts.
    upper = np.interp(rows, [184, 214], [1, 0])
    return warp_rows(result, 0.7 * upper, 3 * upper)


def piston_ink(key, neighbour, left):
    """C11 has keyed-out metal. Borrow the corresponding C10 metal under its rim."""
    if left:
        # Only the rear socket is missing in the left C11. The intact
        # near piston already has the left drawing's highlights.
        under = Image.new("RGBA", key.size)
        # Extend the shaft behind the belly without carrying C10's wider
        # housing lip. Back the small keyed hole with adjacent socket metal.
        under.paste(neighbour.crop((102, 179, 107, 186)), (99, 173))
        under.alpha_composite(neighbour.crop((93, 173, 108, 181)), (96, 167))
        under.alpha_composite(neighbour.crop((87, 181, 114, 198)), (90, 175))
        under.alpha_composite(key)
        return under
    pixels = np.array(key)
    _, labels = cv2.connectedComponents((pixels[..., 3] < 247).astype("uint8"))
    holes = {labels[y, x] for x, y in [(102, 198), (110, 214), (109, 218)]}
    yy, xx = np.indices(pixels.shape[:2], dtype=np.float32)
    source_y = np.interp(yy, [186, 211, 216, 227], [194, 211, 216, 227])
    here = np.interp(yy, [186, 211, 216], [97, 107, 110.5])
    there = np.interp(source_y, [194, 211, 216], [126, 132, 134])
    sample = cv2.remap(np.asarray(neighbour), (xx - here + there).astype("float32"),
                       source_y.astype("float32"), cv2.INTER_LINEAR)
    missing = np.isin(labels, list(holes)) & (xx > 85) & (yy > 184)
    pixels[missing] = sample[missing]
    # The socket behind the trailing foot is open in C11. Seat the back
    # piston from C10 behind its existing rim, aligned at the belly.
    under = Image.new("RGBA", key.size)
    under.paste(neighbour.crop((49, 193, 78, 213)), (46, 186))
    under.alpha_composite(Image.fromarray(pixels))
    return under
