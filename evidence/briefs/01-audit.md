# Package 1 (guns lane, night n19): the arsenal completeness audit

You are the builder for the `guns` lane of tonight's run. Goal of the whole lane: **by morning no weapon is a stand-in and none lacks the cells its neighbours have.** This package builds the measuring stick only. Do NOT draw art or change gameplay in this package.

## Goal

A script that stays in the repo and prints, for every weapon id in `project/data/tables/rivet_arsenal.json` `weapons` (guns from `weapons.json`, melee from `melee_weapons.json`), per camera pitch (`top` = the top-down cutout rig, `p55`, `p70`), which of these exist:

| column | meaning (verify against the code; refine and document the exact rule in the script's header) |
|---|---|
| `held` | own held art: for `top` the weapon's `weapon_art.json` row with its own `held` (a weapon listed in `rivet_arsenal.json` `art_stand_in` is a HOLE); for p55/p70 its own `rivet_eq_<id>.png` strip under `project/features/characters/art/view/<pitch>/` (and/or `weapon_held_pitch.json` / `held_55` art if the code draws held pitch art from there; read `held_pitch_art.gd`, `held_pitch_row.gd`) |
| `fire8` | guns: fire cells for all 8 directions. For p55/p70: the side/facing fire cells in the equipped strip + `rivet_eq_<id>_diag.png` + a `RivetGunDiag.DEG` / `HELMET_X` (and any sibling table in `project/features/characters/rivet_gun_diag.gd`) entry for `<pitch>/<id>`; and a `_noflash` twin where the neighbours have one (`RivetNoFlash`). Streams (flamethrower) use `RivetStrips` flame-diag rules instead; read `rivet_strips.gd`. For `top`: whatever the rig needs (probably N/A: the rig rotates the held part; say so with the reason) |
| `left` | left-facing cells: `rivet_eq_<id>_left.png` (one-handed holds must never be mirrored: owner's hand rule in `RivetStrips.ONE_HAND`). Two-handed weapons count as a hole when there is no left strip, unless the code proves the mirrored cell is correct for that weapon; say which rule you applied |
| `muzzle` | a row in `project/data/tables/rivet_muzzle.json` `strips.<pitch>` for every strip the weapon has (eq, diag, left); guns only |
| `reload` | reload support: `weapon_art.json` `parts.mag` art for magazine guns (read `rivet_reload.gd`, `rig_off_claw.gd`, `project/features/player/rivet_mag_view.gd`); N/A with a reason for weapons with no magazine |
| `recoil` | the weapon's recoil/kick path exists (class `kick` in `rivet_arsenal.json`, any per-weapon recoil row); N/A for melee |
| `casing` | `weapon_art.json` `casing` (shell/casing fx) where the weapon fires cased rounds; N/A with reason for energy/flame/rocket |
| `pickup` | `weapon_art.json` `pickup` + `icon` art exist on disk, and the hub/arena weapon wall art if the wall draws per-weapon art (`arena_weapon_rack.gd`) |
| melee: `strike`, `windup`, `left_strike`, `left_windup` | the melee strips (`rivet_eq_<id>_windup.png`, `_left_strike`, ...) per pitch |

Each cell of the matrix is one of `ok`, `HOLE`, `n/a` (with a short reason in the JSON). File existence must be checked on disk / via `ResourceLoader.exists`, not just in tables. Every res:// path a table names must exist (a missing file is a HOLE).

Known holes scouted on `main` (your audit is the authority; if the audit disagrees, the audit wins and you say why):
- `assault-rifle` has no art of its own: `art_stand_in` -> machine_pistol, and no muzzle row.
- diagonal fire cells missing for homing_shard, ray_gun, mini_nuke (no DEG rows).
- left cells missing for flamethrower, gatling, gloria, mini_nuke, plasma_rifle, rocket_launcher.
- the rocket launcher's p55 diagonals draw no back-blast.
- the magazine view (`project/features/player/rivet_mag_view.gd`) is a placeholder.

## Files (suggested; keep to the guns lane's ownership)

- `project/dev/rivet_arsenal/arsenal_audit.gd` - `class_name ArsenalAudit extends RefCounted`: pure logic, returns the matrix as a typed Dictionary. Split into a second file if it passes ~200 LOC.
- `project/dev/rivet_arsenal/arsenal_audit_run.gd` - `-s` entry (`extends SceneTree`, declares `const KNOWN_FLAGS`): prints the matrix as an aligned text table via `Log` (one row per weapon x pitch, a holes count per weapon and a total), writes `--out=<path>` JSON (`"schema": "gtai.arsenal-audit/1"`, sorted keys) and `--txt=<path>`.
- `project/dev/rivet_arsenal/arsenal_known_holes.json` - the ratchet allowlist: every hole that exists tonight, as sorted `"<weapon>/<pitch>/<column>"` strings, each with a one-line reason.
- `project/tests/unit/test_arsenal_audit.gd` - GUT: (a) every current HOLE is in the allowlist (a NEW hole fails, naming it); (b) every allowlist entry is still a hole (a FIXED hole fails until it is removed from the allowlist, so the list only shrinks); (c) a synthetic case proves the audit sees a missing file as a HOLE (point it at a fake weapon id or inject a path lookup so you do not delete real art).
- Run `node tools/dev/run.mjs arsenal_audit_run -- ...` or the `-s` form to produce:
  - `evidence/arsenal/matrix_before.txt` and `evidence/arsenal/matrix_before.json` (both committed).

The `top` pitch: find out what the top-down view actually draws (cutout rig via `weapon_art.json` held parts; `cut_rig.gd`, `rig_grip.gd`). If a column has no meaning there, mark it `n/a` with the reason, do not invent holes.

## Acceptance

1. `node tools/tests/run_unit.mjs --select=test_arsenal_audit` green.
2. `node tools/lint/lint.mjs` green (uid files committed, launch flags known, file/function sizes).
3. `evidence/arsenal/matrix_before.txt` printed and committed; the text table is readable at a glance (weapon rows, pitch sub-rows, columns as above, `.` for ok, `X` for HOLE, `-` for n/a or similar, plus a legend), and the JSON carries reasons.
4. Mutation: after committing, run `node tools/mutate/mutate.mjs --file=dev/rivet_arsenal/arsenal_audit.gd --tests=test_arsenal_audit --max=20` and paste the killed/(killed+survived) line in your report.
5. One commit for the audit (code + test + uid), one for the before matrix evidence. Stage per path.

## Law

- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Headless only for this package. One Godot process at a time. Kill only your own PIDs.
- Typed GDScript, files ~200 LOC (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. No `git stash`, no `add -A/./-u`, no `commit -a`, no `reset --hard`, never push.
- Do not edit files outside the guns lane: guns owns `project/features/combat/weapons/**`, Rivet's gun/muzzle/magazine/gun-diag view files (`rivet_gun_diag.gd`, `rivet_mag_view.gd`, muzzle view), `rivet_arsenal.json`, `rivet_muzzle.json`, `weapon_art.json`, `weapons.json`, `melee_weapons.json`, the weapon art folders, and a new `project/dev/rivet_arsenal/` audit. This package should touch only new files.
- End with: files changed, commands run and results, the printed matrix (paste it), the hole count per weapon, and anything you could not do.
