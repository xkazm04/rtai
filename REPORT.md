# n10 perf REPORT (DRAFT, kept current; branch `n10-perf`, cut from main 9bbe6d0a)

Method and every number: `docs/perf/LEDGER.md` section "n10 night". Every number is CONTENDED (other lanes' Godots up) unless it says otherwise.

## What works, with its evidence
1. **Rig cost under combo (item 1) cut under the 1 ms target.** rig_bench 50 people, `--view=combo`, headless, interleaved against main 9bbe6d0a: p50 ~1.2 ms -> ~0.6 ms (`evidence/perf/n10-rig/`). The walkers' whole-figure cards hid the cut rig's parts, yet every pose step still solved both legs and both arms: now the limbs are skipped while the card is up (`CutRig.limbs_cold`), posed on the card's release and before a kill's cut reads them. Pixels: a frame-compare of the rig stress at combo differs by 0 pixels against main (`evidence/perf/n10-rig/framecmp/`). Commits d006d70e, a9370647; tests `test_rig_limbs_cold` (5); full unit exit 0 on d006d70e.
2. **The feed's dead-flip scan runs in C++ (item 2).** `CitySim.scan_dead_flips`, cfdb53e4, the script loop kept as the no-DLL fallback. Micro only, debug editor binary, synthetic 400 people: ~22 us against 115-423 us (`evidence/perf/n10-scan/`). Its own share is not separated at the bench.
3. **The release riot at combo (item 3), both cuts together, against main 9bbe6d0a:** frame p50 lower in 6 of 6 interleaved rounds, median paired delta -1.14 ms; rig p50 median 1.665 -> 0.957 ms (`evidence/perf/n10-riotc/`, table in LEDGER). Release exports, 400 actors, 0 errors, equal draws.

## What does not work / not done yet
- **The release riot was not quiet**, which the brief asked for: 0-10 other Godots were up throughout. ab.mjs's own range rule prints WASH on every metric; the 6-of-6 ordering is the claim (sign test p = 0.03). No p99, worst, CPU or RAM claim. At the older tilt70 preset the frame p50 is a wash (lower in 7 of 10 pairs); the rig timer is lower in 10 of 10.
- **One native crash in the top director reel, unexplained, not reproduced.** Exit 139 on 55cbf9db near frame 4641 (the electro_gun chapter), the tree edited during that run, so it is not clean evidence either way. Base 9bbe6d0a finished top 19/19. A full top reel on cfdb53e4 then exited 0 with 19/19 chapters down and 0 SCRIPT ERROR: one clean pass, not an explanation.
- Mutation, sampled, not the whole files: `city_fx_feed` 70 % (7 of 10; the survivors are defensive slot-range checks that real records never trip); the cold-limb lines in `rig_pose` 71 % on the boolean and delete operators only (5 of 7, the survivors delete `_body` and `_head`, which `test_rig_limbs_cold` does not assert). A first `rig_pose` run scored 10 % because I limited it to that one test file, which covers none of the pose maths: it measures that choice, not the rig tests.
- **Item 4 (the research loop): idea 1 was a wash and is reverted.** A C++ fill for the rig feed (4f153362) matched the script's rows and ran ~10 us against ~350 us in a debug microbench, but the release riot at combo showed no gain: frame p50 lower in 1 of 6 pairs, rig p50 higher in 6 of 6, CONTENDED (`evidence/perf/n10-feed/riotc/`). Render CPU and the C++ sim step rose as well, which that change cannot touch, so this run does not prove the fill made anything slower; it only fails to show a gain. Reverted by 409ec9d3. One wash so far; the loop stops at two in a row.

## Gates
`node tools/evidence/run.mjs --no-bench` on d0569d17 (items 1 to 3, before the item 4 work): lint 15/15, unit 1958/0, scenarios 55/0, parity bit for bit over 1200 steps with the planted mutation caught, selftest look goldens 11/11, release-compile 631/0. Full `top` reel on cfdb53e4: exit 0, 19/19, 0 SCRIPT ERROR. tilt70 and combo reels last ran on 55cbf9db (19/19, 0 SCRIPT ERROR), so they do not cover the native scan or the feed fill.

## Merge note
The release DLL is git-ignored. A merge must run `scons platform=windows arch=x86_64 target=template_release` or the shipped game silently keeps the script loop (the rig cut is GDScript and is not affected).

## Calls for the owner
(none yet)

## Next steps
See JOURNAL `NEXT:`.
