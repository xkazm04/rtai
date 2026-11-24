"""Tint / wash hex for a target between-pools floor (L*, C*=24, hue 66) from today's (172,155,135). python -I gains.py <L*>..."""
import sys
import numpy as np
def to_srgb(l): l=np.clip(l,0,1); return np.where(l<=0.0031308,l*12.92,1.055*l**(1/2.4)-0.055)*255.0
def lab2srgb(L,C,h):
    a,b=C*np.cos(np.radians(h)),C*np.sin(np.radians(h)); fy=(L+16)/116; fx,fz=fy+a/500,fy-b/200
    f=lambda t: np.where(t**3>216/24389,t**3,(116*t-16)/(24389/27))
    xyz=np.array([f(fx)*0.95047,f(fy),f(fz)*1.08883])
    m=np.array([[3.2404542,-1.5371385,-0.4985314],[-0.9692660,1.8760108,0.0415560],[0.0556434,-0.2040259,1.0572252]])
    return to_srgb(m@xyz)
base=np.array([172,155,135.])
for L in map(float, sys.argv[1:]):
    t=lab2srgb(L,24,66); g=t/base; g2=g/g.max()
    print(L, np.round(t), 'gain', np.round(g,3), 'norm', np.round(g2,3), 'tint', ''.join(f'{int(round(255*x)):02x}' for x in g2), 'wash', ''.join(f'{int(round(v*x)):02x}' for v,x in zip((246,220,168),g2)))
