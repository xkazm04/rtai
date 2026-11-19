# REPORT - n19 lane `guns`: complete the arsenal

Branch `n19-guns` from `int-n19` @ `28302bd3c`. Director: Claude Opus 5.5. Builder: Astra (GPT-6.2, high).
DRAFT (04:20): sections marked (pending) are filled at the freeze.

Score: the audit matrix (`tools/arsenal` audit, ratchet test `test_arsenal_audit`).
Before `evidence/arsenal/matrix_before.txt`: **51 holes**. After package 6: **10 holes** (`evidence/arsenal/matrix_after_6.txt`). After package 7b: **3 holes** (`evidence/arsenal/matrix_after_7.txt`; the 3 = assault rifle arena rack slot, a Call). Final: (pending).

## What works

| Item | Evidence | Number |
|---|---|---|
| Arsenal audit script + ratchet test (fails when a weapon loses a cell) | `evidence/arsenal/matrix_before.txt`, `project/dev/rivet_arsenal/arsenal_known_holes.json` | 51 holes before; mutate arsenal_audit.gd 6/6, arsenal_audit_files.gd 9/10 |
| Assault rifle has its own art (held, mag, pickup, icon; p55 + p70 strips, diagonals, reload, muzzle rows); `art_stand_in` retired | `gtai-masters/n19/guns/rifle/p55_64_comparison.png`, `p70_64_comparison.png` | rifle 18 -> 3 holes (the 3 = arena rack slot, a Call) |
| Diagonal fire + reload + mag for homing_shard and ray_gun | `gtai-masters/n19/guns/homing_shard/`, `ray_gun/` | 5 -> 0 holes each |
| mini_nuke diagonals + left; rocket diagonals with back-blast on the rear bell at p55 + p70, left | `gtai-masters/n19/guns/rocket_launcher/rocket_launcher_p55_64.png` | 4 -> 0 each |
| Left cells for plasma_rifle, gatling, flamethrower, gloria (and rocket/mini_nuke rebuilt) on the weapon's own hand-made poses: mirror + masked corrections of the asymmetric parts, script-cut (`tools/art/left_from_right.py`, regions in `tools/art/left_regions/`) | `<gun>_p55_left_check.png`, `<gun>_p55_west.png` per weapon | 2 -> 0 each; helmet-ratio delta <= 3.35 %, CIE76 <= 1.89 vs source |
| Dropped rifle lies 0.5 m from the body (owner verdict; ai/anim NEED) | `gtai-masters/n19/guns/rifle_drop/claw_shock_measurements.png` | 0.86 -> 0.52-0.53 m; mutate ground_rifle.gd 8/10 sample |
| Reload cells for electro_gun, machine_pistol, hand_cannon (p55 + p70, right + left): the hand-made plasma/pistol reload figure with the gun's own held art and its own magazine composited by script (`tools/art/reload_composite.py`); electro gun's new brass energy-cell mag | `gtai-masters/n19/guns/<gun>/<gun>_<pitch>_reload_zoom.png`, `<gun>_p55_reload_64.png`, `<gun>_p55_reload_turn32.mp4` | 3 -> 0 holes each (commits 7a696962f, a5b02604b, 9bed8f09c) |
| Magazine view: the ink-block placeholder is now reached only by an unknown weapon (logged once); shoulder tubes carry their own round | `project/tests/unit/test_rivet_mag_view.gd` (00b00b7b9) | mutate (pending) |
| Turn kit: Rivet firing while turning through 8 octants, centred, 32 px/m | `<gun>_p55_turn32.mp4` per weapon | (pending) |

## What does not
(pending)

## What blocked or slowed you
- Session restart killed a child Astra (23:22, 11 min lost); fixed by launching Astra through WMI.
- Fresh full-figure image_gen drifted from the chibi Rivet even when height and tone matched (05b, ~60 min); replaced by the mirror-plus-masked-correction method (06b).
- Quick gate's Godot step fails standalone on the `Log` autoload in untouched files; commits used `--no-godot` with unit `--changed` green.

## Calls for the owner
(pending)

## Merge notes
(pending)

## Next steps
(pending)

## Astra ledger
(pending)
