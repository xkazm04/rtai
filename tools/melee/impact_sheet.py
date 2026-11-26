"""n31 melee 04f part B: the impact audit sheet, before | after, at 64 px/m.

python tools/melee/impact_sheet.py <before_dir> <after_dir> <out.png>

The stills are marks_still crops (res://dev/melee_n31/marks_still.tscn, --ppm=64): before from a temp
worktree at 0f1e1ce95 (the audit commit), after from HEAD. Rows = weapons in the audit order below,
columns = hit human (cop) / hit robot (robot thug) / hit shield (riot cop). Each cell is the before
crop | the after crop; the corner prints the score 0-3 before -> after (before from
evidence/n31-melee/04-impacts/audit.md, after from looking at these stills: see AFTER_WHY).
"""

import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROWS = ["claw", "katana", "plasma_sword", "chainsaw", "electro_baton", "pistol", "gatling"]
COLS = [("cop", "hit human"), ("robot", "hit robot"), ("riot", "hit shield")]
# Which marks_still frame shows the hit best: "" = the hit frame (age 0), "_mid" = half the mark's life
# later (the saw's grind has built up).
FRAME = {"chainsaw": "_mid"}
# audit.md scores (human, robot, shield).
BEFORE = {
    "claw": (3, 2, 2),
    "katana": (1, 1, 2),
    "plasma_sword": (1, 1, 1),
    "chainsaw": (1, 0, 1),
    "electro_baton": (2, 2, 1),
    "pistol": (1, 1, 2),
    "gatling": (1, 1, 2),
}
# 04f's look at the after stills (0 nothing distinct, 1 a stop or kick only, 2 a drawn mark or a
# class-specific feel, 3 reference); AFTER_WHY says what the after crop shows that the before does not.
AFTER = {
    "claw": (3, 2, 2),
    "katana": (2, 2, 2),
    "plasma_sword": (2, 2, 2),
    "chainsaw": (2, 2, 2),
    "electro_baton": (2, 2, 2),
    "pistol": (2, 1, 2),
    "gatling": (2, 1, 2),
}
AFTER_WHY = {
    "claw": "unchanged: the rakes on all three",
    "katana": "cream-and-ink cut with red beads on the cop; cut + dark oil specks on the robot; cut on the slab",
    "plasma_sword": "ember sear on the cop and robot (+ oil specks); sear + ember spit off the slab",
    "chainsaw": "bite starburst on all three (main: nothing); robot: white sparks and oil; slab: spray back",
    "electro_baton": "human unchanged (its arcs are a stun, not in a still); robot specks; amber arc on the slab",
    "pistol": "red flick drops + cream hot point at the stop on a human; robot: one dark speck, weak",
    "gatling": "as the pistol, two drops further; robot: one dark speck, weak",
}
CROP = 240
GAP = 4
LABEL_W = 170
HEAD_H = 40
PAD = 14


def font(size):
    for name in ("arialbd.ttf", "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def crop(path):
    if not os.path.exists(path):
        im = Image.new("RGB", (CROP, CROP), (60, 20, 20))
        ImageDraw.Draw(im).text((10, 10), "no still", fill=(255, 200, 200), font=font(18))
        return im
    im = Image.open(path).convert("RGB")
    cx, cy = im.width // 2, im.height // 2 + 40  # marks_still centres the victim 60 px low
    h = CROP // 2
    return im.crop((cx - h, cy - h, cx + h, cy + h))


def still(folder, weapon, victim):
    return os.path.join(folder, "marks_%s_%s_64%s.png" % (weapon, victim, FRAME.get(weapon, "")))


def main(before_dir, after_dir, out):
    cell_w = CROP * 2 + GAP
    width = LABEL_W + len(COLS) * (cell_w + PAD)
    height = HEAD_H * 2 + len(ROWS) * (CROP + PAD) + 30
    sheet = Image.new("RGB", (width, height), (24, 24, 28))
    draw = ImageDraw.Draw(sheet)
    title = "n31 melee 04 impacts at 64 px/m: each cell main (0f1e1ce95) | n31 (HEAD); score before -> after"
    draw.text((PAD, 8), title, fill=(240, 240, 240), font=font(22))
    for c, (_, name) in enumerate(COLS):
        draw.text((LABEL_W + c * (cell_w + PAD), HEAD_H + 6), name, fill=(230, 230, 160), font=font(22))
    for r, weapon in enumerate(ROWS):
        y = HEAD_H * 2 + r * (CROP + PAD)
        draw.text((PAD, y + CROP // 2 - 12), weapon, fill=(240, 240, 240), font=font(22))
        for c, (victim, _) in enumerate(COLS):
            x = LABEL_W + c * (cell_w + PAD)
            sheet.paste(crop(still(before_dir, weapon, victim)), (x, y))
            sheet.paste(crop(still(after_dir, weapon, victim)), (x + CROP + GAP, y))
            score = "%d -> %d" % (BEFORE[weapon][c], AFTER[weapon][c])
            draw.rectangle((x, y, x + 92, y + 28), fill=(0, 0, 0))
            draw.text((x + 6, y + 3), score, fill=(255, 220, 90), font=font(20))
    foot = (
        "caveats: the 'human' victim is the arena's first guard, who carries a riot shield; gun rows stop one"
        " round on a body (the probe), the victim is not drawn at the stop; chainsaw = the grind's mid frame"
    )
    draw.text((PAD, height - 30), foot, fill=(200, 200, 200), font=font(16))
    sheet.save(out)
    print("sheet %s %dx%d" % (out, width, height))


if __name__ == "__main__":
    main(*sys.argv[1:4])
