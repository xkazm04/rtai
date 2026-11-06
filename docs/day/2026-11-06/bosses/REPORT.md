# d8 bosses: REPORT (lane `bosses`, branch `d8-bosses`)

**What to look at first:** `C:\Users\kazda\kiro\gtai-masters\d8\bosses\frames.json` (15 entries, best
first), then the combined clip `bosses_d8_it4_combined.mp4` (32 s: the throne-car at 64 px/m, the King on
foot at 64 with the cape train, Servo standing at 48 vs the katana).

Every change is selected by the view row's pitch: art lives in `features/bosses/king/art/p55/` and
`features/bosses/servo/art/p55/`, so a `p70/` set drops in beside it. With the default `top` view nothing
moves: each change was md5-checked against the code before it under `--view=top` (see JOURNAL).

## What works (with evidence)

All under `--view=tilt` (55 degrees), seed 2, the live arena (`--boss=king` / `--boss=servo --bot=boss --bot-human --rigs`).

### The King on foot
- **Bust card from `king_55.png`** (Codex strip, 5 facings, the crown cap plum not blood red), 1.5x wide;
  it wears the cape. **Limbs**: a top-view part sheet (plates, pistons, plum sleeves, boots) cut to the
  rig's part boxes, drawn raw (the wider palette survives). The slam's plates rise with the tell.
  Evidence: `king_p3_64_f455_before_after.png`, `king_p3_tilt64_before/after.mp4`, `king_vs_katana_64_close.png`.
