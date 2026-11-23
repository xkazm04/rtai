"""Cut Peg Dolan's approved plates with the planted patrol walk matte. Keep detached fall props."""
import argparse
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from cast_pack import check_cells
from cast_patrol_eight import FOOT, key_figures
from cast_soles import VIEW, band, body_point, bounds

FACES = ("down", "dr", "right", "ur", "up")
# Boot end of the body (not the separate cap and pole) on the two falling drawings.
FALL_BOOTS = {
    70: [[(.54,.13),(.51,.08)],[(.68,.20),(.86,.89)],[(.56,.85),(.94,.68)],
         [(.72,.84),(.90,.47)],[(.62,.90),(.55,.94)]],
    55: [[(.60,.87),(.52,.91)],[(.80,.88),(.88,.84)],[(.88,.82),(.93,.60)],
         [(.84,.83),(.90,.40)],[(.58,.92),(.53,.93)]],
}


def sheet(path, layout, fall=False):
    """Order connected figures by source band. Assign loose props by their band and column."""
    rgb, labels, stats, spill = key_figures(path)
    ids = [i for i, stat in enumerate(stats[1:], 1) if stat[4] >= 30]
    if fall:
        groups = [[[] for _ in range(3)] for _ in range(5)]
        for i in ids:
            x, y, w, h, area = stats[i]
            row = min(4, int((y+h/2)/rgb.shape[0]*5))
            col = min(2, int((x+w/2)/rgb.shape[1]*3))
            groups[row][col].append(i)
    else:
        bodies = sorted((i for i in ids if stats[i, 4] > 1500),
                        key=lambda i: stats[i, 1] + stats[i, 3]/2)
        if len(bodies) != sum(layout):
            raise ValueError(f"{path}: expected {sum(layout)} figures, got {len(bodies)}")
        groups = []
        for n in layout:
            groups.append([[i] for i in sorted(bodies[:n], key=lambda i: stats[i, 0])])
            bodies = bodies[n:]
    rgb = rgb.copy()
    rgb[spill] = (21, 24, 29)
    result = []
    for group in groups:
        strip = []
        for ids in group:
            x, y = stats[ids,:2].min(axis=0)
            r, b = (stats[ids,:2]+stats[ids,2:4]).max(axis=0)
            local = labels[y:b,x:r]
            alpha = np.isin(local, ids)
            color = rgb[y:b,x:r].copy()
            color[~alpha] = 0
            im = Image.fromarray(np.dstack((color,alpha.astype(np.uint8)*255)))
            # Remove thin pole/noose from the registration mask only. Scale the whole RGBA drawing.
            main = local == max(ids, key=lambda i: stats[i,4])
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (11,11))
            thick = cv2.morphologyEx(main.astype(np.uint8), cv2.MORPH_OPEN, kernel)
            n, parts, sizes, _ = cv2.connectedComponentsWithStats(thick)
            mask = parts == (1 + np.argmax(sizes[1:n,4]))
            strip.append((im, mask))
        result.append(strip)
    return result


def cells(folder, pitch, action):
    if action == "planted8_armed_walk":
        strips = []
        for face in FACES[:5 if pitch == 70 else 3]:
            path = folder.parent/f"warden8c/out/warden8_{pitch}_{face}_t3.png"
            strips.append(sum(sheet(path, (4,4)), []))
        if pitch == 55:
            strips.extend(sheet(folder.parent/"warden8b/out/warden8_armed_walk_55_b_t2.png", (8,8)))
        return strips
    path = folder/f"out/warden_{action}_{pitch}.png"
    if action == "hit":
        living, _ = sheet(path, (5,3))
        return [[drawing] for drawing in living]
    return sheet(path, [3 if action == "fall" else 4]*5, action == "fall")


def stature(mask):
    _, top, _, bottom = bounds(mask)
    return bottom - top


def neutral_steel(grid):
    pixels = np.array(grid)
    hue, sat, _ = cv2.cvtColor(pixels[:,:,:3], cv2.COLOR_RGB2HSV).transpose(2,0,1)
    blue = (hue >= 95) & (hue <= 125) & (sat > 50)
    grey = cv2.cvtColor(pixels[:,:,:3], cv2.COLOR_RGB2GRAY)
    pixels[blue,:3] = grey[blue,None]
    return Image.fromarray(pixels)


def pack(folder, pitch, action, heights):
    strips = cells(folder, pitch, action)
    frames = len(strips[0])
    fall = action == "fall"
    ch = 440 if fall else 256
    baseline = ch//2 if fall else FOOT
    figures = []
    for col, strip in enumerate(strips):
        reference = strip[:1] if fall else strip
        scale = heights[col] / np.mean([stature(mask) for _,mask in reference])
        resized = []
        for row,(im,mask) in enumerate(strip):
            boot = band(mask)
            if fall and row:
                x,y,r,b = bounds(mask)
                u,v = FALL_BOOTS[pitch][col][row-1]
                boot = np.array([x+(r-x)*u,y+(b-y)*v])
            size = tuple(round(n*scale) for n in im.size)
            tile = im.resize(size, Image.Resampling.LANCZOS)
            resized.append((tile, boot*np.array(size)/im.size))
        if frames == 8:
            # Use the same torso landmark as the runtime walk solver.
            centres = [body_point(np.asarray(tile)[:,:,3] > 128) for tile,_ in resized]
            body_y = baseline - np.mean([boot[1]-pt[1] for (_,boot),pt in zip(resized,centres)])
            resized = [(tile,np.array([pt[0],pt[1]-body_y+baseline]))
                       for (tile,_),pt in zip(resized,centres)]
        figures.append(resized)
    cw = 2 * (4 + int(np.ceil(max(max(boot[0],tile.width-boot[0])
                                 for strip in figures for tile,boot in strip))))
    grid = Image.new("RGBA",(cw*5,ch*frames))
    for col,strip in enumerate(figures):
        for row,(tile,boot) in enumerate(strip):
            x,y = np.rint([cw/2-boot[0],baseline-boot[1]]).astype(int)
            if min(x,y)<1 or y+tile.height>=ch or x+tile.width>=cw:
                raise ValueError(f"{pitch}/{action}/{col}/{row}: {x},{y} size {tile.size} in {cw},{ch}")
            grid.paste(tile,(cw*col+x,ch*row+y))
    dest = VIEW/f"p{pitch}/appliance_warden_{action}.png"
    grid = neutral_steel(grid)
    grid.save(dest)
    check_cells(dest, frames)
    work = folder/"pack"
    work.mkdir(exist_ok=True)
    plate = Image.new("RGB",(frames*160,5*150))
    for col in range(5):
        for row in range(frames):
            tile = grid.crop((col*cw,row*ch,(col+1)*cw,(row+1)*ch))
            tile = tile.crop(tile.getbbox())
            tile.thumbnail((155,140))
            box = (row*160,col*150,(row+1)*160,(col+1)*150)
            plate.paste("#c8c6bc" if (row+col)%2 else "#424447",box)
            plate.paste(tile,(box[0]+(160-tile.width)//2,box[1]+(150-tile.height)//2),tile)
    plate.save(work/f"{action}_{pitch}.jpg")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("folder", type=Path)
    args = p.parse_args()
    for pitch in (70,55):
        four = cells(args.folder,pitch,"armed_walk")
        raw = [np.mean([stature(mask) for _,mask in strip]) for strip in four]
        heights = np.array(raw) * (155 if pitch == 70 else 153) / raw[1]
        for action in ("armed_walk","attack","hit","fall","planted8_armed_walk"):
            pack(args.folder,pitch,action,heights)
