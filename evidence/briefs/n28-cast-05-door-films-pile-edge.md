# Brief n28-cast-05: door carrier films, pile-driver feet, impact-outline check (continues brief 02)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 20:15 local** (check `date` often): at the hard stop commit what is green, report and END.
**Start your first `git commit` by 19:40; start your last commit no later than 20:00** (the pre-commit hook takes ~12 min).
Never leave finished work uncommitted. If something is not green by 20:00, commit nothing half-made: leave it uncommitted,
list the paths in your report.

Read first, in full: `evidence/briefs/n28-cast-02-feet-door-pile.md` (the parent brief: Why, the bars, Films, the owned-file
ALLOWLIST, the FORBIDDEN list, Repo law, Report). Everything there binds this call, except its "Added 18:15" scope line
(that call, `89ac6ff8f`, did the door carrier's placement; read its diff and the n28 door section at the end of
`docs/art/cast-audit.md`).

Environment, every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**Never run `Godot_*.exe` directly** (not even `--import`): use `tools/dev/run.mjs`, the film tools, gate, mutate, or
`node -e` with `runGodot` from `tools/lib/godot.mjs`. One Godot process at a time. Rendering: `--rendering-driver d3d12`;
windowed: `--position 0,1440`. Kill only your own PIDs. Fold takes into as few Godot launches as possible (8 GB RAM cap shared
by the whole run; `mem-budget: waiting` is not a hang).

## Work, in this order (each part committed before the next)

### A. Door carrier evidence (its placement is already committed in `89ac6ff8f`)
1. `feet_door_before_after_64ppm_tilt70.png` in `C:\Users\kazda\kiro\gtai-masters\n28\cast\`: before (base `d0ab9d03a`, render
   it from a temp worktree: `git worktree add <%TEMP%>/gtai-cast-base d0ab9d03a`, remove it afterwards with
   `git worktree remove`) left, after right, same tick and zoom, right facing, sole dots per rendered frame, contact bracketed.
   If a before render from the temp worktree is impossible in time (it has no native DLLs or import), say so and use the
   numbers table instead of a picture; never fake the before.
2. One clip `feet_door_32.mp4`: the door carrier walking across a metre grid at 32 px/m tilt 70, right and down-right, with a
   64 px/m inset of the feet if the existing tool supports it; true **1920x1080, 60 fps, 15-40 s** through the scratch-project
   path of `tools/film/cast_foot_films.mjs` / `cast_gunner_films.mjs` (Movie Maker ignores `--resolution`; never edit
   `project/project.godot`). `ffprobe` it. Look at at least 4 extracted frames yourself (slab intact, shove pose, no gaps).
3. `frames.json` there: append valid entries (JSON array, best first among the cast items is the gunner; put door after them).
Commit any tool/scene change (new film tools only under `tools/film/`, dev scenes under `project/dev/cast/`).

### B. Pile-driver (`war_machine`) feet, timeboxed to 25 minutes of work
Its card is `enabled: false` (the wave draws an enlarged thug rig) and stays off. Plant the card's walk the way `89ac6ff8f`
planted the door carrier (a `CastPileAnchors`-style table from its shipped walk sheets via a `tools/art/cast_*_soles.py`
measurement, one STEP_M giving 5-10 drawings/s at its 1.8 m/s). **Do not enlarge it**; report its on-screen height at 32 px/m
beside Rivet (77 / 75 px). If its drawings show no identifiable lift in a facing (the n26 audit said its 70 profile has
none), say so with a still `pile_lift_70.png` and the numbers, and do not wire a placement that cannot pass: record "Feet
FAILS: no lift drawn, needs new art" in `docs/art/cast-audit.md` (title the section n28). Numbers before/after: sole / body
jump, right and down-right, 70 and 55, plus turn and reversal jump. List what else on its checklist still fails. Commit.

### C. Impact-outline check (lane item 4), one measured answer
Does the shared impact-outline material draw dark teeth on other cards' HITS at 64 px/m (it did on Mulroney's; `af94f1c6e`
cleaned his cut)? Render a 64 px/m hit frame (during the impact pulse) and the same pose without the pulse for the patrol cop,
riot, SWAT, lancer, door carrier, the warden and the gunner, in ONE Godot launch if the harness allows (start from
`project/dev/cast/` poses/rim scenes the gunner calls used: `git log --oneline -15 -- project/dev/cast`). Measure dark pixels
outside the silhouette per card with `tools/art/cast_mulroney_edge.py` (or its method). Write the table in
`docs/art/cast-audit.md` (section "Impact outline, n28") with pulse / no-pulse per card. Deliver `impact_edge_64.png` (the hit
frames side by side at 64 px/m). If a card shows teeth, fix it the way Mulroney's was fixed (card material path,
`CastCards.painted_ink`), only if it is a card-path file on the allowlist; a fix in the shared impact material itself is a
NEED (write it in your report). If none show teeth, say so with the numbers. Commit.

### D. Only if time remains before 20:00: gunner mutate
`node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_gunner_card_view.gd --max=20 --tests=test_cast_gunner`
(with a 12-minute budget: stop it if it runs over). Quote killed/(killed+survived). Then
`node tools/mutate/mutate.mjs --file=project/features/characters/cast_door_anchors.gd --max=20 --tests=test_cast_door_walk`
if time remains (a data table: survivors on data lines are expected; say which).

## Checks before each commit
`node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs --files=<your changed files>`. Known: on this
machine `quick.mjs` --check-only on `project/features/characters/*.gd` can FAIL with "Failed to compile depended scripts" even
on files unchanged since `main` (a check-only cascade, not this branch). If you hit it, show that `death_pose.gd` fails the
same way, rely on GUT + the pre-commit hook, and say so. **Fix lint and format findings in your own edit and go on.**
If the hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run an `--import` through
`runGodot` and commit again; never skip the hook. No amend, no rebase, never push, staged per path.
No behaviour, speed or timing change: rendering only. No image generation. Never fake a number or a frame; unmeasured is
never zero. Builders claimed things about frames tonight that were false: look at every frame you deliver and describe it.

## Report (then END)
Commits (sha + subject); A: film paths + ffprobe lines + what you saw in 4 frames; B: STEP_M, drawings/s, sole/jump
before/after, turn/reversal, height at 32 px/m, verdict, what else fails; C: the per-card table and verdict; D: mutate
scores; quick gate line; what is left uncommitted (paths) and why.
