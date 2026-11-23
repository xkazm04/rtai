"""Cut the folded sliding gate from the hall shutter and mount the city's wire mesh on steel posts."""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

PROJECT = Path(__file__).resolve().parents[2] / "project"
YARD = PROJECT / "boot/prologue/art/torn_line"
INK = "#262225"
STEEL = "#948779"
LIGHT = "#c7b9a5"


def fence_panel():
    # One repeat, including the half post on either edge. The gaps show the real floor.
    panel = Image.new("RGBA", (240, 80))
    source = Image.open(PROJECT / "features/quest/art/collect_call/cage_mesh.png")
    alpha = source.getchannel("A").filter(ImageFilter.MaxFilter(3)).resize((80, 64), Image.Resampling.LANCZOS)
    mesh = Image.new("RGBA", alpha.size, INK)
    mesh.putalpha(alpha)
    for x in range(0, panel.width, mesh.width):
        panel.alpha_composite(mesh, (x, 7))
    pen = ImageDraw.Draw(panel)
    for y in [8, 66]:
        pen.line((0, y, 240, y), fill=INK, width=4)
        pen.line((0, y - 1, 240, y - 1), fill=STEEL, width=1)
    for x in [0, 240]:
        pen.polygon([(x-6,69),(x,64),(x+13,72),(x+7,77)], fill=(42,35,34,88))
        pen.rectangle((x-4,3,x+4,70), fill=INK)
        pen.rectangle((x-2,4,x,68), fill=STEEL)
        pen.ellipse((x-5,0,x+4,7), fill=LIGHT, outline=INK, width=2)
        pen.rectangle((x-5,49,x+4,52), fill=INK)
    return panel


def lay_panel(image, source, corners, brightness):
    # Map the shutter's whole printed surface to this bent section, including its pen texture.
    w, h = source.size
    uv = [(0, 0), (w, 0), (w, h), (0, h)]
    system = []
    for (x, y), (u, v) in zip(corners, uv):
        system.extend(([x,y,1,0,0,0,-u*x,-u*y], [0,0,0,x,y,1,-v*x,-v*y]))
    mapping = np.linalg.solve(system, np.ravel(uv))
    face = ImageEnhance.Brightness(source).enhance(brightness).transform(
        image.size, Image.Transform.PERSPECTIVE, mapping, Image.Resampling.BICUBIC)
    mask = Image.new("L", image.size)
    ImageDraw.Draw(mask).polygon(corners, fill=255)
    image.paste(face, mask=mask)
    pen = ImageDraw.Draw(image)
    pen.line([*corners, corners[0]], fill=INK, width=5, joint="curve")
    pen.line(corners[:2], fill=LIGHT, width=2)
    pen.line(corners[2:], fill=STEEL, width=2)


def sliding_gate(sheet):
    # The rolled ribs run upright in the sliding frame. The last two sections fold back into the yard.
    steel = sheet.crop((397, 433, 544, 498)).convert("RGB").transpose(Image.Transpose.ROTATE_90)
    gate = Image.new("RGBA", (425, 246))
    sections = [
        ([(5,163),(290,161),(291,228),(6,229)], 1.17),
        ([(290,161),(350,146),(352,211),(291,228)], 0.89),
        ([(350,146),(384,97),(389,153),(352,211)], 1.08),
        ([(384,97),(403,5),(415,40),(389,153)], 0.83),
    ]
    for corners, shade in sections:
        length = np.linalg.norm(np.subtract(corners[1], corners[0]))
        bays = max(1, round(length / 80))
        ribs = Image.new("RGB", (steel.width * bays, steel.height))
        for i in range(bays):
            ribs.paste(steel, (i * steel.width, 0))
        lay_panel(gate, ribs, corners, shade)
    pen = ImageDraw.Draw(gate)
    for x in [23, 261]:
        pen.ellipse((x-6,224,x+7,237), fill=INK)
        pen.ellipse((x-3,226,x+4,233), fill=STEEL, outline=INK)
    for x, y in [(13,171),(281,170),(13,220),(282,219),(398,48),(388,100)]:
        pen.ellipse((x-2,y-2,x+2,y+2), fill=LIGHT, outline=INK)
    return gate


def boundary_wall(sheet):
    # Brick and footings below the west clerestory, with a weathered stone coping.
    wall = Image.new("RGBA", (464, 66))
    bricks = sheet.crop((260, 447, 372, 474)).resize((146, 33), Image.Resampling.LANCZOS)
    foot = sheet.crop((260, 478, 372, 497)).resize((146, 17), Image.Resampling.LANCZOS)
    pier = sheet.crop((220, 412, 241, 497)).resize((19, 57), Image.Resampling.LANCZOS)
    cap = sheet.crop((259, 479, 372, 486)).resize((146, 9), Image.Resampling.LANCZOS)
    pen = ImageDraw.Draw(wall)
    pen.rectangle((3, 55, 463, 65), fill=(44, 39, 39, 96))
    for x in range(5, 464, 146):
        wall.paste(bricks, (x, 11))
        wall.paste(foot, (x, 44))
        wall.paste(cap, (x, 2))
    for x in [0, 148, 297, 445]:
        wall.paste(pier, (x, 2))
        pen.rectangle((x, 0, x + 18, 5), fill=STEEL, outline=INK)
    pen.line((0, 61, 463, 61), fill=INK, width=2)
    return wall


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("front_hall", type=Path)
    args = parser.parse_args()
    fence_panel().save(YARD / "fence_panel.png")
    with Image.open(args.front_hall) as sheet:
        sliding_gate(sheet).save(YARD / "sliding_gate.png")
        boundary_wall(sheet).save(YARD / "boundary_wall.png")
