"""Cut reloads on the unscaled hand-made body. Coordinates in the pose tables
are relative to its opaque crop. Each segment is (breech x/y, tip x/y, width)
or (base x/y, feed x/y, width) for a magazine. Empty lists mean fully occluded.
No row or body is flipped. The left sheets supply their own hand-made poses.
"""
import argparse
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "project/features/combat/weapons/art"
VIEW = ROOT / "project/features/characters/art/view"
RECIPES = Path(__file__).with_name("reload_poses")


def asset(path):
    with Image.open(path) as image:
        image = image.convert("RGBA")
        return image.crop(image.getchannel("A").point(lambda a: 255 if a >= 128 else 0).getbbox())


def cut_cell(master, destination):
    image = asset(master)
    # Match the highlights and the shadows of the brass receiver in the
    # hand-made side cell. Keep the master coil's original ink and luminance.
    a = np.array(image)
    y = np.average(a[:, :, :3], axis=2, weights=(.3, .59, .11))
    strength = np.minimum(y / 65, 1) * np.clip((255-y)/75, 0, 1)
    a[:, :, :3] = np.clip(a[:, :, :3] + strength[:, :, None] * [32, 6, -30], 0, 255)
    image = Image.fromarray(a)
    height = round(image.height * 105 / image.width)
    image.resize((105, height), Image.Resampling.LANCZOS).save(destination, optimize=True)


def electro_barrel(pitch, facing):
    # The side fire twin has no flash and exposes all three prongs. Trace
    # the receiver above the claw; the receiving reload pose supplies the grip.
    outlines = {
        "p55": [(54,69),(62,61),(64,54),(71,51),(76,55),(75,60),(84,60),(98,57),
                (113,60),(128,56),(145,66),(141,98),(124,98),(115,92),(89,85),
                (82,87),(78,82),(69,79),(63,93),(54,91),(59,77),(53,75)],
        "p70": [(37,105),(39,96),(45,93),(46,85),(55,82),(61,87),(59,94),(80,94),
                (84,89),(96,91),(98,95),(124,95),(143,85),(166,95),(166,139),
                (141,141),(127,133),(123,125),(96,121),(88,120),(72,117),(62,113),
                (67,126),(57,125),(61,115),(56,111),(44,108)],
    }
    if facing == 1:
        outlines = {
            "p55": [(28,91),(29,84),(35,83),(37,75),(38,71),(44,71),(47,77),
                    (54,77),(61,74),(77,71),(81,67),(88,65),(102,66),(102,96),
                    (90,99),(82,96),(75,95),(67,99),(65,105),(59,106),(57,97),
                    (50,96),(49,102),(43,104),(44,96),(29,96)],
            "p70": [(34,121),(35,115),(40,111),(45,107),(46,101),(53,100),(58,105),
                    (58,110),(75,107),(84,101),(103,97),(110,94),(116,90),(132,95),
                    (133,120),(122,127),(115,128),(109,125),(102,125),(90,129),
                    (88,137),(82,138),(76,128),(70,128),(66,134),(57,136),(59,127),
                    (47,128),(39,127)],
        }
    with Image.open(VIEW / pitch / "rivet_eq_electro_gun_noflash.png") as strip:
        w = strip.width // 8
        cell = strip.crop((facing*w, 0, (facing+1)*w, strip.height))
    cell = cell.crop(cell.getbbox())
    mask = Image.new("L", cell.size)
    ImageDraw.Draw(mask).polygon(outlines[pitch], fill=255)
    mask = np.minimum(np.asarray(mask), np.asarray(cell.getchannel("A")))
    cell.putalpha(Image.fromarray(mask))
    cell = cell.crop(cell.getbbox())
    if facing == 1:
        cell = cell.rotate(-10, Image.Resampling.BICUBIC, expand=True)
        cell = cell.crop(cell.getbbox())
    return cell


