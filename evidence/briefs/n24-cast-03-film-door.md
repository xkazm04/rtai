# Brief 03 (lane cast): lancer finished and filmed; the door carrier in the game; the next round started

Hard stop: 75 minutes after you start (run `date` first and write the stop time down). At stop-minus-10 commit what
is done and stop. Commit each finished step on its own (staged per path). If anything from brief 02 is still
uncommitted (`git status`: e.g. `project/dev/cast/cast_lancer_stills.gd` + `.uid`, `project/dev/cast/cast_lineup.gd`,
`tools/art/cast_lineup.mjs`), commit it first.

## 0. Start the generation round first (detached, it runs while you work)
Same runner, style block and refs as round 02 (`C:\Users\kazda\kiro\gtai-art\foes-n24\jobs.json`). Jobs:

a. **Lancer attack retake, both pitches** (`rocket_trooper_attack_70`, `_55`). Director's review of the shipped attack
   sheets: columns 1-3 (down, down-right, right) are good; **column 4 (up-right) shows his FACE and aims straight
   RIGHT, column 5 (up) aims RIGHT too** (p70 worst). In the game he faces up-right or up and the tube points 45 or 90
   degrees off. Retake prompt: column 4 = seen from BEHIND three-quarter, his back and backpack toward the viewer, the
   tube pointing up-right (away into the screen at 45 degrees), backblast cone toward the lower-left; column 5 = seen
   from straight behind, backpack and both spare rockets fully toward the viewer, the tube pointing straight UP the
   sheet (away from the viewer), foreshortened, backblast cone toward the viewer at the bottom. Same 4 time rows. Keep
   the old sheet; if the retake's columns 1-3 are worse, splice only columns 4-5 into the shipped grid (same cell size,
   same baseline, same figure height: measure, do not guess) with a small `tools/art/cast_*` script and say so.
