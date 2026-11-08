"""Per-frame global image shift (phase correlation) of a clip, in full-res px; prints the largest."""
import subprocess, sys, numpy as np
src, W, H = sys.argv[1], 640, 400
p = subprocess.Popen(['ffmpeg', '-v', 'error', '-i', src, '-vf', f'scale={W}:{H},format=gray', '-f', 'rawvideo', '-'], stdout=subprocess.PIPE)
win = np.outer(np.hanning(H - 160), np.hanning(W - 80))
prev, out, n = None, [], 0
while True:
    b = p.stdout.read(W * H)
    if len(b) < W * H: break
    f = np.frombuffer(b, np.uint8).reshape(H, W).astype(np.float32)[80:H - 80, 40:W - 40] * win
    F = np.fft.fft2(f)
    if prev is not None:
        R = F * np.conj(prev); R /= np.abs(R) + 1e-9
        c = np.abs(np.fft.ifft2(R)); y, x = np.unravel_index(np.argmax(c), c.shape)
        y = y - c.shape[0] if y > c.shape[0] // 2 else y; x = x - c.shape[1] if x > c.shape[1] // 2 else x
        out.append((n, 2 * x, 2 * y, float(np.hypot(x, y) * 2)))
    prev, n = F, n + 1
s = sorted(out, key=lambda r: -r[3])
if len(sys.argv) > 2: __import__("json").dump([[int(r[0]), int(r[1]), int(r[2])] for r in out], open(sys.argv[2], "w"))
print(sys.argv[1], 'frames', n, 'median shift px %.1f' % np.median([r[3] for r in out]), 'largest (frame, dx, dy, px):', s[:10])
d = {r[0]: r for r in out}
for k in [r[0] for r in s[1:4]]: print(k, [(d[j][1], d[j][2]) for j in range(k - 3, k + 4) if j in d])
