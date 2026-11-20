"""Seat the far arm behind the packed east/west HOVER figure. Called by kerf_n21_cut."""

from math import atan2, cos, dist, radians, sin

from PIL import Image, ImageChops, ImageDraw, ImageEnhance


# Coordinates are local to HOVER, row 2. Each outline follows transparent
# space around the near limb, separating it from the crest and shoulder.
PROFILE = {
    "70": {
        "forearm": [(100, 0), (238, 0), (178, 60), (159, 99), (157, 148),
                    (166, 180), (183, 202), (202, 209), (194, 242), (139, 233), (99, 185)],
        "upper": [(163, 214), (177, 198), (196, 199), (232, 173), (250, 173),
                  (246, 194), (199, 221), (188, 237), (165, 237)],
        "elbow": (182, 222), "shoulder": (241, 186),
        "far_elbow": (204, 172), "far_shoulder": (244, 167),
        "scale": 0.76, "angle": -13,
    },
    "55": {
        "forearm": [(123, 0), (235, 0), (190, 48), (173, 83), (173, 134),
                    (174, 152), (188, 181), (196, 187), (190, 216), (143, 224), (124, 159)],
        "upper": [(154, 197), (169, 179), (186, 181), (219, 151), (242, 144),
                  (248, 164), (187, 215), (159, 217)],
        "elbow": (177, 202), "shoulder": (239, 162),
        "far_elbow": (205, 159), "far_shoulder": (246, 149),
        "scale": 0.79, "angle": -12,
    },
}


def cut_limb(cell, outline):
    mask = Image.new("L", cell.size)
    ImageDraw.Draw(mask).polygon(outline, fill=255)
    limb = ImageEnhance.Brightness(cell).enhance(0.75)
    limb.putalpha(ImageChops.multiply(cell.getchannel("A"), mask))
    return limb


def seat(limb, pivot, destination, scale, angle, mirrored=False):
    # Pillow samples destination -> source. Keep the elbow registered while
    # foreshortening and turning the distal crescent across the near blade.
    c, s = cos(angle) / scale, sin(angle) / scale
    a, b = (-c, -s) if mirrored else (c, s)
    x, y = destination
    inverse = (a, b, pivot[0] - a*x - b*y, -s, c, pivot[1] + s*x - c*y)
    return limb.transform(limb.size, Image.Transform.AFFINE, inverse, Image.Resampling.BICUBIC)


def bearing(start, end):
    return atan2(end[1] - start[1], end[0] - start[0])


def add_far_blade(path, pitch):
    with Image.open(path) as packed:
        atlas = packed.copy()
    w, h = atlas.width // 4, atlas.height // 5
    box = (0, 2*h, w, 3*h)
    cell = atlas.crop(box)
    pose = PROFILE[pitch]
    elbow, shoulder = pose["elbow"], pose["shoulder"]
    far_elbow, far_shoulder = pose["far_elbow"], pose["far_shoulder"]
    upper = cut_limb(cell, pose["upper"])
    forearm = cut_limb(cell, pose["forearm"])
    back = seat(upper, elbow, far_elbow, dist(far_elbow, far_shoulder) / dist(elbow, shoulder),
                bearing(far_elbow, far_shoulder) - bearing(elbow, shoulder))
    back.alpha_composite(seat(forearm, elbow, far_elbow, pose["scale"], radians(pose["angle"]),
                              mirrored=True))
    back.alpha_composite(cell)
    atlas.paste(back, box)
    atlas.save(path)
