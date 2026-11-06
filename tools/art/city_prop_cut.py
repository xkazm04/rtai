"""Cut the city's standing prop cards from the assets library's keyed prop sheets (n8 city lane).

Each sheet's top row holds five facings (toward the camera, three-quarter toward, side,
three-quarter away, back). The five are found by the alpha's column runs inside the top row's
band, cropped, and laid into five equal cells, bottom-aligned and centred, so one cell width
maps to one ground width in game (city_facades.json `props`: cell_w_m). Prints each strip's cell
size and the facing-0 content width as a fraction of the cell (to set cell_w_m from a real width).

usage: python tools/art/city_prop_cut.py <library_root> <out_dir> <55|70> <game_name>=<lib_id> ...
       python tools/art/city_prop_cut.py <library_root> <out_dir> <55|70> --kit <lib_id>
(--kit: a dressing kit sheet of single-view pieces in rows; every piece of every row is cut to
its own tight PNG, <out_dir>/p<pitch>/<lib_id>_<row><col>.png, for the boss arenas' dressing.)
"""

import sys
from pathlib import Path

from PIL import Image

MAX_CELL_H = 256
ALPHA_MIN = 24
GAP = 12


def runs(values, gap):
    """Index runs where values are truthy, joining runs closer than `gap`."""
    out = []
    for i, v in enumerate(values):
        if not v:
            continue
        if out and i - out[-1][1] <= gap:
            out[-1][1] = i
        else:
            out.append([i, i])
    return out


def bands_of(alpha):
    w, h = alpha.size
    px = alpha.load()
    rows = [any(px[x, y] >= ALPHA_MIN for x in range(0, w, 2)) for y in range(h)]
    return [r for r in runs(rows, GAP) if r[1] - r[0] > 40]


def top_band(alpha):
    return bands_of(alpha)[0]


def cut_kit(sheet: Path, out_dir: Path, lib_id: str):
    im = Image.open(sheet).convert("RGBA")
    alpha = im.getchannel("A")
    px = alpha.load()
    out_dir.mkdir(parents=True, exist_ok=True)
    for r, (y0, y1) in enumerate(bands_of(alpha)):
        cols = [any(px[x, y] >= ALPHA_MIN for y in range(y0, y1 + 1, 2)) for x in range(im.width)]
        pieces = [c for c in runs(cols, GAP) if c[1] - c[0] > 40]
        for c, (x0, x1) in enumerate(pieces):
            part = im.crop((x0, y0, x1 + 1, y1 + 1))
            part = part.crop(part.getchannel("A").getbbox())
            k = min(1.0, MAX_CELL_H / part.height)
            part = part.resize((round(part.width * k), round(part.height * k)), Image.LANCZOS)
            name = f"{lib_id}_{r}{c}.png"
            part.save(out_dir / name)
            print(f"{name}: {part.width}x{part.height}")


def facings(alpha, band):
    w, _ = alpha.size
    px = alpha.load()
    y0, y1 = band
    cols = [any(px[x, y] >= ALPHA_MIN for y in range(y0, y1 + 1, 2)) for x in range(w)]
    found = sorted(runs(cols, GAP), key=lambda r: r[1] - r[0], reverse=True)[:5]
    if len(found) < 5:
        raise SystemExit("fewer than five facings in the top row")
    return sorted(found)


def cut(sheet: Path, out: Path):
    im = Image.open(sheet).convert("RGBA")
    alpha = im.getchannel("A")
    band = top_band(alpha)
    crops = []
    for x0, x1 in facings(alpha, band):
        part = im.crop((x0, band[0], x1 + 1, band[1] + 1))
        crops.append(part.crop(part.getchannel("A").getbbox()))
    cw = max(c.width for c in crops) + 4
    ch = max(c.height for c in crops) + 2
    k = min(1.0, MAX_CELL_H / ch)
    cw, ch = max(1, round(cw * k)), max(1, round(ch * k))
    strip = Image.new("RGBA", (cw * 5, ch), (0, 0, 0, 0))
    for i, c in enumerate(crops):
        c = c.resize((max(1, round(c.width * k)), max(1, round(c.height * k))), Image.LANCZOS)
        strip.alpha_composite(c, (i * cw + (cw - c.width) // 2, ch - c.height - 1))
    out.parent.mkdir(parents=True, exist_ok=True)
    strip.save(out)
    print(f"{out.name}: cell {cw}x{ch}, facing0 width {crops[0].width * k / cw:.2f} of cell")


def main():
    lib, out_dir, pitch = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
    if sys.argv[4] == "--kit":
        lib_id = sys.argv[5]
        cut_kit(lib / "keyed" / "prop" / f"{lib_id}_{pitch}.png", out_dir / f"p{pitch}", lib_id)
        return
    for pair in sys.argv[4:]:
        name, lib_id = pair.split("=")
        cut(lib / "keyed" / "prop" / f"{lib_id}_{pitch}.png", out_dir / f"p{pitch}" / f"prop_{name}.png")


if __name__ == "__main__":
    main()
