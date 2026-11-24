# Brief n27-cast-04-gunner: robot gunner A (navy plates) as a cast card, cop quality

Lane `cast`, branch `n27-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 07:58 local** (check `date` often): at the hard stop commit what is green, report and END.
**Commit 1 (cut art + `.import` + provenance) 25 minutes after launch**; commit 2 (row + placement + checklist,
on or off, whatever is true) next; films after.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Rendering runs `--rendering-driver d3d12`, windowed ones `--position 0,1440` (never the main
display). Kill only your own PIDs, never by name.

## Narrowed for time (director, 06:40)
Only about 40 minutes remain before the lane's last-commit time. Do, in order: step 1 (cut + pack + provenance + import,
commit), step 2 (row `enabled: false` unless step 3 fully passes in this call), the still `gunner_vs_cop_32.png` (him beside
the patrol cop at 32 px/m: the owner's robot-not-cop check) and `gunner_beside_64ppm_tilt70.png`, then step 3's numbers as far
as time allows (audit row, honest: what is unmeasured says so). Clips and mutate only if time remains. Everything committed by
07:58; after 07:58 no new commit.
**The pre-commit hook takes about 12 minutes per commit here**: start `git commit` for step 1 no later than 20 minutes
after launch, and start your last commit no later than 07:45. Two commits are the plan; a third only if it can start by 07:45.

## Goal
The owner picked **robot gunner A (navy plates)** (2026-11-24). Draw `robot_gunner` (`enemies.json`: speed 2.2 m/s, telegraph
0.9 s, weapon `cannon`) from plate A at the patrol cop's standard through the card path the lancer, Mulroney and the warden took
(read their commits first: `git log --oneline -25`, `docs/art/cast-audit.md`). Today he is drawn by the generic robot rig
(box head, one lens, hose arms, `FoeLooks.robot_plan`). The owner's condition: navy stays (his colour pick), and he must read as
a ROBOT, not a cop, by shape and finish: pale box head (no cap), one lens, hose arms, navy only as bolted plates on a gunmetal
frame, brass belt to a back drum. **Check it at 32 px/m beside the patrol cop** and say plainly whether he reads as a machine.
Size: about the patrol cop's height, never taller than Rivet (owner: "careful with too large ... enemies").

## Source sheets (director-generated tonight with Codex image_gen, ACCEPTED; do not regenerate)
`C:\Users\kazda\kiro\gtai-art\foes-n27\gunnerA\out\` on #00B140 (notes `notes.md`, prompts `jobs.json`, plate `refs/plate.png`):
- `gunnerA_armed_walk_70.png`: the 4-drawing walk, patrol layout (5 facing bands x 4). The design anchor; p70 only.
- `gunnerA_attack_{70,55}.png`: 5 bands x 4 TIME columns: (1) TELL: rifle up, lens lit bright amber (map to `telegraph_s`),
  (2) FIRE: small pale-cream muzzle flash, (3) RECOIL, (4) RECOVER, lens dim. Check the key keeps the pale flash.
- `gunnerA_hit_70.png`: 5+3 hit layout, used at BOTH pitches (the patrol's basic wound reuses p70; no hit_55 was drawn).
  Drawn ~1.6x larger than the walk: scale every sheet by the walk's body height, never by its cell.
- `gunnerA_fall_{70,55}.png`: 5 bands x 3, power-down onto his back; the rifle lies beside him as a separate piece: keep
  detached pieces inside the cell. Robot: NO red, no blood anywhere.
- 8-drawing walk (the 4-drawing walks fail the Feet rule): `gunnerA8_{70,55}_a.png` = 4 rows x 4: rows 1-2 = down
  (drawings 1-4 / 5-8), rows 3-4 = down-right; `_b.png` = same, rows 1-2 = right, rows 3-4 = up-right; `_c.png` = up only,
  2 rows x 4 (larger figures). Support L in drawings 1-3, R in 5-7. Rejected takes end `_REJ_*`: never use them.
  (If the director's notes mark a 55 sheet rejected or missing, cut p55 walk from what is accepted and say so.)

## Build, in order
1. Cut and pack into `project/features/characters/art/view/{p70,p55}/robot_gunner_{attack,hit,fall,planted8_armed_walk}.png`
   (+ `robot_gunner_armed_walk.png` at p70 from the anchor; at p55 there is no 4-drawing walk: make the planted8 walk the p55
   walk) (+ `.import`), key-clean (zero strongly green-leading opaque pixels), all facings matched to one body height, toned
   alike across sheets. Reuse the cutters Mulroney and the warden used (`tools/art/cast_*`); intermediates in
   `foes-n27/gunnerA/pack/`. One `steam/ai-provenance/2026-11.jsonl` line per shipped PNG (prompt ref
   `gtai-art/foes-n27/gunnerA/jobs.json#<job>`, cutter edits, sha256). `--import`, commit.
