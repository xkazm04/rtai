# REPORT: night lane d5-close (branch `n-d5`), 2026-11-02 21:10 to 2026-11-03 08:15

Mission: push D4 "Ink and Hatch" toward D5 "Inked Grime" (the Rivet concept) where it survives: up close
(64 px/m and above, kill-cams, dialogue, phone, loading art) and on large world surfaces (landmark roofs, big decals).

Paths below are relative to the lane cwd unless they start with `<masters>` =
`C:\Users\kazda\kiro\gtai-masters\night\d5-close\`. Boards in `evidence/` are untracked PNGs (16 MB); a copy of each
is in `<masters>`. The full board index, measurements and every gap list are in `evidence/README.md` (the morning
merge sheet). The running log is `JOURNAL.md`.

## Summary
- **What is live in game code once merged:** only the D5 character detail tier (`RigDetail`, called from
  `CharacterRigs`). Everything else is shaders, params and art that render in the lane's deterministic dev scenes
  (`project/dev/showcase/d5_*.gd`). The visual-engine, city, characters, HUD and combat lanes still have to wire
  them (JOURNAL NEXT 1, 2, 16 and later). The merge sheet's heading "On by default when merged" means "on in the D5
  scenes and in the params defaults". It does not mean the city uses them yet.
- 50 Codex images (the night's budget, all spent by 02:06). 0 were rejected for camera breaks. 2 were rejected for
  other reasons (mural_c, warehouse_b). Ledger: `<masters>gen/ledger.tsv` (50 lines). Every D5 PNG has a provenance
  line in `steam/ai-provenance/2026-11.jsonl`, and `project/tests/unit/test_d5_provenance.gd` guards that.
- 374 commits on `n-d5` (291 files, +11707). Gates are green at 850652b (only docs changed since).

## What works (claim -> evidence)
1. **D5 hero tier on the same rig** (work item 1). There are 4 Rivet sheets, 3 cop sheets and 3 ped sheets. Each is
   cut with the D4 sheet's geometry and uses the D4 alpha (silhouette lock), installed at
   `project/features/characters/art/d5/{rivet,cop,ped}/`. They are drawn as overlays by
   `project/assets/shaders/look_d5_part.gdshader`. The overlay comes on at 56 px/m, is full at 64 and goes off below
   54 (the gap is hysteresis).
   - At 64 px/m it reads closer to the concept than D4 (rust, hatch, ink pressure, off-register vermilion, form
     shade): `evidence/item1_gate.png` (concept / 32 / 48 / D4@64 / D5@64 / D5@96), `evidence/item1b_form_shade.png`,
     `evidence/item1c_shade_k.png`, `evidence/item6_cop_shade.png`, `evidence/item13_killcam128.png`.
   - The fallback is clean. 0 pixels change at 32, 48, 54 and 56 px/m. The zoom sweep is a monotone fade with no pop
     (mean |D5-D4| is 0 at 51-55 and 0.003 to 0.066 at 57-67). Walk shimmer D5/D4 is HF 0.97, re-run at 1.022.
     Measured by `project/dev/showcase/d5_sweep.gd` and `d5_walk.gd`; numbers in `evidence/README.md` under "Motion".
   - The zoom stops are pinned to the code by `project/tests/unit/test_look_d5_params.gd` (checked by mutation).
   - Cost with 16 full rigs at 64 px/m on an RTX 4090: +0.054 to +0.064 ms GPU for the parts and +0.075 ms total
     with the world layer (`evidence/d5-cost.json`).
2. **`look_d5` world print layer** (work item 2). It adds ink-pressure hatch, paper age and grain, and
   misregistration. Amount is 0 at 32 px/m, 0.35 at 48 and 1.0 from 64. Files: `project/assets/shaders/look_d5.gdshader`
   and `project/assets/shaders/look_d5.params.json`.
   - 32 px/m is unchanged from D4 by construction: `evidence/item7_paper_age.png`, `evidence/item2b_street48.png`.
   - The first street hatch read as rain and was reverted (JOURNAL 21:25).
3. **Landmark roofs and big decals** (work item 3).
   - 7 pen-hatch roof plates (union-fist mural, bar, LOCAL 9 union hall, HQ, pension bank, OSHA, tall) in
     `project/features/city/art/d5/roofs/`, gated against D4 at 32 and 48 px/m: `evidence/item3_roofs_gate.png`,
     `evidence/item21_mural_pen.png`, `evidence/item15_local9.png`. The mural at 32 px/m went from L 0.487 / paper
     0.28 to 0.593 / 0.44 (mock 0.589 / 0.41).
   - Street decals: `evidence/item10_street_decals.png`, `evidence/item33_strike_lane.png`.
   - Ground tiles: `evidence/item22_pavement_joints.png` to `evidence/item25_road_dashes.png`.
   - Pen-stroke cast shadows (`look_d5_shadow`): `evidence/item8_shadow_hatch.png`,
     `evidence/item54_rig_shadow_lock.png`.
4. **Hero shot** (work item 4). Rivet versus 2 cops at the mural / LOCAL 9 junction at 32, 48, 64 and the 128 kill-cam,
   beside `d4h2_mock.jpg` and the concept: `evidence/item4_hero_vs_targets.png`, `evidence/hero-d4d5-{32,48,64,96,128}ppm.png`
   (the D4-only controls are `evidence/hero-d4-*ppm.png`). Boss arena: `evidence/arena-d4d5-{64,128}ppm.png`,
   `evidence/item18_arena.png`. The reproduce commands are in `evidence/README.md`.
5. **Close-up art** (work item 5), all installed:
   - 3 portraits plus Rivet, King and cop expression sets: `evidence/item5_portraits.png`,
     `evidence/item5c_{rivet,king,cop}_expressions.png`.
   - Loading illustration: `evidence/item5b_loading.png`.
   - 3 finisher panels: `evidence/item5d_finisher.png`. `finisher_k9.png` is in-game only.
   - Boss intro card: `evidence/item5e_boss_intro.png`.
   - Phone frame: `evidence/item19_phone.png`.
   - Dialogue panel in-engine: `evidence/item17_dialogue.png`.
   - Souls through `look_d5_soul`: `evidence/item4c_souls_print.png`.
   - The store-safe marks are mine; owner review is pending.
6. **Gates** at 850652b (`node tools/evidence/run.mjs --no-bench`):
   - lint 13/13 (`build/evidence/lint.json`), unit 152/0 (`build/evidence/unit-tests.json`), scenarios 8/0
     (`build/evidence/scenario-tests.json`), selftest ok (`build/evidence/selftest.json`).
   - Parity bit-exact over 1200 steps, with the planted mutation caught at step 629 (`build/evidence/parity.json`).
   - Bench PASS at 4b61ff4 (`build/evidence/bench.json`): p99 2.796 ms, 1% low 295 fps, 0 hitches over 50 ms.
   - So the D5 work does not touch the sim or the section 20 budget.
7. **Ladder:** `evidence/ladder.png` (the lane's running before/after ladder; master copy in `<masters>ladder.png`).
   Every A/B round's frames are in `<masters>frames/`.

## What does not work, or is not done
- **D5 detail does not survive at 32 px/m on characters.** This was expected, and the tier is correctly off there
  (`evidence/item1_gate.png`, column 2).
- **Most of the D5 layer is not wired into the game.**
  - `look_d5` over look_d4 in the city: needs the visual-engine lane, zoom blend from `look_d5.params.json`.
  - D5 roofs, ground tiles and decals: needs the city lane.
  - Prop and rig shadows: city and characters lanes.
  - Portraits and phone: HUD lane.
  - Finishers and boss intro: combat lane, on `Events.boss_engaged`.
- **"Package v9" is a proposal, default OFF.** It is look_d5_print + age/grain floors + paper_hi + halo + v9 roof
  plates, and it is the closest frame to the mock tonight at 32 px/m: `evidence/hero-pkg9-32ppm.png`,
  `evidence/arena-pkg9-{64,128}ppm.png`, `evidence/item35_all_proposals_iter7.png`. It is not adopted because it
  changes the shared look_d4 print (visual-engine lane), and under a sub-pixel camera its pans flip more pixels
  (`<masters>item54_shadows_subpx.png`; JOURNAL NEXT 41).
- **Remaining gap to the mock** (see "Gap list after iteration 9" in `evidence/README.md`):
  - Whole-frame L is 0.457 vs 0.475 at equal framing. All of it is paper tone.
  - The light-wash spread and soft pencil greys in the roof art.
  - Heavier parapet outlines.
  - All three need new plates, so they wait for Codex budget.
- **Remaining gap to the concept up close:**
  - King is a static plan-view sprite with no rig.
  - Rivet's steel is lavender, not the concept's mauve (owner A/B).
  - The red misprint (`fringe_k`) and halftone (`dots_k`) are owner A/B options and default off:
    `evidence/item9_steel_owner_ab.png`, `evidence/item43_fringe_owner_ab.png`, `evidence/item47_dots_owner_ab.png`.
- **Not measured:** a min-spec GPU, and the GDScript cost of `RigDetail`'s per-frame material updates.
- **Reverted because worse in-engine:**
  - Street hatch r7 (read as rain).
  - The fibre tooth.
  - The texture-swap tier (1 px outline pop).
  - The vermilion fist mural (7.2% vermilion competed with the cops).
  - Bold Rivet re-inks.
  - The composited ruled roof hatch.
  - Asphalt grain h93.
  - Bolder part lines h65.
  - King through look_d5_part.
  - `rgss` part sampling.
  - Soft rig-shadow edge.
  - A hint_range test (measured hollow).
  - Full list in the JOURNAL summaries.

## What blocked me, and for how long
- **No hard blocks.** The Codex budget (about 50 images) ran out at 02:06. That was the budget, not a rate limit.
  From 02:06 to 08:15 the work was shader, compositing and measurement only.
- **Friction.** I did not time it separately; each item cost a re-run:
  - A parse error in a `-s` run script hangs the Godot launcher with exit 0. Seen twice, each time lost to the timeout.
  - Hero shots taken without `--borrow=` had no street life and were re-shot. Seen 3 times.
  - `GODOT_BIN` was unset in a new shell, which gave stale unit counts. Seen twice.
  - The evidence tool refuses a dirty tree, so the 104 untracked PNGs were moved aside each run.
  - The `gen.sh` limit grep matched "429" inside token counts (false positive).
  - The bench needed `build/export/windows-bench/` to exist (about 10 min, iteration 18).
- **No native build** in the worktree until iteration 18, so parity and bench were unmeasured on this branch until then.

## Next steps (owner / Director)
1. Merge `n-d5` per the merge sheet in `evidence/README.md`. Only `RigDetail` and the two `character_rigs.gd` /
   `cut_rig.gd` hooks change runtime behaviour.
2. Visual-engine lane: read `look_d5.params.json`, drive `look_d5` `amount` from the zoom blend, and decide on package
   v9 together with a pixel-snapped world camera.
3. City lane: adopt the D5 roofs, ground tiles, decals and prop shadows (`D5HeroPropShadow` is the recipe).
   Characters lane: move `D5RigShadow` into `CharacterRigs`.
4. Owner A/Bs: steel lavender vs mauve (`item9`), zebra tone (`item27`), rim +1 px (`item38`), vermilion misprint
   (`item43`, a colour-doctrine call), halftone dots (`item47`), and the store-safe marks on the close-up art.
5. Next Codex budget: new roof plates with lighter parapets and soft pencil mid-tones (gap list 9.2, 9.4), and a
   rigged King.
6. Shared tooling: `tools/bench/run.mjs` prepare() should create the export folder (JOURNAL NEXT 51). Add hint_range
   to the `look_d5*` uniforms, with a before/after frame diff (NEXT 50).
