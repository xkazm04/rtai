"""Estimate the pck saving of a higher WebP lossless effort (LEDGER L8), pixel-free.

Encodes a sample of the project's PNGs with libwebp lossless at Godot's default (quality 25, method 2)
and at the max (quality 100, method 6), checks the decode is bit-exact, and prints bytes and encode/decode ms.
Usage: python -I tools/perf/webp_effort.py <project dir> [sample count]
"""
import io, os, sys, time
from PIL import Image

root = sys.argv[1]
count = int(sys.argv[2]) if len(sys.argv) > 2 else 40
pngs = []
for d, _, files in os.walk(root):
    if ".godot" in d or "addons" in d:
        continue
    pngs += [os.path.join(d, f) for f in files if f.endswith(".png")]
pngs.sort(key=lambda p: -os.path.getsize(p))
step = max(1, len(pngs) // count)
sample = pngs[::step][:count]
tot = {"a": 0, "b": 0, "enc_a": 0.0, "enc_b": 0.0, "dec_a": 0.0, "dec_b": 0.0}
for p in sample:
    im = Image.open(p).convert("RGBA")
    raw = im.tobytes()
    for k, q, m in (("a", 25, 2), ("b", 100, 6)):
        buf = io.BytesIO()
        t = time.perf_counter()
        im.save(buf, "WEBP", lossless=True, quality=q, method=m, exact=True)
        tot["enc_" + k] += time.perf_counter() - t
        data = buf.getvalue()
        t = time.perf_counter()
        back = Image.open(io.BytesIO(data)).convert("RGBA").tobytes()
        tot["dec_" + k] += time.perf_counter() - t
        assert back == raw, p
        tot[k] += len(data)
print("files %d of %d pngs" % (len(sample), len(pngs)))
print("default q25 m2: %.1f MB, enc %.1f s, dec %.2f s" % (tot["a"] / 1e6, tot["enc_a"], tot["dec_a"]))
print("max     q100 m6: %.1f MB, enc %.1f s, dec %.2f s" % (tot["b"] / 1e6, tot["enc_b"], tot["dec_b"]))
print("saving %.1f %%" % (100.0 * (1 - tot["b"] / tot["a"])))