def equipped_receiver(gun, pitch, outline):
    path = VIEW / pitch / ("rivet_eq_" + gun + "_noflash.png")
    if not path.exists():
        path = VIEW / pitch / ("rivet_eq_" + gun + ".png")
    with Image.open(path) as sheet:
        w = sheet.width // 8
        cell = sheet.crop((5*w, 0, 6*w, sheet.height)).convert("RGBA")
    cell = cell.crop(cell.getbbox())
    mask = Image.new("L", cell.size)
    ImageDraw.Draw(mask).polygon([tuple(pt) for pt in outline], fill=255)
    cell.putalpha(Image.fromarray(np.minimum(np.asarray(mask), np.asarray(cell.getchannel("A")))))
    return cell.crop(cell.getbbox())


# Target polygons in native base-cell coordinates, followed by the source
# offset on that same painted cell. Restore the claw or collar behind the
# new receiver before laying the gun down. A zero offset keeps original ink.
GRIP_PATCHES = {
    ("pistol", "p55", 1): [
        ([(43,63),(51,62),(59,58),(68,57),(64,60),(55,63),(50,67),
          (49,70),(48,77),(45,80),(43,78)], (0,0)),
        ([(47,78),(47,73),(49,69),(52,66),(57,65),(61,67),(67,72),
          (71,77),(68,81),(52,82)], (0,12)),
        ([(45,79),(53,78),(60,78),(67,76),(75,73),(76,75),(69,82),
          (52,85),(45,84)], (0,3)),
    ],
    ("pistol", "p55", 7): [
        ([(53,51),(67,48),(73,47),(71,50),(64,51),(58,55),(58,62),
          (55,67),(53,66)], (0,0)),
        ([(55,67),(56,60),(59,56),(63,55),(69,56),(78,62),(77,68),
          (65,70),(56,71)], (0,12)),
    ],
    ("plasma_rifle", "p70", 7): [
        ([(74,79),(108,73),(125,72),(141,88),(141,94),(119,95),
          (90,96),(76,98)], (0,0)),
        ([(84,96),(87,91),(91,86),(97,83),(103,81),(109,81),
          (115,83),(120,87),(124,91),(138,91),(140,98),(130,102),
          (110,99),(83,99)], (-74,0)),
        ([(113,83),(120,87),(124,91),(138,91),(140,98),(130,102),
          (110,99),(108,92)], (-101,2)),
        ([(141,89),(178,89),(178,125),(141,125)], (45,0)),
    ],
}


def refill(body, original, offset, patches, erased):
    for points, (dx, dy) in patches:
        mask = Image.new("L", body.size)
        ImageDraw.Draw(mask).polygon([tuple(np.add(pt, offset)) for pt in points], fill=255)
        # Pillow translates the entire donor in integer pixels, including its
        # transparent edge, so hidden steel cannot leave an interpolated halo.
        donor = Image.new("RGBA", body.size)
        donor.paste(original, (-dx, -dy))
        body.paste(donor, mask=Image.fromarray(np.minimum(np.asarray(mask), erased)))


