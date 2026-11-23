# Brief n24-melee P1: one click, one swing, per melee weapon

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop 18:45 wall clock** (check `date`). **Commit deadline 18:40**: whatever is green by then is
committed; anything unfinished is described in your final report, not left half-staged.

## The owner's words (verbatim)
"Melee weapons double-attack on one click look horrible, we need on unique swing per weapon, with unique
brutal animation per human enemies as it should one-shot them." and "Remove cursors for melee weapons, as
they shapes are confusing". This package is the swing part (and the cursor if time allows). The one-shot
kills come in the next package: do not start them.

## Setup (once, first)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run.
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- Run one `"$GODOT_BIN" --headless --path project --import` first (main moved since the cache was made).
- One Godot process at a time in this lane. Anything windowed: `--position 0,1440` (never the main
  display). Anything that renders: `--rendering-driver d3d12`. Free your own processes by PID, never by name.
- Read `AGENTS.md`, `STANDARDS.md`, `tools/README.md` (the film kit: `tools/film/film.mjs`,
  `tools/film/compare.mjs`, `--rev=HEAD` snapshots so edits do not break a queued film).

## What the director already found (verify it, then write the confirmed cause in your report)
With a melee weapon selected the swing press is LEVEL, not an edge: `RivetWheel.swing_pressed`
(`project/features/player/rivet_wheel.gd:69-85`, `c.is_held(actions, &"fire")`) and the non-wheel
`StagePilot._melee_press` (`project/boot/collect_call/stage_pilot.gd`, "a held fire swings too") return
true on every tick fire is held. `MeleeCombo.press()` (`project/features/player/melee_combo.gd`) sets
`buffered = true` while a hit plays and `step()` then starts hit 2 at `windup + active + cancel_ticks`.
A mouse click lasts several ticks, so every click chains a second hit. Also check that `PlayerShock`
(`player_shock.gd`, stepped with the held melee key in `StagePilot._attacks`) does not add a second strike
on a click; if it does, that is a second cause: name it and fix it in `player_shock.gd`.

