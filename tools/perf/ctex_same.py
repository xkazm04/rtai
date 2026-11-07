"""Check two `.godot/imported` dirs decode to the same pixels (LEDGER L8): every WebP/PNG payload in each
`.ctex` (one per mip level) decoded and compared byte for byte.
Usage: python -I tools/perf/ctex_same.py <imported dir A> <imported dir B>
"""
import io, os, struct, sys
from PIL import Image


def payloads(data):
    out, i = [], 0
    while True:
        r = data.find(b"RIFF", i)
        p = data.find(b"\x89PNG", i)
        cands = [x for x in (r, p) if x >= 0]
        if not cands:
            return out
        j = min(cands)
        if j == r and data[r + 8:r + 12] == b"WEBP":
            n = struct.unpack("<I", data[r + 4:r + 8])[0] + 8
        elif j == p:
            n = struct.unpack("<I", data[j - 4:j])[0]
        else:
            i = j + 4
            continue
        out.append(data[j:j + n])
        i = j + n


a_dir, b_dir = sys.argv[1], sys.argv[2]
same = diff = missing = 0
for f in sorted(os.listdir(a_dir)):
    if not f.endswith(".ctex"):
        continue
    fb = os.path.join(b_dir, f)
    if not os.path.exists(fb):
        missing += 1
        continue
    pa = payloads(open(os.path.join(a_dir, f), "rb").read())
    pb = payloads(open(fb, "rb").read())
    ok = len(pa) == len(pb) and all(
        Image.open(io.BytesIO(x)).convert("RGBA").tobytes() == Image.open(io.BytesIO(y)).convert("RGBA").tobytes()
        for x, y in zip(pa, pb))
    if ok:
        same += 1
    else:
        diff += 1
        print("DIFF", f, len(pa), len(pb))
print("same %d diff %d missing %d" % (same, diff, missing))
