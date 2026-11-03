# REPORT - night lane d4-production (branch `n-d4`), 2026-11-02 21:09 to 2026-11-03 08:15

Mission: bring every visible placeholder up to D4 "Ink and Hatch" quality (art assets, manifest, provenance only).
`masters:` = `C:\Users\kazda\kiro\gtai-masters\night\d4-production\` (outside git). Day-by-day record: `JOURNAL.md`.
Evidence index for the in-tree evidence: `evidence/README.md`. Every path cited below was checked to exist at 08:20.

## Headline

- **The city texture table has 0 placeholders. It started the night with 22** (vehicles 44-53, decals 54-64, kerb corner 10).
  The selftest prints "72 art textures, 0 placeholders" (`evidence/iter27/gates-31f8c4c.txt`).
- All 5 work-order items have shipped art, each with before/after frames of the same scene at 32 and 48 px/m (64 on
  the boards). Running ladders: `masters:ladder.png` and `masters:ladder2.png`. Summary sheets:
  `evidence/iter14/night_iter14_summary.png`, `evidence/iter16/night_iter16_summary.jpg`,
  `evidence/iter18/night_iter18_summary.jpg`.
- **Gates are green at HEAD 0e733b6** (re-run for this report, `evidence/report/gates-0e733b6.txt`): lint 13/13 over 176
  files, unit 142/142, scenarios 8 ran / 0 failed, rc 0 (replay_60s final `cbeb734ff9b97c41`).
  The last full `tools/evidence/run.mjs`, bench included, was at 31f8c4c. All 6 checks passed
  (`evidence/iter27/gates-31f8c4c.txt`): parity bit-exact, bench p99 6.5 ms, 1 % low 110 fps, 0 hitches. The bench box
  was contended (see Blocked). Since 31f8c4c only JOURNAL / evidence files have changed.
- Branch: 298 commits on top of main, 417 files, 191 PNGs. Nothing pushed or merged.
- Codex: **29 images, 194 cells, 7 rejected** (camera breaks / side or front views), no usage limit hit. That is under
  the ~60-image cap. Provenance: `steam/ai-provenance/2026-11.jsonl` has 517 lines, all parse; procedural redraws carry
  a `code:` tool line. `art_src/d4.manifest.json` lists 51 masters, and all 51 sha256 match (iteration 27 check).

## What works (claim -> evidence)

| # | Work order item | Shipped | Evidence |
|---|---|---|---|
| 1 | Vehicles: 3 sedans + grey sedan, taxi, police cruiser (vermilion on the light bar only), van, pickup, ambulance, hatchback; 2 damage states each; burnt wreck; teal hijack overlay | `project/features/city/art/vehicles/` (+ README); table ids 44-53 wired, ids and footprints unchanged. Bold 5 px inner ink stroke, near-black glass, D5 ink grime on intact cars (54bf23f). Traffic atlases `traffic_atlas.png` / `_hijack.png` / `_d1.png` / `_d2.png`, 3 x 3, cell = sim art id | `masters:before_v/`, `after_v/`, `after_v2/` (table, 32/48/64), `masters:board_i18/extras/` (damage, wrecks, hijack), `masters:target_compare.png`; moving traffic `masters:before_tr/`, `after_tr/` |
| 2 | Kerb corner, decals (oil, skid, glass, tank tracks, blood s/m/l, scorch x2, bullet holes, puddle ...), 7 generic roofs, street furniture | Kerb corner (procedural, joins both straights); 11 table decals + dynamic decals (`features/city/art/decals/README.md`); `features/city/art/roofs/roof_*.png` (7); all 20 F-08 props given an ink stroke; lamp post, payphone, vending machine, mailbox, bollard redrawn; ground tiles calmed toward the target (paving joints, zebras, cream kerb, asphalt grain, patches removed); oil_stain re-inked (cbde379) | `masters:after_d/`, `masters:after_r/`, `masters:board_i18/{decals,props,roofs}/`, `evidence/iter18/asphalt_patches_nd4_ab.jpg`, `evidence/iter18/junction_wedge_ab.png`, `evidence/iter21/oil_city_ab.jpg` |
| 3 | FX sheets: muzzle x3, tracer, impact puff, 8-frame explosion, smoke, debris, crackle, ink blood burst, casing | `project/features/fx/art/fx_atlas.png` 8 x 4 x 256 px, layout in `features/fx/art/README.md`. Ink splat = one ink pool with a cream sticker edge (165ae0f). Inked arc ball (fc6501c). Seen in n-visual's real FX system | `masters:after_x/`, `after_x2/`, `masters:after_i14m_fx/fx-32ppm-1-fx.png` |
| 4 | Cream-coat ped fix + more looks | Coat / hat brim re-toned to print density 0.39 (parts layout unchanged); 5 new parts (hoodie, overalls, cap, bald, beanie) in `features/characters/art/ped/parts.json`; sleeve value variants `_dark` / `_grey` (767ee6c); 14 px arm outline so cream sleeves don't vanish on cream paving (97558d7) | `masters:before_c/` and `after_c2/` (rig 32/48), `masters:before_p/` and `after_p/` (parts 32/48/64), `evidence/iter16/night_iter16_summary.jpg` |
| 5 | Pickups + HUD | 11 pickup tokens `project/assets/pickups/` (+ accent table README); HUD frames (cash, wanted + pips, ammo ticket, soul cards idle / teal-active, memo) plated with an ink rim, soul portraits, flat vermilion heat pip (62923f7), inked numeral strip `features/hud/art/hud_digits.png` | pickups `masters:after_k/`; HUD drawn in-engine through the dev overlay `dev/showcase/hud_overlay.gd`: `masters:after_hud/`, `after_hud2/`, `masters:after_hud3/city-0-32ppm-hud40.png` |
| - | Evidence rigs (dev only) | `project/dev/showcase/asset_board.gd` (`--page=table|extras|props|decals|roofs|fx|hijack`), `parts_board_run.gd`, `city_frame.tscn` (real World + CityView, 3 foci, `--hud= --cars= --police=`) | `masters:before_city/` vs `after_city/` (22 -> 0 placeholders in the city) |
| - | Quest 1 (the only playable quest) in D4 | places, cast (Rivet, patrol cops, robots, guards, Mertz), Toner Room floor (d6317ee), fire FX seen from above. The view code is a patch (see below) | `evidence/iter14/night_iter14_summary.png`, `evidence/iter16/morning-full-stack-gates.txt` |

**Morning merge dry run** (iteration 16, `evidence/iter16/morning-full-stack-gates.txt`): main + n-d4 + n-visual + the 4
patches. Every merge is clean except `JOURNAL.md`. Every patch applies and the re-bake matches the golden.
lint 13/13, unit 260/260, scenarios 8/8, parity exact. Re-checked on n-visual ce0db12 in iteration 18
(`evidence/iter18/morning-stack-gates.txt`: unit 266/266).

## What does not work / not done

- **No game code was changed. Wiring that needs code is delivered as patches, not commits:**
  - REQUEST 16: quest 1 view art, `evidence/iter14/q1_view_art.patch`.
  - REQUEST 19: generic roofs in the generator pick, plus street variants. `evidence/iter10/generator_art_pick_v2.patch`
    moves the AST-12 golden list.
  - REQUEST 21: the new crowd looks and sleeves, `evidence/iter16/rig_sleeves_and_looks.patch`.
  - REQUEST 23: FX muzzle / crackle fade, `evidence/iter14/fx_fade.patch`.
  - REQUEST 18: traffic atlas wiring, `masters:traffic_atlas_wiring.patch` / `masters:traffic_atlas_wiring_after_n-visual.patch`.
    It may be unnecessary, because n-visual wired the atlas itself.

  Until these are applied, the generic roofs, new ped looks and quest 1 art are **not visible in the game**.
- **On n-d4 alone, moving traffic still draws a grey slab.** The merged stack (n-visual) draws the atlas cars.
- **The damage-state, wreck and hijack atlases appear only on the dev board.** Nothing in the code switches a moving car
  to them yet (a per-car state hook is needed; that is code).
- **Pickups under the world pass (look_d4) at 32 px/m:** the Sobel edges fill the glyphs in. They read cleanly only in
  the item pass (REQUEST 2, visual-engine).
- **The HUD exists only as a dev overlay.** The game has no HUD scene, so it is judged on the overlay frames. No
  lettering font is bundled; the numerals are own art.
- **In-world soul sprites are not shipped** (REQUEST 24: n-d5 has D5 ones in its masters).
- **n-visual's look / block goldens must be re-blessed after the merge.** They were blessed without n-d4's art, so all
  16 move (`evidence/iter14/merged-n-visual-41ee996-gates.txt`).
- **Tried, then reverted or not shipped** (each has evidence):
  - Cop torso to ink navy (`masters:work/cop_ab.png`): the shoulders made a vermilion bullseye.
  - D5 hatch / grime on Rivet's parts (`masters:work/i16/rivet_ab_g2.png`): noise at 32/48.
  - Dock 9 charcoal floor (`evidence/iter18/dock_dark_rejected.jpg`).
  - Calmer pavement cracks (`evidence/iter20/cracks_calm_rejected.jpg`, `cracks_nochips_nogain.jpg`).
  - Grey "replaced slab" squares removed, then put back.
- **Gaps vs the target that this lane can't fix** (code / shader):
  - roof parapets and cast shadows;
  - the junction zebra layout (a ring round the centre tile vs crossings on the approaches);
  - street-clutter placement;
  - the aquatint blotches on cream paving at 64 px/m (REQUEST 22);
  - the speckled slabs should come from the print grit (REQUEST 20);
  - the soft grey disc round the explosion (lighting pass).

## Blocked / friction (and for how long)

- **No hard block.** Codex never hit a usage limit. On iterations 16-31 no new image was needed, so 0 images were drawn.
- **Bench contention, about 1 h 40 min in total.** In iterations 20-25 (06:40-07:30) other lanes' Godot processes were
  running, so I didn't run the bench. Every bench run tonight overlapped other lanes: it passed at 643996e, 4eed8e5 and
  31f8c4c, but **no clean idle-box bench exists**. The first run at 21:47 failed because the
  `build/export/windows-bench/` directory was missing in the fresh worktree (I created it; the runner doesn't).
- **`run.mjs` refuses a dirty tree** (my mistake, twice: I edited files while it ran). It cost one full re-run each
  time, about 15 min in total. The logs now go to /tmp first.
- **Renders during gates** failed `rig_stress` p50 once (1.02 ms > 1.0) because of contention. It passed when re-run alone.
- **New PNGs import with mipmaps off by default.** That made thin marks vanish at 32 px/m; fixed per asset.
- **Iterations 22-31 were check-only**, because there was not enough time before the freeze for a fully evidenced change.

## Owner decisions still open

1. Cop uniform: full vermilion (shipped) or an ink uniform with a small vermilion accent (needs a redraw)? Riots
   currently show dozens of vermilion bodies; the target's cop is ink and cream.
2. Blood: ink with a cream rim (shipped, as the brief asks) or vermilion (as the target frame paints it)?
3. Hatch Rivet's limbs for the 64 px/m boss arenas only? The variant is kept in `masters:work/i16/`.
4. Which font for the HUD / lettering, and should speaker names be vermilion?
5. REQUEST 24: who ships the in-world soul sprites?
6. Teal robot eyes: this doesn't apply to the top-down quest cast, because no eyes show from above.

## Next steps (morning order for the Director)

1. Merge `n-d4`, then `n-visual`. `JOURNAL.md` is the only conflict; keep both, since each lane keeps one at the root.
2. `git apply` REQUEST 16 (`evidence/iter14/q1_view_art.patch`), 19 (`evidence/iter10/generator_art_pick_v2.patch`),
   21 (`evidence/iter16/rig_sleeves_and_looks.patch`) and 23 (`evidence/iter14/fx_fade.patch`).
3. Re-bake (`just bake`), then re-bless n-visual's look / block goldens. Run `node tools/evidence/run.mjs` on an idle box.
4. Review the art commits; each one reverts on its own: 7a35d1b, 0b08658, 4cd1521, cbde379, 767ee6c, 97558d7, 165ae0f,
   d6317ee, fc6501c, 62923f7, 54bf23f. The originals are in `masters:backup_*`.
5. Code follow-ups (other owners):
   - the traffic damage / hijack state hook;
   - pickups in the item pass;
   - a real HUD scene using `features/hud/art/`;
   - roof parapets / shadows;
   - the junction layout.
6. Art follow-ups for this lane, once the owner decides:
   - the cop accent redraw (decision 1);
   - slice and ship the in-world souls (decision 5);
   - a vermilion blood variant (decision 2).
