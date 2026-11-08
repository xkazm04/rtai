"""Replays BossCam's framed focus (camp-a.txt: tick, framed x y, eased x y, m/px) through CamFollow's
law at several accel limits; prints the camera's worst accel, worst speed and worst lag (px, 40 px/m).
Hit-stop frames (repeated ticks) are skipped, as CamFollow.advance holds on them."""
import math, sys
rows = []
for l in open(sys.argv[1]):
    r = list(map(float, l.split()))
    if not rows or r[0] != rows[-1][0]: rows.append(r)
mpp = rows[100][5]
def run(apx):
    a = apx * mpp; pos = None; vel = (0, 0); tgt = None; out = []
    for r in rows:
        t = (r[1], r[2])
        if pos is None or a <= 0: pos, tgt, vel = t, t, (0, 0); out.append(pos); continue
        tv = (t[0] - tgt[0], t[1] - tgt[1]); e = (tgt[0] - pos[0], tgt[1] - pos[1]); tgt = t
        d = math.hypot(*e); c = min(d, a * (math.sqrt(0.25 + 2 * d / a) - 0.5)) if d > 0 else 0
        w = (tv[0] + (e[0] / d * c if d else 0), tv[1] + (e[1] / d * c if d else 0))
        dv = (w[0] - vel[0], w[1] - vel[1]); n = math.hypot(*dv)
        if n > a: dv = (dv[0] / n * a, dv[1] / n * a)
        vel = (vel[0] + dv[0], vel[1] + dv[1]); pos = (pos[0] + vel[0], pos[1] + vel[1]); out.append(pos)
    v = [((out[i][0] - out[i-1][0]) / mpp, (out[i][1] - out[i-1][1]) / mpp) for i in range(1, len(out))]
    acc = [math.hypot(v[i][0] - v[i-1][0], v[i][1] - v[i-1][1]) for i in range(1, len(v))]
    lag = [math.hypot(out[i][0] - rows[i][1], out[i][1] - rows[i][2]) / mpp for i in range(len(out))]
    return max(acc[5:]), max(math.hypot(*x) for x in v[5:]), max(lag), sum(x > 4 for x in acc[5:])
for apx in (0, 1, 1.5, 2, 3, 4, 6):
    print('accel %.1f px/tick^2: worst accel %.1f, worst speed %.1f px/tick, worst lag %.1f px, ticks with accel > 4: %d' % ((apx,) + run(apx)))
