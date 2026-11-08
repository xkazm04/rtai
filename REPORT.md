# n9 lane `world`: REPORT (DRAFT written 05:45 in it16; the freeze session finalises it)

Branch `n9-world`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n9\world\` (frames.json, 15 entries) and
`evidence/n9-world/` in this worktree. Every item below names its commit and DECISION (docs/decisions.md).
The whole set in one clip (87.6 s, each segment titled by item): `world_n9_set_combined_32-64ppm.mp4`.

## The exe for the owner

`build/export/windows/RTAI.exe` (521 MB, pck embedded, + `gtai_sim.windows.template_release.x86_64.dll` beside
it), exported at a8fbe016 (code = 6ca2448f, fully gated) with:

    export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/world
    "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe

Boots with no flags into combo (70 in play). Smoke: `RTAI.exe --headless --quit-after 600`, exit 0, 0 SCRIPT
ERROR. To see the work:
- the city block and its dead: `RTAI.exe -- --arena=city --rigs`
- the King's robe (combo, 70 easing to 55 on engage): `RTAI.exe -- --boss=king --rigs`

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
   - Quest 1's dock contractors (not rigs, drawn by `StreetQuestCards`) lie in the same five poses since it19
     (918cbe58: assets `dead_plan_v1_contractor`, grade B; drawn opaque, DECISION world/quest-dead-plan-opaque).
     Dock 9 at 32 px/m, t13800: before three planks side by side, heads one way; after twisted sprawls along
     each blow, neighbours differ (`dock9_contractors_dead_before_after_tilt70_32ppm_t13800_crop3x.png`, a 20 s
     clip `dock9_contractors_dead_after_tilt70_32ppm_t13450-14050.mp4`).
   - They fall into the pose (db8cdbb8, DECISION world/quest-dead-fall): over 0.4 s from the blow the body lands
     a touch large near where he stood, slides 0.6 m along the blow and turns into its rest; it popped in one
     frame before (`dock9_contractor_fall_before_after_tilt70_32ppm_halfspeed.mp4`).
   - A later body slides clear of those already down (3e7e39de, DECISION world/quest-dead-spread): within 1.6 m,
     up to 0.9 m, the earlier dead never move. Filmed at 64 px/m for the first time (a dev capture lean,
     `quest1_clip.gd --cam=dead`): before, three contractors in the middle of the crossing merged into one orange
     blob; after, each body reads (`dock9_dead_spread_before_after_tilt70_64ppm_t13800.png`, the half-speed
     clip `dock9_dead_spread_before_after_tilt70_64ppm_t13560-13860_halfspeed.mp4`, the 32 px/m crop x3).
   - The blood soaked into each body lies on the drawn corpse (19d43e8d, DECISION world/quest-soak-on-plan-corpse),
     not beside it at his standing spot (`dock9_soak_on_body_before_after_tilt70_64ppm_t13800.png`).
   - Each kill's blood pool grows from under the drawn corpse (e3c54005, DECISION
     world/quest-pool-under-plan-corpse); the signature-kill check still asks at his spot, so a signature kill
     never gets a second blood. Clip pair from one build at 64 px/m: before, the pools spread beside the bodies
     and the lowest body had none under him (`dock9_pool_under_corpse_before_after_tilt70_64ppm_t13760_crop.png`,
     the half-speed clip `..._t13560-13860_halfspeed.mp4`).
   - The pools fade like the live fight's stains (12 s + 4 s; it25, DECISION world/quest-pool-stain-life), no
     longer lying on the crossing for minutes after their bodies went
     (`dock9_pools_fade_stain_life_before_after_tilt70_32ppm_t14000-16000.mp4`, 32 px/m; the close-up
     `..._64ppm_t14600-15800.mp4` and its t15400 / t15800 still: at t15800 the after's pools are fading, the
     before's stay full).
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
   - Filmed at 32 px/m (it4, 2x crops) and at a true 64 px/m (it23, combo and tilt70, before | after from one
     build: `king_robe_before_after_combo55_tilt70_64ppm_phase3_seed2_t1400.png`).
   - At 70 the bust's fur and cape now hang to an inked hem over the robe instead of ending on a straight cut
     (it25, assets king_bust_70_hem_v2; DECISION world/king-bust-hem; 64 px/m tilt70 t1400 / t1700:
     `king_bust_hem_before_after_tilt70_64ppm_phase3_seed2_t1400_t1700_x2.png`).

## What does not (yet)

- The Dock 9 dead still lie close on the crossing (the quest kills them there); the push separates them but
  limbs still touch. The contractor sheet's pose D reads as a second face-down (assets graded it B).
- At a wall the lying pose's hood and one hand overlap the building's edge by ~0.3 m (64 px/m close-up: it reads as a
  body slumped against the wall, feet out). The view bound pulls the pose back along the blow only; left as is.
- At Dock 9 a blood pool still outlasts its body by ~6 s (the decay table's law: stains linger 12 s, bodies 6 s),
  so for a few seconds after a corpse decays its pool lies with nobody on it (Call C-6). Until it25 this lasted
  minutes; quest 1's blood now takes the live fight's stain life (see item 2).
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
  - Quest 1's dock dead: a 0.4 s fall (0.6 m slide, 0.35 rad turn), drawn opaque.
  - Options: (a) as built; (b) no jitter; (c) a longer shotgun slide; (d) the dock fall at 0.25 s
    (`StreetQuestDeadPlan.FALL_TICKS` 15).
- **C-4 the robe at 70.**
  - At 64 px/m the shipped 70 bust card ended on a hard horizontal cut (the fur and cape sliced straight) above
    the legs (d9 bust art, there before the robe too).
  - Built (it25, DECISION world/king-bust-hem): (d) assets' redraw of the 70 bust with the fur and cape hanging
    to an irregular inked hem over the robe (king_bust_70_hem_v2, grade A), the bust's anchor kept:
    `king_bust_hem_before_after_tilt70_64ppm_phase3_seed2_t1400_t1700_x2.png` (left = the cut card).
  - Options still open: (a) the cut card (`KingArt.HEM` false); (b) LIFT 0.6 so more robe shows; (c) a shorter
    drawn 70 robe. The redraw is the library's, not the shipped pixels (faces, chain and fur spots redrawn; at
    64 px/m it reads as the same King). Drawing the robe in front of the bust was tried in it23 and does not help.

- **C-5 the car knock-down.**
  - Built: threshold 5 m/s, slide 0.8 x the car's speed, 1.2 s down, damage 2.5 x (speed - 2.5).
  - Options: (a) as built; (b) slide_k 0.5; (c) threshold 8 m/s.
  - Each is one bodies.json value.

- **C-6 the pools after the bodies go (quest 1, Dock 9).**
  - Seen at 32 px/m: once a body has decayed (6 s + 1.2 s fade, corpse_decay.json), its blood pool stays on the
    crossing with nobody on it; the live fight's table lets stains outlive bodies (12 s + 4 s), and quest 1 keeps
    blood_fx.json's minutes-long decals (`gtai-n9/tmp/world/pools_outlast_bodies_32ppm_it23.png`).
  - Built (it25, DECISION world/quest-pool-stain-life): (a) quest 1 takes the live fight's stain life (12 s +
    4 s), so the pools go ~6-10 s after their bodies instead of minutes. Clip pair from one head, 32 px/m,
    t14000-16000: `gtai-masters/n9/world/dock9_pools_fade_stain_life_before_after_tilt70_32ppm_t14000-16000.mp4`
    and the t15400 / t16000 still; the 64 px/m close-up `..._64ppm_t15400_t15800.png` shows what (b) would
    shorten: at t15400 the heap's bodies are gone and its pools still lie as one dark mass for ~6 s.
  - Options still open: (b) as (a) plus stains linger 6 s like the bodies (one corpse_decay.json value, which
    also changes the live fight); (c) Dock 9's bodies linger 12 s.

## Next steps

1. Assets' pose D redrawn if the owner asks.
2. The wall overlap: a probe that reaches the jitter-swung hand was tried in it19 and showed no visible gain at
   64 px/m (kept as a patch under `gtai-n9/tmp/world/`); only if a shot shows a body over a roof edge again.
3. Freeze: the full gate (`node tools/evidence/run.mjs --no-bench`), the director reel x3 at the head, the exe
   (`build/export/windows/RTAI.exe`), this report finalised.