## Step 1: see it (before)
Film one click with each melee weapon on a cop on the tree as it is (HEAD = main b3f4727c0): hands (the
claw, `rivet_melee.json`), `chainsaw`, `electro_baton`, `katana`, `plasma_sword` (`melee_weapons.json`).
Use `tools/film/film.mjs` (a `weapon:<id>` shot if it fits melee, `--rev=HEAD`, `--on=` beats; read
`tools/README.md`); if no existing shot gives "one click on a cop", add the smallest shot/probe to what
film.mjs already supports (a dev file under `project/dev/melee/` is yours). One click = fire pressed for
6 ticks then released. 32 px/m, tilt 70, 1080p60, and a 64 px/m close-up. Record per weapon the hit
starts per click from telemetry (`StagePilot.melee_swings`, or a counter you add in `PlayerMelee`).
Output: `C:\Users\kazda\kiro\gtai-masters\n24\melee\before\` (stills + mp4 per weapon). Print the
swings-per-click table in your report (expected before: 2 for the blades).

## Step 2: one click, one swing (the change)
1. **Rule**, in `melee_combo.gd` / `player_melee.gd` (not in rivet_wheel.gd or stage_pilot.gd): a table
   value `single_swing` (top level of `melee_weapons.json` and `rivet_melee.json`, shipped `true`). When
   on: a press while a hit plays never buffers a next hit; a press that continues a press already held on
   the previous tick does not start anything while a hit plays; a button still held when the recovery
   ends starts the same single swing again (the held repeat, only after recovery). No automatic second
   hit, ever. `false` = the old combo, byte-identical (keep the old rows' path working).
2. **One swing row per weapon**, tuned and documented in its row (`doc`), each its own arc (`cone_dot`),
   reach, windup, active and recovery ticks. Starting points (tune them so the swing reads at 60 Hz):
   - hands / claw: one claw rake (keep the claw's first hit's feel: short, quick).
   - chainsaw: one rev and drive: a rev-up windup, the drive in (lunge), the grind while held
     (keep `grind_ticks` / `grind_min_ticks`), and the rip-out folded into its recovery (one row).
   - electro_baton: one short crack (fast windup, 3 active, the overhead crack's arc to metal
     `chain_hops` 2 and a stun).
   - katana: one cut (a clean diagonal draw-cut with its lunge).
   - plasma_sword: one wide sweep (widest cone). **Its deflect window must keep working**: `deflect_m`
     and `PlayerDeflect` are the pressure lane's rules, do not change them; keep its active ticks at
     least as long as the old longest plasma hit (6).
   How to express "one row" is your call (e.g. a `swing` hit id per weapon naming the single hit, the old
   combo rows kept for `single_swing: false`). Update `project/data/schemas/` for these tables.
   Damage numbers stay where they are for now (the one-shot rule is the next package).
3. **Its own drawn motion per weapon** (view, `melee_swing.gd`, `melee_smear_view.gd`,
   `melee_weapon_view.gd`, `rivet_swipe_view.gd`): a per-weapon swing shape in the weapon's row (e.g.
   `swing_style`: rake / drive / crack / cut / sweep with its own anticipation, follow-through, arc and
   side), so the five swings look different on screen. Use the existing strike/windup art first
   (`project/features/characters/art/view/**/rivet_eq_*_windup*`, `*_strike*`, `rivet_strike.png`);
   do NOT draw new character frames in this package (new frames need the Codex image pipeline: if a
   weapon clearly needs frames, say so in your report with a still).
4. **Telemetry**: a unit test per weapon: a click held 1, 6 and 20 ticks gives exactly one hit start;
   a button held through two full recoveries gives exactly two (the repeat after recovery); a second
   click during the swing gives no second hit before the recovery ends. Plus `single_swing: false`
   reproduces the old chain (2 starts on a 6-tick click for the katana).
5. **Replays/tapes**: run the scenarios (`just scenarios` equivalent) and the replays. A shipped tape or
   golden that contains melee and moves: list each one with a one-line reason in your report and add one
   dated line to `docs/decisions.md` (`- [2026-11-22] DECISION n24 melee: ...`, append-only, one line).
   No sim, parity or bake digest may move.
6. **After**: film the same clicks again on the change -> `...\n24\melee\after\`, and a before|after
   side-by-side per weapon at the same tick (`tools/film/compare.mjs` fits). Look at your frames. Print
   the after swings-per-click table (must be 1.0 for all five).

## Step 3 (only if steps 1-2 are committed before 18:15): no cursor for melee
`project/features/hud/weapon_cursor.gd`: with hands or a melee weapon selected, the weapon-shaped
cursor is gone; show the plain system arrow (no custom cursor) so the player still has a pointer, as a
table/const value with the alternative (a small plain dot) one value away. Unit test. Still of before
and after to `...\n24\melee\cursor\`.

## Files you may edit (allowlist; any other path: stop and report a NEED)
`project/features/player/melee_*.gd`, `project/features/player/player_melee.gd`,
`project/features/player/player_shock.gd`, `project/features/player/rivet_swipe_view.gd`,
`project/features/hud/weapon_cursor.gd`, `project/data/tables/melee_weapons.json`,
`project/data/tables/rivet_melee.json`, `project/data/tables/melee_marks.json`, their schemas under
`project/data/schemas/`, new files under `project/dev/melee/`, tests named for these files
(`project/tests/unit/test_melee_*.gd`, `test_player_melee*.gd`, `test_weapon_cursor*.gd`), existing tests
that break because of THIS change (fix the expectation, say which), `tools/film/**` only to add a melee
shot (small, tested), one appended line in `docs/decisions.md`, one appended flag in
`project/boot/launch_args.gd` `KNOWN_FLAGS` if you need a flag (then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n24 melee"`).
**Forbidden** (other lanes own them): `rivet_wheel.gd`, `stage_pilot.gd` (a one-line call site only if
unavoidable: name it), `player_motion*.gd`, `top_down_mover.gd`, `live_input.gd`, `player_command.gd`,
`rivet_walk.gd`, `player_deflect.gd`, `player_guard*.gd`, `enemies.json`, `weapons.json`,
`input_actions.json`, `combat.json`, `combat_arena.gd` (one-line call sites only), `features/gauntlet/**`,
`features/souls/**`, `features/characters/art/**`, `signature_kills.json` and `features/combat/kills/**`
(next package).

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer,
5 params max; `Log` not `print`; no global RNG, sim steps on `SimClock.TICK_DT`. Data is JSON with a
schema. Commit `.uid`/`.import` with new files. Stage per path (`git add <path>`), one commit per change;
no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
Fix lint and format findings in your own edit and go on. Before each commit:
`node tools/gate/quick.mjs` (read its usage) and `node tools/tests/run_unit.mjs --changed`.
After the rule commit: `node tools/mutate/mutate.mjs --file=project/features/player/melee_combo.gd --max=20 --lines=<changed lines>` and quote killed/(killed+survived).

## Report (your final message)
The confirmed cause; before/after swings-per-click table; the five swing rows (ticks, reach, cone);
files changed per commit (sha); test, quick gate and mutate results; film paths; tapes/goldens that moved
and why; what you could not do and why; anything that needs new drawn frames.