2. Row `robot_gunner` in `cast_cards.json`, drawn by the existing card path (the lancer row is the model; he is a machine,
   so read how `FoeCastView.feed` treats `h.machine` and how `ArenaRobotRigs.takes` diverts machines: the card must replace
   the robot rig's drawing for him only, and `enabled: false` must leave today's robot rig look exactly as it is). His walk on
   the N-drawing anchored placement (`CastCards.anchored`), as cop8 / Mulroney / the warden. The hit is a directional shove
   today (40-strength): keep the mechanics, only draw it. The death is `DeathPipe.kill_robot` power-down: draw the fall cells
   on it. The electro gun and the claw's full discharge finish robots (melee lane's code): do not touch kill code; if his
   card hides a finisher's effect, write a NEED in your report.
3. Checklist: every point of `docs/art/cast-checklist.md` at both pitches, his row in `docs/art/cast-audit.md`. Numbers:
   planted feet (sole <= 2 px, body jump <= 12 px at 32 px/m, right and down-right, 70 and 55, `cast_feet.mjs`); body jump on
   a stop, a turn AND a reversal (aim one way, step the other); drawings/s; the 64 px/m edge measure
   (`tools/art/cast_mulroney_edge.py`) on every sheet; size px at 32 px/m 70 degrees for him, the patrol cop and Rivet;
   palette: navy only on plates, no red, no teal, no vermilion; the lit lens reads at 32 px/m. `enabled: true` ONLY if every
   point passes; otherwise `enabled: false` with the fails in the audit row. Never ship a half character. Commit.
   **The bars are the checklist's and nothing else**: never invent a stricter one and keep him off by it (the warden lost a
   whole call to "travel + 2 px" tonight); quote each number beside the checklist bar.
4. Films (after the commit; look at every frame), to `C:\Users\kazda\kiro\gtai-masters\n27\cast\`:
   `gunner_beside_64ppm_tilt{70,55}.png` (beside the patrol cop, Rivet and today's robot rig look, front three-quarter and
   back, `project/dev/cast/cast_lineup.gd`), `gunner_vs_cop_32.png` (him beside the patrol cop at 32 px/m, the robot-not-cop
   check), `gunner_fire_64.png` (the four attack columns, down-right, at 64 and at 32 beside), `gunner_before_after_32.png`
   (same tick and zoom: robot rig today / card), `gunner_close_64.mp4` (walk, lens tell, fire, hit, fall), `gunner_fight_32.mp4`
   (32 px/m tilt 70, Rivet against three gunners, card on, a dev scene under `project/dev/cast/` like `cast_warden_fight`):
   1920x1080, 60 fps, 15 to 40 s, `ffprobe` both. Append entries to `frames.json` there (valid JSON array).
   **True 1920x1080 only:** Godot's Movie Maker renders at the project viewport (1280x800) and ignores `--resolution`. Reuse
   tonight's `tools/film/cast_warden_films*` (commit `6b3bdffcd`: a scratch project with the viewport overridden; never edit
   `project/project.godot`) and check one extracted frame: Rivet about 77 px (front) at 32 px/m, about 154 at 64.
5. Mutate: `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
`project/features/characters/art/view/{p70,p55}/robot_gunner_*` (new), `project/data/tables/cast_cards.json` (+ schema),
`project/features/characters/cast_*.gd`, `street_*.gd` (card drawing/placement only), `foe_*.gd`,
`project/features/combat/squad/foe_cast_view.gd`, `foe_*_card_view.gd`, `cast_*.gd` there,
`project/features/arena/arena_robot_rigs.gd` and `arena_wave_cards.gd` (smallest edit, drawing only), `project/dev/cast/**`,
`tools/art/**`, `tools/film/**` (new files only), `project/tests/unit/test_cast_*.gd`, `test_street_*.gd` (ADD only) (+ `.uid`),
`docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md`
(append one line at a time), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n27\gunnerA\pack\**`, `C:\Users\kazda\kiro\gtai-masters\n27\cast\**`.
**Forbidden** (other lanes): `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art,
`input_actions.json`, `rivet_motion.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `project/dev/gauntlet/**`, `tools/gauntlet/**`, root
`JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, every other character's shipped art. No behaviour, speed or timing change:
rendering only (replay digests, quest 1 and prologue tapes must not move). No image generation in this call.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`,
amend or rebase; never push. `--import` after new art or scripts before committing; commit `.uid`/`.import` with their source.
`node tools/gate/quick.mjs` before each commit. **Fix lint and format findings in your own edit and go on.** If the pre-commit
hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again
(never skip the hook). Never fake a number or a frame: unmeasured is never zero.

## Report at the end (and END at the hard stop)
Commits (sha + subject); the checklist row with every number; robot-not-cop verdict at 32 px/m in one sentence; enabled
true/false and why; film paths + ffprobe lines; mutate score; quick gate line; any NEED; what you could not do.
