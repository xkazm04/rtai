# Brief 02 (lane cast): the lancer in the game; the door carrier round started

Hard stop: 75 minutes after you start (check `date` at the start and write the stop time down). Commit finished work
as you go; at stop-minus-10 commit what is done and stop. Your previous session (brief 01) made the audit, the checklist,
`project/dev/cast/` and the round `C:\Users\kazda\kiro\gtai-art\foes-n24\`. If anything from it is uncommitted
(`git status`), commit it first, staged per path (`cast_stride.gd` too if it is finished, else leave it untracked and say so).
Your NEED on `tools/debt/baseline.json` is granted: the run's rules let each lane raise the baseline through the debt
tool only. Run `node tools/debt/debt.mjs --update --accept-regression="cast lineup dev scene for n24 cast"` and commit
`tools/debt/baseline.json` together with the staged lineup files (`cast: lineup dev scene for the wave cast`).

## 0. Start the next generation round first (it runs while you work)
The director reviewed the lancer round:
- ACCEPTED: `rocket_trooper_armed_walk_70`, `_attack_70`, `_hit_70` (look at the `_55` ones yourself with the same eye).
- REJECTED: `rocket_trooper_fall_70.png` (and check `_55`): he dives prone and keeps aiming the launcher; it reads as
  taking cover, not dying. Move the rejected file(s) to `foes-n24/rejects/<name>_v1_prone-aiming.png`. Retake prompt
  direction: the killing blow throws him back off his feet, the launcher leaves his hands (it falls beside him, not
  aimed), arms and head go limp, last frame lying still on his back or side, unmistakably dead, the backpack and its two
  spare rockets still on him; same layout as the cop's fall rows; no blood colour other than red, and only a little.
- Add to the same `jobs.json` the **door carrier** (shield robot, owner's pick `foes-n22/out/shield-robot-a.png`: a navy
  armoured robot carrying a door-sized BARE STEEL slab with amber-and-black striped edges, an amber slit eye; read the
  pick in `foes-n22/notes.md`). Sheets at 70 and 55: armed walk (slab carried in front), attack (tell: slab drawn back /
  braced low; then a forward shove-lunge; recover), hit (sparks allowed, no blood), fall (a machine power-down collapse,
  slab drops). **Size**: about 2.0 m tall beside Rivet's 1.65 m (state it in the prompt with Rivet as the scale ref), not
  a giant. **Slab width**: the shove's hit is `FoeShield.SLAB_HALF_M` = 0.32 m each side (0.64 m wide,
  `project/features/combat/squad/foe_shield.gd`); draw the slab that wide relative to the body (about the robot's
  shoulder width, not wider). Owner: "Narrow the slab when the door carrier is redrawn from your pick".
- Start the runner detached (as in brief 01), note PID and log.

## 1. Cut and pack the lancer (commit A)
Cut the accepted sheets (and the retaken fall when it lands; if it lands too late, ship the lancer with the swat fall
and say so) with the repo's cutters into `project/features/characters/art/view/{p70,p55}/rocket_trooper_*.png` (+
`.import`), toned with the cop's tools. Look at every cell yourself at 32 and 64 px/m: clean cut (no green fringe, no
halo, no clipped tube or boot), feet planted, scale steady across the cells. Reject and re-cut rather than ship a bad cell.
One provenance line per shipped file in `steam/ai-provenance/2026-11.jsonl` (append only, same shape as the cop's lines).
Run a Godot `--import` before committing.

## 2. Draw the lancer from his own sheets in the game (commit B)
Today `FoeLooks.wears_swat` puts the rocket trooper in the SWAT rig + `FoeLauncherView`'s drawn tube, and
`FoeRocketPose` squashes the rig during the tell. Make a rocket trooper draw as his own whole-figure card everywhere a
SWAT card would draw (near full rig and far card), on the same anchors, facings and mirroring as the cops' grids:
- walking / standing: the armed walk grid (stride by distance as the cops);
- the tell and shot: the attack grid, 4 frames per facing mapped to the sim's own timing (shoulder at tell start, aim,
  fire on the shot tick, recover) — read the timing from the fighter (`tell_left` etc.), never from wall clock;
- hit: his hit cells through the same hit path the cops use; death: his fall grid through the fall path;
- `FoeLauncherView` stops drawing its tube and knees when the card draws (the card has the tube); the rocket itself and
  its flight stay as they are.
Put it behind ONE switch so the placeholder is one value away (a const or a table value, e.g. a new table
`project/data/tables/cast_cards.json` + schema keyed by archetype id listing the sheets per pitch and action; this is
the table every later enemy will use, so design it for that). Render only: no sim, replay or parity digest moves.
New code in your own new files (`project/features/characters/cast_*.gd` or `project/features/combat/squad/foe_*view*.gd`);
existing shared files (`street_cop_walk.gd`, `street_walker_hit.gd`, `street_walker_fall.gd`, `foe_looks.gd`,
`arena_*`) get one-line call sites only, and you list each one in your report. A unit test for the table and the
frame mapping (tell -> frame) under `project/tests/unit/test_cast_*.gd`.

## 3. Stills (if time)
Extend the lineup (`project/dev/cast/`) or add a dev scene that shows the lancer beside the patrol cop and Rivet:
walking, in the tell, firing, hit and dead, at 32 and 64 px/m tilt 70 (and 55). Save to
`C:\Users\kazda\kiro\gtai-masters\n24\cast\lancer_*.png`. Look at them.

## Setup and law
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run; `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12` to render; `--position 0,1440` on any window. One Godot at a time; kill only your own PIDs.
Allowed paths: `project/features/characters/art/view/**/rocket_trooper_*`, `shield_robot_*`; new `cast_*`/`foe_*view*`
files as above; `project/data/tables/cast_cards.json` + its schema; `project/tests/unit/test_cast_*`;
`project/dev/cast/**`; `tools/art/cast_*`; `docs/art/cast-*.md`; one-line call sites as above;
`steam/ai-provenance/2026-11.jsonl` (append); `C:\Users\kazda\kiro\gtai-art\foes-n24\**`;
`C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and report a NEED. Forbidden: numbers in
`enemies.json`, `weapons.json`, `combat.json`, `input_actions.json`, `project/features/player/**`, `rivet_walk*`,
`rivet_run8*`, `project/features/souls/**`, `project/features/gauntlet/**`, `project/dev/gauntlet/**`, `melee_*`,
`signature_kills.json`, `project/features/combat/kills/**`, `combat_arena.gd` (one-line call sites only, listed),
JOURNAL.md, REPORT.md, `evidence/briefs/`.
AGENTS.md / STANDARDS.md: typed GDScript, ~200 lines per file (300 hard), functions <= 40 lines, <= 5 params, `Log` not
`print`, data JSON with a schema. Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`,
`node tools/godot/check.mjs`, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit).
Commit `.uid`/`.import` with sources. Stage per path; never amend, rebase, stash, `add -A`, push. After the code commit:
`node tools/mutate/mutate.mjs --file=<your main new .gd> --max=20` and quote the score.
Colour law: red is blood only; cops are blue; vermilion only for danger/objectives/Rivet's collar; teal only for souls;
amber for heat and the hazard bands.

## Report back
Commits (sha + message), the files, the one-line call sites, checks run and results, mutate score, the round PID/log and
which jobs are done, what you looked at and rejected (count takes), what is left.
