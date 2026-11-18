# Brief 02 `vault-view` (lane move, n19): the vault reads on screen, filmed before/after

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; every windowed run `--position 0,1440` (secondary monitor, never
the main display). One Godot process at a time. Never kill processes by name.

## Goal
With `--vault` on, the vault is visibly a committed hop over the obstacle, using Rivet's EXISTING rig (no new
art in this package): at 32 px/m in the top view and at tilt 55 and 70, and at 64 px/m close up. Then the
evidence: a dev course, same-tick before/after stills, a 32 px/m clip of 10 to 40 s, a 64 px/m close-up.

## What is true today (scouted; verify)
- `PlayerVault` (`features/player/player_vault.gd`) gives the vault's tick, `airborne()`, `lift()` (0..1 arc)
  after brief 01b. Rivet's sim position travels continuously over the obstacle.
- Rivet's rig is fed in `features/arena/arena_rigs.gd` (the ai lane's file): `_put(0, rivet, ...)` writes
  `RigFeed.pos` (world px, ground point); `_rivet_clips()` starts `RigClips.Clip.ROLL` when
  `pilot.motion.rolls` changes (clip length `roll_ticks * TICK_DT`) and hides the gun while
  `pilot.motion.phase == PlayerMotion.Phase.ROLL`. `RigFeed` has no height channel.
- `core/render/view_mode.gd` `ViewMode.lift_px(h_m)` is how far h metres rises on screen under the current
  view (`top` is flat: 0). Shadows: check how Rivet's ground shadow / cast shadow is placed (RigCastShadows).

## Build
1. The pose: during a vault Rivet's rig plays the roll's tuck for the vault's length (a tucked hop), the gun is
   hidden as in the roll, his drawn body rises by `lift() * apex_m` (through `ViewMode.lift_px`) while his
   ground shadow stays on the ground, and in the flat `top` view (where lift is 0 on screen) the body scales
   up by a small data value at the apex (`vault.top_scale`, ~1.12) so the hop still reads. If the tuck reads
   wrong for a hop over a waist-high box, say so and propose; do not invent new art.
2. Where the code goes: all logic in a new `features/player/vault_view.gd` (yours). In the other lanes' files
   you may make **at most three one-line call sites in `features/arena/arena_rigs.gd`** (ai lane) and **at most
   two one-line call sites in `features/characters/**`** (anim lane), each a single line calling into your
   class, each named in your commit message (file:line). If it cannot be done within that, stop and report the
   minimal set it needs instead of editing more.
3. A dev course `project/dev/rivet_motion/vault_course.gd` (+ `_run.gd`, the launcher pattern of
   `motion_course.gd`; declare `const KNOWN_FLAGS` so `tools/dev/run.mjs` checks them): the real arena stage
   (and the city proving block if the arena plan has it; otherwise a city spot with a bench and a sedan) with
   real rigs and real view, Rivet driven by scripted `TickInput`: sprint at a cover_low and vault it, vault a
   bench / sedan in the city, try a cover_high (refused), try a blocked landing (stops). Flags: `--ppm=32|64`,
   `--view=top|tilt|tilt70|combo` (`tilt` = pitch 55 with the p55 art, `tilt70` = pitch 70 with p70; `combo` is the shipped default if view.json says so), `--vault` or
   `--no-vault` passed through, `--stills=<ticks>` writes PNGs, `--out=<dir>`. Same seed, same input: with
   `--no-vault` it is the BEFORE (the roll press at the same tick rolls into the box), with `--vault` the AFTER.
4. Render, at the same ticks, before and after:
   - 32 px/m stills at top, tilt 55 and tilt 70 around the arena vault (approach, take-off, apex, landing);
   - 64 px/m close-up stills of the apex and landing at tilt 70;
   - a 32 px/m clip (mp4 via `--write-movie` to .avi then ffmpeg to mp4 h264, 10-40 s) of the whole course
     at tilt 70 with `--vault`, plus the same at top view.
   Output to `C:/Users/kazda/kiro/gtai-masters/n19/move/vault/` (create it; never into git). Make a labelled
   side-by-side sheet per pair (before | after, tick in the label) with `tools/film/sheet.mjs` or a small
   script under `tools/art/` or `tools/film/` if needed. Look at every image yourself before you report and say
   what you see in each (does the box ever overlap his feet; does the hop read; is the gun hidden).
5. Unit test(s) for `vault_view.gd` (lift curve endpoints, top-view scale at apex, zero outside a vault).

## Repo law (binding)
As before: AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`; `.uid` files.
Do not edit features/combat, features/city, native, goldens or digests. Stage per path; no stash, add -A or
reset --hard; never push. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
quick gate + lint clean; `run_unit.mjs --changed` and `--fast` green; the vault scenario green;
`node tools/dev/run.mjs vault_course ...` ends with an `ok exit 0; SCRIPT ERROR 0; unknown arg 0` verdict line
(quote it); the stills, sheets and clips exist in the masters folder; report the list of files with one line
each saying what is in it.

## Also in this package (from my review of 01/01b)
A. Mutation on `features/player/player_vault.gd` (sampled 12, mine): 50%. Real gaps, kill them with tests:
   line 32 (`enabled` from data: assert the shipped table gives false and `shipped()` without flags is off),
   line 74 (`intercept` without a `prepare` this tick must refuse), line 121 (`interrupt` clears `_ready`, so a
   stale prepare cannot fire later), line 172 (`_bind` from an arena stage then a non-arena stage clears the
   arena boxes). Run `node tools/mutate/mutate.mjs --file=features/player/player_vault.gd --max=20` after and
   quote the score; do the same for `features/player/vault_probe.gd`.
B. The fuzz started only 26 vaults of 360. Add a second fuzz family aimed at vaultable obstacles (approach
   points sampled in front of cover_low faces and city props whose height <= max, speeds and angles spread
   around the limits) so at least 200 vaults start; keep the per-tick asserts and print the counts.
C. A vault into a standing guard moved him 1.7 m at 11.3 m/s peak (smoothstep). Keep it (the sprint tackles
   too), but put the peak speed and the guard displacement in the scenario's printed counts.
