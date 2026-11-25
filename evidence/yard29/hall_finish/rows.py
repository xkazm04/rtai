import sys, numpy as np
from PIL import Image
# lower window row (y 340..400 px at the front camera, 32 px/m) per bay, mean luma, by bay center x px
bays = {"shutter_w": 32, "burst": 506, "feed": 979, "shutter_e": 1453, "collapsed": 1926}
for f in sys.argv[1:]:
    a = np.asarray(Image.open(f).convert('RGB')).astype(float)
    l = a @ [0.2126, 0.7152, 0.0722]
    out = {}
    for k, c in bays.items():
        x0, x1 = max(0, c - 200), min(1920, c + 200)
        out[k] = round(l[340:400, x0:x1].mean(), 1)
    print(f.split('/')[-1], out)
