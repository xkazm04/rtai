# BRIEF: lane n12-visual (visual quality of the engine and of combat), night 2026-11-09/10

Owner's words: "brainstorm 10 ideas how to improve visual quality of the engine or combat ... lets pick
all, execute in your recommended order during this night, in one new branch using one Opus builder."

You are the one builder. The Director (the session that dispatched you) reviews each group's diff and
sends you the next group. The owner is asleep: nobody answers questions tonight. Where a call is the
owner's, take the conservative default, keep a before flag or data value, and list it under "Calls for
the owner" in the REPORT.

## Where you work

- Worktree `C:\Users\kazda\kiro\gtai-wt\n12-visual`, branch `n12-visual`, cut from main `812a0b061`.
  Never touch `C:\Users\kazda\kiro\gtai` (main checkout) or the other worktrees (`n11-*`, `int-day`,
  `scratch-*`, `codex/*`): other lanes may be live in them.
- The native DLLs are already copied into `project/native/bin/` (git-ignored). You still need, once:
  a `--import` (a fresh worktree's first import takes about 5 minutes; a 300 s timeout is not a failure,
  run a plain import first) and `dev/bake_city.gd` (the baked chunks are git-ignored).
- Do not merge to main, do not push, do not delete branches. The owner reviews `n12-visual` in the morning.
- Films and stills go to `C:\Users\kazda\kiro\gtai-masters\n12\visual\` (create it), with a `frames.json`
  index like `gtai-masters\n7\ranged\frames.json`. Scratch films go to `build/` or the OS temp dir.
- Records, both in `docs/night/2026-11-09/visual/` (inert for the evidence scope): `JOURNAL.md`, appended
  after every iteration (what you tried, the command, the number, the commit), and `REPORT.md` at the end
  of each group, in the shape of `docs/night/2026-11-05/ranged/REPORT.md` (what works with its evidence,
  what was tried and dropped, calls for the owner). Keep the JOURNAL current enough that you could resume
  from it alone after losing your context.

## Read first

`AGENTS.md` and the sections of `STANDARDS.md` it points at (GIT, GDS, ARC, DAT, SIM, section 20),
`project/core/render/README.md`, `project/features/combat/hit_feel/README.md`, `docs/polish/ranged.md`
and `docs/polish/melee.md` (the 0-3 rubric and how a change is evidenced),
`docs/backlog/combat-notes-2026-11-04.md`, the last 60 lines of `docs/decisions.md` (the n10 perf loop:
how a gain is measured here, in CPU seconds with an A/A control), and
`docs/night/2026-11-05/ranged/REPORT.md` as the model for your own report.

## Law for every package (a package that breaks one is not done)

1. **Audit before you build.** Earlier lanes shipped a lot. For every package, first find what exists,
   film it, and score it. If the idea is already there, say so with the file and the film and spend the
   time on its weakest measured cell instead. Known already: `hit_feel.json` has per-class rows AND
   per-weapon overrides with `FeelCam`/`FeelBudget` (idea 3 is mostly shipped); the Gatling and its
   spin-up exist (part of idea 8); the n10 lane did a perf loop on the riot (part of idea 10).
2. **View only.** Nothing you add may change the sim: parity stays bit-exact, replays identical, no sim
   code reads view state, no global RNG, no frame delta outside `World._process` (take an rng stream or a
   tick hash for visual jitter). Run `node tools/tests/run_parity.mjs` when you touch anything near the seam.
3. **Zero at rest.** A new shader uniform or effect is exactly neutral when idle, so the golden look
   frames (`tests/golden/look/`, `dev/selftest/look_golden.gd`) do not move. If a golden must move, that
   is an owner call: do not re-bake goldens tonight, put the effect behind its data value at 0.
4. **Data, not constants.** Tuning goes in a JSON table with its schema (a new key in every row where the
   schema demands it). Every change has a before: a boot flag declared in the entry's `KNOWN_FLAGS`, or a
   data value that restores the old picture.
5. **The colour rule.** Red/vermilion is blood and Rivet's danger only, teal is the souls only, police are
   blue. No new hue enters the print without being a plate that already exists.
6. **Budgets.** Shakes, stops, kicks and flashes go through `FeelBudget` / `flash_budget.gd`; lights through
   `light_pool.gd`; fx through `fx_pool.gd`; draw order through `RenderLayers`. Reduced motion and
   `--feel=off` switch off everything that moves or flashes the frame. No full-screen flash faster than
   the flash budget allows (photosensitivity).
7. **Perf is measured, not assumed.** Each package that adds per-frame work is measured on the riot / city
   fight before and after with the n10 instrument (A/A control). A package that costs more than 0.15 ms
   frame p50 at combo, or adds a frame over 25 ms, is cut back or left behind its flag defaulted OFF, with
   the figures in the REPORT. Section 20 hard limits are never crossed.
8. **Evidence.** Each visible change gets an A/B film at 32 px/m (and 48 where it matters) from the same
   build, named in `frames.json`. Score the rubric cell before and after; an unfilmed cell is `?`. Look
   at your own frames (read the stills) before claiming a score. Run `node tools/evidence/cites.mjs` on
   the REPORT.
9. **Gates before every commit**: `node tools/lint/lint.mjs`, `node tools/tests/run_unit.mjs --changed`
   (the full `run_unit.mjs` and the scenarios at the end of each group), the debt ratchet. For a logic
   file you changed, run `node tools/mutate/mutate.mjs --file=...` before claiming its tests bite. New
   logic gets a unit test. Record the gates' state on arrival FIRST (lint, unit `--fast`, scenarios) in
   the JOURNAL: a gate that is red before you start is reported, not inherited.
10. **Git.** Stage per path, one commit per landed change, message in the repo's style, ending with
    `Co-Authored-By: Claude Opus <noreply@anthropic.com>`. No `add -A`, no stash, no `reset --hard`.
    A change that fails its acceptance is reverted with `git revert` or never committed, and journalled.
11. **Size.** GDScript files about 200 LOC (hard 300), functions 40 lines, typed, `Log` not `print`,
    `Loc.t()` for any text. Features do not name `dev/` or `tests/` classes.
12. **Stop rules.** Two iterations on one cell without a measured or visible gain: write it down and move
    on. A package blocked on something only the owner can give (an art pick, a golden re-bake, a new
    addon): do the part that is not blocked, list the call, move on. Never guess a figure into the REPORT.

## The groups, in order. Return to the Director after each group with the report below.

### Group A: headroom first (idea 10)
- **A1. The city fight's frame.** Reel chapter 18 (the city block fight) lagged: aggregate p99 8.79 ms,
  1 % low 74 fps, worst frame 424 ms at r19, r16 was 8.52 ms / 88 fps, never bisected. Reproduce on today's
  head with a clean run (`project/dev/bench/` has `fight_frames.gd`, `quest1_frames*.gd`, `city_bench`;
  `tools/bench/run.mjs`; the run ledger tells you if the machine is contended). If it is already fixed by
  the n10 loop, show the figures and stop. If not: find the worst frames' cause (`node_spans.gd`, the hitch
  log) and fix the top one or two, each kept only on a measured gain.
- **A2. A fight frame gate.** A repeatable "combat frame" measurement the later groups (and future lanes)
  run in one command: the city fight and the arena horde at combo, reporting frame p50/p99, worst frame,
  frames over 25 ms, with the A/A noise floor printed beside it. Reuse the existing bench and evidence
  plumbing; if `tools/evidence/run.mjs` can carry it as a kind without lengthening the default run past
  reason, add it, else leave it a dev command and say why.
- Acceptance: baseline figures for both scenes are in the JOURNAL with the noise floor; the gate command is
  documented in AGENTS.md's command table (one row); the worst-frame cause is named with evidence or the
  miss is shown not to reproduce.

### Group B: the hit itself (ideas 3 and 4)
- **B1. Victim sync (idea 4).** Every weapon's victim reacts on the hit frame (0-2 ticks), along the hit.
  Known late: the homing shard (reel chapter 14: shard flight + `ReactLink` queue + the burst kill). Known
  weak: the human's reaction when struck and when killed by the electro gun and by the plasma rifle
  (backlog items 1 and 4). Measure the tick gap per weapon in the arena first (a table of weapon, hit tick,
  first reaction tick), fix the ones over 2.
- **B2. Per-weapon camera grammar (idea 3).** The table exists. Fill the gaps: any weapon still riding its
  class row where its neighbour of the same class reads differently, and one new dimension if the audit
  shows it is missing and it reads at 32 px/m: a zoom punch (data keys in `hit_feel.json` + schema, through
  `FeelBudget`, off under reduced motion and `--feel=off`). Do not retune rows the owner approved unless a
  rubric cell is below 2.
- Acceptance: the sync table before/after with every weapon at 0-2 ticks or its reason; the Victim sync and
  Impact cells of `docs/polish/ranged.md` and `melee.md` updated with films; parity bit-exact.

### Group C: the print answers the hit (ideas 1 and 2)
- **C1. Ink line weight on impact.** For a few ticks after a hit the ink outline of the struck figure (and,
  for heavy/blast, a radius of the world print around the hit) thickens and wobbles, scaled by the damage
  class. Find the right seam first: `look_noir_impact.gdshader`, `impact_frame.gd`, `look_d5*.gdshader`,
  `look_d4_item.gdshader`, `print_part.gdshader`. Per-class amounts in data.
- **C2. Plate misregistration shock.** A blast (mini-nuke, rocket, a car kill, a boss slam) kicks the
  vermilion/teal plate shifts that `look_profiles.json` already carries, then they settle back in a few
  ticks. It must respect the colour rule (the shift moves existing plates, it invents no colour), the flash
  budget and reduced motion.
- Acceptance: goldens unchanged at rest (the selftest passes untouched); A/B films for light, heavy and
  blast; cost measured with A2's gate; both effects default ON only if they pass law 7, else OFF with figures.

### Group D: reading the fight (ideas 7 and 8)
- **D1. Occlusion and depth (idea 7).** The player always sees the fight: audit `city_occlusion.gdshader`,
  the reserved `roof_occluders` band, `cast_shadow.gdshader`, `noir_figure_shadows.gd`. Film a fight beside
  and under tall geometry in the top-down and the angled view (`features/view_pitch`). Fix the worst case of
  a hidden fighter or a floating figure (a missing contact shadow). The n10 lane moved the crowd occlusion
  scan to C++: do not undo it.
- **D2. Melee holds, swings and the plasma sword (idea 8).** Backlog items 2 and 3: how Rivet holds and
  swings the katana, chainsaw, electro baton, plasma sword and claw: anticipation, a swing smear along the
  arc, a settle. Score `docs/polish/melee.md` first and work weakest first. The plasma sword's asset: improve
  it with the repo's own art pipeline (`docs/art/weapons.md`, `tools/art`, `art_src/`) if that pipeline
  can produce it offline; if a better asset needs a generator you do not have, leave the shipped asset, put
  up to three candidate treatments (shader or drawn) in masters as stills, and make it a call for the owner.
  Never commit an asset without its provenance line (`docs/provenance.md`).
- Acceptance: before/after films per weapon touched; rubric cells updated; no new texture over the section
  20 limits; `.import`/`.uid` files committed with their sources.

### Group E: the street joins in (ideas 5, 6, 9), each only if A2's gate shows the headroom
- **E1. Light from combat (idea 5).** Muzzle flashes, plasma, arcs and fire light nearby walls, bodies and
  the ground through `light_pool.gd` / `light_layer.gd` (see `noir_lamps.gd`, `noir_headlights.gd`,
  `noir_combat_fx.gd`, `muzzle_flash.gd` for what is lit today). A pool cap in data; the nearest N win.
- **E2. Battle residue (idea 6).** Scorch, casings and drag marks stay after a fight, in a bounded ring
  (`corpse_stains.gd`, `blood_decals.gd`, `blood_marks.gd`, `stain_cover.gd`, `kill_marks.gd`,
  `corpse_scorch.gd` show how blood does it and how it is batched). Oldest fade first; a hard cap in data.
- **E3. Crowd panic that ripples (idea 9).** The street reacts in a wave from the shot outward: a flinch,
  a look toward the gunfire, then the scatter (`crowd_react.gd`, `city_scare.gd`, `near_miss.gd`,
  `stun_crowd.gd`, `crowd_atlas.gdshader`). View only: the sim's panic is not changed, only how the baked
  crowd shows it. If the picture needs the sim to change, stop and make it a call.
- Acceptance per item: A/B film in the city block; the gate's figures before and after; default ON only
  inside law 7.

## What you return after each group (your final message, plain text, no file dump)

1. Commits (sha + one line each) and the branch head.
2. Per package: shipped / already existed (file + film) / partly / dropped, with the one figure or rubric
   cell that proves it, and the film name.
3. Gates at the group's head: lint, unit (full), scenarios, parity, debt: pass/fail with counts. A failure
   you did not cause is named as inherited with the arrival figure.
4. Perf: the gate's before/after for the group.
5. Calls for the owner, each with the default you took and the flag or value that reverses it.
6. Anything you were unsure of, or measured against your own expectation. If a claim in this brief turned
   out wrong (a file that is not what the brief says, an idea that cannot be view only), say so: the brief
   was written from a light read of the tree and your measurement outranks it.

Start with: import, bake, the gates on arrival, then Group A. Stop and return when Group A is reported.
