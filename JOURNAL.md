# JOURNAL: lane weapon-art (night 2026-11-04, branch n-weapon-art)

## Iteration 1 (01:03-02:03)

- 01:03 Read: brief, gunplay REPORT (pistol prop candidate never landed; `held_scale` unread), d5-cast REPORT
  (cutout parts: flat fills, ink outline, 320 part px = 1 m, `claw_pistol` bakes the gun into the hand cell),
  image route §8, T2 concept, palette tokens. No other night-lane JOURNAL had a REQUEST yet.
- Registry rules applied (sprite-and-atlas-production, depth-ordered-layered-art): one coherent sheet per family so the
  design language holds across weapons; silhouette first (icons checked at small size); parts authored in rig part px
  with grip/muzzle as data, not baked into a hand cell; chroma key with tolerance >= 12 (the backend drifts).
- FRICTION 01:05 codex `image_gen` refused the first prompt (`moderation_blocked`, violence): words like pistol,
  rocket launcher, molotov. Rephrased as "scrap-built gadget props" with the same shapes: accepted. Keep weapon nouns
  out of image prompts (the data ids stay the working names).
- MILESTONE 01:15 core six side-view sheet (pistol, machine pistol, rocket launcher, flamethrower + tank, electro gun,
  molotov): one coherent design language (worn gunmetal, tape, rust, cream plates, bold ink, only vermilion = rocket
  nose stripe + molotov rag). Cut with `tools/art/weapon_cut.py`.
- DECISION weapon-art views: the SIDE view is the pickup (a gun lying on the floor shows its side) and the source of
  the HUD icon (cream silhouette in an ink ring); the TOP-DOWN view is the held part on the rig. Rejected: one sprite
  for both (a side-view gun in a top-down claw sticks its grip out sideways).
- DECISION weapon-art FX palette: muzzle flashes are paper with a vermilion core (fx layer, danger/hit_flash use);
  flame is vermilion with a paper core; electro arcs are paper with an ink ring, NOT teal (teal = souls only) and not
  cop blue. Procedural and seeded (`tools/art/weapon_fx.py`), so they stay byte-stable. Alternative for the owner: an
  energy accent ink for electro/plasma (a new palette token).
- MILESTONE 01:20 `data/tables/weapon_art.json` (gtai.weapon-art/1) + `WeaponArt` loader + `test_weapon_art.gd`:
  grip_px / muzzle_px measured from the held part (bore line), `make_held()` returns a Sprite2D whose
  origin is the grip at the drawn length (32 px/m), `muzzle_m()` = shot spawn offset, `fx_frames()`.
  Commit caff378f. Unit 702/702, lint 13/13.
- MILESTONE 01:25 lineup dev scene `dev/weapon_art/weapon_lineup.gd` (real cutout rig, look_d4, a cop):
  first frame showed the weapons hidden under the arm and too small. DECISION: held layer over the actors,
  drawn lengths 1.5x real (pistol 0.70 m), held parts through `print_part` (A/B frame). Commit 9723d420.
- MILESTONE 01:30 the nine melee/advanced weapons (side + top sheets), energy/nuke flashes, plasma bolt, ray
  rings, shard. All 15 rows. Commit 3e10c534. Unit 703/703. Answers rivet-arsenal REQUEST 2 (except gloria).
- `docs/art/weapons.md`: the design language, views, the contract (API), the pipeline.
- frames.json written (10 entries) at `gtai-masters/n4/weapon-art/frames.json`.
- FRICTION: Windows python writes CRLF and `1.0`; the table goes through `tools/art/canon_json.mjs` (the lint's
  own canonicalJson). New PNG imports default to no mipmaps; the rig parts use mipmaps, so the ingest needs a
  sed on `*.png.import` + a re-import (TODO: fold into a tool).
- 01:32 started brutality REQUEST 3 (gore bits sheet: stump caps, chunks, bone, splash, charred overlay,
  x-ray skeleton, ash), worded as "comic effect stickers" to pass moderation.

### Notes for other lanes
- To rivet-arsenal: merge or cherry-pick caff378f..HEAD. `WeaponArt.new().make_held(id)` parents to a socket;
  the dev lineup puts it at `hand.global_transform * (claw_w * 0.62, claw_h * 0.5)` and sets
  `plan.hand_pistol = plan.hand_closed` so the baked `claw_pistol` cell does not double the gun.
  Use `PartMaterials.get_mat(PartKind.PART, false, 0)` on it so it prints like the rig.
- To gunplay: shots and flashes spawn at `muzzle_m(id)` from the grip; flash frames `fx_frames(muzzle_fx(id))`,
  anchor `fx_anchor()`; projectile `fx_frames(projectile_fx(id))`; casing `casing_fx(id)`.
