"""n27 readability: Rivet body, blocking belt boxes and gap belt luminance against the floor ring from a 32 px/m film still. DRESSING=<row> selects the cover rows (default line_fire)."""
import json, sys
import numpy as np
from PIL import Image
from scipy import ndimage

frame_path, log_path, dress_path = sys.argv[1:4]
import re
ART = 'C:/Users/kazda/kiro/gtai-wt/n25-yard/project/'
frame = np.array(Image.open(frame_path).convert('RGB')).astype(float) / 255.0
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
lum = (lin(frame) * np.array([0.2126, 0.7152, 0.0722])).sum(axis=2)   # relative luminance 0..1
m = re.search(r'at (-?[\d.]+),(-?[\d.]+), rivet (-?[\d.]+),(-?[\d.]+)', open(log_path).read())
rep = {'center_m': [float(m[1]), float(m[2])], 'rivet_m': [float(m[3]), float(m[4])], 'ppm': 32, 'ground_k': 0.9396926}
if len(sys.argv) > 4: rep['ppm'] = int(sys.argv[4])
dress = json.load(open(dress_path))['dressings'][__import__('os').environ.get('DRESSING','line_fire')]['layout']
ppm, k = rep['ppm'], rep['ground_k']
cx, cy = rep['center_m']
H, W = lum.shape
def to_px(x, y): return (W / 2 + (x - cx) * ppm, H / 2 + (y - cy) * ppm * k)
def art_alpha(path, w, h, rot_deg=0.0):
    img = Image.open(ART + path.replace('res://', '')).convert('RGBA').resize((w, h), Image.BILINEAR)
    if rot_deg:
        img = img.rotate(-rot_deg, expand=True, resample=Image.BILINEAR)
    return np.array(img)[:, :, 3] > 128
def place(mask, cxp, cyp):
    out = np.zeros((H, W), bool)
    h, w = mask.shape
    x0, y0 = int(round(cxp - w / 2)), int(round(cyp - h / 2))
    xs, ys = max(x0, 0), max(y0, 0)
    xe, ye = min(x0 + w, W), min(y0 + h, H)
    if xe > xs and ye > ys:
        out[ys:ye, xs:xe] = mask[ys - y0:ye - y0, xs - x0:xe - x0]
    return out
def ring(mask, m, forbid):
    r = int(round(m * ppm))
    ry = max(1, int(round(m * ppm * k)))
    st = np.ones((2 * ry + 1, 2 * r + 1), bool)
    grown = ndimage.binary_dilation(mask, structure=st)
    return grown & ~mask & ~forbid
def contrast(body, forbid):
    r = ring(body, 0.5, forbid)
    return abs(lum[body].mean() - lum[r].mean()), lum[body].mean(), lum[r].mean()

res = {'covers': {}, 'gap': {}, 'frame': frame_path}
boxes = {}
for row in dress['cover']:
    if not row['id'].startswith('conveyor_'): continue
    w_m, h_m = row['size_m']
    bw, bh = int(round(w_m * ppm)), int(round(h_m * ppm * k))
    pcx, pcy = to_px(*row['at'])
    box = np.zeros((H, W), bool)
    x0, y0 = int(round(pcx - bw / 2)), int(round(pcy - bh / 2))
    box[max(y0,0):y0 + bh, max(x0,0):x0 + bw] = True
    body = place(art_alpha(row['art'], bw, bh), pcx, pcy)
    boxes[row['id']] = (box, body, bw, bh)
allbox = np.zeros((H, W), bool)
for b, _, _, _ in boxes.values(): allbox |= b
for cid, (box, body, bw, bh) in boxes.items():
    cov = body[box].mean()
    closed = ndimage.binary_closing(body, structure=np.ones((int(0.5*ppm*k)+1, int(0.5*ppm)+1), bool)) & box
    c, lb, lr = contrast(body, allbox)
    res['covers'][cid] = {'box_px': [bw, bh], 'coverage_raw': round(float(cov), 3),
                          'coverage_closed_0.5m': round(float(closed[box].mean()), 3),
                          'lum_body': round(float(lb), 3), 'lum_ring': round(float(lr), 3), 'contrast': round(float(c), 3),
                          'frame_dark_cov': round(float((lum[box] < 0.6 * lr).mean()), 3)}
# gap belt pieces: thin non-colliding debris (belt_*, roller_*)
gap_masks = []
for row in dress['debris']:
    if not (row['id'].startswith('belt_') or row['id'].startswith('roller_')): continue
    w_m, h_m = row['size_m']
    bw, bh = max(1, int(round(w_m * ppm))), max(1, int(round(h_m * ppm)))
    pcx, pcy = to_px(*row['at'])
    m = art_alpha(row['art'], bw, bh, row.get('rotation_deg', 0.0))
    if k != 1.0:  # ground squash in y
        im = Image.fromarray((m * 255).astype(np.uint8)).resize((m.shape[1], max(1, int(round(m.shape[0] * k)))), Image.BILINEAR)
        m = np.array(im) > 128
    gap_masks.append((row['id'], place(m, pcx, pcy)))
gm = np.zeros((H, W), bool)
for _, m in gap_masks: gm |= m
gm &= ~allbox
c, lb, lr = contrast(gm, allbox)
if len(sys.argv) > 5:
    f2 = np.array(Image.open(sys.argv[5]).convert('RGB')).astype(float) / 255.0
    l2 = (lin(f2) * np.array([0.2126, 0.7152, 0.0722])).sum(axis=2)
    res['gap_vs_nogap'] = {'lum_with': round(float(lum[gm].mean()), 3), 'lum_without': round(float(l2[gm].mean()), 3), 'darkening': round(float(l2[gm].mean() - lum[gm].mean()), 3)}
res['gap'] = {'lum_body': round(float(lb), 3), 'lum_ring': round(float(lr), 3), 'contrast': round(float(c), 3), 'pieces': len(gap_masks)}
# Rivet: a disc of his body radius (0.45 m) at his feet position, floor ring 0.5 m around
rx, ry_ = to_px(*rep['rivet_m'])
yy, xx = np.mgrid[0:H, 0:W]
R = 0.45 * ppm
rbody = ((xx - rx) ** 2 + ((yy - ry_) / k) ** 2) <= R ** 2
if rbody.any():
    c, lb, lr = contrast(rbody, allbox)
    res['rivet'] = {'at_px': [round(rx), round(ry_)], 'lum_body': round(float(lb), 3), 'lum_ring': round(float(lr), 3), 'contrast': round(float(c), 3)}
else:
    res['rivet'] = None
covs = [v['coverage_raw'] for v in res['covers'].values()]
cons = [v['contrast'] for v in res['covers'].values()]
res['summary'] = {'min_cov_raw': min(covs) if covs else None, 'mean_rail_contrast': round(float(np.mean(cons)), 3) if cons else None}
print(json.dumps(res, indent=1))
# overlay for checking
ov = Image.open(frame_path).convert('RGB')
a = np.array(ov)
for cid, (box, body, _, _) in boxes.items():
    edge = box & ~ndimage.binary_erosion(box)
    a[edge] = (255, 0, 255)
a[gm & ~ndimage.binary_erosion(gm)] = (0, 255, 255)
a[rbody & ~ndimage.binary_erosion(rbody)] = (0, 255, 0)
Image.fromarray(a).save(frame_path.replace('.png', '_overlay.png'))
