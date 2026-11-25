# Plasma sword at tilt 70: walk and run row 1 by row edit, katana as donor (n29-02a)

Round: `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/` (`STATE.md`, `jobs.json`, `scripts/`, `final1/`). Nothing under `project/` changed. No Godot run. Nothing committed.

Route: one image edit per row. Image 1 is the katana's p70 row 1: `refs/donor_walk_row1.png` (4 cells, 384x256 slots at scale 1.0) and `refs/donor_run_row1.png` (8 cells, 192x128 slots at scale 0.64, the molotov row-1 layout). Image 2 is `refs/plasma_sword_equipped.png` (the 8 facings from `rivet_eq_plasma_sword.png` + `_left`). The prompt is the molotov row-1 template with the katana swapped for the sword in the same claw (`jobs.json`).

**IMAGES 3**:
- walk row 1, try 1 (kept)
- run row 1, try 1 (failed sole y, and the collar looked like rope)
- run row 1 retry, `edit_run_row1_b` (kept)

Each image came back in about 4 min. The tool copied none of them to `out/`: each was copied by hand, and each gen process tree was stopped by PID.

## Bars (`scripts/prep_row.py`, `final1/metrics_*_row1.json`)

Each returned cell is keyed and scaled so its dome width matches the donor cell. It is then placed by dome centre x and sole y (the n28 raw registration).
- **dome w**: the width difference left after that fit.
- **dome x**: the head-over-sole x offset compared with the donor's, as a % of the donor dome width.
- **sole y**: the sole line with the dome TOP registered instead. This shows a figure drawn shorter or taller. Under the raw registration it is 0 by construction, which is how the n28 tables report it.

Self-test with the donor as the edit: dome <= 0.75 %, sole y <= 2 px (from the 0.64 round trip of the run layout), leg IoU >= 0.975.

| Row | dome w max | dome x max | sole y max | leg IoU min | signed travel own / donor | same lead | tone dev (pre -> post) | verdict |
|---|---|---|---|---|---|---|---|---|
| walk 1 | 0.0 % | 0.78 % | 2 px | 0.959 | -16.33, 16.33 / -16.67, 16.67 | 4/4 | 10.6 -> 0.02 | PASS |
| run 1 try 1 | 0.78 % | 1.55 % | **5 px** (cols 2,3,6,8: -4,-3,-3,-5) | 0.905 | 3.0, 4.33 / 2.67, 4.0 | 6/8 | 11.0 -> 0.04 | FAIL (figures shorter; collar like rope) |
| run 1 retry | 0.77 % | 2.33 % | 2 px | 0.951 | 2.0, 4.33 / 2.67, 4.0 | 8/8 | 9.5 -> 0.10 | PASS |

Bars:
- dome <= 3 %
- sole y <= 2 px
- leg IoU (below 64 % of the figure) >= 0.80
- tone dev <= 2: the opaque mean against the sword strip's front-facing mean (107.4, 74.1, 47.2), after the finish_tone law

By eye, no kept cell has an extra limb, a second sword or any katana left over.

**Blade hue** (bright, saturated pixels):
- The strip's blade glows amber-yellow: hue median 43 deg (p10 21, p90 52), mean rgb 247,177,37.
- Kept rows: walk median 40.5 deg (p10 27, p90 52), run 40.1 deg (p10 24, p90 55).
- No teal (at most 4 px, on outline edges).
- The pixels counted as red hue are dark outline edges and the helmet crack, as on the donor. None are on the blade core.

**By eye, walk:** crisp. The collar is a flat band with straight orange-and-black diagonal stripes. The hilt is a ribbed bronze grip with a small straight crossguard. On cols 1 and 4 a reddish cross-hatched ring at the blade base looks a lot like a wrapped fitting; it is small at 64 px/m.

**By eye, run retry:** legs, boots and stride match the donor. But:
- the figure is softer than the donor: most rivets on the legs and boots are gone
- the hilt has no crossguard
- the blade's upper edge has a dark rust rim
- the collar's stripes still twist a little on cols 2, 3 and 8: better than try 1, but not as flat as the donor's band

After the tone law, both rows are warmer than the katana donor, because the sword strip's mean is warmer than the katana sheets.

## Judging crops (no Godot)

Scale 0.96, nearest neighbour. This is the in-game size at 64 px/m: HEIGHT_M 1.65 x player_scale k 1.5 x 64 / (FIG_PX 110 x grid RES 1.5). Sources: `rivet_frames.gd`, `rivet_walk.gd`, `player_scale.json`.
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/row1_judge_64.png`: walk, then run, in bands `stop-gap` / `new (sword)` / `katana donor`, every cell of row 1.
  - The stop-gap is approximate: the bare `rivet_walk.png` / `rivet_run8.png` row 1, with `weapon_art` `held_long.png` placed at `walk_grid.palm_percent.p70`, pointing +x, 1.44 m long.
  - It does not use the live rig's rotation or the held_small tone, so the stop-gap blade reads as a thin grey knife.
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/row1_judge_close.png`: walk col 1 and run col 1 at 3x nearest, each new cell beside its donor cell.
