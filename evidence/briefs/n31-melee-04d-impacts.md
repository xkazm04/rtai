# Builder n31-melee-04d (opus): impacts of one quality, round 2 - the plasma sear hot, metal on metal, the saw on a slab

Read `evidence/briefs/n31-common.md` (binding), `evidence/n31-melee/04-impacts/` (the 04a audit: scores and the
shared facts), and the 04b/04c commits (`git show --stat ca7009066 adb92f40b d3b9ed945`). Tag `04d`. HARD STOP:
commit each part by 25 min into the call; report and END 50 min after launch. Commit with `git commit -- <paths>`.
View/feel only: no hit rule, damage or timing changes; replay/scenario digests must NOT move (run the melee
scenarios you touch to show it).

Owner: "Animations from weapons/projectiles and impact on enemies are inconsistent - some of them detailed and well
thought, some on surface done without care." References for a 3: the claw rake marks, the plasma rifle scorch
(`PlasmaScorchView`), the saw grind.

Rule for every part: find the CAUSE first (read the shader / the draw / the event path and write it in 2 lines in
your report) before changing a value. Every part gets an in-game still at 64 px/m AND at 32 px/m tilt 70 beside
Rivet BEFORE its commit (`project/dev/melee_n31/marks_still*` exists from 04b: extend it, don't fork it); LOOK at
both stills (Read the png) and say what reads. Colour law: red is blood only, cops blue, vermilion only for danger
and Rivet's collar, teal only for souls, amber for fire, heat and electric current, white/cream for sparks.

## Part A: the plasma sword's sear reads HOT (director's look at 04c: a cream bar across the chest, no ember core)
Bar: at 32 px/m the sear's core is visibly amber/ember-hot (not cream, not vermilion) on at least the first 10
ticks, and cools to char; the katana's cut stays ink+cream. Suspected cause to check first: the print/ink pass
snapping an amber-ink blend to vermilion or cream (n30 combat's finding: any amber-ink blend snaps to vermilion),
or the core drawn in cream under a thin ember bloom. If the cause is in `project/core/render/**` (not ours): do
NOT edit it - draw the hot core so the pass keeps it (an unblended amber stroke above the ink, as the plasma rifle
scorch does: copy its colours and draw order) and write `NEED director: <file:line> <rule>` with the patch idea.

## Part B: a living robot hit throws metal (audit: robot hits 0-1 for every melee weapon; no sparks, no oil)
`blood_fx.json` `hits.thug_hit` (10 spark-and-oil drops in 70 deg along the blow) exists and is wired only in
`dev/enemy_ai/enemy_rig_fight.gd:20`. Wire it for every NON-lethal melee hit (and gun BODY hit if the same event
carries it in one line) on a robot victim in the game views (`CombatBlood` / its route `BloodVictims.Route.ROBOT`;
`CombatArena.wounded` is the hit event 04b used). Humans unchanged (no red on a non-lethal hit stays as is). Cap
the spray so a chainsaw grinding a robot does not fill the frame (one spray per `MeleeWound` strike, not per tick;
say the count per second of grind). Bar: a claw hit and a katana hit on robot thug A each throw visible white
sparks that land as dark oil drops, at 32 px/m.

## Part C: the saw (and the baton/plasma) through a shield draws something on the slab (audit: 1)
`ShieldSparks` fires only on `ReactLink.blocked`; the chainsaw, baton and plasma sword go `through`
(`melee_weapons.json` vs_shield). Fire a shield-face spray on a `through` contact too: the chainsaw a chattering
white spark fan off the slab once per bite (reuse ShieldSparks, its own count), the baton an amber arc flick, the
plasma sword an ember spit. Bar: visible at 32 px/m on a riot cop's shield during the chainsaw grind.

## Part D (only if A-C are committed by 35 min): play take
`node tools/melee/play_take.mjs` (02p4 added `--game-flags`), seed 7, chainsaw then plasma_sword, main (temp
worktree at `ba8e470b0` or the before flags) | HEAD, 20-30 s each, beside film `beside_impacts_<w>.mp4` to
`C:/Users/kazda/kiro/gtai-masters/n31/melee/`, appended to its `frames.json` (read it first). Look at 3 stills.

Owned for this call: `project/features/fx/combat_blood.gd`, `blood_victims.gd`, `shield_sparks.gd`,
`project/features/combat/**/blade_marks.gd`, `claw_marks.gd`, `saw_marks.gd`, `melee_marks.json`, `hit_feel.json`,
`project/features/fx/noir/blood_fx.json` (one wiring key at most), `project/dev/melee_n31/**`, tests for these.
`react_link.gd`: read; one additive signal/branch only if Part C cannot be done without it (say so).
Anything in `project/core/render/**`, `features/souls/**`, `combat/ai/**`, `combat/squad/**`: NEED, do not edit.
Lane lock and APPDATA as in the common law. Mutate the main changed file `--max=20 --lines=<changed>` with a test
subset at the end only if time remains; quote the score.
