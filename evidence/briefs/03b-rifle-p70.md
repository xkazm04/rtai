# Package 3b (guns lane, night n19): the assault rifle, part 2 - p70, reload, no stand-in

Part 1 (`evidence/briefs/03a-rifle-p55.md`, its report in `evidence/briefs/03a-rifle-p55.out.txt`, and the commits since `dd169ec55`) gave the assault rifle its own `weapon_art.json` row, top-down art and p55 strips. Read those first: reuse the same prompts, references, art key, manifest and cutting scripts, so p70 matches p55 and the neighbours.

## Deliverables

1. p70 Rivet strips for the rifle, the same set as p55: `rivet_eq_<key>.png`, `_diag.png`, both `_noflash` twins, `_left.png`; `RivetGunDiag` rows `p70/<key>` (DEG, HELMET_X, FOOT_PX, measured), `rivet_muzzle.json` rows. References: the p70 neighbours (`p70/rivet_eq_plasma_rifle*.png`, `p70/rivet_eq_electro_gun_left.png`), the keyed library p70 sheets, and your own p55 rifle sheets for the gun.
2. Reload strips for the rifle at p55 and p70: `rivet_reload_<key>.png` and `rivet_reload_<key>_left.png`, in the layout of `rivet_reload_plasma_rifle*.png` / `rivet_reload_pistol*.png` (read whoever draws them: `rivet_reload.gd` and its tables, and the tools/art script that cut the existing ones). The magazine he swaps is the rifle's straight box magazine (the `mag.png` you made in part 1).
3. Remove the stand-in: drop `assault-rifle` from `rivet_arsenal.json` `art_stand_in` (leave the `art_stand_in` mechanism itself in place, now empty, unless the schema forbids an empty object). Confirm with a still that the top-down rig and both pitches draw the rifle, not the machine pistol.
4. Feel, without balance: confirm the rifle's shot cue (`audio_cues.json` from_rivet rifle cue), `hit_feel.json` `assault_rifle` row and the muzzle flash/casing from part 1 all fire on Rivet's rifle; if any of them silently falls back to the machine pistol's, wire the rifle's own (data only). Damage, burst, rate, spread, range, hitboxes do not change.
5. Update `arsenal_known_holes.json`, re-run the audit, write `evidence/arsenal/matrix_after_3b.txt` (+ .json). Target: `assault-rifle` 0 holes.
6. Evidence in `C:/Users/kazda/kiro/gtai-masters/n19/guns/rifle/`: a 64 px/m contact sheet per pitch with every direction (8 aim directions, rest + fire), old (base commit `28302bd3c`) beside new; a 32 px/m clip (10-40 s, mp4) of Rivet firing the rifle while turning through all eight directions, p55. Use `tools/film/` (compare.mjs, sheet.mjs; if no shot turns him, the simplest dev-only driver you can add under `project/dev/rivet_arsenal/` with its flags declared). Add a `frames.json` there (8-15 entries, best first: `{file, title, ppm, before, note}`).

## Art law (same as part 1)
image_gen only, own-art references only, masters to `C:/Users/kazda/kiro/gtai-masters/n19/guns/masters/` + `art_src/n19-guns.manifest.json` entries, prompts under `docs/art/prompts/n19/guns/`, one provenance line per shipped PNG in `steam/ai-provenance/2026-11.jsonl`, cut by script under `tools/art/`, never by hand. Look at every sheet before it ships. Rivet's neck band is a rigid striped hazard collar. List every mirrored cell (only where gun and Rivet are symmetric in that view).

## Acceptance
- `node tools/tests/run_unit.mjs --changed` and `--select=test_arsenal_audit,test_rivet_gun_diag,test_rivet_fire_cam` green; `node tools/lint/lint.mjs` green; `node tools/tests/release_compile.mjs` green; `node tools/gate/quick.mjs` before each commit.
- After the code/data commits: `node tools/mutate/mutate.mjs --file=features/characters/rivet_gun_diag.gd --max=10` (quote the score).
- One commit per change, staged per path, `.import`/`.uid` with their sources.

## Law
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns`, `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` before every Godot run; `--rendering-driver d3d12` to render; windowed runs `--position 0,1440`. One Godot at a time; kill only your own PIDs.
- No sim/replay/parity/bake digest moves (stop and report if one does). Typed GDScript, size limits, `Log`. No stash / add -A / commit -a / reset --hard / push.
- Ownership as in part 1: shared `tools/art/rivet_frames.json` and `rivet_strips.gd`: rifle rows only, list the lines.
- Report: commits, holes before/after, the evidence files, mirrored cells, anything left.

## Added by the director after reviewing part 1 (priority 0, do it first)

Part 1 cut the p55 rifle strips at 110 px figures while the neighbours ship at 165 (`rivet_res.gd`), so the rifle draws softer than every other gun. Director's ruling: registering the rifle in `project/features/characters/rivet_res.gd` is a one-line call site the guns lane may make (the director names it in JOURNAL); touch only the rifle's line(s) there. Re-cut the p55 rifle strips at the neighbours' density from the same masters (re-measure DEG/HELMET_X/FOOT_PX and the muzzle rows at the new res) and cut p70 at its neighbours' density from the start. Then reshoot part 1's p55 stills at 64 px/m and check side by side with `rivet_eq_plasma_rifle` that the ink line and texel size match.

Also: part 1 reported the quick gate's Godot step failing with a parse/teardown error that reproduces on the untouched baseline. Before your first commit, run `node tools/gate/quick.mjs` once, and if Godot still fails, capture the exact error line and the file it names in your report (do not work around it with `--no-godot` without saying so per commit).