- MILESTONE 01:35 gore stickers for brutality REQUEST 3 (`art/gore/`: stump_round, stump_oval, chunks_3, chunk,
  bone, splash, charred, xray, ash; blood tokens only, comic ink). Not in weapon_art.json yet: load by path
  `res://features/combat/weapons/art/gore/<id>.png`. Lineup `--fire`: flashes cycle on the muzzles,
  projectiles ahead. Commit 295db1b3.
- MEASURE 01:36 FX at 1x part scale were specks at 64 px/m; at 2x they read at 64. At 32 px/m the cream flash
  and the cream tracer still wash out on cream paving (frame `lineup-core-fire-32ppm-2x.png`).
- 01:37 started the canon nail gun "Gloria" (side + top in one sheet, img06).

NEXT (iteration 2):
1. FX at game scale: regenerate `weapon_fx.py` with a thicker ink ring (about 14 part px) and an ink-dark tracer
   core or ink streak so flashes and tracers read on cream paving at 32 px/m; add `fx_draw_scale` (2.0) to the
   table + `WeaponArt.fx_scale()` so gunplay draws at the same size as the lineup. Re-shoot `--fire` at 32 + 64.
2. Ingest Gloria (img06 out/gloria.png: cut the 2 rows as side / top; add a ROWS entry, one_hand, ~0.75 m,
   flash_pistol, tracer -> a `nail` projectile cell), provenance, test count 16.
3. Add the gore cells to the table (a `gore` array in gtai.weapon-art/1 + `WeaponArt.gore_texture(id)`), tell
   brutality in JOURNAL. Consider top-down redraws of charred/xray if they read wrong on the rig.
4. Fold the `*.png.import` mipmaps sed + re-import into a tool step.
5. Arena station `data/tables/arena_stations/weapon-art.json` (a weapon rack of pickups); check the arena schema.
6. A real-time clip (not a still) of a Rivet firing each core weapon in the arena once rivet-arsenal's socket and
   gunplay's FX hookup land (merge their branches); until then a lineup clip with the flash cycling.
