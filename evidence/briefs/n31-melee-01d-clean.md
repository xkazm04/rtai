# Builder n31-melee-01d (opus): clean the pixel mask to the blade, then the after on HEAD

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `01d`. Your files: `project/dev/melee_n31/blade_*`,
`tools/melee/blade_volume*`, their tests, `evidence/n31-melee/01-volumes/**`, `evidence/n31-melee/02-sweep/volumes/**`.
HARD STOP: commit each finished part by 25 min into the call; report and END 55 min after launch.

## Why
01c (commits 79f704a3a..e728966ae) measures the drawn swing from rendered frames; the overlays sit on the blade and
the swipe (director looked: katana smear, claw slash, baton). But the before's drawn-no-hit (claw 13, saw 27, baton
21, katana 19, plasma 19 of 60) is inflated: in `before/sheet.png` the vermilion cells crowd AROUND and BEHIND Rivet,
where no blade is drawn. Causes 01c named: (1) Rivet's own moving body (strike arm, lunged torso, head) is in the
mask; (2) stray arena-motion blobs ~3.3 m behind him and a comb of bars up-left (katana, plasma); (3) repeated
identical masks over several ticks (baton k 2..6: pose hold or a stale frame read - resolve which).
The owner's complaint is the blade passing through a body: the measure must count the BLADE AND SWIPE only.

## Build
1. Mask = blade + swipe + smear only. Pick the cleanest of, and say which and why:
   (a) per tick, a reference render with the weapon/swipe/smear layers hidden (held weapon, swipe view, smear) so
       the diff isolates them - for strip weapons (katana, plasma, saw drawn inside Rivet's d9 strip cell) this does
       not work alone; for those
   (b) per tick, render Rivet's body silhouette of THAT tick (e.g. the same strip cell drawn with only the body
       part, or the frame with the cell hidden vs shown) and keep mask pixels outside it dilated 4 px; plus
   (c) keep only connected components that touch the weapon's grip region / Rivet's silhouette (drops blobs).
   Fix the repeated-frame issue if it is a stale read (wait a frame after setting the tick, or force a draw).
2. VALIDATE by looking: overlay frames for all 5 weapons at the hit tick +1 AND at the last cutting tick, outline on
   the blade/swipe only, not on his head or torso. Save `overlay_clean_<weapon>_k<k>.png`. Say what you saw.
3. Re-run the before (temp worktree at `ba8e470b0`, as 01c did; remove it after) -> replace
   `evidence/n31-melee/01-volumes/before*` (01c's version to `before-01c/`). Then the AFTER on HEAD with
   `--melee-sweep` (the sweep built in 02p2: `project/features/player/melee_sweep.gd`; hit side needs the flag in the
   hit probe too: `--model --label=after-model` with the flag passed, then the pixel run with
   `--hits=...after-model`) -> `evidence/n31-melee/02-sweep/volumes/`. Table before | after: drawn-no-hit (all /
   inside the cutting ticks), hit-not-drawn, mover drawn-no-hit, per weapon; polar sheet before | after side by side.
   Bars (judged by the director): drawn-no-hit 0 inside the cutting ticks (standing ring), mover <= 5 %,
   hit-not-drawn <= 5 %.
4. Write `drawn_ticks.json` again (bulk `deg_p5_p95`, `reach_p95`) from the clean mask for both.

## Rules
- Before killing ANY PID: print its CommandLine and kill only if it names this worktree (`n23-street`) or your own
  tool. Never by name.
- Another builder (`03`, fatalities) may share the lane's Godot lock: batch renders, do Godot-free work while waiting.
  Do not touch player_melee.gd / melee_sweep.gd / melee tables (if the after shows a gap, REPORT it with numbers;
  the director sends the fix to a sweep builder).