b. **The clamshell** (sentry turret, owner's pick `foes-n22/out/sentry-turret-a.png`, notes in `foes-n22/notes.md`).
   It never moves; only the dome and twin barrels turn. The square steel base plate with its amber-and-black apron
   is drawn **square to the sheet in every cell** (it never turns), the navy half-dome on top turns to the facing.
   Sheets at 70 and 55: `sentry_turret_attack` (5 facing columns down, down-right, right, up-right, up x 4 time
   rows: idle/tracking, tell = barrel jackets glowing amber up their length + slit lit, fire = short twin muzzle
   flash at the barrel tips, recover = heat fading), `sentry_turret_hit` (the cop's 2-band 5+3 layout, sparks only,
   no blood), `sentry_turret_fall` (5 columns x 3 rows: struck, the dome blown open / tilted with smoke, a dead
   wreck with the cage exposed; base plate stays). **Size**: the dome about 1.1 m wide and 0.9 m high, the base plate
   about 1.4 m square: shorter than the cop (1.8 m), Rivet (1.65 m, drawn x1.5 in game) is the scale ref.
c. **The pile-driver** (war machine, owner's pick `foes-n22/out/war-machine-b.png`): two hydraulic excavator-arm legs
   with round striped pile-driver feet, navy cab with an amber light bar (blank lamps), a fat striped side cannon, an
   engine block on the back with two rows of open amber louvres (its weak spot: keep it readable from behind).
   **Size: 2.6 m tall, about 1.8 m wide** (Rivet 1.65 m is drawn 1.5x in game, so on screen it stands about his
   drawn height and much wider; it is NOT a giant: owner, "we should be careful with too large bosses and enemies").
   Sheets at 70 and 55: `war_machine_walk` (5 facings x 4 stride, heavy planted steps), `war_machine_attack` (5 x 4:
   cannon lowers to aim, breech glows amber = tell, fire with a short muzzle blast, recoil/recover),
   `war_machine_stomp` (5 x 4: one foot lifted high = tell, slam with a dust ring, recover, settle),
   `war_machine_hit` (2-band 5+3, sparks), `war_machine_fall` (5 x 3: legs buckle, cab crashes down, louvres
   smoking). Painting: most visible armour police navy, steel grey, amber only on lamps, louvres, stripes.
Note PID and log; if the runner stalls copying to `./out`, take the image from `~/.codex/generated_images/`.

## 0b. Loose ends from brief 02 (do these right after starting the round)
- Your report says the placeholder teardown logged a deferred `_kneel` error (switch off -> on, or rig release). Find it:
  a script error in the log is a gate failure. Fix it in your own files (or a one-line call site), with a unit test.
- Your last full unit run timed out: run `node tools/tests/run_unit.mjs --changed` and quote the pass line, and run the
  scenarios once (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`, exit 0) because
  `arena_rigs.gd` changed. Quote both.
- Your review accepted all 120 lancer cells; the director rejects attack columns 4 and 5 (see 0a). Check facings
  against the cop's columns, not just the cut, in every future review.

## 1. The lancer, finished (commits as needed)
- When 0a lands: look at every new cell at 32 and 64 px/m; cut, pack, tone, `--import`, provenance line; restill.
- The dead lancer in `lancer_64ppm_tilt70.png` lies about 155 px long (head to boots) = about 2.4 m: the cop is 1.8 m.
  Add a dead patrol cop beside the dead lancer in the stills (same tick, same zoom) and measure both lying lengths
  with the repo's own number tool or a script; if the lancer is more than 10% longer, fix the fall pack scale.
- **Film** (owner judges by it): at 32 px/m, tilt 70, 1080p60, 15 to 40 s (`ffprobe` it), the lancer in a real
  gauntlet wave or arena fight with Rivet (`tools/film/film.mjs`, `project/dev/enemy_ai/foe_duel.gd`, or the gauntlet
  with `--waves`/a seed that spawns rocket troopers; find the cheapest real path), showing walk, kneel tell, fire,
  hit and death; plus a 64 px/m close-up clip of the same. If a launch needs a new flag in a file you do not own,
  stop that path and write a NEED. Output: `C:\Users\kazda\kiro\gtai-masters\n24\cast\lancer_wave_32.mp4`,
  `lancer_close_64.mp4`. Watch it (extract 6 stills with ffmpeg and look) before you call it done.

## 2. The door carrier in the game (commit)
The round 02 sheets in `foes-n24/out/shield_robot_*` are accepted by the director at sheet level except: the hit
sheets carry small yellow-green spark ticks beside the slab: make sure the cutter neither leaves green fringe on them
nor keeps them as orphan blobs (drop them if they cut badly; the game draws its own sparks via `ShieldSparks`).
- Cut, pack (both pitches), tone, provenance, `--import`. Look at every cell at 32 and 64 px/m.
- **Slab width = the shove's hit**: `FoeShield.SLAB_HALF_M` (0.32 m each side, 0.64 m) in
  `project/features/combat/squad/foe_shield.gd`. Measure the drawn slab in the down-facing walk cell at 64 px/m
  (expect about 41 px wide); scale or pick so it matches within 15%. Body about 2.0 m tall. Say both numbers.
- Wire it through `cast_cards.json` (a `shield_robot` row) and the same one switch. Today it is the thug robot rig
  scaled 1.18x (`FoeLooks.robot_plan`) plus `FoeShieldView`'s drawn slab: with the card on, the rig and the vector
  slab do not draw; with the row's `enabled: false` everything is as on main. Robots may not go through the human
  `CutRig` head card path: read how `ArenaRobotRigs` draws and find the smallest clean hook (your own new file,
  one-line call sites listed). Walk by distance, attack rows from the fighter's tell and shot ticks as the lancer,
  hit, fall. Render only: no sim, replay or parity digest moves (`node tools/tests/run_unit.mjs --changed`; if an
  arena file changed, `just scenarios` equivalent: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`).
- Stills like the lancer's: `C:\Users\kazda\kiro\gtai-masters\n24\cast\door_{32,64}ppm_tilt{70,55}.png` beside the cop
  and Rivet: walking, braced tell, shove, hit, dead. Look at them.

## Setup and law
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12`
to render; `--position 0,1440` on any window. One Godot at a time; kill only your own PIDs, never by name.
Allowed paths: `project/features/characters/art/view/**/{rocket_trooper,shield_robot,sentry_turret,war_machine}_*`;
new `project/features/characters/cast_*.gd`, `project/features/combat/squad/foe_*view*.gd` (existing foe views: render
switches only); `project/data/tables/cast_cards.json` + schema; `project/tests/unit/test_cast_*`; `project/dev/cast/**`;
`tools/art/cast_*`; `docs/art/cast-*.md`; one-line call sites in shared render files (`arena_*`, `street_*`,
`foe_looks.gd`, `arena_robot_rigs.gd`), each listed in your report; `steam/ai-provenance/2026-11.jsonl` (append);
`C:\Users\kazda\kiro\gtai-art\foes-n24\**`; `C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and
report a NEED. Forbidden: numbers in `enemies.json`, `weapons.json`, `combat.json`; `input_actions.json`;
`project/features/player/**`; `rivet_walk*`, `rivet_run8*`; `project/features/souls/**`; `project/features/gauntlet/**`;
`project/dev/gauntlet/**`; `melee_*`; `signature_kills.json`; `project/features/combat/kills/**`; `combat_arena.gd`
(one-line call sites only, listed); JOURNAL.md, REPORT.md, `evidence/briefs/`.
AGENTS.md / STANDARDS.md: typed GDScript, ~200 lines per file (300 hard), functions <= 40 lines, <= 5 params, `Log`
not `print`, data JSON with a schema. Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`,
`node tools/godot/check.mjs`, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit).
Commit `.uid`/`.import` with sources; run a Godot `--import` after new art. Stage per path; never amend, rebase, stash,
`add -A`, push. After a code commit: `node tools/mutate/mutate.mjs --file=<your main new .gd> --max=20` and quote the score.
Colour law: red is blood only; cops are blue; vermilion only for danger/objectives/Rivet's collar; teal only for souls;
amber for heat and the hazard bands. Never a real person's likeness.

## Report back
Commits (sha + message), files, the one-line call sites, checks and results, mutate score, round PID/log and which
jobs landed, every take you rejected and why (count takes per sheet), the two slab numbers, film paths with ffprobe
duration, what is left.
