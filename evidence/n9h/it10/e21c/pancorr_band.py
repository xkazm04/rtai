"""Per-frame image shift of a ground band (full-res y 420-620 of 1280x800) by phase correlation; then the
pan-step unevenness over consecutive frame pairs both moving >= 6 px: |a-b|/max(a,b) (0 even, 0.5 a 1:2 alternation)."""
import subprocess, sys, json, numpy as np
src, W, H = sys.argv[1], 640, 400
y0, y1 = 210, 310
p = subprocess.Popen(['ffmpeg', '-v', 'error', '-i', src, '-vf', f'scale={W}:{H},format=gray', '-f', 'rawvideo', '-'], stdout=subprocess.PIPE)
win = np.outer(np.hanning(y1 - y0), np.hanning(W - 80))
prev, mags, n = None, [], 0
while True:
    b = p.stdout.read(W * H)
    if len(b) < W * H: break
    f = np.frombuffer(b, np.uint8).reshape(H, W).astype(np.float32)[y0:y1, 40:W - 40] * win
    F = np.fft.fft2(f)
    if prev is not None:
        R = F * np.conj(prev); R /= np.abs(R) + 1e-9
        c = np.abs(np.fft.ifft2(R)); y, x = np.unravel_index(np.argmax(c), c.shape)
        y = y - c.shape[0] if y > c.shape[0] // 2 else y; x = x - c.shape[1] if x > c.shape[1] // 2 else x
        mags.append(float(np.hypot(x, y) * 2))
    prev, n = F, n + 1
pairs = [abs(a - b) / max(a, b) for a, b in zip(mags, mags[1:]) if a >= 6 and b >= 6]
pairs = pairs or [0.0]
out = {"clip": src, "frames": n, "pairs": len(pairs), "median": float(np.median(pairs)), "mean": float(np.mean(pairs)),
       "share_ge_0_4": float(np.mean([q >= 0.4 for q in pairs])), "max_step_px": max(mags) if mags else 0}
print(json.dumps(out))
