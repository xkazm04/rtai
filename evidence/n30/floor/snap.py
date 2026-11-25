import sys
import numpy as np
from PIL import Image
INKS = {'cream':(0.949,0.910,0.835),'steel':(0.561,0.533,0.506),'ink':(0.090,0.075,0.106),
        'verm':(0.910,0.314,0.165),'amber':(0.929,0.671,0.259),'teal':(0.122,0.710,0.659)}
NAMES=list(INKS); C=np.array([INKS[n] for n in NAMES])
def snap(rgb):  # rgb float N x 3 -> index
    d=((rgb[:,None,:]-C[None,:,:])**2).sum(-1); return d.argmin(1)
def report(path):
    a=np.asarray(Image.open(path).convert('RGBA')).astype(np.float64)/255
    op=a[...,3]>=0.75
    rgb=a[...,:3]
    s=snap(rgb[op]); print(path, 'texels', op.sum(), {NAMES[i]:int((s==i).sum()) for i in range(6)})
    # bilinear midpoints between horizontal/vertical/diag neighbours (both opaque)
    tot={};
    for dy,dx in [(0,1),(1,0),(1,1)]:
        A=rgb[:rgb.shape[0]-dy,:rgb.shape[1]-dx]; B=rgb[dy:,dx:]
        m=op[:op.shape[0]-dy,:op.shape[1]-dx]&op[dy:,dx:]
        for t in (0.25,0.5,0.75):
            s=snap((A*(1-t)+B*t)[m])
            tot[(dy,dx,t)]=int((s==3).sum())
    print(' verm blends', sum(tot.values()), tot)
if __name__ == "__main__":
    for p in sys.argv[1:]: report(p)
