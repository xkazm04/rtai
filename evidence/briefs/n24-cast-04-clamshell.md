# Brief 04 (lane cast): brief 03's leftovers; the clamshell in the game; the pile-driver round; the standing rule

Hard stop: 75 minutes after you start (run `date` first and write the stop time down). At stop-minus-10 commit what
is done and stop. Commit each finished step on its own (staged per path). Work the sections in order; an enemy you
cannot finish is committed with its row switched off, or its art only (no half-drawn enemy
ships: an unfinished enemy keeps its placeholder, `enabled: false` in `cast_cards.json`).

## 0. First: start the pile-driver round (detached, it runs while you work)
Same runner, style block and refs as rounds 02/03 (`C:\Users\kazda\kiro\gtai-art\foes-n24\jobs.json`).
Director's review of the round-03 pile-driver sheets (`foes-n24/out/war_machine_*`), all REJECTED as whole sheets:
- every 70 sheet: column 1 (down) is a PLAN VIEW from straight above (copied from the concept's inset), column 2
  (down-right) shows the BACK louvres at the near-left with the cannon right: it reads as facing right/away, never
  toward the viewer. Columns 3 (right profile), 4 (up-right, louvres toward the lower-left) and 5 (up, louvres toward
  the viewer) are mostly right in attack_70, stomp_70, hit_70, walk_55.
- `war_machine_walk_55` column 1 is the only good front view so far (cab front, lamps, low camera): use it as the
  front-facing reference image for the retake.
- smoke in fall_70 row 3: no smoke, haze or any translucent effect anywhere.
Root cause: the concept plate `foes-n22/out/war-machine-b.png` has a top-down INSET at its right. **Crop the
concept to its hero view (left ~63%, no inset) before passing it as a reference**, and pass the walk_55 column-1 cell
(cut from the sheet) as the front reference. Write per column what faces the viewer:
col 1 (down) = the front: heavy wide front armour plate and navy cab face toward the viewer, amber light bar on the
roof, cannon muzzle on the machine's right side pointing at the viewer (foreshortened circle), the engine block and
louvres HIDDEN behind the cab; camera 70 (or 55) degrees above the floor, never straight down. col 2 (down-right) =
front three-quarter: front plate and the right side visible, cannon pointing toward the lower-right, louvres hidden.
col 3 (right) = right profile, cannon pointing right, louvres at the left (rear) end. col 4 (up-right) = rear
three-quarter, louvres toward the viewer's lower-left, cannon pointing up-right. col 5 (up) = straight from behind,
louvre rows facing the viewer, cannon pointing up the sheet.
If whole sheets keep failing, generate the two front columns alone (a 2-column x N-row sheet, same scale and
baseline as the rest) and SPLICE them into the good columns 3-5 of the round-03 sheets with a `tools/art/cast_*`
splice tool (measured heights and baselines, as you did for the lancer). Count takes per sheet. Sheets: walk, attack,
stomp, hit, fall at 70 and 55 (layouts as brief 03 section 0c). Size: 2.6 m tall, ~1.8 m wide.

## 1. Brief 03 leftovers (fill these before anything new)
Read `evidence/briefs/n24-cast-03-film-door.out.txt` (your own report) and `git status`. Finish and commit what 03
left: the door carrier wired behind `cast_cards.json` (check: slab drawn width = 0.64 m within 15%, body ~2.0 m;
switch off = main), the lancer films `C:\Users\kazda\kiro\gtai-masters\n24\cast\lancer_wave_32.mp4` and
`lancer_close_64.mp4` (32 / 64 px/m, tilt 70, 1080p60, 15-40 s by `ffprobe`; walk, kneel tell, fire, hit, death; watch
6 stills you extract), the door stills `door_{32,64}ppm_tilt{70,55}.png`, the `_kneel` error, the unit `--changed`
pass line and the scenarios exit code. Then a **door carrier film** the same way (`door_wave_32.mp4`,
`door_close_64.mp4`: walk, braced tell, shove, hit, death).

## 2. The clamshell (sentry turret) in the game
Use the v2 sheets `foes-n24/out/sentry_turret_{attack,hit,fall}_{70,55}_v2.png`. Director's review (sheet level):
- ACCEPTED: attack_70_v2, fall_70_v2, hit_70_v2, attack_55_v2, fall_55_v2, hit_55_v2: facings right, base plate
  square and still in every cell.
- FAULT to clean in the cut: translucent green-white **smoke wisps above the twin stacks in every 55 cell** and in
  the fall sheets' rows 2-3 (big plumes in fall_55 row 2 and fall_70 row 2). Erase everything above the stack caps
  and any low-alpha / green-tinted pixel cluster that is not body (a mask from the stack-cap line upward, then a
  despill). Look at the stacks of every cell at 64 px/m: no grey or green haze may survive. If a plume overlaps the
  dome (fall row 2), erase it there too or retake that row; never ship a half-keyed wisp.
- Row order: map rows to idle / tell / fire / recover by what is drawn (glow up the barrels = tell, muzzle flash =
  fire), not by position. The hit sheet's small yellow spark ticks: drop them (the game draws its own sparks).
- Cut, pack (both pitches), tone, provenance lines, `--import`; look at every cell at 32 and 64 px/m.
- Wire through `cast_cards.json` (`sentry_turret` row, same switch). Today the rig is hidden and `FoeTurretView` draws
  vector shapes. With the row on, the card draws (attack row from the fighter's tell and shot ticks; idle = row 0;
  hit; fall), and `FoeTurretView` draws only what the card does not (keep any aim line / tell mark that is the danger
  read). With `enabled: false` everything is as on main. Render only: no sim, replay or parity digest moves.
- Size: dome about 1.1 m wide, plate about 1.4 m square. Measure and say both.
- Stills `C:\Users\kazda\kiro\gtai-masters\n24\cast\clamshell_{32,64}ppm_tilt{70,55}.png` beside the cop and Rivet:
  idle, tell, fire, hit, wreck. A 32 px/m clip of it firing at Rivet in a fight (15-40 s, ffprobe) + a 64 px/m close-up.

## 3. The pile-driver, when its round has landed (only if section 0 gave accepted sheets)
Review every sheet yourself against the per-column words in section 0 BEFORE cutting (facing per column, plan view,
smoke). Then as section 2 for `war_machine_{walk,attack,stomp,hit,fall}`: wire through `cast_cards.json` (the table
may need a `stomp` action key: extend the schema; the attack row comes from the alt telegraph when the stomp is the
one telling: read the fighter). Today it is the thug robot rig scaled 1.65x (`FoeLooks.robot_plan`) + `FoeWalkerView`
+ `FoeWalkerCrackView`: keep the weak-spot read (the louvres) working, drawn by the card or the view. Height 2.6 m
beside Rivet's 1.65 m: measure and say it. If you run out of time, commit the accepted, cut sheets (art + provenance)
with the row `enabled: false` and say so.

## 4. The standing rule (docs, small, do it before stop-minus-15 whatever else is open)
- Find where the character art rules live (`docs/art/`, `STANDARDS.md` art section). Add a short section (where they
  live; if STANDARDS.md is the only home, put the section in `docs/art/cast-checklist.md` and one pointer line in the
  docs/art index or README, NOT in STANDARDS.md) saying: a character enters a wave only when it passes
  `docs/art/cast-checklist.md`; the checklist items in one table (item, how it is checked, the cop's value).
- Write the pass/fail table per enemy (lancer, door carrier, clamshell, pile-driver, and every other archetype from the
  audit) into `docs/art/cast-audit.md`, with today's state.
- Do NOT edit `docs/decisions.md`; put the proposed one-line decision text in your report and the director appends it.

## Setup and law
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12`
to render; `--position 0,1440` on any window. One Godot at a time; kill only your own PIDs, never by name.
Allowed paths: `project/features/characters/art/view/**/{rocket_trooper,shield_robot,sentry_turret,war_machine}_*`;
new `project/features/characters/cast_*.gd`, `project/features/combat/squad/foe_*view*.gd` (existing foe views: render
switches only); `project/data/tables/cast_cards.json` + schema; `project/tests/unit/test_cast_*`; `project/dev/cast/**`;
`tools/art/cast_*`; `docs/art/cast-*.md` (+ one pointer line in a docs/art index); one-line call sites in shared render
files (`arena_*`, `street_*`, `foe_looks.gd`, `arena_robot_rigs.gd`), each listed in your report;
`steam/ai-provenance/2026-11.jsonl` (append); `C:\Users\kazda\kiro\gtai-art\foes-n24\**`;
`C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and report a NEED. Forbidden: numbers in
`enemies.json`, `weapons.json`, `combat.json`; `input_actions.json`; `project/features/player/**`; `rivet_walk*`,
`rivet_run8*`; `project/features/souls/**`; `project/features/gauntlet/**`; `project/dev/gauntlet/**`; `melee_*`;
`signature_kills.json`; `project/features/combat/kills/**`; `combat_arena.gd` (one-line call sites only, listed);
`docs/decisions.md`, `STANDARDS.md`, `AGENTS.md`; JOURNAL.md, REPORT.md, `evidence/briefs/`.
AGENTS.md / STANDARDS.md: typed GDScript, ~200 lines per file (300 hard), functions <= 40 lines, <= 5 params, `Log`
not `print`, data JSON with a schema. Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`,
`node tools/godot/check.mjs`, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit).
Commit `.uid`/`.import` with sources; run a Godot `--import` after new art. Stage per path; never amend, rebase, stash,
`add -A`, `commit -a`, push. After a code commit: `node tools/mutate/mutate.mjs --file=<your main new .gd> --max=20`
(changed lines) and quote the score. If arena files changed, run the scenarios once
(`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) and quote the exit code.
Colour law: red is blood only; cops are blue; vermilion only for danger/objectives/Rivet's collar; teal only for souls;
amber for heat and the hazard bands. Never a real person's likeness. Check facings against the cop's column order
(down, down-right, right, up-right, up) in every review, not only the cut.

## Report back
Commits (sha + message), files, the one-line call sites, checks and results (unit pass line, scenarios exit, lint),
mutate score, round PID/log and which jobs landed, every take rejected and why (count takes per sheet), measured sizes
(slab width, door body height, dome width, plate size, pile-driver height), film and still paths with ffprobe
durations, the proposed decisions.md line, what is left.
