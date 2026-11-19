# REPORT - n19 lane `guns`: complete the arsenal

Branch `n19-guns` from `int-n19` @ `28302bd3c`. Director: Claude Opus 5.5. Builder: Astra (GPT-6.2, high).
Final at the 07:30 freeze; HEAD `87d0606ab`.

Score: the audit matrix (`project/dev/rivet_arsenal/arsenal_audit.gd`, ratchet test `project/tests/unit/test_arsenal_audit.gd`).
Before `evidence/arsenal/matrix_before.txt`: **51 holes**. After package 6: **10 holes** (`evidence/arsenal/matrix_after_6.txt`). After package 7b: **3 holes** (`evidence/arsenal/matrix_after_7.txt`; the 3 = assault rifle arena rack slot, a Call). Final: **3 holes** (`evidence/arsenal/matrix_after_11.txt`, `.json`), plus **52 informational gaps** (13 weapons x walk + run grid x 2 pitches) reported outside the ratcheted total.

Gate: `node tools/gate/run.mjs --rev=HEAD` on `87d0606ab`: RUNNING at 07:35 (log `build/gate/87d0606ab5c8/evidence.log`); result appended below when it ends. Frames index: `gtai-masters/n19/guns/frames.json` (12 entries).

## What works

| Item | Evidence | Number |
|---|---|---|
| Arsenal audit script + ratchet test (fails when a weapon loses a cell) | `evidence/arsenal/matrix_before.txt`, `project/dev/rivet_arsenal/arsenal_known_holes.json` | 51 holes before; mutate arsenal_audit.gd 6/6, arsenal_audit_files.gd 9/10 |
| Assault rifle has its own art (held, mag, pickup, icon; p55 + p70 strips, diagonals, reload, muzzle rows); `art_stand_in` retired | `gtai-masters/n19/guns/rifle/p55_64_comparison.png`, `p70_64_comparison.png` | rifle 18 -> 3 holes (the 3 = arena rack slot, a Call) |
| Diagonal fire + reload + mag for homing_shard and ray_gun | `gtai-masters/n19/guns/homing_shard/`, `ray_gun/` | 5 -> 0 holes each |
| mini_nuke diagonals + left; rocket diagonals with back-blast on the rear bell at p55 + p70, left | `gtai-masters/n19/guns/rocket_launcher/rocket_launcher_p55_64.png` | 4 -> 0 each |
| Left cells for plasma_rifle, gatling, flamethrower, gloria (and rocket/mini_nuke rebuilt) on the weapon's own hand-made poses: mirror + masked corrections of the asymmetric parts, script-cut (`tools/art/left_from_right.py`, regions in `tools/art/left_regions/`) | `<gun>_p55_left_check.png`, `<gun>_p55_west.png` per weapon | 2 -> 0 each; helmet-ratio delta <= 3.35 %, CIE76 <= 1.89 vs source |
| Dropped rifle lies 0.5 m from the body (owner verdict; ai/anim NEED) | `gtai-masters/n19/guns/rifle_drop/claw_shock_measurements.png` | 0.86 -> 0.52-0.53 m; mutate ground_rifle.gd 8/10 sample |
| Reload residue fix: wrists/shoulder refilled from the hand-made base cells, 12 strips recut byte-identical elsewhere | `gtai-masters/n19/guns/hand_cannon/hand_cannon_p55_reload_zoom.png` (looked: clean) | f0990e096 |
| Reload cells for electro_gun, machine_pistol, hand_cannon (p55 + p70, right + left): the hand-made plasma/pistol reload figure with the gun's own held art and its own magazine composited by script (`tools/art/reload_composite.py`); electro gun's new brass energy-cell mag | `gtai-masters/n19/guns/<gun>/<gun>_<pitch>_reload_zoom.png`, `<gun>_p55_reload_64.png`, `<gun>_p55_reload_turn32.mp4` | 3 -> 0 holes each (commits 7a696962f, a5b02604b, 9bed8f09c) |
| Magazine view: the ink-block placeholder is now reached only by an unknown weapon (logged once); shoulder tubes carry their own round | `project/tests/unit/test_rivet_mag_view.gd` (00b00b7b9) | mutate rivet_mag_view.gd 17/38 (40 sampled) + line 135 boundary 1/1 (4043fc526) |
| Turn kit: Rivet firing while turning through 8 octants, centred, 32 px/m | `<gun>_p55_turn32.mp4` per weapon; index `evidence/arsenal/turns_after_11.json` | 6 pre-centring clips re-shot (5 weapons incl. both rocket arenas), 48 firing frames checked; mutate turn driver 23/24, diagonal fit 32/39 |

