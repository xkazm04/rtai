# n31 ghost 23 part 1: Kerf play measure on HEAD, main | HEAD

Builder `g23-kerf-measure`, 2026-11-26. HEAD = `60e6bbdea`. main = `ba8e470b0` numbers copied from `measure-ohm-play.md` (g13, same tool, same bot fit).
Play, profile average, seeds 1-10 (all 10 run), `--waves=3`, relaxed bot fit (shipped bot: Kerf at any target), real strike. Tool: `tools/ghost/deploy_measure.mjs --mode=play --form=kerf`.

| side | deploys | mean hits / deploy | median hits | kills | whiffs (0 hit) | refusals | press->damage ticks (median) | mean near (<= 9 m) | share of near |
|---|---|---|---|---|---|---|---|---|---|
| main (hold, cone, instant cut) | 60 | 1 | 1 | 60 | 0 | not logged | 1 | 4.13 | 24 % |
| HEAD (lock, sight 12 ticks, blink + cut) | 60 | 0.85 | 1 | 51 | 9 (15 %) | not logged | 12 | 2.18 | 39 % |

- A HEAD cut still takes at most one foe (max hits 1). 51 of 60 landed; the 9 whiffs are locks that broke before the cut (target died or left): wave 1 1 of 22, wave 2 5 of 20, wave 3 3 of 18. Per seed deploys/whiffs: 1:7/1 2:5/1 3:7/0 4:6/1 5:8/2 6:6/1 7:5/1 8:4/0 9:4/1 10:8/1.
- Key to damage is 12 ticks (0.2 s) on every deploy, where main hit on the release tick.
- Refusals: the measure bot only presses when it has a target, and the dump logs none, so a refused press (no target, no cooldown) is not counted here: not measured.
- Near is not comparable between the sides: HEAD 2.18 vs main 4.13 foes within 9 m (the HEAD dump samples near at the cut after the lock/blink, the bot's pick also differs), so the "share of near" 24 % -> 39 % mostly reflects that, not a stronger cut. Per deploy the cut kills 0.85 foes instead of 1.
- Shipped fit (`head-kerf-shipped`): 0 deploys in 10 seeds x 3 waves (the shipped bot never fires Kerf early, as g08/g13 found).

Files: `evidence/n31/ghost/measure-60e6bbdea-play-head-kerf-relaxed.json`, `measure-60e6bbdea-play-head-kerf-shipped.json`.
```
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf --fit=relaxed --seeds=10 --waves=3 --tag=head-kerf-relaxed
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf --seeds=10 --waves=3 --tag=head-kerf-shipped
```

## Part 1 (g24): why each whiff broke (HEAD `1f074f187` + `KerfDrop.broke`)

Same play measure (relaxed fit, seeds 1-10, 3 waves, profile average): 60 deploys, 51 hits, 9 whiffs, identical to the section above. Each whiff now carries `broke` (`KerfDrop.broke`, set by `cut_target`) plus, from the dev tool, the weapon that killed a dead lock (kill_landed) and the target's distance from Rivet at the cut.

| cause | whiffs of 9 | detail |
|---|---|---|
| dead: killed by Rivet (his own weapon) during the 12-tick wind-up | 6 | claw 4 (seeds 4, 5, 5, 10), katana 1 (seed 6), gloria 1 (seed 9); killed 3 to 11 ticks before the cut; the target was at 0.7-2.7 m (seed 9: 7.8 m) |
| dead: killed by another ghost / other (fire, blast, ...) | 0 | none: no deploy_* or other weapon in the kill log |
| wall (line to the target blocked at the cut) | 3 | seeds 1, 2, 7 at 8.0, 8.5, 5.2 m; the target was alive and in range |
| range (past range + 2 m) | 0 | none |

- So 6 of the 9 whiffs (10 % of deploys) are the target dying to Rivet's own melee in the wind-up: the press locked a foe he was already fighting. 3 (5 %) are a wall that came between Rivet and a live, in-range target (Rivet or the foe moved). No lock broke from range.
- A re-lock on a live second foe would fix the 6 dead ones only if another foe stands in the cone; the 3 wall ones re-pick from Rivet's position and may find a clear foe or not.
- `broke` is also asserted in `test_kerf_drop.gd` (dead, range).

File: `evidence/n31/ghost/measure-1f074f187-play-head-kerf-cause.json`.
```
node tools/ghost/deploy_measure.mjs --mode=play --form=kerf --fit=relaxed --seeds=10 --waves=3 --tag=head-kerf-cause
```