7. Read REQUESTs from brutality / gunplay / rivet-arsenal / human-reactions / showcase JOURNALs.
- MILESTONE 01:41 Gloria (canon nail gun, painted heart; downscaled 0.45 to the family's resolution, icon redone),
  FX thicker ink ring, `fx_draw_scale` 2.0 + `WeaponArt.fx_scale()` (NEXT item 1 half done: the 32 px/m read on
  cream is still weak). Commit f4abd9a5. Unit 703/703, scenarios 28/28, lint 13/13.
- Scratch sources for re-running the ingest live in `C:\Users\kazda\kiro\gtai-spike\weapon-art\{top,side,fx,img0N}`
  (outside git; raw sheets + prompts are also in masters `raw/`). Keep them until the art is final.
- frames.json: 13 entries (design-sheet-all16 replaces all15).
- 01:43 arena station deferred (not enough time left to verify a capture). Findings for iteration 2: stations are
  `data/tables/arena_stations/<lane>.json` (gtai.arena-station/1, areas range|pit|course|pad|hub; the hub rect is
  [-3,-5,18,10] m in `arena.json`); lane code is an `ArenaHook` script named by the row's `script`
  (res://features/...gd); `attach_view(view)` receives the `CollectCallView` (`px_per_m`), called from
  `dev/arena/arena_game.gd:89`. Plan: `features/combat/weapons/art/weapon_rack_hook.gd` lays the 16 pickups as a
  rack in the hub (props `weapon_rack`), shot in `--arena` and `--arena=city` at 32 + 64 px/m.
- MEASURE 01:46 evidence gate (`node tools/evidence/run.mjs --no-bench --allow-dirty` at f4abd9a5): lint PASS 13/13,
  scenarios PASS 28/28, parity PASS (bit-exact, mutation caught at 629), selftest PASS (look 11/11 + block 5/5
  worst 0.00, no new off-doctrine accents), unit 702/703: the one failure is the known flake `test_noir_shadows`
  ("Parameter t is null"); re-run alone 2/2 pass. Logs: `evidence/weapon-art/evidence-it1.log`, `gates-it1/`.
  No bench (no runtime-path change: the art is not wired into the live game yet). Replay/parity goldens untouched.

## Calls for the owner (draft, for the REPORT)
- weapon-art-1: drawn length 1.5x real (pistol 0.70 m) vs real size. Frames: `lineup-core-64ppm.png` (1.5x) and the
  first lineup (real size, only the muzzle tips showed; regenerate with the old `length_m`). One value per row.
- weapon-art-2: held weapons printed through print_part (dark ink silhouette) vs raw colour. Frame: `print-ab-64ppm.png`.
- weapon-art-3: electro / plasma / ray effects paper-white in an ink ring vs a new energy accent ink (a palette token).

NEXT (iteration 2), in order: (1) the 32 px/m read of the flashes and tracers on cream paving (a darker tracer
core / ink streak; re-shoot `--fire`); (2) the arena weapon rack station (findings above); (3) gore cells into the
table; (4) the mipmaps import step folded into a tool; (5) a clip in motion once rivet-arsenal's socket lands
(merge n-rivet-arsenal); (6) read the other lanes' JOURNALs for new REQUESTs (brutality REQUEST 3 delivered; tell them).
- 01:50 tracer: charcoal body + paper hot head + ink ring; at 32 px/m it now reads as a dark streak on cream paving
  (`lineup-core-fire-32ppm-2x.png` re-shot). The pistol flash is still small at 32 px/m: next pass = bigger
  frame 0 (or fx_draw_scale per family) and a 1-tick paper bloom.

## Iteration 3 (01:53 - 02:53)
- 01:55 committed the unfinished iteration-2 work (2fda318d): rocket blast 4 frames, scorch decal, electro spark 3,
  Gloria's nail, bigger pistol/SMG flashes, gore stickers as `gore_*` fx cells (schema allows art/gore/), 
  `weapon_fx_table.py` folds the mipmaps import step (NEXT item 4 done). Test for the new cells. Answers gunplay
  REQUEST 3 (rocket body, flame loop, scorch, spark) and showcase REQUEST 5 (rocket body + smoke + blast) art-side.
- MERGE 01:58 n-rivet-arsenal (to 25e9a75d; it already holds n-gunplay to 671f61ce and my art to 295db1b3) into
  n-weapon-art (1658b421): RivetHeldView puts my held parts in Rivet's live claw; GunHand/FightAreas/FxView. JOURNAL kept ours.
- MILESTONE 02:02 `WeaponFxArt` (30a50cbc): the lane's cells in the LIVE fight. FxView + FightAreasArt ask it first
  (3 one-line hooks in gunplay's files: `fx_view.gd` shots + muzzle, `fight_areas_art.gd` blasts). `--weapon-fx=shapes`
  = the before. Gates at 30a50cbc: unit 724/724, scenarios 30/30, lint 13/13 (`evidence/weapon-art/*-it3.log`).
- MEASURE 02:00 arena rocket clip 64 px/m: full chain reads (launcher in the claw, tube flash at its mouth, rocket +
  tail flame + smoke, paper burst with a vermilion heart, vermilion fireball, smoke ring over the scorch, guard dies
  red). Defect found and fixed: the rocket drew over Rivet's chest for its first ticks (sim spawns at the body centre)
  -> `CLEAR_M` 1.1 m.
- MEASURE 02:05 flamethrower 64 px/m: round puffs = a row of beads; electro arc = a thin white scribble.
  -> `weapon_fx_jet.py`: flame tongues along the stream + an in-between tongue; bold arc stretched to bolt length
  (5400d4be). Re-shot: the jet now reaches the guard as one stream and the burn takes.
- FRICTION: the arena bot's timing is not reproducible across windowed runs for the electro gun (bolts at 40 m/s
  never landed in a sampled window twice); the electro arc in-game is NOT evidenced yet. The rocket runs ARE
  identical across runs (A/B on the same ticks worked).
- MEASURE 02:12 A/B rocket 64 px/m before/after on identical ticks; city block (`--arena=city`) rocket at 32 px/m:
  the burst and smoke ring read on cream paving. City hostiles still quest-1 discs (showcase REQUEST 6).
- Clips + frames in masters (`it3-*`), frames.json 15 entries (newest best first). Scratch AVIs in build/clips (ignored).
- Rules applied (realtime-combat-semantics / motion-quality-gating): render-only reads of sim state, no RNG, no
  delta; judged in motion at 64 and 32 px/m on the real rig; each defect seen in a clip, fixed, re-shot.

### Notes for other lanes (iteration 3)
- To gunplay: I touched your `fx_view.gd` (2 hooks) and `fight_areas_art.gd` (1 hook) on n-weapon-art: WeaponFxArt
  answers first, your shapes are the fallback. If you rewrite those lines, keep the `WeaponFxArt.shot/muzzle/blast`
  calls (or merge n-weapon-art). Your chain arcs, fire patches, burning humans and stun stay yours; my cells for
  them: `spark_0..2`, `flame_0..2`, `scorch`, `gore_charred`/`gore_ash` via `WeaponArt.fx_frames()`.
- To showcase (REQUEST 4 + 5): the white stick is gone once n-weapon-art (or n-rivet-arsenal) is in your branch:
  RivetHeldView draws the held parts; WeaponFxArt draws rocket + smoke + blast in the real fight. Nothing to wire.
- To brutality: gore stickers are fx cells now: `WeaponArt.new().fx_frames(&"gore_stump_round")` etc.

## Calls for the owner (adds)
- weapon-art-4: weapon-art cells (comic burst, vermilion fireball, smoke ring, scorch) vs gunplay's procedural
  shapes for the live fight. Frame `it3-rocket-ab-64ppm.png`, clips `it3-rocket64_after/before.mp4`. Default: cells.
- MILESTONE 02:19 spent brass + flash on the gun (782f7c6a): `WeaponCasings` (render-only, deterministic from the
  round count, cleared when the tick runs backwards, at most 24 on the floor) throws the `casing` cell off the gun
  claw's side; the muzzle flash moved from the body centre line onto the held gun's muzzle (`GUN_SIDE_M` 0.35 m,
  ahead 0.45 m), both measured in the 64 px/m machine-pistol clip (`it3-smg-flash-brass-64ppm.png`). The tracers
  (charcoal + paper head) read on the grey arena floor. `test_weapon_casings.gd` (3 tests).
- NOTE the rocket/flame clips in masters were shot before the flash moved onto the gun (flash on the centre line).
- DECISION brass side: casings fly to the gun claw's side (aim.orthogonal()), away from the body, not to Rivet's
  right as a real ejection port would: on the rig the gun sits left of the aim line and brass thrown right crossed
  his torso. Alternative = flip the sign in `WeaponCasings.track`.

- MILESTONE 02:24 casing in ink-2 with a paper rim at 1.3x (0ab63327): the first city pass (pistol, 48 px/m) showed
  the steel brass vanishing on cream paving; now dark specks that read on cream and on the grey arena.
  Clip `it3-city-pistol48.mp4`, frame `it3-city-pistol-brass-48ppm.png`. Unit 727/727 at aa414541.
- MILESTONE 02:27 rounds leave from the held gun (554c8df0): drawn rounds start `GUN_SIDE_M` to the gun side and
  converge onto the sim's line by `CONVERGE_M` 3 m; the 30 fps strip shows the tube flash at the held gun, then the
  rocket out of its muzzle. Rocket A/B and the headline clip re-shot with it.
- FINDING 02:27: in every `--weapon=` clip the claw holds Rivet's default gun, not the weapon he fires:
  `RivetHeldView` follows `StagePilot.hold.held` (WeaponHold), which GunplayHook's `--weapon` never sets.
- REQUEST 1 -> rivet-arsenal (cc gunplay): when GunplayHook arms `arena.gun` from `--weapon=<id>`, set the
  WeaponHold to the same id (or have RivetHeldView read `arena.gun.trigger.spec.id` when a table gun is armed), so
  the rocket launcher / flamethrower / electro gun are in the claw in the arena and city clips. weapon-art's held
  parts and grip/muzzle points for all 16 are in `weapon_art.json`; nothing else is missing on the art side.

NEXT (iteration 4), in order:
1. Electro gun in the live fight: the arc + spark are drawn but NOT yet seen in a clip (the bot's electro timing does
   not repeat across windowed runs). Use the arena range station (static dummies) or `--start=range` + a longer
   capture, find frames by tiling every frame around Rivet; judge the bold arc at 64 and 32 px/m.
2. Molotov in the live fight: the spinning bottle (`molotov` held part) + wick flame + the fire patch; same hunt.
3. The pistol end to end at 32 px/m in the city block (`--arena=city --weapon=pistol`): flash on the gun, tracer,
   brass on cream paving (does the cream casing vanish on cream? if so an ink-steel casing variant).
4. DONE 02:27 (rocket A/B + headline clip re-shot). Next: the held weapon matching the fired one (REQUEST 1 ->
   rivet-arsenal); once it lands, re-shoot the core six in the claw at 32 and 64 px/m (the in-game lineup, brief item 4).
5. Gunplay's chain arcs / fire patches / burning humans / stun still draw gunplay's shapes: offer `spark`, `flame`,
   `scorch`, `gore_charred` hooks the same way (one line each in `fight_areas_art.gd`), or REQUEST to gunplay.
6. The weapon-rack arena station (`arena_stations/weapon-art.json` + an ArenaHook laying the 16 pickups in the hub).
7. Brutality: check n-brutality's JOURNAL for how the gore cells are used; redraw any that read wrong on the rig.
- MEASURE 02:29 gates of record at ec1ad879 (final tree of iteration 3): lint 13/13 (655 files), unit 727/727,
  scenarios 30/30 (`evidence/weapon-art/{unit,scenarios}-it3-final.log`). Parity/replay untouched (render-only
  change; no sim file edited). No bench this iteration (render-only; the cells replace shapes of similar cost).
- 02:29 n-brutality uses `gore/ash.png`; `gore/charred.png` is a front view and unusable on the top-down rig.
  NEXT 8: redraw `charred` (and check `xray`) top-down, matching the human cutout rig's silhouette from above.
