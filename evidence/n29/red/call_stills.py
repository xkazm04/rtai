"""n29 red call stills: rocket/nuke band mock and Mertz gloves boxes. Pillow only."""
import colorsys
import sys
from PIL import Image, ImageDraw

ROOT = "C:/Users/kazda/kiro/gtai-wt/n23-street/project/features/combat/weapons/art/fx/"
OUT = "C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/"
BG = (0x15, 0x12, 0x1A, 255)
CREAM = (0xF2, 0xE6, 0xC4, 255)


def is_red(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    h *= 360
    return (h <= 24 or h >= 345) and s > 0.5 and v > 0.45


def amber_mock(img: Image.Image) -> Image.Image:
    out = img.copy()
    px = out.load()
    ah, as_, _ = colorsys.rgb_to_hsv(0xED / 255, 0xAB / 255, 0x42 / 255)
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if is_red(r, g, b, a):
                v = max(r, g, b) / 255
                nr, ng, nb = colorsys.hsv_to_rgb(ah, as_, v)
                px[x, y] = (round(nr * 255), round(ng * 255), round(nb * 255), a)
    return out


def count(img: Image.Image) -> int:
    px = img.load()
    return sum(is_red(*px[x, y]) for y in range(img.height) for x in range(img.width))


def rocket_pair() -> None:
    sprites = []
    for name in ("rocket", "nuke_shell"):
        img = Image.open(ROOT + name + ".png").convert("RGBA")
        mock = amber_mock(img)
        print(name, img.size, "reddish before", count(img), "after mock", count(mock))
        sprites.append((img, mock))
    scale = max(1, -(-160 // min(i.height for i, _ in sprites)))
    scale = max(scale, 8)
    pad, label = 16, 20
    cells = [(i.width * scale, i.height * scale) for i, _ in sprites]
    rowh = max(h for _, h in cells)
    colw = max(w for w, _ in cells)
    width = pad + 2 * (colw + pad)
    height = pad + len(sprites) * (label + rowh + pad)
    sheet = Image.new("RGBA", (width, height), BG)
    d = ImageDraw.Draw(sheet)
    y = pad
    for img, mock in sprites:
        for col, (im, text) in enumerate(((img, "shipped (kept)"), (mock, "amber mock (not shipped)"))):
            x = pad + col * (colw + pad)
            d.text((x, y), text, fill=CREAM)
            big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
            sheet.alpha_composite(big, (x, y + label))
        y += label + rowh + pad
    sheet.convert("RGB").save(OUT + "call_rocket_band_pair_8x.png")


def mertz_gloves() -> None:
    src = Image.open(OUT + "red_elec_tazer_after2_64.png").convert("RGBA")
    px = src.load()
    pts = {(x, y) for y in range(src.height) for x in range(src.width)
           if px[x, y][3] > 0 and px[x, y][0] > 170 and px[x, y][1] < 110 and px[x, y][2] < 90}
    seen, boxes = set(), []
    for p in sorted(pts):
        if p in seen:
            continue
        stack, comp = [p], []
        seen.add(p)
        while stack:
            cx, cy = stack.pop()
            comp.append((cx, cy))
            for dx in range(-3, 4):
                for dy in range(-3, 4):
                    n = (cx + dx, cy + dy)
                    if n in pts and n not in seen:
                        seen.add(n)
                        stack.append(n)
        if len(comp) >= 20:
            xs, ys = [c[0] for c in comp], [c[1] for c in comp]
            boxes.append((min(xs), min(ys), max(xs), max(ys), len(comp)))
    for b in boxes:
        print("glove bbox", b[:4], "px", b[4])
    marked = src.copy()
    d = ImageDraw.Draw(marked)
    for x0, y0, x1, y1, _ in boxes:
        d.rectangle((x0 - 3, y0 - 3, x1 + 3, y1 + 3), outline=CREAM, width=2)
    if boxes:
        cx0 = max(0, min(b[0] for b in boxes) - 12)
        cy0 = max(0, min(b[1] for b in boxes) - 12)
        cx1 = min(src.width, max(b[2] for b in boxes) + 13)
        cy1 = min(src.height, max(b[3] for b in boxes) + 13)
        crop = src.crop((cx0, cy0, cx1, cy1))
        crop = crop.resize((crop.width * 3, crop.height * 3), Image.NEAREST)
    else:
        crop = Image.new("RGBA", (10, 10), BG)
    label = 24
    w = src.width + 8 + crop.width
    h = max(src.height, crop.height) + label
    sheet = Image.new("RGBA", (w, h), BG)
    ImageDraw.Draw(sheet).text((4, 6), "vermilion gloves = cast art (NEED cast)", fill=CREAM)
    sheet.alpha_composite(marked, (0, label))
    sheet.alpha_composite(crop, (src.width + 8, label))
    sheet.convert("RGB").save(OUT + "call_mertz_gloves_64.png")


if __name__ == "__main__":
    rocket_pair()
    mertz_gloves()
    sys.exit(0)