def inset(body, part, segment, offset, outline=None, loose=False, pistol_base=False, round_load=False, patches=()):
    """Project the part along the painted surface. Preserve the hand-inked outer
    contour and the original opacity where the gun and claw overlap."""
    x, y, tx, ty, width = segment
    start = np.array([x, y], dtype=float) + offset
    end = np.array([tx, ty], dtype=float) + offset
    axis = end - start
    if loose or round_load:
        width = max(width, np.linalg.norm(axis) * part.height / part.width)
    across = np.array([-axis[1], axis[0]]) / np.linalg.norm(axis) * width / 2
    if end[0] < start[0]:
        across *= -1
    quad = np.float32([start-across, end-across, end+across, start+across])
    # Premultiplied alpha avoids white fringes where the little prongs meet air.
    source = part.resize((max(3, round(np.linalg.norm(axis)*1.6)), max(3, round(width*1.6))),
                         Image.Resampling.LANCZOS).filter(ImageFilter.UnsharpMask(1, 120, 2)).convert("RGBa")
    w, h = source.size
    dst = cv2.getPerspectiveTransform(np.float32([[0,0],[w-1,0],[w-1,h-1],[0,h-1]]), quad)
    pixels = cv2.warpPerspective(np.asarray(source), dst, body.size, flags=cv2.INTER_LINEAR)
    paint = Image.frombytes("RGBa", body.size, pixels.tobytes()).convert("RGBA")
    if loose:
        # Remove precisely the original separated magazine, keeping the floor
        # transparent, then seat the replacement on its observed centre line.
        alpha = np.asarray(body)[:, :, 3] >= 128
        yy, xx = np.indices(alpha.shape)
        delta = np.stack((xx-start[0], yy-start[1]), axis=-1)
        u = (delta @ axis) / np.dot(axis, axis)
        v = abs(delta @ np.array([-axis[1], axis[0]])) / np.linalg.norm(axis)
        constrained = (u > -.07) & (u < 1.07) & (v < max(segment[4]*.59, width*.59))
        if not pistol_base:
            alpha &= constrained
        _, ids = cv2.connectedComponents(alpha.astype("uint8"))
        cx, cy = np.rint((start + end) * .5).astype(int)
        label = ids[cy, cx]
        if label == 0 or np.sum(ids == label) > 4 * np.linalg.norm(axis)**2:
            raise ValueError("loose magazine is not a separate opaque component")
        body.paste((0, 0, 0, 0), mask=Image.fromarray(cv2.dilate((ids == label).astype("uint8")*255, np.ones((3,3), "uint8"))))
        body.alpha_composite(paint)
        return
    if round_load:
        # A speedloader is circular. Seat its full face between the fingers,
        # replacing the exposed flat surface of the base pistol magazine.
        core = Image.new("L", body.size)
        n = across * segment[4] / width
        points = [start-n, end-n, end+n, start+n]
        ImageDraw.Draw(core).polygon([tuple(np.rint(pt).astype(int)) for pt in points], fill=255)
        body.paste((0, 0, 0, 0), mask=core)
        body.alpha_composite(paint)
        return
    if outline:
        selection = Image.new("L", body.size)
        ImageDraw.Draw(selection).polygon([tuple(np.add(pt, offset)) for pt in outline], fill=255)
        original = np.array(body)
        mask = np.asarray(selection).copy()
        if pistol_base:
            mask = cv2.dilate(mask, np.ones((5, 5), "uint8"))
            # Include the slide sight and its antialiased upper ink where it
            # meets air. A continuous dome or claw ends the search unchanged.
            for x in np.where(mask.any(axis=0))[0]:
                y = int(np.where(mask[:, x])[0][0])
                top = max(0, y-9)
                clear = np.where(original[top:y, x, 3] == 0)[0]
                if clear.size:
                    mask[top + clear[-1] + 1:y, x] = 255
        # Reconstruct just the newly uncovered sliver beneath the old stock.
        # The new housing is drawn at its own width over the restored plate.
        yy, xx = np.indices(mask.shape)
        u = ((xx-start[0])*axis[0]+(yy-start[1])*axis[1]) / np.dot(axis, axis)
        v = abs((xx-start[0])*axis[1]-(yy-start[1])*axis[0]) / np.linalg.norm(axis)
        muzzle = (u > .74) & (u < 1.23) & (v < max(13, width*.6))
        rgb = cv2.inpaint(original[:, :, :3], mask, 2, cv2.INPAINT_TELEA)
        alpha = original[:, :, 3].copy()
        if pistol_base:
            # Restore the silhouette beneath the removed slide before seating
            # the new receiver. All pixels outside the traced gun stay intact.
            alpha[mask != 0] = 0
            muzzle[:] = False
        else:
            alpha[muzzle] = 0
        body.paste(Image.fromarray(np.dstack((rgb, alpha))), mask=Image.fromarray((mask > 0) | muzzle))
        if patches:
            refill(body, Image.fromarray(original), offset, patches, ((mask > 0) | muzzle).astype("uint8")*255)
        body.alpha_composite(paint)
        if pistol_base:
            # A slide sight can leave a detached antialiased edge just outside
            # the trace. Remove only islands beside the replaced receiver.
            remaining = np.array(body)
            count, labels, stats, _ = cv2.connectedComponentsWithStats((remaining[:, :, 3] > 0).astype("uint8"))
            near = cv2.dilate(mask, np.ones((13, 13), "uint8")) != 0
            for label in range(1, count):
                island = labels == label
                if stats[label, cv2.CC_STAT_AREA] < 120 and np.all(near[island]):
                    remaining[island] = 0
            body.paste(Image.fromarray(remaining))
        return
    overlay = Image.alpha_composite(body, paint)
    # The figure and its silhouette are the measured base. Only opaque surface
    # under the identified fittings receives paint, never neighbouring air.
    alpha = body.getchannel("A")
    overlay.putalpha(alpha)
    body.paste(overlay, mask=alpha.point(lambda a: 255 if a else 0))


