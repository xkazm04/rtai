# Builder n31-melee-02p3 (opus): choose the sweep geometry from the clean pixels, pass the bars, flip it on

Read `evidence/briefs/n31-common.md` first (binding), then `evidence/briefs/n31-melee-02-sweep.md` (rule, bars) and
`evidence/n31-melee/02-sweep/{reach,guard,mutate}.md`. Tag `02p3`. HARD STOP: commit each part by 25 min into the
call; report and END 55 min after launch. Commit with `git commit -- <paths>`.

## State (end of session 2)
- `--melee-sweep` (off) = sweep over the drawn cutting ticks, struck once per hit; with the flag the swing rows'
  `sweep_reach_m` / `sweep_lunge_ticks` / `sweep_recovery_ticks` replace reach / lunge / recovery
  (`MeleeHit.adopt_sweep`). Provisional: baton 1.5, katana 1.8 (+ lunge 4), plasma 1.9, claw recovery 18.
- Guard rail flag on (kills/swing vs before, bar +-15 %): claw +9.9 PASS, baton -2.2 PASS, plasma -11.1 PASS,
  chainsaw +19.4 ABOVE, katana -25.7 BELOW.
- Clean drawn volume from 01d: `evidence/n31-melee/01-volumes/before/drawn_ticks.json` (`deg_p5_p95`, `reach_p95`
  per tick; read the bulk fields, not min/max) and, if 01d finished it, the after on HEAD with the flag in
  `evidence/n31-melee/02-sweep/volumes/`. CHECK the overlays (`overlay_clean_*`) before trusting a number.

## Parts
1. Geometry from the drawing: per weapon set `sweep_reach_m` = the clean drawn reach (p95 over the cutting ticks)
   minus the 0.45 m body radius if the table field is to the body's edge (check `MeleeSweep.crosses`), and the arc
   from the drawn angle range (if `MeleeSwing.angle`'s sweep differs from the pixels' `deg_p5_p95` over the cutting
   ticks by > 10 deg, add a per-weapon `sweep_arc_deg` read with the flag). Plasma: its hit cone today reaches
   sideways where nothing is drawn (01c: 10 hit-not-drawn) - the sweep's sector must follow the drawing.
   Katana: the pixels read it longer than 1.8 m; expect ~2.5. Table: weapon, before reach/arc, drawn, chosen.
2. Chainsaw guard: the +19 % comes from the sweep catching more bodies over ticks 9..14 before the grind; recovery
   raises kills/swing. Choose ONE lever and DECISION it: the saw's sweep window ends at its first bite (it grinds
   what it caught, it does not keep sweeping), or `sweep_reach_m` from the drawing. Re-run the guard for
   chainsaw + katana (+ any weapon whose reach moved): `node tools/melee/play_baseline.mjs --label=after-sweep-2
   --sweep --weapons=<...> --out=evidence/n31-melee/02-sweep`. Bars +-15 %.
3. Volumes after: `node tools/melee/blade_volume.mjs` per 01d's re-run command with the flag; table before | after
   + polar sheet side by side in `evidence/n31-melee/02-sweep/volumes/`. Bars: drawn-no-hit 0 inside the cutting
   ticks (standing ring), mover <= 5 %, hit-not-drawn <= 5 %. If a weapon misses, say by how much and why.
4. Only if 1-3 pass: flip the default ON (`--melee-sweep=off` restores the before; keep the old flag accepted),
   run `node tools/tests/run_scenarios.mjs` (allow 20 min) and `node tools/tests/run_unit.mjs`, re-pin each moved
   digest once with ONE dated `docs/decisions.md` line naming item 2 and the digests. Quest 1 script + native
   parity must not move (if they do: stop, revert the flip, report).
5. Mutate survivors (`evidence/n31-melee/02-sweep/mutate.md`): add tests that kill the cut window's first tick and
   the state byte; re-run `node tools/mutate/mutate.mjs --file=project/features/player/melee_sweep.gd --max=20
   --tests=test_melee_sweep`; quote the score; remove the temp worktree it leaves if it is yours.

## Session 3 window (launch ~00:08): parts 1-3 ONLY, no flip in this call
Commit part 1+2 by 00:35, part 3 by 00:45, report and END by 00:50 (the session dies at 00:57: uncommitted work is
lost). Parts 4-5 are the next call. Inputs: 01e's body-free numbers (commits after ffedbbe48 touching
`evidence/n31-melee/01-volumes/` and `02-sweep/volumes/`, `after.md`, `before_after.png`, `drawn_ticks.json`):
read `git log --oneline -8` and those files first; use 01e's mask rule for part 3. Guard rail runs
(`tools/melee/play_baseline.mjs`) and blade_volume runs each take the lane Godot lock; another builder may hold it
(item 4 audit, Godot-free, should not). Keep the reach choice explainable in ONE table row per weapon.
Chainsaw: prefer the lever "the sweep window ends at its first bite" (the saw grinds what it caught) - DECISION it
in `docs/decisions.md` (one line, `- [2026-11-25] DECISION melee n31 ...`) only if the guard passes with it.
