# Brief 04 `cover-view` (lane move, n19): cover reads on screen, filmed before/after

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; every windowed run `--position 0,1440` (secondary monitor, never
the main display). One Godot process at a time. Never kill processes by name. Commit each step as it lands: this
session is stopped at 75 minutes.

## Goal
With `--cover` on, being in cover, sliding, peeking and leaving are readable at 32 px/m in the top view and at
tilt 55 and 70, using Rivet's EXISTING rig and cells (no new art in this package). Then the evidence: a dev
course, same-tick before/after stills, a 32 px/m clip of 10 to 40 s, a 64 px/m close-up.

## What is true (from package 03 and 02; read the code, it is in `features/player/`)
- `PlayerCover` / `CoverQuery` landed in package 03 (read its commits: `git log --oneline -12`).
- The vault's view (`features/player/vault_view.gd`) shows the pattern for posing Rivet's rig from the move lane:
  one single-line call site in `features/arena/arena_rigs.gd` (`VaultView.feed(...)`, line ~143), a node that
  writes the rig's canvas item transform after the depth sort, the cast-shadow fix. Reuse that pattern (a
  `CoverView`), sharing helpers with VaultView rather than copying them.
- The p55 peek card for quest 1's hide (`boot/collect_call/view/hide_peek.gd`, art `rivet_hide_<pitch>`) is a
  dumpster with Rivet inside: it is a bin, not a wall pose, so it is NOT the art for wall cover. Its behaviour
  (only the visor shows above the bin) is the reference for a low-cover crouch: the crate hides his body, his
  head and gun read.

## Build
1. The pose, from the existing rig:
   - IN at low cover: crouched (a data value `cover.crouch_scale_y`, ~0.78, scales the posed body about his feet;
     a top-view equivalent that still reads: say what you chose), facing out from the wall when not aiming, the
     gun drawn and held;
   - IN at high cover: standing, back to the wall (facing along the normal, out of the wall);
   - PEEK: upright, facing the aim, gun out; the lean is already in the sim position;
   - SNAP/LEAVE: blend over the phase's ticks, no pop.
2. Readability at tilt: when Rivet is behind a box on screen (north of it at tilt 55/70) the box's standing card
   would hide him. Check what happens with today's prop/occluder sort. He must stay readable (his head and gun at
   least), by a rule that stays honest about cover: e.g. the occluding card fades or he draws a silhouette over
   it. Choose, do it inside your own files plus at most the call sites allowed below, and say what you chose.
3. Call sites: at most three single lines in `features/arena/arena_rigs.gd` (ai lane) in total including the
   vault's existing one, and at most two in `features/characters/**` (anim lane); each named file:line in its
   commit message. If that is not enough, stop and report the minimal set needed.
4. Dev course `project/dev/rivet_motion/cover_course.gd` (+ `_run.gd`, the `vault_course` pattern, `const
   KNOWN_FLAGS`): the arena with one or two scripted guards firing at Rivet from across a cover_low and a
   cover_high. Scripted `TickInput`: walk to cover, press, slide, peek out past the end and shoot, duck back,
   leave. `--no-cover` is the BEFORE (same input; the press does nothing, he stands in the open next to the box),
   `--cover` the AFTER. Flags `--ppm`, `--view=top|tilt|tilt70`, `--stills=<ticks>`, `--out=<dir>`.
5. Render, same ticks before and after, to `C:/Users/kazda/kiro/gtai-masters/n19/move/cover/`:
   - 32 px/m stills at top, tilt 55, tilt 70: in cover with a guard's round stopping in the box (the round must
     be visible in the frame), sliding, peeking and firing, leaving;
   - 64 px/m close-ups at tilt 70 of IN at low cover and of PEEK;
   - a 32 px/m clip at tilt 70 and one at top of the whole course (10-40 s, mp4 h264);
   - labelled before|after sheets (`tools/film/vault_pairs.py` or a shared generalisation of it).
   Look at every image yourself and write an `INDEX.md` there like `../vault/INDEX.md`: say what you see in each,
   honestly (does the crate hide his body and not his head; can you tell which side the threat is; is the aim
   readable at 32 px/m).
6. Unit tests for `cover_view.gd` (crouch scale only at low cover IN, none outside cover, blends at snap/leave).

## Repo law (binding)
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`; `.uid` files. Do not edit
features/combat, features/city, native, goldens or digests. Stage per path; no stash, add -A or reset --hard;
never push; never stage JOURNAL.md. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
quick gate + lint clean; `run_unit.mjs --changed` and `--fast` green; the cover and vault scenarios green;
`node tools/dev/run.mjs cover_course ...` verdict line `ok exit 0; SCRIPT ERROR 0; unknown arg 0` (quote it);
the stills, sheets, clips and INDEX.md exist; `git status` clean.
