import sys
sys.path.insert(0,"evidence/n29-keys/rag")
import numpy as np
from PIL import Image, ImageDraw
import _ref as R, flame_cells as F
def annot(rel, out, s=2, grid=None, region=None):
    a=R.load(F.V+rel)
    im=Image.fromarray(a,"RGBA"); b=Image.new("RGBA",im.size,(60,60,70,255)); b.alpha_composite(im)
    if region: x0,y0,x1,y1=region; b=b.crop(region)
    else: x0=y0=0
    b=b.resize((b.width*s,b.height*s),Image.NEAREST); d=ImageDraw.Draw(b)
    from scipy import ndimage
    m=R.mask(a); lab,n=ndimage.label(m,structure=np.ones((3,3)))
    for i in range(1,n+1):
        ys,xs=np.nonzero(lab==i)
        if 25<=len(ys)<=500:
            bx=((xs.min()-x0)*s,(ys.min()-y0)*s,(xs.max()+1-x0)*s,(ys.max()+1-y0)*s)
            if bx[2]<0 or bx[3]<0 or bx[0]>b.width or bx[1]>b.height: continue
            d.rectangle(bx,outline=(0,255,0)); d.text((bx[0],bx[1]-10),"%d,%d"%(xs.min(),ys.min()),fill=(255,255,0))
    b.save(out)
if __name__=="__main__":
    annot(sys.argv[1],sys.argv[2],int(sys.argv[3]), region=tuple(map(int,sys.argv[4].split(","))) if len(sys.argv)>4 else None)
