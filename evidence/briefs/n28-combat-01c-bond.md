# Brief n28-combat-01c-bond (fresh, continues 01b): commit Tonnage's bar 85 + Kerf cut 5, the n28 ten-seed table, mutate, the bond film

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP 19:05 (wall clock): write your report and END, even mid-task. Commit part A by 18:35.** Never stop to ask: at a
fork pick what best serves the owner's words, write it in your report, go on. Fix lint and format findings in your own
edit and go on. No amend, no rebase, no push.

Read `evidence/briefs/n28-combat-01b-bond.md` first: its Why, Contract, Checks, Repo law and Allowlist all bind you. This
brief replaces its "State" and "What".

## State
- The per-form bar code, data, schema and tests (part A of 01b) are written and UNCOMMITTED in this tree; the director
  reviewed them: correct. `ghost_forms.json` still holds the probe value `"tonnage": 999`.
- The probe (part B.1) is DONE: `build/n28/probe/probe-<1..10>.json` (+ `log-*.txt`, all `ok exit 0`). Tonnage's bond per
  rest (waves[i].bond.tonnage, i = rest-1): seed 1 `0,12,32,48,52,64,80,120,120`; seed 2 `0,24,48,60,64`; seed 3
  `0..0,12,24,36`; seed 6 `...,4,20`; seed 8 `0,0,12,40,44,44,52,60,104,104`; seeds 4,5,7,9,10 at most 8. Max at rest 7 =
  80 (seed 1). **Chosen value: 85** (smallest multiple of 5 strictly above 80). Expected: seed 1 masters Tonnage at wave
  8, seed 8 at 9. Kerf (bar 30, cut 5) reaches 30 at rest 10 on seed 5 in the probe.
- `evidence/n28/bond/summarize.mjs` and `report.mjs` were already adapted by the previous call (check them; finish them).
- The machine had room at 18:00 (cap 3.6/8 GB). For headless runs `export GTAI_GODOT_EST_MB=600`; renders `1000`. One seed
  of bond_measure takes about 15 s.
- Every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.

## What, in order
A. Set `"tonnage": 85`. Fix the doc phrase if it still says Tonnage "stops mastering at wave 3" (it should read "so
   Tonnage's first mastery comes later"). Run `node tools/tests/run_unit.mjs --changed` and
   `node tools/tests/run_unit.mjs --select=test_gauntlet_mastery,test_bot_pick_mastery,test_ghost_boss_cut,test_ghost_bond,test_ghost_bond_ring`,
   then `node tools/gate/quick.mjs`. Append ONE line to `docs/decisions.md`:
   `- [2026-11-24] DECISION n28 combat: bond.master_at_by_form.tonnage = 85 (his bond at rest 7 was 80 at most on the ten seeds of evidence/n27/bond/mastery.md, probe arm with his bar out of reach, so his first mastery comes at rest 8 or later); master_at stays 30 for Dent, Kerf, Ohm (owner: keep 30 and play first); per_boss_cut 3 -> 5 (owner). Rejected: a higher master_at for all (n27: it only dropped the late masteries).`
   Stage per path (the 9 modified files + decisions.md) and commit. The hook takes up to ~12 min; if it fails on
   `tools/film/kill_reel_*.break.test.mjs`, run a headless Godot `--import` and commit again. Never skip the hook.
B. The n28 arm on the committed tree: seeds 1..10 exactly as the probe (`node tools/dev/run.mjs res://dev/ghost-forms/bond_measure.tscn --fixed-fps=60 --bot=average --pick=greedy --seed=<n> --waves=15 --mastery-free=1 --result=<abs path>`; check `build/n28/probe/run-1.txt` for the exact command the probe used and match it), results to `build/n28/arm/`.
   Copy the probe JSONs and the n28 results into `evidence/n28/bond/runs/` (small JSON, commit them).
   Write `evidence/n28/bond/mastery.md` + `mastery.json`: a table n27 (the free arm of `evidence/n27/bond/mastery.json`)
   beside n28: runs with a mastery, first-mastery waves, which ghost, first masteries inside waves 8..15, Kerf mastered
   (and at which wave), Kerf's bond at the end and his boss cuts per seed; plus the probe's Tonnage bond per rest per seed and
   the rule that chose 85. Say plainly if the result differs from the expectation (seed 1 wave 8, seed 8 wave 9). Commit.
C. Mutate: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond.gd --max=20 --lines=<the changed lines> --tests=test_ghost_bond,test_ghost_bond_ring,test_ghost_boss_cut`
   (budget 15 min; stop it past that and say so). Quote killed/(killed+survived) and each survivor in
   `evidence/n28/bond/mutate.txt`. Commit.
D. Film (start by 18:45 at the latest, else skip and say so): as `evidence/n27/films/films.md` and
   `evidence/n27/films/render_bond.mjs` describe (entry `project/dev/ghost-forms/bond_film.tscn`, seed 2,
   `--bond-prefill=6`), 32 px/m, 1920x1080, 60 fps, 15-40 s, to
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/bond_mastery.mp4`, plus a 64 px/m still of the HUD chip strip with
   Tonnage's ring partly filled: `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/bond_chips_64.png`. Renders use
   `--rendering-driver d3d12`, windowed at `--position 0,1440` if windowed. `ffprobe` each and quote the line. Look at the
   frames (Read the PNGs): the ring fills against his bar; the chip numbers 1 to 4 read. Start
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (array of `{file,title,ppm,before,note}`; `before` =
   `C:/Users/kazda/kiro/gtai-masters/n27/melee/films/bond_mastery.mp4` if it exists, else null). Any render tool you write
   goes under `evidence/n28/bond/`.

## Report and END (short, as your final message)
Commit shas; the n27/n28 table (paste it); unit + quick gate lines; mutate score + survivors; film/still paths + ffprobe
lines; what failed or was left.
