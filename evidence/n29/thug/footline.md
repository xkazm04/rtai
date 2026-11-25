# Robot thug A (n29): the shoe foot line (claw cut out), before / after the cutter fix

Row `robot_thug` stays `enabled: false`. Measured on the shipped PNGs by `tools/art/cast_thug_feet.py`
(texels of the packed sheet; `+` = above the line). Standing cells (walk, attack, hit, fall drawing 0):
lowest opaque row (alpha >= 128) after the claw columns in `CUT` are removed, against the foot line
(row 224 of the 256 cell; the fall cell's ground row is its centre, 220). Fall drawings 1-2 (resting):
body bottom against 220. Bar: |gap| <= 2.

The fix (`tools/art/cast_thug_pack.py` `replant`): after the gunner cutter packs a sheet, each cell named in
`CUT` moves vertically by whole texels (no resampling, x unchanged) so its shoe sole sits on the line; the
fall's resting cells move so their body bottom sits on 220. Re-packed: p70 attack, hit, fall; p55
armed_walk, attack, hit, fall. Checked: every cell not in `CUT` (and not a resting fall cell) is byte-identical
to the shipped sheet, every moved cell is the shipped cell rolled by its shift (a pure translation).

Not re-packed: `p70/robot_thug_armed_walk.png` (the four-drawing walk; the row walks
`robot_thug_planted8_armed_walk.png`, which `CastThugAnchors` plants on the measured shoe and which did not
move). In its down, down-right and right cells the support shoe is drawn behind the claw: only the lifted
foot shows, so no sole can be measured and planting on the lifted foot would sink him; it keeps the claw-tip
line (`KEEP_LINE`). The planted8 walk and `cast_thug_anchors.gd` are unchanged, so the feet audit in
`feet_size.md` stands (not re-run).

Fall: the bar puts the body bottom of the resting drawings on the ground row. Before, the gunner cutter
anchored them at 62 % of their height, so the body bottom sat 55 to 76 texels below the ground point (the
convention of most shipped fall sheets, e.g. `robot_gunner_fall.png`); now the fallen body lies behind
(up-screen of) the point he stood on, feet at the point. Looked at on grey (`fall70_after.png` in
`build/look/n29-thug/foot/`): all ten resting cells lie on the row, no loose part.

Unchanged by the moves (same pixels): key-clean 0 / 0 green / magenta-leading opaque px on all seven
re-packed sheets; stripe medians (deg) p70 attack 37.97, hit 36.56, fall 36.56; p55 armed_walk 36.56,
attack 35.16, hit 33.75, fall 37.97 (before = after). Strict red (hue < 12 or > 345, sat > 128, val > 89):
p70 attack 0, hit 0, fall 1; p55 armed_walk 4, attack 0, hit 1, fall 5, before = after: every one a dark
rust edge pixel within 2.2 px of an amber stripe or lens, shipped so in `75b0374d0` (not changed here).

| sheet | pitch | facing | drawing | measured | gap before | gap after | claw cut (% of width) | verdict |
|---|---|---|---|---|---|---|---|---|
| armed_walk | 70 | down | 0 | shoe | 22 | 22 | (0-47) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | down | 1 | shoe | 33 | 33 | (0-47) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | down | 2 | shoe | 49 | 49 | (0-47) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | down | 3 | shoe | 35 | 35 | (0-47) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | dr | 0 | shoe | 31 | 31 | (0-50) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | dr | 1 | shoe | 15 | 15 | (0-50) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | dr | 2 | shoe | 24 | 24 | (0-50) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | dr | 3 | shoe | 18 | 18 | (0-50) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | right | 0 | shoe | 4 | 4 | (36-100) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | right | 1 | shoe | 10 | 10 | (36-100) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | right | 2 | shoe | 25 | 25 | (36-100) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | right | 3 | shoe | 23 | 23 | (36-100) | NOT MEASURABLE (support shoe drawn behind the claw), sheet kept |
| armed_walk | 70 | ur | 0 | shoe | -1 | -1 |  | PASS |
| armed_walk | 70 | ur | 1 | shoe | 0 | 0 |  | PASS |
| armed_walk | 70 | ur | 2 | shoe | 0 | 0 |  | PASS |
| armed_walk | 70 | ur | 3 | shoe | 0 | 0 |  | PASS |
| armed_walk | 70 | up | 0 | shoe | -1 | -1 |  | PASS |
| armed_walk | 70 | up | 1 | shoe | -1 | -1 |  | PASS |
| armed_walk | 70 | up | 2 | shoe | 0 | 0 |  | PASS |
| armed_walk | 70 | up | 3 | shoe | 0 | 0 |  | PASS |
| attack | 70 | down | 0 | shoe | -1 | -1 |  | PASS |
| attack | 70 | down | 1 | shoe | 8 | 0 | (0-33) | PASS |
| attack | 70 | down | 2 | shoe | 0 | 0 | (0-27) | PASS |
| attack | 70 | down | 3 | shoe | -1 | -1 |  | PASS |
| attack | 70 | dr | 0 | shoe | -1 | -1 |  | PASS |
| attack | 70 | dr | 1 | shoe | 8 | 0 | (0-34) | PASS |
| attack | 70 | dr | 2 | shoe | -1 | 0 | (0-25) | PASS |
| attack | 70 | dr | 3 | shoe | 0 | 0 |  | PASS |
| attack | 70 | right | 0 | shoe | 0 | 0 |  | PASS |
| attack | 70 | right | 1 | shoe | 0 | 0 |  | PASS |
| attack | 70 | right | 2 | shoe | 0 | 0 |  | PASS |
| attack | 70 | right | 3 | shoe | 0 | 0 |  | PASS |
| attack | 70 | ur | 0 | shoe | 0 | 0 |  | PASS |
| attack | 70 | ur | 1 | shoe | 0 | 0 |  | PASS |
| attack | 70 | ur | 2 | shoe | 0 | 0 |  | PASS |
| attack | 70 | ur | 3 | shoe | 0 | 0 |  | PASS |
| attack | 70 | up | 0 | shoe | 0 | 0 |  | PASS |
| attack | 70 | up | 1 | shoe | -1 | -1 |  | PASS |
| attack | 70 | up | 2 | shoe | 0 | 0 |  | PASS |
| attack | 70 | up | 3 | shoe | 0 | 0 |  | PASS |
| hit | 70 | down | 0 | shoe | -1 | 0 | (0-32) | PASS |
| hit | 70 | dr | 0 | shoe | -1 | 0 | (0-37) | PASS |
| hit | 70 | right | 0 | shoe | 0 | 0 |  | PASS |
| hit | 70 | ur | 0 | shoe | -1 | -1 |  | PASS |
| hit | 70 | up | 0 | shoe | 0 | 0 |  | PASS |
| fall | 70 | down | 0 | shoe | 12 | 0 | (0-48) | PASS |
| fall | 70 | down | 1 | body | -75 | 0 |  | PASS |
| fall | 70 | down | 2 | body | -70 | 0 |  | PASS |
| fall | 70 | dr | 0 | shoe | 25 | 0 | (0-52) | PASS |
| fall | 70 | dr | 1 | body | -71 | 0 |  | PASS |
| fall | 70 | dr | 2 | body | -67 | 0 |  | PASS |
| fall | 70 | right | 0 | shoe | 8 | 0 | (26-100) | PASS |
| fall | 70 | right | 1 | body | -67 | 0 |  | PASS |
| fall | 70 | right | 2 | body | -56 | 0 |  | PASS |
| fall | 70 | ur | 0 | shoe | -1 | 0 | (28-100) | PASS |
| fall | 70 | ur | 1 | body | -65 | 0 |  | PASS |
| fall | 70 | ur | 2 | body | -59 | 0 |  | PASS |
| fall | 70 | up | 0 | shoe | 0 | 0 |  | PASS |
| fall | 70 | up | 1 | body | -76 | 0 |  | PASS |
| fall | 70 | up | 2 | body | -70 | 0 |  | PASS |
| armed_walk | 55 | down | 0 | shoe | 0 | 0 | (0-38) | PASS |
| armed_walk | 55 | down | 1 | shoe | 8 | 0 | (0-38) | PASS |
| armed_walk | 55 | down | 2 | shoe | -1 | 0 | (0-38) | PASS |
| armed_walk | 55 | down | 3 | shoe | 6 | 0 | (0-38) | PASS |
| armed_walk | 55 | dr | 0 | shoe | -1 | 0 | (0-40) | PASS |
| armed_walk | 55 | dr | 1 | shoe | 11 | 0 | (0-40) | PASS |
| armed_walk | 55 | dr | 2 | shoe | -1 | 0 | (0-40) | PASS |
| armed_walk | 55 | dr | 3 | shoe | 5 | 0 | (0-40) | PASS |
| armed_walk | 55 | right | 0 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | right | 1 | shoe | 0 | 0 |  | PASS |
| armed_walk | 55 | right | 2 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | right | 3 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | ur | 0 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | ur | 1 | shoe | 0 | 0 |  | PASS |
| armed_walk | 55 | ur | 2 | shoe | 0 | 0 |  | PASS |
| armed_walk | 55 | ur | 3 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | up | 0 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | up | 1 | shoe | 0 | 0 |  | PASS |
| armed_walk | 55 | up | 2 | shoe | -1 | -1 |  | PASS |
| armed_walk | 55 | up | 3 | shoe | -1 | -1 |  | PASS |
| attack | 55 | down | 0 | shoe | -1 | -1 |  | PASS |
| attack | 55 | down | 1 | shoe | 20 | 0 | (0-45) | PASS |
| attack | 55 | down | 2 | shoe | 18 | 0 | (0-35) | PASS |
| attack | 55 | down | 3 | shoe | -1 | -1 |  | PASS |
| attack | 55 | dr | 0 | shoe | 0 | 0 |  | PASS |
| attack | 55 | dr | 1 | shoe | 15 | 0 | (14-50) | PASS |
| attack | 55 | dr | 2 | shoe | 16 | 0 | (18-49) | PASS |
| attack | 55 | dr | 3 | shoe | 0 | 0 |  | PASS |
| attack | 55 | right | 0 | shoe | -1 | -1 |  | PASS |
| attack | 55 | right | 1 | shoe | -1 | -1 |  | PASS |
| attack | 55 | right | 2 | shoe | -1 | -1 |  | PASS |
| attack | 55 | right | 3 | shoe | -1 | -1 |  | PASS |
| attack | 55 | ur | 0 | shoe | 0 | 0 |  | PASS |
| attack | 55 | ur | 1 | shoe | 0 | 0 |  | PASS |
| attack | 55 | ur | 2 | shoe | 0 | 0 |  | PASS |
| attack | 55 | ur | 3 | shoe | -1 | -1 |  | PASS |
| attack | 55 | up | 0 | shoe | 0 | 0 |  | PASS |
| attack | 55 | up | 1 | shoe | 0 | 0 |  | PASS |
| attack | 55 | up | 2 | shoe | -1 | -1 |  | PASS |
| attack | 55 | up | 3 | shoe | 0 | 0 |  | PASS |
| hit | 55 | down | 0 | shoe | -1 | 0 | (0-45) | PASS |
| hit | 55 | dr | 0 | shoe | 22 | 0 | (0-45) | PASS |
| hit | 55 | right | 0 | shoe | 0 | 0 |  | PASS |
| hit | 55 | ur | 0 | shoe | -1 | -1 |  | PASS |
| hit | 55 | up | 0 | shoe | 0 | 0 |  | PASS |
| fall | 55 | down | 0 | shoe | 8 | 0 | (0-29) | PASS |
| fall | 55 | down | 1 | body | -75 | 0 |  | PASS |
| fall | 55 | down | 2 | body | -73 | 0 |  | PASS |
| fall | 55 | dr | 0 | shoe | 26 | 0 | (0-45) | PASS |
| fall | 55 | dr | 1 | body | -71 | 0 |  | PASS |
| fall | 55 | dr | 2 | body | -66 | 0 |  | PASS |
| fall | 55 | right | 0 | shoe | 0 | 0 |  | PASS |
| fall | 55 | right | 1 | body | -68 | 0 |  | PASS |
| fall | 55 | right | 2 | body | -55 | 0 |  | PASS |
| fall | 55 | ur | 0 | shoe | -1 | -1 |  | PASS |
| fall | 55 | ur | 1 | body | -61 | 0 |  | PASS |
| fall | 55 | ur | 2 | body | -62 | 0 |  | PASS |
| fall | 55 | up | 0 | shoe | 0 | 0 |  | PASS |
| fall | 55 | up | 1 | body | -67 | 0 |  | PASS |
| fall | 55 | up | 2 | body | -71 | 0 |  | PASS |

Reproduce: `cd tools/art && python cast_thug_feet.py [--review]` (overlays to
`gtai-art/foes-n29/thug/pack/feet_{70,55}.png`: claw cut red, sole cyan, line magenta);
`python cast_thug_pack.py --only=attack,hit,fall` and `--only=armed_walk --pitch=55`;
`python cast_thug_provenance.py --only=<pitch>/<action>,...`.
