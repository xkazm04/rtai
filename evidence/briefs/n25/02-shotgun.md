# Package 02 `shotgun`: Mulroney's real shotgun

Wall-clock hard stop and commit deadline: given at the top of the launch note below. Stop early when done.

## Goal (owner, verbatim): "Add a real shotgun to the weapon table."
Mulroney fires a real shotgun: pellets in a cone, deadly close, weak far, and a **pump between shots** that is his tell and
the player's opening. He uses it instead of the three rifle rounds he fires today, and he still falls last. As a player weapon
it exists in the table and can be held, drawn with stand-in art until its own art is drawn.

## What I know
- Today `project/boot/prologue/prologue_squad_fire.gd` (~line 57-64) fires Mulroney's "shotgun" as three `rifle` rounds across
  `shotgun_half_deg: 9` (`prologue_stage.json`), each round's `left_m` set to his weapon's `reach_m`. His row
  `sergeant_mulroney` in `enemies.json` uses weapon `rifle`.
- Enemy weapons: `enemies.json` `weapons` map (`baton`, `pistol`, `rifle`, ...: burst, burst_gap_s, cooldown_s, damage, reach_m,
  speed_mps, round), read by `project/features/combat/ai/enemy_weapon.gd` / `enemy_roster.gd`; schema `project/data/schemas/enemies.schema.json`.
- Player weapons: `weapons.json` `weapons` list (each row has `pellets`, `spread_deg`, `range_m`, `speed_mps`, `damage`,
  `shot_cue`, `tier`, ...), read by `project/features/combat/weapons/weapon_spec.gd`; `gun_hand.gd:48` and `projectile_sim.gd:39`
  already loop over `pellets`. There is no damage falloff field: "weak far" comes from the cone (pellets diverge, so fewer
  land) plus a short `range_m`. Prefer that over new engine code.
- Held art: `rivet_arsenal.json` `weapons` maps an id to a grip class; `art_stand_in` (id -> id, snake_case) draws a weapon with
  another's held art. Pick the nearest `two_hand_long` weapon as the stand-in.

## The contract with the other lanes (strict)
- NEW rows only: a player row `shotgun` in `weapons.json` and an enemy weapon row `shotgun` in `enemies.json` `weapons`, used
  by `sergeant_mulroney` only (change his row's weapon to `shotgun`: that row is this lane's own). **No existing row's numbers
  change** (the n24 pressure lane is editing them). Rows stay sorted the way each table sorts them.
- If the enemy row needs fields the schema lacks (e.g. `pellets`, `spread_deg`, `pump_s`), add them as OPTIONAL properties to
  `enemies.schema.json` (a small, append-only hunk). Do not change `enemy_weapon.gd` / `enemy_roster.gd` unless the row cannot be
  read otherwise; if so, keep the change additive (a new optional field with a default that leaves every other weapon identical)
  and say so in the final message. The pellet cone and the pump for Mulroney live in the prologue files (`prologue_squad_fire.gd`
  or a new `prologue_shotgun.gd`), reading the new row.
- The new player row must NOT enter anything that draws from the weapon table at random or by tier (gauntlet loot / bot arsenal,
  armories, quest 1 table guns, the showcase reel): find every reader of `weapons.json` rows and confirm. Every shipped tape and
  scenario outside the prologue must stay byte-identical; if a reader would pick it up, use the table's existing way to keep
  a row out (e.g. its `tier` or `enabled`) and record which.

## What to build
1. Enemy `shotgun` row and Mulroney firing it: N pellets (about 6-8) in a cone (about 20-30 degrees), short reach (about 8-10 m,
   which is today's reach), damage per pellet such that point-blank (all pellets) hurts Rivet clearly more than a rifle burst
   and at full reach only one or two pellets land. Between shots a **pump**: a visible tell on Mulroney (a short pump motion or a
   marker drawn the way the prologue draws his order tell; colour law: vermilion only for danger) of about 0.6-0.9 s, during
   which he cannot fire, so the player can close in or roll through. He still falls last (the 0.25 hp floor while his squad
   stands is unchanged). Keep his orders (volley / flank) and their timings as they are.
2. Its own cue: the player row's `shot_cue` and Mulroney's shot use a `shotgun` cue. If `audio_cues.json` needs a new cue row,
   append one that reuses existing samples (no generated audio); a pump cue too if the table makes that cheap. If audio needs
   any other file, report a NEED.
3. Player `shotgun` row in `weapons.json` (pellets, spread, short range, magazine, pump-paced `rof_hz`, `reload_s`, cue) and in
   `rivet_arsenal.json` `weapons` (grip class `two_hand_long`) + `art_stand_in`. Show that Rivet can hold and fire it: the
   existing dev way to put any weapon in hand (an arsenal/armory dev scene or a launch flag already in `KNOWN_FLAGS`); take a
   1920x1080 still of Rivet holding it at 64 px/m and one of the pellet cone in flight at 32 px/m.
4. Pickup after the fight: **default no** (the owner's script does not say so). Make it one data value in `prologue_stage.json`
   (e.g. `mulroney.drops_shotgun: false`) only if it is cheap; otherwise just record the decision. Add
   `- [2026-11-23] DECISION prologue: ...` lines to `docs/decisions.md` for: the shotgun numbers, the pump tell, the pickup default,
   and how the player row is kept out of random draws.
5. Unit tests: `project/tests/unit/test_prologue_shotgun.gd` (or a name matching the class): pellet count per shot, the cone's
   angular spread bounds, pellet hits on a Rivet-size target at 2 m vs 8 m vs beyond reach (falloff: many -> few -> zero),
   no shot during the pump, the player row loads through `WeaponSpec` with its pellets and spread. Deterministic (RNG via the registry).

## Acceptance (run all, quote results)
- Pilot: `node tools/dev/run.mjs prologue --bot --seed=7 --result=<abs json under build/dev>` twice, verdict ok, results cmp-identical,
  0 deaths, Mulroney falls last, end card reached; quote wave 2's seconds and the number of shotgun shots / pump windows.
  If the bot needs a change to survive the shotgun, change only `prologue_bot.gd`.
- `node tools/tests/run_unit.mjs --changed` green; full scenario suite green; quest 1 and the 60 s replay unchanged.
  `node tools/achievements/gen.mjs validate` if lint needs it. `node tools/gate/quick.mjs` green before each commit.
- Commits: (a) data rows + schema + reader tests, (b) Mulroney's shotgun + pump in the prologue, (c) films/stills entry if any.
- mutate `--max=20` on the main prologue file you changed for the shotgun; quote the score.
- Clip: add a clip id `shotgun` to `project/dev/prologue/prologue_film.gd` and `capture/film.ps1` that starts ~2 s before
  Mulroney's first shotgun shot in range of Rivet and runs 20 s (it must show at least two pumps), 1920x1080, 60 fps, 32 px/m,
  tilt 70, seed 7. Render to `C:/Users/kazda/kiro/gtai-masters/n25/path/shotgun.avi`, convert with ffmpeg to `shotgun.mp4`
  (H.264, yuv420p, crf 20), delete the .avi; quote `ffprobe` duration. Stills into the same folder: `shotgun-pump.png` (the pump
  tell visible), `shotgun-cone.png`, `shotgun-held-64ppm.png`.

## Final message
Files changed, commit shas, the numbers you chose and why, which readers of the weapon table you checked, test/scenario/mutate
lines, clip path and duration, NEEDs, and anything left.