## What does not
- The assault rifle has no slot on the arena weapon rack (3 holes: top/p55/p70 rack pickup). Adding one widens the hub weapon wall by 1 m (a layout change; the wall keeps its x1 scale either way): a Call, not built.
- Armed walk/run grids (`rivet_walk_eq_<w>.png`, `rivet_run8_eq_<w>.png`) exist only for pistol, plasma_rifle, gatling, flamethrower and katana; the other 12 weapons walk on the bobbing facing card. Not in the owner's audit list, so the matrix reports them as informational gaps outside the ratcheted total (package 11; see the final matrix).
- Mirror-based left cells: the re-slanted collar stripes are rough broken strokes at 2x (NW worst) beside the source's clean bands. Not visible at 64 px/m; the scripted clean band is written up in `evidence/briefs/10-collar-bands.md` but was not built.
- Diagonal fire cells drawn tonight (homing_shard, ray_gun) are a paler copper than the dark rest strip; the hand-made electro/plasma diagonals share that tone, so it is house style, but it is the closest-to-tellable new art.
- Reload cells are taller and stockier than the walk figure because they reuse the hand-made plasma/pistol reload figure, as plasma's own reload already does.

## What blocked or slowed you
- Session restart killed a child Astra (23:22, 11 min lost); fixed by launching Astra through WMI.
- Fresh full-figure image_gen drifted from the chibi Rivet even when height and tone matched (05b, ~60 min); replaced by the mirror-plus-masked-correction method (06b).
- Quick gate's Godot step fails standalone on the `Log` autoload in untouched files; commits used `--no-godot` with unit `--changed` green.

## Calls for the owner
1. **Assault rifle on the arena rack.** Recommended: leave it off the rack tonight (the hub wall keeps its current width). Alternative: a fourth rack slot, which widens the wall 1 m and closes the last 3 audit holes. Still: `gtai-masters/n19/guns/rifle/p55_64_comparison.png`.
2. **Armed walk/run grids for 12 weapons.** Recommended: a dedicated night drawing them through the mirror/composite method (32 + 64 cells per weapon and pitch). Alternative: keep the facing card for one-handed guns and draw only the two-handed ones.

## Merge notes
- `project/features/player/rivet_held_view.gd` L77: one-line change (mag view gate) in move's folder; it is Rivet's held-gun view, which the brief gives to guns. Keep ours.
- Shared with anim: `tools/art/rivet_frames.py` (`_manifest`, keep both sides' adjacent lines), `tools/art/rivet_frames.json` rows, `project/features/characters/rivet_res.gd` rows, `rivet_strips.gd` L11-12. Each is an appended row per weapon cell set; take the union.
- `tools/debt/baseline.json`: dev_loc allowance +522 (audit kit, through the debt tool) plus later kit growth; after a conflict run `node tools/debt/merge_baseline.mjs`.
- `steam/ai-provenance/2026-11.jsonl`: guns appended one line per shipped PNG; union with the other lanes.
- `project/features/combat/weapons/art/ground_rifle.gd`: `GroundRifle.BODY_GAP` (false = old placement) answers ai/anim's NEED (rifle 0.86 m -> 0.52 m).

## Next steps
1. Clean scripted collar bands on the mirror-based left cells (`evidence/briefs/10-collar-bands.md` items 1-3).
2. Armed walk/run grids for the 13 weapons the info column names (Call 2).
3. Rifle rack slot if Call 1 says yes (closes the last 3 holes).
4. Raise rivet_mag_view.gd's mutation score (17/38 sampled) with first-author tests.
5. Quick gate's standalone `Log` parse error (`part_library.gd:60`) so commits stop needing `--no-godot`.

## Astra ledger
| # | Tag | Min | Verdict |
|---|---|---|---|
| 1 | audit | 13 | accepted (commit blocked by debt; finished in 2) |
| 2 | audit-finish | 15 | accepted |
| 3 | rifle-p55 | 48 | accepted |
| 4 | rifle-p70 | 11 | abandoned (killed by a director session restart) |
| 5 | rifle-p70b | 22 | accepted |
| 6 | shard-ray | 64 | accepted |
| 7 | launchers | 50 | accepted for holes; left-cell look bounced (05b) |
| 8 | rifle-drop | 29 | accepted |
| 9 | left-scale | 60 | accepted for tools/holes; look bounced (fresh figures drift) |
| 10 | left-cells | 3 | abandoned (replaced by the template method) |
| 11 | left-template | 22 | accepted |
| 12 | left-continue | 37 | accepted; gloria/rocket p70 bounced |
| 13 | p70-fix | 28 | accepted |
| 14 | reload | 16 | bounced (electro reload kept the plasma stock) |
| 15 | reload-gun | 75 | accepted (cap hit during the last mutate run) |
| 16 | final | 52 | accepted (walk/run info column, reload residue fix, clips re-shot, mutate survivors) |

What I would brief differently: ask for the build-on-the-hand-made-cell method (mirror + masked correction, composite onto the hand-made reload figure) from the first art package, not after two rounds of fresh full-figure generations; demand the 2x zoom sheet (source | new | held) with every art commit from the start, because a thumbnail sheet hid both real faults and caused one wrong bounce; and keep mutate runs out of the last 15 minutes of a session.
