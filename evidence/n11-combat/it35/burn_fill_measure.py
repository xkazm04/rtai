import sys
from pathlib import Path
import numpy as np
from PIL import Image
sys.path.insert(0, "tools/art")
import street_fall_between as fb
import street_hit_fill as hf
def masked(path):
    im = Image.open(path).convert("RGBA"); a = np.asarray(im).copy()
    f = a.astype(float)/255; r,g,b = f[...,0],f[...,1],f[...,2]
    mx=np.maximum(np.maximum(r,g),b); mn=np.minimum(np.minimum(r,g),b)
    flame=(r>0.6)&(r>=g)&(g>b+0.1)&((mx-mn)/np.maximum(mx,1e-6)>0.35)
    a[flame,3]=0
    return Image.fromarray(a)
for k in ["cop_patrol","cop_riot","swat","thug","ped_hood","ped_cap","ped_punk","ped_jogger"]:
    grid = Image.open(fb.P70/fb.KINDS[k][1]).convert("RGBA")
    mid = hf.mean_thickness(grid,1,5)*(grid.height/5)/fb.STILL_PX
    burn = mid/hf.mean_thickness(masked(fb.P70/f"{k}_burn_hit.png"),0,1)
    hit = mid/hf.mean_thickness(Image.open(fb.P70/f"{k}_hit.png").convert("RGBA"),0,1)
    print(f"{k:12s} hit {hit:.2f} burn_measured {burn:.2f}")
