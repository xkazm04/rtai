"""n13 weapon art: treatment B (the owner's pick, n12 D2) - a heavier ink rim round a glowing
blade, cut into a Rivet equipped strip from the blade's own plate (no new colour).

usage: python -I tools/art/blade_ink_rim.py <strip.png> <out.png> [--px=0.5] [--reach=6] [--cells=8]

rivet_frames.py --manifest calls ink_rim() on a row that carries "ink_rim" ({"px", "reach"}), right
after the cut, so a manifest re-run regenerates the treated strip; the row without the key (or
rivet_frames.py --no-ink-rim) cuts the shipped strip byte for byte (the before).

Per cell: the blade's core is the largest connected run of its glow (saturated warm, bright). Its
plate is every opaque pixel within `reach` px of the core; the rim colour `ink` is the darkest decile
of the plate's outline (the band within 1.5 px of the outside): the plate's own ink line, no new
colour. B, as n12's candidate drew it (fitted on its cells 0 and 5 at strip scale, see the n13
JOURNAL): the cutter's soft halo outside the plate, out to `px`, turns solid ink, falling off over
one more pixel. Only transparent or dark soft pixels gain ink: a strike cell's drawn arc (bright
and soft) is skipped, so the candidate's stray ink dots on the arc are not repeated. Deterministic
(numpy + scipy distance transforms only).
"""

import sys

import numpy as np
from PIL import Image
from scipy import ndimage

OPAQUE = 160
OUTLINE_PX = 1.5


def _core(t: np.ndarray) -> np.ndarray:
    r, g, b, a = (t[..., i] for i in range(4))
    glow = (a > OPAQUE) & (r > 190) & (g > 100) & (b < 150) & (r - b > 80)
    lab, n = ndimage.label(glow)
    if n == 0:
        return glow
    sizes = ndimage.sum(glow, lab, range(1, n + 1))
    return lab == (int(np.argmax(sizes)) + 1)


def _cell(t: np.ndarray, px: float, reach: float) -> np.ndarray:
    core = _core(t)
    if not core.any():
        return t
    a = t[..., 3]
    solid = a > OPAQUE
    to_core = ndimage.distance_transform_edt(~core)
    plate = solid & (to_core <= reach)
    to_out = ndimage.distance_transform_edt(solid)
    outline = plate & (to_out <= OUTLINE_PX)
    lum = t[..., :3] @ np.array([0.299, 0.587, 0.114])
    ink_px = t[outline][:, :3]
    if len(ink_px) == 0:
        return t
    order = np.argsort(lum[outline])
    ink = np.median(ink_px[order[: max(1, len(order) // 10)]], axis=0)
    out = t.copy()
    # the outside within px of the plate (the cutter's soft halo and the next pixel) takes the ink,
    # solid to px and falling off over one more pixel; a bright soft pixel (an arc) is skipped
    to_plate = ndimage.distance_transform_edt(~plate)
    soft_dark = (a <= 25) | (lum < np.median(lum[plate]))
    ring = (~solid) & (to_plate <= px + 1.0) & soft_dark
    a_old = a / 255.0
    a_ink = np.clip(px + 1.0 - to_plate, 0.0, 1.0)
    a_new = a_ink + a_old * (1.0 - a_ink)
    for ch in range(3):
        c = (ink[ch] * a_ink + t[..., ch] * a_old * (1.0 - a_ink)) / np.maximum(a_new, 1e-6)
        out[..., ch] = np.where(ring, c, out[..., ch])
    out[..., 3] = np.where(ring, np.round(a_new * 255.0), out[..., 3])
    return out


def ink_rim(src: str, dst: str, px: float = 0.5, reach: float = 6.0, cells: int = 8) -> None:
    rgba = np.asarray(Image.open(src).convert("RGBA")).astype(float)
    cw = rgba.shape[1] // cells
    out = rgba.copy()
    for c in range(cells):
        out[:, c * cw : (c + 1) * cw] = _cell(rgba[:, c * cw : (c + 1) * cw], px, reach)
    img = Image.fromarray(np.clip(np.round(out), 0, 255).astype(np.uint8), "RGBA")
    img.save(dst, optimize=True)


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    px = float(opts.get("px", 0.5))
    reach = float(opts.get("reach", 6.0))
    ink_rim(args[0], args[1], px, reach, int(opts.get("cells", 8)))


if __name__ == "__main__":
    main()
