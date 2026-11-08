# JOURNAL - lane world (n9, branch n9-world)

## it1 (2026-11-08 00:55-01:55) BUILD

Read: brief, seams + perf d9 REPORTs (Call P-1 / LEDGER L4, seams Call 3 bikes), AGENTS.md, decisions tail.
Registry rules applied: `perf-regression-gating` (BC7 judged on its mechanism + a measured VRAM A/B, pixels
gated by the goldens' own tolerance, the bikes-only and BC7-only deltas separated before the re-bless so each
moved golden has a named cause), `motion-quality-gating` (judge combo in motion on the reel, not a still).

- MILESTONE item 1 built: view.json default `combo`; `ViewMode.select()` pins a run's view; `city_selftest`
  pins `top` (look goldens + accent audit stay the straight-down reference); `traffic.bike_share` 0.06;
  BC7 on 772 imports (`node tools/handheld/bc7_arm.mjs project` then `--import`, 77 s, 0 errors).
- Golden deltas measured before blessing (seed 91 junction riot, top):
  - BC7 only (bikes 0): 11/11 inside tolerance, means 0.78-1.85.
  - BC7 + bikes 0.06: 2/11 (d1 only) inside, means 4.32-14.73: bikes change the riot's deaths and car spots.
  - block (BC7 + bikes): 5/5 inside, means 0.62-1.46.
  - Re-blessed all 16 (junction 11 + block 5) in the item-1 commit; DECISION world/combo-bikes-bc7.

### Item 2 design: the dead, from scratch (written before any code)

What is wrong today (seen in `view/p70/cop_patrol_long_fall.png`): 5 facings x 3 frames; every lying frame is
the same plank: straight, legs together, arms out ahead, flat. One pose per facing, so a riot's dead are clones
lined up by blow direction, and the fall is a 3-frame flip with no travel.

How a top-down crime game sells a death at this camera (the reading is from above, so the silhouette IS the
death): the body goes the way the blow pushes it; the knees go first (a crumple), the torso twists so the hips
and shoulders do not line up; the limbs land at broken, unequal angles (one arm under, one flung; one knee bent);
the body slides a little after impact and settles with a small rebound; blood pools out under it over seconds
(that part exists: CorpseStains). Sameness kills it: neighbours never share a pose.

Design:
- Poses per body class (5): A face-down crumple (knees folded, one arm under the chest, one flung up past the head);
  B thrown on the back, spread and broken (arms wide at unequal angles, one knee up and fallen sideways);
  C side curl (on the side, knees drawn, the top arm over the face); D twisted sprawl (hips face-down, shoulders
  turned up, legs scissored); E slumped sitting-then-fallen (the legs folded under, the torso fallen sideways:
  the low-energy death, for melee and point-blank pistol).
- The lying poses are drawn in PLAN view (straight down, flat on the ground) and drawn on the ground plane, so the
  view's own ground transform foreshortens them at 70 and 55 and they can be ROTATED freely along the blow
  (no 5-facing clone line, no pitch-specific settled art). The fall frames (buckle, mid-fall) stay per pitch
  (p70 / p55 cut from the cast's cards); the swap happens at impact, when the figure is lowest.
- Pick: weapon class + blow -> candidate set (shotgun / car / explosion: B, D thrown; rifle / pistol: A, D, C;
  melee / point blank: E, C, A), then the first candidate no corpse within 3 m already shows (deterministic:
  the person's id hashed, never the global rng).
- Motion (60 Hz ticks): buckle 0-8 ticks (the per-pitch frame 0), mid-fall 8-18 (frame 1, the card rotating
  toward the blow's ground angle), impact at 18 (the plan pose, scale 1.04 -> 1), slide 18-30 along the blow
  0.4-1.2 m by weapon energy (ease-out), settle 30-40 (a 3-degree counter-rotation rebound). The slide stops at
  walls (item 4's rule, the sim's thrown body).
- Classes: street walkers (one figure set re-tinted per look is NOT enough: suit, worker, hood, shopper silhouettes
  differ), cops (patrol, riot, SWAT), the gang (thug), Rivet's own death sprawl (robot: limbs at hard angles, one
  servo arm detached is optional/no).

REQUEST to assets: dead_plan_v1 (one sheet per body class: ped_suit, ped_worker, ped_hood, ped_shopper,
cop_patrol, cop_riot, swat, thug, rivet), pitch "plan" (straight down, 90 degrees, flat on the ground): 5 lying
poses in a row (A face-down crumple, B on the back spread and broken, C side curl, D twisted sprawl, E legs
folded under, torso fallen sideways), each pose's pelvis at its cell centre, head toward the top of the cell,
the cell 384 x 384 at the still strip's 192 px standing height (the body ~1.4x of standing when stretched, never
longer), transparent ground, the ink outline and print grain of the approved cast cards, copied BY EXAMPLE from
the approved cards (ped_*_70 stills, cop_patrol/cop_riot/swat 70, thug 70 v3, Rivet 70 at his n9 size from
lane rivet). No blood on the sprites (the game pools its own). Limbs at unequal, broken angles; hips and
shoulders never aligned; no pose straight and symmetrical (the owner: "they lay down like in the bed now").
Why: the owner's verdict on the dead; the plan-view poses rotate freely along the blow on the ground plane, so
one sheet serves 70 and 55.

- NOTE to all lanes (01:36): item 1 landed on n9-world at 3e02d3b8: **main's boot default is now `combo`**
  (view.json `default`), sim bikes at 6 %, BC7 on the drawn art (772 imports), the 16 look goldens re-blessed.
  The selftest scenes and the GUT suite pin `top` (`ViewMode.select("top")`, `tests/support/gut_pre_run.gd`);
  pass `--view=top` yourself where you need the old default. Pixel tests on art: `TestArt.rgba(tex)` (BC7 art
  is compressed; `get_pixel` on it reads nothing). rig_stress caps full rigs at 16 + CORPSE_PINS under a card view.
- FRICTION: the first unit run timed out at 600 s: BC7 made test_vehicle_views' `get_pixel` loop log 261k
  "compressed image" errors (1.8 M log lines). Fixed with TestArt.rgba.
- Gates at 3e02d3b8: lint 15/15; unit 1815/1 (the unknown-view fallback, fixed in the commit, view suites 38/0);
  scenarios 53/54 before the rig_stress cap fix (17 full rigs = 16 + a pinned fresh corpse, the card view's
  design); director reel (headless, 16000) top / tilt70 / combo 19/19 chapters all down, 0 SCRIPT ERROR
  (`evidence/n9-world/director-reel-it1-*.log`). Full evidence --no-bench: running.
- Still: no-flags boot lands in combo (`gtai-masters/n9/world/boot_noflags_lands_in_combo_70_32ppm_f420.png`).
  The standing city clip at seed 7 showed no bike in 15 s at 6 % (sparse traffic): film a drive next.
- Owed for item 1: the evidence run's result; the city-with-bikes still + clip (a drive); the BC7 riot VRAM A/B
  (scratch "before" worktree ready and imported at `C:/Users/kazda/kiro/gtai-n9/tmp/world/before`: main +
  combo + bikes 0.06, lossless, so only BC7 differs; arms `lossless:^--path <that>/project` vs `bc7:`, under
  bench.lock); frames.json.