- **The cape train (session 4):** the card's cape is static, so the drawn cape's follow-through was lost.
  Now on foot the cape's train streams from his back to the ground through the charge/ram flare and the
  slam landing, and nothing shows at rest. Evidence: `king_cape_train_64_before_after.png`,
  `king_p3_cape_train_tilt64.mp4`, and at 48 px/m (session 5, 2-11 s of phase 3, seed 2):
  `king_p3_cape_train_tilt48_sheet.png`. Session 6 (02b11a53): in the charge the train lay inside the
  vermilion charge lane and its cloth melted into it; now ink side edges run root to hem and the root is
  darker (`KingCape.TRAIN_ROOT_DARK` 0.55, `TRAIN_SIDE_INK`), the hem stays vermilion with its ermine.
  Same seed and ticks, before | after: `king_p3_cape_train_charge_tilt48_before_after.png` (frames.json #5); at the shipped 32 px/m, from the exe: `king_p3_cape_train_charge_tilt32_exe.png`
  (the edge is a thin line there, not heavy).

### The throne-car
- **Walls from the approved car sheet:** a 40-slice stack (`KingCarWalls`) drawing the side, front and
  rear bands. It has our own gilded sunburst grille (not a maker's trade dress), amber tail lamps, plum drapes with gold
  tassels and gilded wheels. **The roof plan** (quilted plum deck, laurel ring) and **the throne** (an upright card)
  are both Codex art from the sheet.
- **Hood cannon + bumpers (session 4):** the barrel is cut from the sheet's side view and drawn on the swivel
  mount. The painted bumper rows stand 0.18 m proud of nose and tail.
- Evidence: `king_car_64_t720_before_after.png`, `king_car_cannon_bumpers_64_before_after.png`,
  `king_car_tilt32_before/after.mp4` (procession and ram), `king_car_tilt32_ram_before_after.png`.

### The gang
- A steel helmet with a plum band, gold-framed shades and a gold rope chain with an emerald medallion
  (head card), plus gunmetal bodies with gold knuckles and toes (part sheet). Evidence: `gang_tilt64_close_vs_rivet.png`,
  `gang_tilt48_after_bodies.png`.

### Servo
- **p55 parts from `servo_55.png`** (ochre enamel, tan steel, copper hoses), the 2-row rack wings and the flying drone.
- **He stands under tilt:** his upper body is 1.6 m over his feet, the legs stretch up to it, and he casts a swept shadow. Before this he
  read as a floor decal.
- **Kraft boxes:** the landed, falling and slung parcels are standing boxes under tilt.
- Evidence: `servo_stands_vs_katana_64_before_after.png`, `servo_stands_tilt48_katana.mp4`,
  `servo_stands_tilt32_before_after.png`, `servo_crates_tilt64_before_after.png`,
  `servo_parcels_falling_tilt64_before_after.png`, `servo_tilt48_drones_rotor_dash.mp4`.

### Mid-fight pitch changes (session 5)
- view70's combined view eases 70 -> 55 into a boss fight. A court card now re-dresses when the pitch moves:
  it swaps to that pitch's strip, or back to the shared card at a pitch with none (8dbbbcf0, unit test 55 -> 65 -> 55).
  At a steady pitch the tilt frames are md5-identical to before.

### Close combat at 64 px/m
The King vs the katana, the gang vs Rivet, and Servo at contact with the katana (`--ghost=kerf --loadout=katana`):
the parts hold their detail and do not turn to mush.

## Gates (on the final code tip 02b11a53)
- Director reel, headless (`--loadout=pistol --rigs --quit-after 8000`): **tilt 19/19 chapters fully down,
  top 19/19, 0 SCRIPT ERROR**.
- `node tools/evidence/run.mjs --no-bench`: lint 15/15, unit 1428/0, parity bit-exact (planted mutation caught
  at 629), selftest (look goldens 11/11, block 5/5), export-audit 542 loaded, 0 failed: PASS. **Scenarios 51/52:
  `scenario_rig_stress` missed its 1 ms wall-clock budget** (200 people p50 1.005 and 1.009 ms, the miss under
  contention and its re-judge alone after 100 s). Re-run alone at 18:11 (`run_scenarios.mjs --only=rig_stress`):
  **PASS**, p50 0.839 ms (50 people 0.755). This lane changes no rig or sim code (the last change draws the
  King's cape train under tilt only; scenarios run headless), and the same gate passed 52/52 on 8dbbbcf0 at
  17:44: a margin miss on a 4-lane machine at the freeze, not a regression. Bench not run (no bench lock).
- `top` identity was measured for every change: a raw-frame md5 of the old code vs the new code under `--view=top` (JOURNAL).

## What does not work / known gaps
- An arm can cross over the bust card at melee range (RigDepthSort, which belongs to chars).
- The cape train in the charge lane is fixed by its edges and shade (02b11a53), not by draw order: it still sits
  above the lane's fill. Drawing it under the fill is the other option, not built.
- `scenario_rig_stress` sits on its 1 ms budget (200 people p50 0.84-1.01 ms across today's runs): see Gates.
- The emerald accents key toward grey (the chroma despill clamps green).

## Calls for the owner
Each call names the default that is built, the alternative one value away, and how to see it.
1. **Cape under tilt:** the card's cape (default) vs the drawn fan (`KingArt.CARD_CAPE = false`).
   Still: `call_cape_car_fan_vs_card_48.png`.
2. **Bust width 1.5x** (`KingArt.STRIPS["king"][2]`). Exe: `RTAI.exe -- --rigs --boss=king --phase=3 --view=tilt`.
3. **Emerald gems:** regenerate the gem accents on magenta to keep them green (today they key toward grey).
4. **Throne card size:** 3.0 m face-on, a head over the crown like the sheet (`KingCarWalls.THRONE_W_M`).
5. **Hood cannon position:** on the roof art's laurel ring (0.33 of the car vs 0.2; view only, the coins follow; `KingCarWalls.ART_MOUNT_K`).
6. **Car walls:** flush art with painted wheels vs main's proud drawn tyres: `king_car_64_t720_before_after.png`.
7. **Servo's stand height:** `ServoArt.STAND_M` 1.6 m (0 = the flat rig): `servo_stands_vs_katana_64_before_after.png`;
   exe `RTAI.exe -- --rigs --boss=servo --view=tilt`.
8. **The cape train:** `KingCape.TRAIN_K` 1 (default; 0 = card only): `king_cape_train_64_before_after.png`;
   exe `RTAI.exe -- --rigs --boss=king --phase=3 --view=tilt`.
9. **Proud bumpers:** `KingCarWalls.BUMPER_PROUD_M` 0.18 m (0 = flush): `king_car_cannon_bumpers_64_before_after.png`.

## Exe
`build/export/windows/RTAI.exe` (the `windows-showcase` preset: it boots into the arena; pass the arena args after `--`).
Export: `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
(with `APPDATA=C:/Users/kazda/kiro/gtai-d8/appdata/bosses`). **Exported at 18:10 from 02b11a53** (exit 0, 0 ERROR lines).
Smoke, 600 frames each (King phase 3 at 64 px/m tilt, Servo at 48 tilt, the King in top): exit 0,
0 SCRIPT ERROR, 0 "triangulation failed"; the last frames show the angled art.
- The King, angled: `RTAI.exe -- --rigs --boss=king --view=tilt` (on foot: add `--phase=3`; close range: `--ppm=64`)
- Servo, angled: `RTAI.exe -- --rigs --boss=servo --view=tilt`
- The same fight in `top` (today's art): drop `--view=tilt`.

## What blocked
- Nothing blocked the lane for longer than a few minutes. Image jobs never waited: each round touched
  `image.want` and the asset lane yielded within its job (e.g. r5 at 15:13, 97 s, first try).
- Friction and its cost:
  - this lane's appdata had a plain empty `export_templates` folder, not the junction. Found and fixed at
    17:13 before the export, about 5 min lost. chars' and weapons' appdata folders looked the same (FYI in JOURNAL).
  - `tools/godot/check.mjs` fails on unchanged files in this worktree ("Failed to compile depended scripts").
    I parse-checked through the live arena runs and GUT instead, so no time was lost.
  - Wall-clock budgets with 4 lanes running: `scenario_corpse_horde` (with the reel running beside it) and
    `scenario_rig_stress` (at the freeze) missed their budgets under contention. Each passed when re-run alone.
    About 15 min of re-runs in total.
  - I once edited the tree while `evidence` ran, which tripped its tree-changed guard. One re-run (about 10 min).

## Where the evidence is
Stills, clips and `frames.json` are in `C:\Users\kazda\kiro\gtai-masters\d8\bosses\` (the brief's folder), not in
the repo's `evidence/`. Path check at 18:42: every still and clip this REPORT names exists there. `frames.json`
has 15 entries, 0 missing. The source sheets `king_55.png` and `servo_55.png` are in `gtai-art\angle-r1\out\`.
The four cutters in `tools/art/` and the `art/p55/` folders exist. `build/export/windows/RTAI.exe` is from 18:10.
Since 02b11a53 only JOURNAL.md, REPORT.md and docs/decisions.md have changed, so the exe is built from HEAD's code.

## Next steps
- Fold the court card strips into chars' `ViewMode.art` route after the merge (rows in JOURNAL 14:47); KingArt keeps the limbs and the cape.
- A p70 set for view70's sample (the same cutters: `tools/art/king_parts_pitch.py`, `king_car_walls.py`,
  `king_car_cannon.py`, `servo_parts_pitch.py` take the 70 sheets).
- Kerf v2 is waiting for the owner's look (not in this lane).
