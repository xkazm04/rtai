"""Heights of the figures in the size_beside_32.mp4 film (n29-cast-13).

The camera and street are static, the figure row walks, so a per-pixel median over
frames sampled across the clip is the empty street. Per frame: |frame - median| > T,
dilated, connected components; a figure is a component 22-90 px tall and 12-70 px
wide that is not label text (labels sit in a row band below the figures and are cut
by the row where the text begins). Height = top row to bottom row of the opaque
changed pixels, in the video's px (32 px/m).
usage: python cast_film_heights.py <frames_dir> <out_dir>
"""
import sys, glob, json, os
import numpy as np, cv2

NAMES = ["warden", "contractor", "gunner", "rocket_trooper", "sentry_turret", "mulroney",
         "door_carrier", "war_machine", "cop_0.92", "cop_0.85", "cop_1.10", "rivet"]


CROPS = {'door_carrier', 'war_machine', 'sentry_turret', 'rivet', 'mulroney'}


def main(fr: str, out: str) -> None:
    files = sorted(glob.glob(os.path.join(fr, "a*.png")))
    imgs = [cv2.imread(f) for f in files]
    med = np.median(np.stack(imgs[::2]), axis=0).astype(np.uint8)
    res = {n: [] for n in NAMES}
    clipped = {n: 0 for n in NAMES}
    k = np.ones((5, 9), np.uint8)
    for i, im in enumerate(imgs):
        a = im.astype(float)
        r = a / (med.astype(float) + 1)
        chg = np.abs(a - med.astype(float)).sum(2) > 60
        # the ground shadow is an even darkening of the street (same ratio in all channels)
        shadow = (r.mean(2) > 0.45) & (r.mean(2) < 0.95) & ((r.max(2) - r.min(2)) < 0.12)
        d = (chg & ~shadow).astype(np.uint8)
        d[:380] = 0
        d[700:] = 0
        # the name labels are one text row band: the first row whose changed count tops 550
        cut = 10**6
        lab_rows = np.nonzero(d.sum(1) > 550)[0]
        if len(lab_rows):
            cut = lab_rows[0] - 5  # the ascenders start ~4 rows above the dense row
            d[cut:] = 0
        n, lab, st, _ = cv2.connectedComponentsWithStats(cv2.dilate(d, k, iterations=1))
        figs = []
        for j in range(1, n):
            x, y, w, h, a = st[j]
            if 22 <= h <= 100 and 12 <= w <= 100 and a > 600:
                m = (lab == j) & (d > 0)
                ys, xs = np.nonzero(m)
                cnt = np.bincount(ys - y, minlength=h)
                ok = np.nonzero(cnt >= 2)[0]
                figs.append((xs.mean(), y + ok[0], y + ok[-1], (x, y, w, h)))
        figs.sort()
        if len(figs) != 12:
            continue
        for nm, (cx, t, b, bb) in zip(NAMES, figs):
            res[nm].append((i, int(b - t + 1), bb))
            if b >= cut - 2:
                clipped[nm] += 1
            if nm in CROPS and i in (10, 30):
                cx0 = int(cx)
                c = im[max(t - 6, 0):b + 8, cx0 - 60:cx0 + 60].copy()
                c[6, :] = (0, 0, 255)
                c[b - t + 6, :] = (0, 255, 0)
                cv2.imwrite(os.path.join(out, f"crop_{nm}_{i}.png"), cv2.resize(c, None, fx=4, fy=4, interpolation=0))
        if i in (4, 20, 36, 44):
            vis = im.copy()
            for _, _, _, (x, y, w, h) in figs:
                cv2.rectangle(vis, (x, y), (x + w, y + h), (0, 0, 255), 1)
            cv2.imwrite(os.path.join(out, f"boxes_{i}.png"), vis[380:700])
    json.dump({k: [(a, b) for a, b, _ in v] for k, v in res.items()}, open(os.path.join(out, "h.json"), "w"))
    riv = np.median([h for _, h, _ in res["rivet"]]) if res["rivet"] else 0
    for nm in NAMES:
        h = [x[1] for x in res[nm]]
        if h:
            print(f"{nm:15s} n={len(h):2d} med={np.median(h):5.1f} min={min(h)} max={max(h)} /rivet={np.median(h)/riv:.3f} bottom at label cut in {clipped[nm]}")
    print("frames used", len(res["rivet"]), "of", len(imgs))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
