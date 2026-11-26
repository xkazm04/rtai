# Builder n31-melee-02-sweep (opus): make the hit follow the blade

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `02`.
HARD STOP: this call has ~40 min (launched ~21:45). Commit part 1 by 22:10, END with the report by 22:22 sharp
(your process is killed at 22:27; uncommitted work is lost). Do ONLY part 1 below in this call.

## THIS CALL = part 1 only
Implement rule items 1 and 2 (sweep over the drawn cutting ticks, struck set once per enemy per hit, sector from
the drawn angles), behind a launch flag `--melee-sweep` that is OFF by default (declare it in
`project/boot/launch_args.gd` KNOWN_FLAGS; debt `--accept-regression="--melee-sweep for n31 melee"`), read once
into a static like `MeleeSwing.sharp`. With the flag off the game must be byte-identical (no digest moves: run
`node tools/tests/run_unit.mjs --changed` and the replay/scenario checks that cover melee). GUT tests: a dummy
entering the drawn cut on the last cutting tick is hit with the flag on and not with it off; nobody is hit twice
per hit; the struck set survives write_state. Report which ticks each weapon now tests (per hit) as a table.
Items 3-6 are the next call.

## The owner's complaint and the before
"Melee weapons are visible smashing through enemies and nothing happened." The before, measured on main by
`tools/melee/blade_volume.mjs` (see `evidence/n31-melee/01-volumes/before.md`, `before/volumes.json`):
Robust numbers (hit timing, trustworthy): every weapon tests its hit on ONE tick (claw 4, baton 3, katana 6,
plasma 7 from the press; the chainsaw at 11, 22, 30), but keeps drawing the cut 2-6 ticks after it (claw and baton
2, katana 3, chainsaw 4, plasma 6) and the blade stays on screen to tick 12-48. A late mover entering the drawn cut
after the test tick is never hit. Drawn GEOMETRY of 01a is NOT validated (overlay off; strip-cell blades
unmeasured) - a separate call (01c) is rebuilding it from pixels; do not depend on it.
Guard-rail baseline (`evidence/n31-melee/01-baseline/before/before.md`, waves 1-4, seeds 1-5): kills/swing claw
0.795, chainsaw 0.787, electro_baton 1.04, katana 0.994, plasma_sword 1.238.

## The rule to build (DECISION lines are yours to refine, one `docs/decisions.md` line for the rule)
1. Sweep, not one tick. `melee_combo.gd:lands()` is true only at `tick_in == windup`. Make the hit test run on
   every tick in which the blade is DRAWN cutting (the sim derives it from the same pure function the view uses:
   `MeleeSwing.cutting()` / `MeleeSwing.angle()` are static and RNG-free, so the sim may call them; never read a
   view node from the sim). Each enemy is hit at most once per hit (a struck-id set on PlayerMelee, cleared when
   `combo.hit_index` changes or the combo goes idle; it must be in `write_state` so replays stay exact). The
   chainsaw keeps its grind re-test every `grind_ticks`.
2. From the blade, not the centre: on each sweep tick, test the sector the blade crossed since the last tick
   (from the previous drawn angle to the current one, about the aim) out to the drawn reach (grip offset + drawn
   blade length + the enemy's radius), not `dir.dot(facing) >= cone_dot` from Rivet's centre. Keep `landed` /
   `whiffs` counting one per hit (whiff only if the whole sweep struck nothing).
3. Bring drawing and volume together from both sides: lift `rivet_swipe_view.gd` REACH_MAX_M (1.35 m clamp) to the
   weapon's real reach where the reach is right; shorten `reach_m` in the table where the art cannot show it.
   Give the katana's hits a `lunge_ticks` where `lunge_m` > 0 has none so the lunge has arrived at contact.
4. Bars (re-run `tools/melee/blade_volume.mjs --label=after`): drawn-but-no-hit = 0 inside the cutting ticks for
   the standing ring; <= 5 % for the late mover; hit-but-not-drawn <= 5 %.
5. Guard rail (re-run `tools/melee/play_baseline.mjs --label=after`): kills per swing per weapon in gauntlet waves
   1-4 within +-15 % of `evidence/n31-melee/01-baseline/before/baseline.json`. If the sweep makes a weapon
   stronger beyond that, pay it back in recovery ticks (one value per weapon), DECISION with before -> after.
6. Digests: scenario/replay digests that move get re-pinned once with a dated decisions line naming this item.
   Quest 1's script and native parity must not move.

## Evidence tail (same call)
- Polar plots before | after side by side: `evidence/n31-melee/02-sweep/`.
- Commands and result lines in the report; mutate `node tools/mutate/mutate.mjs --file=project/features/player/player_melee.gd --max=20 --lines=<changed>` with a test subset; quote killed/(killed+survived).
