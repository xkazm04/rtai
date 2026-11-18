# Brief 08 `car-doors` (lane move, n19): a short enter and exit motion for cars

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## Context
`project/features/vehicles/vehicle_service.gd` swaps Rivet into and out of a car on the tick the use key is
pressed (`try_enter` about line 52, `exit` about line 73; hijack throws the driver out at `DOOR_OFF`). Nothing
moves Rivet to the door or out of it: he pops. Tonight only the `gfx` lane may re-bless a sim, replay or parity
digest, so any change that alters the sim when nobody asked for it is forbidden; a sim change ships behind a flag
that is OFF.

## Design (decided; build exactly this)
Two layers, each switchable alone:
1. **Sim door phase, flag `--car-doors` (KNOWN_FLAGS, appended, one commented line), default from
   `vehicle_handling.json` `doors.enabled` = false.** On: entering takes `doors.enter_ticks` (about 14): Rivet's
   foot position moves from where he stood to the driver's door point (`b.pos + side * DOOR_OFF`-ish, but the
   point that is clear of solids; if it is not clear, the enter is refused as today's out-of-reach case), the car
   is held (no throttle; a hijacked moving car keeps its own motion and the phase is skipped: hijack stays
   instant), then `driving` is set. Exiting takes `doors.exit_ticks` (about 10) and only starts below
   `doors.exit_max_mps` (a fast car still lets him bail out instantly, today's behaviour); Rivet appears at the
   door and steps `doors.step_out_m` away from the car. Never inside a solid or a car hull: check with the
   world's own collision preview. Deterministic on the fixed tick; the phase is in `write_state` ONLY when it is
   active, so flag-off digests are byte-identical (prove it: a unit/scenario check that flag-off state bytes
   match the code without the phase).
2. **View motion, on by default (render only, `vehicle_handling.json` `doors.view` true).** With the sim phase
   on, the view draws Rivet walking to the door, the door card swinging (or the car's sprite nudged by 1 px if no
   door art exists: do not draw new car art), and Rivet sliding in (fade/clip into the car); on exit the reverse.
   With the sim phase OFF, the view still plays a short cosmetic version (Rivet's figure eases from his last
   foot point into the car over about 0.25 s, and out from the door over about 0.2 s) without touching sim
   state. Rivet's existing walk cells are fine; no new drawn art.

## Tests and evidence
- Unit tests red before, green after: enter takes enter_ticks and ends in `driving`; blocked door refuses;
  exit below/above exit_max_mps; flag off = today's instant swap; no solid overlap at every tick of the phase.
- A scenario that enters, drives 3 s, and exits a parked car with scripted input, twice, identical digests, with
  `--car-doors` on; and the existing city/vehicle scenarios unchanged with it off.
- Frames: same-tick before/after (flag off vs on) at tilt 70, 32 and 64 px/m, a 32 px/m clip (10 to 40 s) of
  enter, short drive, exit, to `C:/Users/kazda/kiro/gtai-masters/n19/move/car/` with INDEX.md. Look at them.
- `node tools/mutate/mutate.mjs --file=features/vehicles/vehicle_service.gd --max=20` (or the new door file) and
  quote the score.

## Not yours
`features/city/**`, `features/police/**`, `native/**` (gfx); `features/characters/**` (anim); combat/arena (ai);
any golden or digest file. `project/boot/**` only a one-line call site if unavoidable, named in the commit.

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300: `vehicle_service.gd` is at 200,
put the phase in a new `vehicle_doors.gd`); `Log`; JSON data with its schema updated; commit `.uid` files.
Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md or evidence/. Keep doc
comments. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
quick gate + lint clean; `run_unit.mjs --changed` and `--fast` green; full scenarios green with the flag off;
the door scenario green twice; frames + clip + INDEX.md; mutation score; `git status` clean.
