"""Cut a keyed library portrait sheet (two busts side by side: neutral, emotion) into two
trimmed busts for the dialogue box: <out>/<id>.png and <out>/<id>_mood.png, each scaled to
HEIGHT px tall. The split column is the emptiest alpha column in the middle third.
Device mode (--device): take the first facing of a five-facing prop sheet instead.

usage: python tools/art/portrait_cut.py <keyed.png> <out_dir> <id> [--device]
"""
import sys
from PIL import Image

HEIGHT = 320
ALPHA_MIN = 16


def trim(im: Image.Image) -> Image.Image:
    a = im.getchannel("A").point(lambda v: 255 if v >= ALPHA_MIN else 0)
    box = a.getbbox()
    return im.crop(box) if box else im


def scaled(im: Image.Image) -> Image.Image:
    w = max(1, round(im.width * HEIGHT / im.height))
    return im.resize((w, HEIGHT), Image.LANCZOS)


def split_column(im: Image.Image, lo: float, hi: float) -> int:
    a = im.getchannel("A")
    w, h = im.size
    best, best_x = None, w // 2
    for x in range(int(w * lo), int(w * hi)):
        n = sum(1 for y in range(0, h, 2) if a.getpixel((x, y)) >= ALPHA_MIN)
        if best is None or n < best:
            best, best_x = n, x
    return best_x


def main() -> None:
    src, out, pid = sys.argv[1], sys.argv[2], sys.argv[3]
    im = Image.open(src).convert("RGBA")
    if "--device" in sys.argv:
        x = split_column(im, 0.1, 0.3)
        scaled(trim(im.crop((0, 0, x, im.height)))).save(f"{out}/{pid}.png")
        return
    x = split_column(im, 0.34, 0.66)
    scaled(trim(im.crop((0, 0, x, im.height)))).save(f"{out}/{pid}.png")
    scaled(trim(im.crop((x, 0, im.width, im.height)))).save(f"{out}/{pid}_mood.png")


if __name__ == "__main__":
    main()
