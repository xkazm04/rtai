# Crops the boss bar's phase count from two 1280x800 (or 1280x720) grabs and stacks them x4: before | after.
import sys
from PIL import Image
before, after, out = sys.argv[1], sys.argv[2], sys.argv[3]
box = (860, 0, 1060, 64)
tiles = [Image.open(p).convert("RGB").crop(box).resize((800, 256), Image.NEAREST) for p in (before, after)]
sheet = Image.new("RGB", (800, 256 * 2 + 8), (20, 20, 20))
sheet.paste(tiles[0], (0, 0)); sheet.paste(tiles[1], (0, 264))
sheet.save(out)
