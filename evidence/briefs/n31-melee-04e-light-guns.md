# Builder n31-melee-04e (opus, 30 min): light-gun hits that read on a body

Read `evidence/briefs/n31-common.md` (binding) and the audit `evidence/n31-melee/04-impacts/audit.md` (pistol,
machine_pistol, gloria, gatling: hit human 1, hit robot 1 - "a 0.12 m ink burst for 4 ticks, flash 4, kick 1 px,
no blood on a wound"). Read what 04d just committed (`git log --oneline -8`, its robot spark wiring in
`combat_blood.gd`) before you start: build on it, do not redo it. Tag `04e`. Launched ~02:57; commit by 03:18;
report and END by 03:24 whatever state (the session stops at 03:32 and kills you). `git commit -- <paths>`.
View/feel only: no damage, timing or hit rule; scenario/replay digests must not move (run
`node tools/tests/run_unit.mjs --changed` and the gun scenarios you touch, e.g. `--only=` names from
`tools/tests/run_scenarios.mjs --list` that mention gun/ranged, if one exists).

Owner: "Animations from weapons/projectiles and impact on enemies are inconsistent - some detailed and well
thought, some on surface done without care." Reference 3 for guns: the plasma rifle scorch (`PlasmaScorchView`).

Find the cause first (2 lines in the report): where a BODY impact is drawn (`gun_fx_rounds.gd:_impact` ->
`fx.impacts`, drawn by `gun_fx_marks.gd`), and why a wounded human shows no blood (`combat_blood.gd` reacts to
kills only). Then, ONE change, data-driven per gun (`gun_fx.json` rows or `hit_feel.json`), colour law: red is
blood only, white/cream sparks, amber for heat:
- a light round hitting a HUMAN body throws a small red flick: 2-3 drops along the round's direction that land as
  specks (reuse the blood spray code CombatBlood already has for kills, a small `kind`; a new `blood_fx.json` row
  is allowed), capped per victim (at most one flick per 6 ticks, so the gatling does not paint the street;
  write the cap as one value);
- the ink burst gets a 1-2 tick cream hot centre (bigger for gloria/gatling than pistol) so the hit point pops;
- on a ROBOT body the same hit throws 3-4 white sparks (if 04d's robot wiring already covers gun body hits, keep
  it and say so).
Bar: at 32 px/m tilt 70, a pistol hit and a gatling burst on a patrol cop each show a visible red flick and a
hot point; on robot thug A white sparks. Still at 64 px/m AND 32 px/m (extend `project/dev/melee_n31/marks_still*`,
which 04b/04d use; add a `--gun=<id>` path if it has none), Read the pngs and say what reads, BEFORE the commit.
Owned: `project/features/fx/combat_blood.gd`, `project/features/fx/noir/blood_fx.json` (one row),
`project/features/combat/weapons/gun_fx_*.gd`, `project/features/combat/weapons/gun_fx.json`,
`project/data/tables/hit_feel.json`, `project/dev/melee_n31/**`, tests for these. Anything else: NEED, stop.
Lane Godot lock with your tag; one Godot at a time (02p5 renders films beside you: keep your runs short). Fix lint
and format findings in your own edits. Mutate only if time remains: `--max=10 --lines=<changed> --tests=<subset>`.
If the cause shows the fix is bigger than 20 minutes: commit nothing half-done, write the cause and the plan in
`build/n31/04e/state.md` and report.
