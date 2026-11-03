# REPORT: lane d5-cast (branch `d-cast`), day run 2026-11-03

Written at 17:30 in the REPORT phase. The branch has 81 commits on top of main (089400e). Its last change to code or art
is **8dbf7f4**: `git diff 8dbf7f4 HEAD -- project tools` is empty, and every later commit only touches the journal or
the evidence docs. Nothing was pushed or merged.

Paths: `evidence/` = `evidence/` in this worktree. `M:` = `C:\Users\kazda\kiro\gtai-masters\day-d5\d5-cast\`, which is
outside git. **Owner page:** `M:frames.json`, with 15 labelled frames. I checked at 17:30 that every `file` exists. `M:ladder.png` holds the frames.
Every performance number below is **CONTENDED**: seven lanes shared one GPU.

## What works

### 1. Rivet's scale (verdict 1)
- **Measured** with the new headless `project/dev/bench/rig_footprint.gd`, from a plan-view bbox in the idle guard.
  - Before (the night Rivet, size_k 1.3): 2.50 x 2.62 m.
  - A cop is 1.27 x 1.88 m and a ped 0.69 x 1.34 m.
  - The mass was his long arms held in a wide guard. **Evidence:** `evidence/d5-cast/rivet-footprint.json`.
- **Now:** `RivetPlan.FORMS` base = (size_k 1.2, guard_k 0.7, hand_z -250). The guard hunches as T2 draws him, so he
  measures 1.90 x 2.05 m, about 1.25x a cop, which is how T1 draws him. Commits 8118692 and 062939d.
- **Kept readable:** the claw and the torch read at 32 px/m.
- **Sim untouched:** the sim radius stays 0.6 m, so no replay or parity golden moved. The look goldens pass unblessed.
- **Decisions:** `docs/decisions.md` has two lines, "Rivet scale" and "Rivet stance".
- **Ghost-form hook:** the bulky ghost form would be a new `RivetPlan.FORMS` row. The `night` row (1.3, open guard) is
  still there. I did not build the form.
- **Frames:**
  - real game: `M:frames/rivet-hunch-city1-ab.png` (city_frame at 32/48/64/128, before | after);
  - dev scene: `M:frames/rivet-t2-vs-hero-128ppm.png` (beside T2), `M:frames/t1-vs-hero-48ppm.png` (beside T1) and
    `M:frames/rivet-lineup-32ppm-3way.png` (night | iteration 1 | now).

### 2. Cops in blue (verdict 6)
- **Cop art (7b4965d):** the cop parts are recoloured in the D4 and D5 tiers.
  - The uniform is `cop_blue` #3A4766; the small marks (shoulders, cap badge) are `cop_blue_hi` #4F86E0.
  - The alpha is unchanged (silhouette lock), and the recolour is deterministic (`M:recolor_cops.py`).
- **Shaders:** `print_part.gdshader` and the shared `look_d5_part.gdshader` gain a cop-blue plate and a teal guard.
- **Vermilion left on cops:** 0 px in all 34 cop and police art files (gate r - max(g,b) > 40).
- **Heads as T1 draws them:** cream domes, a thick ink ring in the D4 tier, a navy band and a blue badge. Commits 34acc56,
  90bb8f6 and 704570f. **Evidence:** `evidence/d5-cast/cop-helmet-t1.json`, `cop-cap-t1.json` and `cop-rim-t1.json`.
- **Cruiser:**
  - the sprites (intact, d1, d2) have a blue light bar; the wreck had no vermilion;
  - traffic-atlas cell 8 is recoloured in all four atlases;
  - **evidence:** `evidence/d5-cast/cruiser-atlas-print.json`, and the frame `M:frames/cruiser-art-ab.png`.
- **Gate: tell a cop from a ped at a glance, measured in the real city riot at 32 and 48 px/m.**
  - Every cop stays its own blue blob: 15 blobs / 2393 px at 32, and 13 / 2864 px at 48.
  - The cop body against the ped ink is only dE76 28. The `cop_blue_hi` marks (dE 68) carry the read.
  - **Evidence:** `evidence/d5-cast/cop-gate.json`.
  - On the merged preview (d-city + d-combat + d-cast), 7 blue clusters at 32 px/m match the 7 cops in view
    (JOURNAL, iteration 47).
- **Real-game cop close-up, before (main) vs after, at 32/48/64/128:**
  - Built with `project/dev/showcase/cop_close.tscn` (8dbf7f4). It runs the real World + CityView + crowd, and the
    camera follows the nearest live cop.
  - Vermilion fell 4012 -> 0 px at 64 and 8008 -> 0 at 128. At 32 and 48, the only vermilion left is Rivet's collar.
  - **Evidence:** `evidence/d5-cast/cop-closeup-real.json`. **Frames:** `M:frames/cop-follow-real-4zoom-ab.png` and
    `M:frames/merge4-preview-cop-follow-4zoom.png`.
- **Riot frames:** `M:frames/city0-32ppm-crop2x-ab.png` and `M:frames/riot-city0-64ppm-real.png`.

### 3. Soul trail descoped (verdict 3)
- The trail only ever lived in the D5 hero dev scene (`D5HeroExtras`); the game path never drew one.
- It is now off by default, and `d5_hero.gd -- --souls` shows it (`project/dev/showcase/d5_hero.gd:7,57`).
- The art and `look_d5_soul.gdshader` are kept. The decision is in `docs/decisions.md` ("souls trail descoped").

### 4. Portraits (verdict 6 + doctrine)
- **Cop portraits:** all 5 are recoloured onto a navy ramp, with 0 vermilion px left, and wear T1's cream dome
  (commit 02d459e).
  - This used 0 Codex images: the recolour keeps the "great" D5 style exactly.
  - **Frame:** `M:frames/portraits-cop-dome-3way.png` (orig | navy | dome).
- **Rivet's portraits:** busts, so the scale change does not apply. Their red-orange stays on the collar and the rust
  drips, which matches T2. No change.
- **Provenance:** 98 `d5-cast` rows in `steam/ai-provenance/2026-11.jsonl`. The hash audit matched at 12:35.

### 5. King on the cutout rig (the stretch item)
- `KingPlan` uses Rivet's skeleton and part layout, with size_k 1.3. His parts came from 1 Codex image, sliced with
  Rivet's alpha (`M:king/`).
- A unit test checks that every King part exists (`project/tests/unit/test_rig_plans.gd`).
- It is dev only: `dev/showcase/king_showcase.gd`. A size dial was added later (`--king-size`, commit 294e6b5).
- **Frame:** `M:frames/king-size-option.png` (64 px/m, 1.3 vs 1.2).
- **Codex images used today:** 1 of the ~25 budgeted.

### Gates
- **Last full run:** on a clean tree at 8dbf7f4, with `node tools/evidence/run.mjs --no-bench`. Results:
  - lint 13/13;
  - unit 326/326;
  - scenarios 8/8;
  - parity: 1200 steps exact, and the planted mutation was caught at step 629;
  - look goldens 11/11 (worst 1.37) and block 5/5 (worst 0.91), unblessed;
  - "no new off-doctrine accents".
- **Re-runs on HEAD:** unit 326/0 and scenarios 8/0 at 17:01, lint 13/13 at 17:12.
- **Rig bench A/B vs main** (headless CPU, CONTENDED): no rig-cost change. **Evidence:** `evidence/d5-cast/rig-bench-ab.json`.

## What does not work / is open
- **Possible perf gap.**
  - In the GPU bench A/B (`evidence/d5-cast/gpu-bench-ab.json`, 2+2 interleaved, CONTENDED), every section-20 limit passes.
  - But riot p99 CPU is ~4.9 ms on d-cast vs 3.2-3.5 ms on main, higher in both pairs.
  - The rig update is ruled out. Contention is the leading explanation, but that is unmeasured; the root cause is unknown.
- **Parked police cruisers** print their light bar as grey ink in the real game. `look_d4.gdshader` (d5-city's shader)
  has no cop-blue plate.
  - A tested 17-line fix is at `M:look_d4-cop-blue-plate.patch`. It is REQUEST 4 -> d5-city and is not landed.
  - **Evidence:** `evidence/d5-cast/cruiser-parked-plate.json` and `M:frames/parked-cruiser-plate-ab.png`.
- **Moving cruisers on d-cast alone** print the blue bar as soul-teal. They need d-city's `look_d4_item` cop-blue plate,
  so **merge d-city before or with d-cast**.
- **D5 grime on the outer crowd at 64 px/m.** In the real game, only the 16 nearest people get the D5 tier; the rest are
  D4 atlas cells.
  - A D5 atlas twin was tried 3 times and not shipped. One attempt was committed as 7f187e1 and reverted in f88df08.
  - In the 3rd attempt (`M:crowd-twin-v3.patch`), the extra bake was held out of the load timing.
  - It looks worse at 64: it bakes a thinner sticker rim. That is consistent with the live full rigs, but the crowd
    separates less from the asphalt.
- **Not done:** an uncontended 3+3 bench. The bench lock was held by other lanes at almost every check from 16:09 to 17:19.
- **Doc nit:** the "cops in blue" line in `docs/decisions.md` cites `evidence/cop-gate.json`. The real path is
  `evidence/d5-cast/cop-gate.json`. Not fixed in the REPORT phase.
- **Pre-existing, not this lane:** `run_scenarios` prints exit-time ObjectDB / resource leak lines. main prints them too.

## What blocked me, and for how long
- **The bench lock**, from about 16:09 to 17:19 (~70 min). Every GPU bench in that window was skipped, by the rule.
  Only one window (16:20-16:40) gave the 2+2 A/B.
- **Waiting on d5-city's look_d4 cop-blue plate** (REQUEST 1 -> 3 -> 4), from 10:50 to the end of the day. I worked
  around it with a tested patch; nothing was waiting on it.
- **A flaky unit test,** `test_noir_shadows` ("Parameter t is null"). It failed 3 times inside evidence runs and passed
  each re-run. It cost re-runs, not hours.
- **Gap in commits:** none on this branch between 13:20 and 15:40. The journal gives no reason.

## Owner choices for the 18:00 sync (each is one revert or one constant)
1. **Rivet's stance:** the T2 hunch at 1.2 (shipped), or the open guard = revert 062939d and 8118692.
2. **King's size:** 1.3 (shipped), or `KingPlan.SIZE_K = 1.2` (`M:frames/king-size-option.png`).
3. **Cop heads:** T1 cream domes + ink ring (shipped), or navy = revert 704570f, 34acc56 and 90bb8f6. For the portraits'
   black helmets, also revert 02d459e.
4. **Cop shoulders:** A, blue-hi balls (shipped), or B, navy with a small core (`M:recolor_cops.py` `shoulder_marks`).
5. **King's portrait cape:** vermilion (shipped), or ink (`M:frames/king-cape-option.png`, `M:king_cape/`).
6. **The D5 crowd twin at 64 px/m:** off (shipped), or `M:crowd-twin-v3.patch`, then re-bless the goldens.

## Next steps
- **Merge recipe** (proved on 3 scratch merges; 0 code conflicts with every day lane at 16:12):
  1. Merge d-city, then d-cast. For JOURNAL.md, keep both sides; for the goldens, take either side.
  2. Apply `M:look_d4-cop-blue-plate.patch`.
  3. Delete the `accent_debt` rows `cop_vermilion_32/48/64`.
  4. Run `look_golden --bless` once on the fully merged tree (d-city, d-combat and d-bodies also move the goldens), with
     a decisions line.
  5. Re-run the selftest unblessed.
- **Perf:** run a 3+3 riot A/B, d-cast vs main, on a quiet machine. Only if the gap holds, bench
  `M:perf-bisect/A-revert-print_part-copblue.patch`, then `B-revert-cop-head_swap.patch`. A bench worktree needs
  `build/export/windows-bench/` created first.
- **After the merge:** shoot a city_frame with a parked and a moving cruiser on screen, and check that both bars print
  cop blue.
- **Later:** King goes into the game with the boss ticket (KingPlan is ready). The ghost form is a new `RivetPlan.FORMS`
  row. The souls stay behind `--souls` until a combat mechanic uses them.
