# Brief 01 (lane anim, tag farcop): far city cops drawn as the wrong ped

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Run `node tools/gate/quick.mjs` before each commit.
- File ownership: lane anim owns `project/features/characters/**` (except Rivet's gun/muzzle/magazine views) and
  `tools/art/**` for them. You MUST NOT edit `project/features/city/**`, `project/features/police/**`, `native/**`,
  or any sim/replay/parity/bake digest. If such a change is needed, write it up (exact file, line, change) in your final
  report and I will pass it to the owning lane.
- Do not move any sim, replay, parity or bake digest. Look goldens: only re-bless one whose frame really contains the
  changed pixels, and name it in the commit message.

## The suspected fault
Every city foot cop carries art variant 7 (`ART_COP` in the sim spawner; the GDScript reference sim is under
`project/features/city/sim/`, find the constant with grep). `boot/city_characters.gd:~99` passes `sim.get_variants()`
to the rig feed; `RigFeed.look_of(i)` returns 7 for a cop. Two draw paths:
- Full rig (16 nearest, `project/features/characters/character_rigs.gd` `_acquire`, ~line 194-196): builds
  `RigVariant.crowd(look)`, and when `look.kind != kind` falls back to `RigVariant.crowd_index_for(feed.ids[i], kind)`.
  So near cops are fine.
- Baked crowd (LOD-1, `character_rigs.gd` `baked_cell`, ~line 135): `CrowdAtlas.cell_for(feed.look_of(i), clip, t)`,
  which maps through `RigVariant.atlas_look(7)` = 7 = atlas row of the overalls-bald PED. No kind fallback. So a cop
  beyond the 16 nearest rigs may draw as a civilian. Traced in code by the police lane
  (`docs/day/2026-11-17/police/REPORT.md` lines 40-47), never confirmed by eye.
- The sim's own native render path (`native/.../render.cpp` `frame_of`, `sim_render.gd`) probably has the same bug.
  That is the gfx lane's: do not edit it, only find and describe it.

## Do, in order
1. **Probe first, before any fix.** Build a dev probe (under `project/dev/`, e.g. `project/dev/probe/far_cop_rows.gd`,
   or an env/flag-gated hook in an existing dev runner — your choice, keep it out of release code paths) that runs the
   city at heat 3 with a crowd and, for every row drawn by the baked crowd layer whose kind is COP, logs: tick, actor id,
   kind, `look_of`, the atlas row actually drawn (cell // FRAMES_PER_LOOK), and whether that row's `RigVariant.crowd(row).kind`
   is COP. Write the result as JSON to `evidence/farcop/probe_before.json` with a summary count
   `{cop_rows_baked, drawn_as_ped, drawn_as_cop}`. Also count how many cops the native/sim render path draws and with
   which frame row, if you can read it from GDScript without touching gfx-owned files.
   Find how the police lane got heat 3 (look at `docs/day/2026-11-17/police/REPORT.md`, `tools/film/shots.mjs`,
   `tools/bench/run.mjs --heat`, and the launch flags in `project/boot/launch_args.gd`).
2. **Film before**: a heat-3 city film at **16 px/m** where far cops are in frame (use `tools/film/film.mjs` if a shot
   or flags allow zoom 16 and heat 3; otherwise the smallest dev runner that does). Stills at 2-3 ticks with far cops;
   crop/annotate (script, not by hand) at least one still that circles a far cop. Output to
   `C:/Users/kazda/kiro/gtai-masters/n19/anim/farcop/before/`.
3. **If the probe shows drawn_as_ped > 0: fix the GDScript half** in `project/features/characters/character_rigs.gd`
   (or `crowd_atlas.gd`): the baked path must use the same kind fallback as `_acquire`: if the look's body plan kind
   differs from the row's kind, use `RigVariant.crowd_index_for(feed.ids[i], kind)`. Put the decision in ONE shared
   helper that both paths call (e.g. a static `RigVariant.look_for(look, id, kind) -> int`) so they cannot drift.
   Also check the crowd baker / readback / any other place that maps `look_of` to an atlas row (grep `look_of`,
   `atlas_look`) and route them through the helper too.
4. **Unit test** (first-author, `project/tests/unit/test_far_cop_look.gd` or extend an existing rig test): a feed row of
   kind COP with look 7 yields a cop atlas row in `baked_cell`, and the full-rig path and the baked path pick the SAME
   look for the same actor. Also a ped row with look 7 still draws the overalls-bald row (no regression).
5. Re-run the probe -> `evidence/farcop/probe_after.json` (drawn_as_ped must be 0). Film after at the same seed, tick and
   zoom -> `C:/Users/kazda/kiro/gtai-masters/n19/anim/farcop/after/`. Make a side-by-side before/after still (script) at
   16 px/m and one at 32 px/m. Also a 10-40 s clip at 32 px/m (mp4) of the heat-3 street.
6. Run `node tools/tests/run_unit.mjs --changed`, then `node tools/gate/quick.mjs`, then commit (probe, fix, test as
   separate commits if clean). Then `node tools/mutate/mutate.mjs --file=features/characters/character_rigs.gd --lines=<the changed lines>`
   (and on the helper file) and quote killed/(killed+survived).
7. Write `evidence/farcop/NEED-gfx.md`: the exact native change (file, function, line, what to change) that gives the
   sim's own render path the same kind fallback, with the probe numbers as evidence. Do not edit native.

## Acceptance (I will check each)
- probe_before.json and probe_after.json exist with the counts; the before/after stills at the same tick and zoom;
  the unit test fails on the old code (say how you verified that) and passes on the new.
- `run_unit.mjs --changed` green, quick gate green, mutate score quoted.
- No file outside lane anim's ownership edited (besides a new dev probe under `project/dev/` and a `KNOWN_FLAGS` line
  if you truly need a new flag: append one line only).
- If the probe shows the fault is NOT real (all far cops drawn as cops), stop after step 2, commit the probe, and say
  why with numbers.

End your report with: files changed, commits (sha + subject), commands run and their result lines, frame paths.
