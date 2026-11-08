# n9 lane `world`: REPORT (DRAFT written 05:45 in it16; the freeze session finalises it)

Branch `n9-world`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n9\world\` (frames.json, 15 entries) and
`evidence/n9-world/` in this worktree. Every item below names its commit and DECISION (docs/decisions.md).

## What works, with its evidence

1. **Main boots combo, sim bikes at 6 %, BC7 in every build, one re-bless** (c3b30b76 + the item-1 commit;
   DECISION world/combo-bikes-bc7).
   - `view.json` default `combo`; `ViewMode.select()` pins a run's view; `city_selftest` pins `top`, so the look
     goldens stay the straight-down reference. `traffic.bike_share` 0.06. BC7 on 772 imports
     (`tools/handheld/bc7_arm.mjs`, then `--import`).
   - Goldens measured before the bless: BC7 alone kept 11/11 inside tolerance; bikes moved the riot's deaths and
     car spots (2/11 inside). All 16 (junction 11 + block 5) re-blessed in the one commit.
   - Gate at c3b30b76: lint 15/15, unit 1816/0, parity bit-exact (1200 steps, planted mutation caught at 629),
     goldens 11/11 + 5/5 worst 0.00, release-compile 614/0. rig_stress: see Call C-1.
   - BC7 riot A/B (`tools/perf/ab.mjs`, under bench.lock): **VRAM 900.7 -> 539.8 MB (-361 MB, -40 %)**; frame
     time a wash (2 of 4 runs CONTENDED). `evidence/n9-world/bc7-ab/`.
   - Stills: a no-flag boot landing in combo; a sim bike with rider in traffic at 32 px/m; the dense drive clip.
2. **The dead, redesigned** (71c0b951, 2f258eeb, b5c5a28f; DECISIONs world/dead-plan-view, world/dead-plan-wired,
   world/quest-dead-plan).
   - Plan-view lying poses (assets dead_plan_v1, 13 body classes x 5 poses: face-down crumple, back spread,
     side curl, twisted sprawl, folded on the side) laid on the ground along the blow, picked by the death
     family, neighbours within 3 m differ, a slide of 0.35-1.2 m into the sim rest and a small settle. The baked
     far crowd dead take them too.
   - Riot before/after at 32 and 64 px/m: straight planks -> twisted sprawls.
   - Quest 1's dock contractors (not rigs) are wired the same way and wait on one sheet (see "does not").
3. **Cars knock Rivet down** (703c287b, b0f1024e, 0c04d16b; DECISIONs world/car-hits-rivet-sim, -on,
   world/car-knock-damage-event-only).
   - Both twins, bit-exact. Above 5 m/s a car throws him along its heading; below it, the car brakes and stops at
     his body.
   - Scenarios `scenario_car_knocks_rivet` (one knock at 12 m/s, 6.6 m slide, 23.75 dmg) and the creeping arm of
     `traffic_yields_rivet` (stops at 2.33 m, no knock).
   - The view's DOWN flag and the `rivet_knock` meta; lane rivet wired its drawn knock-down strips to it.
   - Clip: `dev/showcase/car_knock_clip.tscn` (before: the car drives over him).
4. **Thrown bodies stop at walls** (42ca18ba view, a42e54f0 sim, 8101a2a1 arena props; DECISIONs
   world/dead-stop-at-walls-view, -sim, world/arena-solids-to-sim).
   - The dead slide never takes a step into a building, prop or parked-car cell, in both twins (parity
     bit-exact; the branch is exercised).
   - The arena's walls and cover are stamped into the sim cells, so the crowd walks round the kerb barrier.
   - Filmed (it16, `dev/showcase/dead_wall_clip.tscn`): a body thrown at a building face at 16 m/s.
     - Before: he ends 2.4 m inside the building, lying on its roof.
     - After: he stops at the face.
     - Shot at 64 px/m (stills + clip) and 32 px/m.
5. **The King's robe** (e8bd8dd7; DECISION world/king-robe).
   - The King walks under the long drawn robe (assets king_robe_55 / _70).
   - At 55 the hem covers the steel shins, the gold boots show at its front, and it swings with the stride.
   - At 70 the bust covers most of it (Call C-4).

## What does not (yet)

- **Quest 1 Dock 9's dead contractors still lie in the old straight frame**: they draw through
  `StreetQuestCards`, not the rigs, so the redesign missed them until it16. The code is in (b5c5a28f). The sheet is
  REQUESTed from assets (`dead_plan_v1_contractor`). Before still:
  `dock9_contractors_dead_before_tilt70_32ppm_t13800*.png`.
- At a wall the lying pose's hood and one hand overlap the building's edge by ~0.3 m (64 px/m close-up: it reads as a
  body slumped against the wall, feet out). The view bound pulls the pose back along the blow only; left as is.
- The knock damage is an Event only (the city has no Rivet hp outside the pits).
- rig cost under combo is above the provisional 1 ms (C-1).

## What blocked, and for how long

- Nothing blocked for long. (Iteration numbers 11, 12, 14 and 15 have no sessions: by the clock it10 ended 04:11,
  it13 ran 04:10-05:10 and it16 05:10-06:10, so no hours were lost, only numbers.)
- An old-commit "before" for quest 1 failed: the city did not stream with the n9 native DLLs. Befores now come
  from the same build with a toggle, or from the GDScript twin (`--ref`).

## Calls for the owner

- **C-1 rig cost under combo.**
  - Measured: about 1.1-1.4 ms p50 at 50 people, against the provisional 1 ms (top 0.5-0.76 ms).
  - Built: gate `top`, log combo (DEVIATION STD-20-RIG).
  - Options: (a) as built until perf cuts it; (b) a 1.5 ms budget for card views; (c) MAX_FULL 12 under combo.
- **C-3 the dead.**
  - 5 poses per class, picked by the death family.
  - Slide 0.35 m (melee), 0.6 m (bullet), 1.2 m (blast); a ±0.4 rad jitter.
  - Options: (a) as built; (b) no jitter; (c) a longer shotgun slide.
- **C-4 the robe at 70.**
  - Options: (a) as built (bust LIFT 0.74 hides most of it); (b) LIFT 0.6 so more robe shows; (c) a shorter
    drawn 70 robe.
- **C-5 the car knock-down.**
  - Built: threshold 5 m/s, slide 0.8 x the car's speed, 1.2 s down, damage 2.5 x (speed - 2.5).
  - Options: (a) as built; (b) slide_k 0.5; (c) threshold 8 m/s.
  - Each is one bodies.json value.

## Next steps

1. Pack `dead_plan_v1_contractor` when served (`python tools/art/dead_plan.py --only=contractor`, add it to
   CLASSES). Then film Dock 9 before/after at 32 and 64 px/m.
2. Optional: bound the lying pose by its own sideways extent at a wall (the ~0.3 m hand/hood overlap).
3. Freeze: the full gate (`node tools/evidence/run.mjs --no-bench`), the director reel x3 at the head, the exe
   (`build/export/windows/RTAI.exe`), this report finalised.
