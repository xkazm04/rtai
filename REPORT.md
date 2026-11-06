# d8 bosses: REPORT (lane `bosses`, branch `d8-bosses`)

> DRAFT written 17:10 (session 4). Owed at the freeze (18:30): the Windows export, `evidence --no-bench`,
> the final gate numbers on the tip, and the exact exe command lines checked against the build.

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
  `king_p3_cape_train_tilt64.mp4`.

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

### Close combat at 64 px/m
The King vs the katana, the gang vs Rivet, and Servo at contact with the katana (`--ghost=kerf --loadout=katana`):
the parts hold their detail and do not turn to mush.

## Gates (refresh the numbers on the final tip at the freeze)
- Director reel, headless (`--loadout=pistol --rigs --quit-after 8000`) on 6344f887: **tilt 19/19 chapters fully down,
  top 19/19, 0 SCRIPT ERROR**.
- On 0f11ec5f: unit full run **1427/1427**, scenarios **52/52** (run alone). Lint 15/15 on every commit.
- `top` identity was measured for every change: a raw-frame md5 of the old code vs the new code under `--view=top` (JOURNAL).
- `node tools/evidence/run.mjs --no-bench` on 27512277 (code = 76cbfcfb): **all PASS**: lint 15/15, unit 1427/0, scenarios 52/52, parity bit-exact (planted mutation caught at 629), selftest (look goldens 11/11, block 5/5), export-audit 542 loaded, 0 failed.

## What does not work / known gaps
- Mid-fight pitch changes (view70's combined view): a card swapped once keeps its strip if the pitch moves.
  The fix is to fold the court strips into chars' `ViewMode.art` route after the merge (rows in JOURNAL 14:47).
- An arm can cross over the bust card at melee range (RigDepthSort, which belongs to chars).
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
(with `APPDATA=C:/Users/kazda/kiro/gtai-d8/appdata/bosses`). A trial export at 17:14 worked and its smoke run
(`--boss=king --phase=3 --view=tilt`) showed 0 SCRIPT ERROR. The final exe is re-exported from the tip at the freeze.
- The King, angled: `RTAI.exe -- --rigs --boss=king --view=tilt` (on foot: add `--phase=3`; close range: `--ppm=64`)
- Servo, angled: `RTAI.exe -- --rigs --boss=servo --view=tilt`
- The same fight in `top` (today's art): drop `--view=tilt`.

## Next steps
- Fold the court card strips into chars' `ViewMode.art` route after the merge, and re-dress the card when the pitch moves.
- A p70 set for view70's sample (the same cutters: `tools/art/king_parts_pitch.py`, `king_car_walls.py`,
  `king_car_cannon.py`, `servo_parts_pitch.py` take the 70 sheets).
- Kerf v2 is waiting for the owner's look (not in this lane).