def build(gun, only_pitch=None, only_suffix=None):
    base = "plasma_rifle" if gun == "electro_gun" else "pistol"
    poses = json.loads((RECIPES / (base + ".json")).read_text())
    outlines = json.loads((RECIPES / (base + "_outlines.json")).read_text())
    mag = asset(ART / gun / "mag.png")
    for pitch, rows in poses.items():
        if only_pitch is not None and pitch != only_pitch:
            continue
        if gun == "electro_gun":
            angled = electro_barrel(pitch, 1)
            side = electro_barrel(pitch, 5)
        else:
            # Side rest exposes the silhouette around the slide and muzzle.
            outline = json.loads((RECIPES / (gun + "_held.json")).read_text())[pitch]
            held = equipped_receiver(gun, pitch, outline)
        for suffix, count, offset in (("", 8, 0), ("_left", 3, 8)):
            if only_suffix is not None and suffix != only_suffix:
                continue
            name = "rivet_reload_" + base + suffix + ".png"
            with Image.open(VIEW / pitch / name) as sheet:
                strip = sheet.convert("RGBA")
            width = strip.width // count
            for i in range(count):
                rect = (i*width, 0, (i+1)*width, strip.height)
                cell = strip.crop(rect)
                origin = cell.getbbox()[:2]
                gun_region, *magazines = rows[offset+i]
                if gun == "electro_gun":
                    held = side if offset+i in (2, 9) else angled
                    start, tip = np.array(gun_region[:2]), np.array(gun_region[2:4])
                    axis = tip - start
                    start = start - axis * (.19 if pitch == "p55" and offset+i != 4 else .08)
                    gun_region = [*start, *tip, np.linalg.norm(tip-start)*.41]
                    if offset+i == 4:  # only the emitter projects past the back of the helmet
                        held = angled.crop((angled.width//2, 0, angled.width, angled.height))
                        gun_region[4] *= 1.9
                else:
                    # Seat the longer skeleton stock behind the grip. Keep the
                    # slotted muzzle at the location painted into the base.
                    start, tip = np.array(gun_region[:2]), np.array(gun_region[2:4])
                    start = start - (tip-start) * (.33 if gun == "machine_pistol" else .10)
                    if gun == "hand_cannon":
                        # The broad cylinder seats lower in the claw than the
                        # pistol slide. Allow the round muzzle its full lip.
                        start[1] += 3
                        tip = tip + (tip-start) * .07 + [0, 3]
                    gun_region = [*start, *tip, np.linalg.norm(tip-start)*held.height/held.width]
                inset(cell, held, gun_region, origin, outline=outlines[pitch][offset+i], pistol_base=base == "pistol",
                      patches=GRIP_PATCHES.get((base, pitch, offset+i), ()))
                for n, region in enumerate(magazines):
                    inset(cell, mag, region, origin, loose=offset+i == 5 and n == len(magazines)-1,
                          pistol_base=base == "pistol", round_load=gun == "hand_cannon")
                strip.paste(cell, (i*width, 0))
            strip.save(VIEW / pitch / name.replace(base, gun), optimize=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("gun", choices=("electro_gun", "machine_pistol", "hand_cannon"))
    parser.add_argument("--energy-master", type=Path)
    args = parser.parse_args()
    if args.energy_master:
        if args.gun != "electro_gun":
            parser.error("only electro_gun uses the energy-cell master")
        cut_cell(args.energy_master, ART / args.gun / "mag.png")
    build(args.gun)
