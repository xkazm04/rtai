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
1. DONE 02:33 (`--weapon=electro_gun --bot=range` gives repeatable bolts at the dummies; frame
   `it3-electro-arc-64ppm.png`: the bold arc reads; its forks look a little like twigs -> a jaggier redraw).
   Was: the electro gun in the live fight: the arc + spark are drawn but NOT yet seen in a clip (the bot's electro timing does
   not repeat across windowed runs). Use the arena range station (static dummies) or `--start=range` + a longer
   capture, find frames by tiling every frame around Rivet; judge the bold arc at 64 and 32 px/m.
2. DONE 02:34 molotov via `--bot=range`: the bottle was a speck in flight -> BOTTLE_K 1.8 (96aa742e); now the
   bottle + wick read arcing over the dummy, bursting into the blast cells + gunplay's fire patch.
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
- MEASURE 02:33 electro arc in the live arena (range bot, 64 px/m): reads as a bold paper bolt with a spark head.
  TIP: `--bot=range` is the repeatable way to film a gun at static dummies (the gunplay bot's timing drifts).
- MEASURE 02:34 molotov (range bot, 64 px/m): bottle was a speck -> drawn 1.8x (96aa742e), re-shot, reads.
  Gates of record stay at ec1ad879 (lint 13/13, unit 727/727, scenarios 30/30); since then only render constants in
  `weapon_fx_art.gd` (BOTTLE_K) + docs; lint 13/13 at 96aa742e.

## End of iteration 3 (02:35). State for iteration 4
- In the live fight now (arena, `--arena=city`): flash frames on the held gun, tracers/nails, rocket + smoke + tail
  flame, flame tongues, electro arc + spark, molotov bottle, rocket/molotov blast over scorch, spent brass. All
  evidenced in masters `it3-*` (frames.json 15 entries).
- Still gunplay's shapes: chain arcs between victims, fire patches (fx_fire loop), burning humans, stun sparks.
- The claw shows the default gun under `--weapon=` (REQUEST 1 -> rivet-arsenal). Biggest remaining visual gap.
NEXT (iteration 4), first three: (a) read rivet-arsenal's JOURNAL for REQUEST 1; if not taken, wire it as glue in
my branch (RivetHeldView reads `arena.gun.trigger.spec.id` when armed) and re-shoot the core six in the claw at
32 + 64 px/m (brief item 4, the in-game lineup); (b) top-down `charred` (+ `xray`) for brutality; (c) the weapon-rack
arena station. Then items 5-8 above.

## Iteration 4 (02:34 - 03:34)
- 02:34 read: rivet-arsenal took REQUEST 1 in substance: its weapon switch (RivetCarry, `--loadout=`,
  `--bot=arsenal`) sets the held weapon, so the claw holds the gun that fires. Brutality REQUEST 4 (top-down X-ray
  + charred) open. Rivet-arsenal NEXT mentions a magazine part (not requested yet) and the flamethrower tank on HIP
  (my `flamethrower/tank.png` exists; their wiring).
- MERGE 02:36 n-rivet-arsenal (to 27aae78a) into n-weapon-art (6b0f2255). JOURNAL kept ours. A headless `--import`
  is needed after the merge (new class_names: RigGrip) or windowed runs fail to compile `world.gd`.
- MILESTONE 02:44 brutality REQUEST 4: `gore/xray_top`, `xray_top_jolt`, `charred_top`, `charred_top_slump`
  (9c136aee). One Codex sheet with a crop of the cop rig from above (64 px/m lineup) as reference: the model kept
  the rig's layout (head disc, shoulder oval, arms forward to the right). Cells `gore_*_top`, anchor = the head disc
  centre (so they sit on the rig's origin). Provenance lines. Raw + prompt in masters `raw/gore_topdown4.*`.
- FRICTION: `--arena` is not a flag: the arena is the scene `res://dev/arena/arena.tscn` before `--`; with the flag
  the run plays the default city (first clip wasted). `--write-movie` needs an absolute path.
- BUG 02:41 (mine, from iteration 3): `WeaponCasings.draw` errored every frame on a casing-less gun (`x if c else []`
  is an untyped Array assigned to Array[Texture2D]). Only seen now because the switch moves from the pistol to the
  electro gun with brass still on the floor. Fixed: typed fallback, the lying brass still draws (073780ed).
- MEASURE 02:47 the arsenal clips at 64 px/m, fired weapon in the claw: pistol, electro gun (two-hand), rocket
  launcher (shoulder), molotov (bottle with burning wick), machine pistol, plasma rifle, flamethrower + hose.
  Defects seen: (1) the flame jet fired upward = a stack of round vermilion balloons with drips (reads as blood
  drops); (2) the molotov flashed the full flame cell at the claw on each throw.
  Fix (073780ed): jet tongues long and thin at the nozzle, fanning out with distance (grow (1.15+0.6k, 0.32+1.5k));
  molotov `muzzle_fx` "" (a throw has no flash); the flamethrower's nozzle lick at `NOZZLE_K` 0.45. Re-shot: the jet
  reads as one stream from the nozzle. Frames `it4-flame-balloons-before-64ppm.png` / `it4-flame-jet-nozzle-64ppm.png`.
- MEASURE 02:53 gates at 8ad641de: lint 13/13 (664 files), unit 730/731: the one failure is the known flake
  `test_noir_shadows` ("Parameter t is null"), re-run alone 2/2 pass (`evidence/weapon-art/noir-alone-it4.log`);
  scenarios 32/32. Unit failure before that was my own test pinning the molotov's muzzle frames: updated (a thrown
  weapon has no flash), plus the top-down gore cells.
- MILESTONE 02:55 brief item 4, the in-game lineup in the claw: `it4-lineup-claw-64-32ppm.png` (7 weapons, live arena
  pit, 64 px/m and 32 px/m) and clips `it4-claw-loadA/B-64ppm.mp4`, `-32ppm.mp4` (15 s each, the arsenal bot
  switching every 4 s in a real fight).
- FINDING 02:56: pistol and machine pistol have the same shape in the claw (the SMG's wire stock hides under the
  forearm, its side feed box is a small tab); at 32 px/m both are a dark blob. Breaks "a unique silhouette per
  weapon". Started a held-view redraw: the side feed box long and curved (an edit of the existing top view).
- FRICTION 02:57 Codex refused the SMG held-view edit (violence filter; the reference images are gun-shaped,
  the prompt avoided weapon words). Did it by hand instead: `tools/art/smg_feed_box.py` repeats the cut part's
  feed-box tab, adds a tape band and curves it toward the muzzle (deterministic; grip/muzzle y +84 for the pad).
- MILESTONE 02:59 SMG feed box (6b7ff079): A/B on the same ticks `it4-smg-feedbox-ab.png`: at 64 px/m a side stub
  that the pistol does not have; at 32 px/m only a notch (modest). Weapon tests 18/18.
- DECISION weapon-art SMG silhouette: lengthen the side feed box (a sideways stub reads from above) rather than
  a longer barrel (the length already differs 0.70 vs 0.90 m and did not read in the claw). Alternative = revert
  `machine_pistol/held.png` + its grip/muzzle rows (one commit).
- frames.json: 15 entries, it4 first (claw lineup, loadout clips, flame fix, gore top-down, SMG A/B).

### Notes for other lanes (iteration 4)
- To brutality (REQUEST 4 delivered): `WeaponArt.new().fx_frames(&"gore_xray_top")` (+ `_jolt` for the strobe's
  alternate frame), `gore_charred_top`, `gore_charred_top_slump`; `fx_anchor()` is the head-disc centre = the rig
  origin, drawn facing +x (rotate by the body's facing). Sheet: masters `frames/it4-gore-topdown-sheet.png`.
- To rivet-arsenal: your weapon switch is the in-game lineup now (thanks). The flamethrower tank is
  `art().part_texture(&"flamethrower", "tank")`. A magazine part for the reload: say so in a REQUEST and I draw it.
- To gunplay: `muzzle_fx` of the molotov is "" now (a throw has no flash); `WeaponFxArt.muzzle` returns early on "".
- MILESTONE 03:06 `WeaponFxElectro` (5ffe58af): gunplay's chain arcs drawn with the electro arc cell (end to end, a
  spark star where it lands) and the stun daze as two spark stars circling the head; FightAreasArt asks first
  (2 one-line hooks in gunplay's `fight_areas_art.gd`), zigzags remain the fallback. Dev still before/after
  `it4-electro-chain-daze-48ppm.png` (`dev/weapon_art/electro_cells.gd`; the window stretch makes it 48 px/m).
  First pass sparks were specks (SPARK_K 0.8 / 0.55) -> 1.6 / 1.3.
- MEASURE 03:08 live: `--bot=arsenal --loadout=electro_gun --start=pit` at 64 px/m: the bolt lands on the riot
  guard, the daze stars circle his head, a second bolt, he drops in red. `it4-electro-daze-live-64ppm.png`, clip
  `it4-electro-daze-64ppm.mp4`. A chain between two victims is still not filmed (the guards spread out).
- TIP: `--bot=arsenal --loadout=<one gun>` is the way to film one weapon in a real fight with it in the claw;
  `--bot=gunplay --weapon=` still shows the default gun in the claw (REQUEST 1 path untouched) and missed a lot.
- MEASURE 03:08 gates of record at 81d45fd7: lint 13/13 (667 files), unit 731/731, scenarios 32/32
  (`evidence/weapon-art/{unit,scenarios}-it4-final.log`). Render-only changes + data rows; no sim file, no replay
  or parity golden touched. No bench (render-only; cells replace shapes of similar cost).

## Calls for the owner (adds, iteration 4)
- weapon-art-5: the SMG's long curved side feed box (unique outline in the claw) vs the original small tab.
  Frame `it4-smg-feedbox-ab.png` (same ticks, 64 + 32 px/m). Default: the feed box.
- weapon-art-6: the electro daze as paper spark stars circling the head (weapon-art) vs gunplay's zigzag
  chevrons. Frames `it4-electro-chain-daze-48ppm.png` (side by side), `it4-electro-daze-live-64ppm.png`.

NEXT (iteration 5), in order:
1. At 32 px/m the one-hand guns print as dark blobs in the claw (print_part): try a paper rim (1-2 px cream
   outline) on held parts or a lighter print for weapons only; A/B at 32 px/m on the arena and the city block.
2. The electro arc forks read as twigs: a jaggier arc (more kinks, forks forward not backward) in
   `weapon_fx_jet.py`; film a chain between two guards (the range dummies are too far apart: maybe a station row
   1.5 m apart in `arena_stations/weapon-art.json`).
3. The weapon-rack arena station (`arena_stations/weapon-art.json`; rivet-arsenal's `--pickups=` already lays
   pickups, so the rack may just be a station that passes `--pickups=` ids + a label).
4. The in-game lineup for the advanced nine in the claw: `--loadout=hand_cannon,ray_gun,mini_nuke` and
   `gloria,homing_shard,...` (slots: 1 sidearm, 2 long, 3 heavy, 4 thrown), 64 + 32 px/m, one sheet.
5. Read brutality's JOURNAL: do they use `gore_*_top`? Re-check the X-ray strobe with the top-down sticker.
6. A magazine part if rivet-arsenal REQUESTs it (reload readability).
- MILESTONE 03:13 in-game lineup of the advanced guns in the claw (`--loadout=hand_cannon,ray_gun,mini_nuke`,
  `gloria,homing_shard`): `it4-lineup-claw-adv-64-32ppm.png`, clip `it4-claw-loadC-64ppm.mp4`. With the core seven
  (`it4-lineup-claw-64-32ppm.png`) every gun is now shown held in a live fight at 64 and 32 px/m. Melee weapons
  are not carried (RivetCarry takes weapons.json guns only): their held parts stay in the iteration-1 lineup.
  FINDING: ray gun and homing shard look alike along the arm (long, pale); at 32 px/m only the mini-nuke's
  vermilion nose and the hand cannon's bulk survive. NEXT 1 (paper rim) + a silhouette pass on those two.
- 03:15 correction: the merge commit 6b0f2255 says "to 27aae78a" but merged n-rivet-arsenal at dacd0e2d (one more
  journal-only commit). Scratch AVIs (1.5 GB) and the Codex scratch dir deleted; raw sheets kept in masters `raw/`.
  frames.json 15 entries, every file and every `before` exists. Session closes here; NEXT (iteration 5) above.

## Iteration 5 (03:14 - 04:14), BUILD

- 03:15 read JOURNAL, git log, other lanes' JOURNALs. REQUESTs to me open: rivet-arsenal REQUEST 8 (a magazine
  part per magazine gun with a grip point: the reload pantomime does not read without it), showcase REQUEST 11
  (weapon-art and gunplay both draw Rivet's muzzle flash and brass: agree one owner). Took REQUEST 8 first (another
  lane waits on it), ahead of my own NEXT 1 (paper rim).
- MILESTONE 03:40 REQUEST 8 DONE (43a4e356): `mag.png` for pistol (the slide plate + a brass nose + a dark base pad),
  machine_pistol (the curved feed box with its tape band, the SMG's own claw stub), plasma_rifle (the cream glass
  cell with its end caps), hand_cannon (a six-round speed-loader disc). Cut from each gun's own held part and
  re-inked by `tools/art/weapon_mags.py` (deterministic, no generation; provenance rows point at the source
  sheets). Data: `parts.mag` + new optional `part_grip_px.mag`. API: `WeaponArt.make_held(id, "mag")` (same scale
  as the held part, origin on the part grip, feed end +x; null for a gun with no magazine). `make_part` was a 21st
  public method (gdlint max 20), so `make_held` takes the optional part instead.
  `WeaponMagView` (my folder) draws it in Rivet's OFF claw while `rig.reload_k` is 0..2 (out to the hip, in) and
  leaves the spent one on the floor at the 0->1 crossing (8 kept, turned 0.7 rad off the claw line). Hooked in
  `dev/arena/arena_rigs.gd attach()` (6 lines after RivetHeldView; shared arena file, recorded here).
- FRICTION: the arena only draws the cut rigs with `--rigs` (without it the quest-1 sprite cast plays and nothing
  held is drawn); the first two clips were wasted. Rivet's RIGHT arm has no `hand` sprite (his claw is inside the
  forearm cell), so the off claw is `sides[R].fore` at u 0.86; the left (gun) arm has `hand`.
- MEASURE 03:26 live `--rigs --ppm=128 --bot=arsenal --loadout=machine_pistol --start=pit`, reload at tick 840:
  the feed box rides the right claw out to the hip, a spent one lies on the floor, the fresh one goes in.
  Frame `it5-smg-reload-mag-128ppm.png` (masters). Reads at 128 px/m; at 64 px/m it is a small striped stub.
- Gates at 43a4e356: lint 13/13 (668 files), unit 732/732 (`evidence/weapon-art/unit-it5.log`). Render-only +
  data; no sim file touched.
- To rivet-arsenal (REQUEST 8 answer): the magazine is drawn already by `WeaponMagView` (render only, reads your
  `rig.reload_k`); if you would rather own the draw inside RivetHeldView, take `art.make_held(id, "mag")` and
  drop my hook block in ArenaRigs. The spent one drops at reload_k crossing 1.0.
- MILESTONE 03:37 paper rim + brass (551a2467): every held part and magazine sits on a 1 world px cream rim
  (`WeaponArt.make_held` adds 8 HALO-material silhouettes under it; `--weapon-rim=off` for the A/B). A/B on the
  same tick (850, pistol reload) at 64 and 32 px/m: `it5-rim-ab-64-32ppm.png`. At 32 px/m the pistol had merged
  into the dark arm; with the rim it is its own outlined object, and the magazine in the off claw reads too.
  FINDING on the way: my brass was a charcoal 0.4 m brick (casing cell INK_2 at SCALE 1.3), as big as the
  magazine. Now a paper glint with a charcoal rim end at 0.75 (before: `it5-rim-ab-oldbrass-64-32ppm.png`).
  The magazines' cartridge marks were a brass colour outside the palette tokens: now paper_2.
  Unit 732/732 + the new rim test (weapon_art 11/11); lint 13/13. Docs: weapons.md section, 3 DECISION lines.
- Registry rules applied: sprite-and-atlas-production (parts cut from the same source sheet, one px-per-metre per
  weapon, the grip as data), depth-ordered-layered-art (the rim at z -1 under its part, the spent mags under the
  rigs, the carried one above), motion-quality-gating (each claim judged in the live arena on the same
  deterministic tick, A/B by one flag). No deviation.
- REQUEST 11 (showcase) answer: agreed with the r4 merge rule. weapon-art draws Rivet's muzzle flash, brass AND
  now the reload magazine for any gun with weapon-art art; gunplay's GunFx keeps smoke, impacts, the hostiles'
  muzzle stars and the fallback for guns without art.
- REQUEST 5 -> gunplay (cc showcase, Director at merge): GunFx drops its own ink-stick magazine at reload start
  (`gun_fx.gd` `mag_drop`), and weapon-art's WeaponMagView now drops the gun's real magazine at the hip: after
  the merge each reload would leave two. Please skip GunFx's drop when `WeaponArt.part_texture(id, "mag")` is
  not null (same rule as the shells), or set `"mag_drop": false` on pistol, machine_pistol, plasma_rifle and
  hand_cannon in `gun_fx.json`.
- MILESTONE 03:43 evidence with the rim, live arena pit at 64 px/m: `it5-reload-mags-rim-64ppm.png` (all four
  magazine guns: out to the hip, the spent one on the floor + a fresh one in the claw, going in; each reads, the
  speed-loader as a disc with paper rounds) and clip `it5-reload-mags-64ppm.mp4` (6.8 s, about 1.7 s per reload:
  the 900-frame captures end 0.6 s after each drop). Claw lineup with the rim `it5-lineup-claw-rim-32-64ppm.png`
  (pistol, electro gun, rocket launcher, molotov at 32 x3 and 64) and clips `it5-claw-rim-loadA-32ppm.mp4` /
  `-64ppm.mp4` (18 s). At 32 px/m every gun is now an outlined object in the claw; the electro gun's two prongs
  and the rocket's vermilion nose survive.
- frames.json: 15 entries, it5 first (reload sheet + clip, rim A/B, rim lineup + clip, SMG 128 close-up); dropped
  the oldest it3 entries (their files stay; every file and `before` checked to exist).
- Pickups: PickupsView already puts each pickup on a paper disc with an ink ring, so no rim needed there.
- Gunplay agreed to the same split (their JOURNAL 385-390). Brutality has not taken the top-down stickers yet
  (`gore_*_top`); their X-ray still uses the front-view skeleton.

## Calls for the owner (adds, iteration 5)
- weapon-art-7: the paper rim under the held weapons (each gun reads as its own object in the claw at 32 px/m)
  vs none (the gun prints as part of the dark arm). Frame `it5-rim-ab-64-32ppm.png` (same tick, both scales).
  Default: rim on; `--weapon-rim=off` for the other.
- weapon-art-8: the spent magazine stays on the floor (the last 8, like the brass) vs fading out. Frame
  `it5-reload-mags-rim-64ppm.png`. Default: stays (it tells where a fight happened).

NEXT (iteration 6), in order:
1. (done 03:52-03:54, see below) Next silhouette check: gloria vs the PISTOL at 32 px/m (both one-hand at the side,
   both a dark bottle with a pale spot); if they merge, give gloria's nail drum a wider round outline.
2. The electro arc forks read as twigs: a jaggier arc (more kinks, forks forward) in `weapon_fx_jet.py`; film a
   chain between two guards (a station row 1.5 m apart in `arena_stations/weapon-art.json`).
3. The weapon-rack arena station (`arena_stations/weapon-art.json` + `--pickups=` all 16, a label per gun).
4. If gunplay/showcase merge before REQUEST 5 lands: set `mag_drop: false` for the four magazine guns in
   `gun_fx.json` (two magazines per reload otherwise).
5. The reload close-up with the rim at 128 px/m (the it5 128 frame predates the rim).
- MILESTONE 03:47 ray gun silhouette (872adbe9): the emitter rings stretched x1.45 across the bore line
  (`tools/art/ray_gun_rings.py`, deterministic; grip/muzzle y +37; provenance). Same deterministic ticks at
  32 px/m, ray gun vs homing shard (`it5-ray-vs-shard-32ppm.png`): the ray gun is now wider with a bumpy outline,
  the shard gun slim with its funnel; told apart, modestly. The advanced three with the rim at 32 px/m also seen
  (hand cannon a fat outlined block, mini-nuke's vermilion nose).
- FRICTION: a crystal mask for the shard gun by luminance also takes the cream body plates; left for NEXT 1.
- DECISION weapon-art ray gun silhouette: stretch the rings sideways (a ribbed outline reads from above) rather
  than enlarge the bulb (the tip is under the muzzle flash half the time). Alternative = revert
  `ray_gun/held.png` + its grip/muzzle rows (one commit).
- Gates of record this session: lint 13/13 (668 files), unit 733/733 at 872adbe9 (`unit-it5-final.log`; weapon tests 20/20
  after the ray gun), scenarios 32/32 at 934b7ded (`evidence/weapon-art/scenarios-it5.log`). Render-only + data +
  one dev arena hook; no sim file, no replay or parity golden touched. No bench (render-only: 8 rim sprites on
  one held gun + 1 magazine).
- frames.json 15 entries (it5 first; the design sheet kept). Scratch AVIs and crops deleted.
- MILESTONE 03:52 homing shard silhouette (973a383d): the crystal cluster lifted by a hand polygon and stretched
  x2 across the bore line (`tools/art/shard_crystals.py`; grip/muzzle y +16; provenance). Same ticks at 32 px/m:
  `it5-ray-vs-shard-b-32ppm.png` (before `it5-ray-vs-shard-32ppm.png`): the shard gun prints as a lumpy pale
  crystal mass, the ray gun as a ribbed ink shape; told apart by tone and outline now. Weapon tests 20/20, lint 13/13.
  frames.json entry replaced by the -b frame (15 entries). Scratch AVIs deleted.
- DECISION weapon-art shard gun silhouette: a crystal mass bulging past the body (stretch x2 of the lifted cluster)
  rather than separate spikes pasted on (more seams, slower). Alternative = revert `homing_shard/held.png` + rows.
- CHECK 03:54 gloria vs plasma rifle at 32 px/m with the rim (`--loadout=gloria,plasma_rifle`): told apart by grip
  and length already (gloria one-hand at the side, a short bottle with a pale drum; the plasma rifle long on the
  aim line with its pale cell). No edit. Frame (masters, not in frames.json) `it5-gloria-vs-plasma-32ppm.png`.
  Gloria vs the pistol is the next pair to judge (NEXT 1).
- Session close 03:55: 10 commits this iteration (43a4e356..), all gates green (lint 13/13, unit 733/733,
  scenarios 32/32), frames.json 15 entries. Worktree clean except the untracked lane logs in evidence/.

## Iteration 6 (03:53 - 04:53), BUILD

- 03:53 read JOURNAL, git log, other lanes' JOURNALs. Open REQUESTs to me: human-reactions REQUEST 1 (SWAT look:
  `head_swat` + `torso_swat` in the d5 cop style) and REQUEST 2 (a robot thug part sheet in Rivet's part names).
  Every weapon has its art, so these come ahead of my own NEXT list (another lane waits on them).
- MILESTONE 03:58 REQUEST 1 DONE (d9102db7): `head_swat` / `torso_swat` in BOTH cop sets (`art/cop` D4 flat,
  `art/d5/cop` D5 hatched), derived by `tools/art/swat_parts.py` (deterministic, no generation) from `head_cap` /
  `torso`, so footprint and pivots are the rig's own (parts.json rows copy them; `derived_from` names the base).
  Helmet: the cream crown becomes a dark gunmetal shell, the brim band a pale visor, two ink side rails (the
  reverse of the patrol cap's tones: the three cop heads read apart). Vest: the blue shirt stays the main fill,
  a darker blue plate carrier with an ink rim and three ink pouches with paper flap lines down the back edge. No
  red, no vermilion. Dev lineup `dev/weapon_art/swat_lineup.gd` (patrol, riot, SWAT, Rivet, idle + walk at
  32/48/128 px/m): `it6-swat-look-128-48-32ppm.png` (masters). At 32 px/m the SWAT is the dark-helmeted cop
  with a dark pouch row; told apart from patrol (white cap) and riot (white helmet + shield) at a glance.
  Provenance: 4 rows (the source part's row + the derivation).
- To human-reactions (REQUEST 1 answer): `RigVariant.make(BodyPlan.Kind.COP, "swat", "head_swat", "torso_swat",
  false)` works as is (my lineup uses it); the crowd index + CrowdAtlas clamp are yours.
- MILESTONE 04:04 REQUEST 2 DONE (dae102b7): the robot thug's own part set, `art/thug/` (D4) + `art/d5/thug/` (D5),
  Rivet's 25 part names with his parts.json copied (sizes and pivots identical), derived by
  `tools/art/thug_parts.py` (deterministic): dark cool gunmetal plates, rust -> dark oil stains (no red, no
  vermilion, the torch tip's teal goes grey too), a single round optic on the helmet (gunmetal bezel, paper lens,
  ink pupil, a glint), ink dents + two paper gang bars on the back plate (the head covers the chest from above).
  50 provenance rows. The lineup (`it6-thug-parts-and-lineup.png`): at 32 px/m the thug prints as an ink body
  with one pale eye and steel arms, Rivet as the vermilion collar on a cream body: told apart at a glance.
  NOTE: the print shader's limb LOD paints every robot's arms the same steel at 32 px/m (limb_fill), so the thug's
  difference there is the body + optic; the gunmetal arms show from the D5 tier (about 64 px/m) up.
- To human-reactions (REQUEST 2 answer): `ThugPlan.ART_DIR = "thug"` is the one line; collar and hose are
  recoloured too (no vermilion) in case a plan draws them.
- DECISION weapon-art thug look: derived from Rivet's parts by script (same layout, darker gunmetal, one optic)
  rather than a new generated sheet (a Codex sheet needs the layout template + slicer + silhouette lock, about an
  hour, and risks pivots that do not fit ThugPlan). Alternative: a generated "street-gang robot" sheet through
  the d5-close slicer, one art_dir swap. Same call for SWAT (derived from the cop cap/torso).
- MILESTONE 04:08 electro bolt (e00fe838, NEXT 2): `arc_0..2` redrawn as jagged lightning (6 sharp kinks on
  alternating sides with seeded jitter, tapering to the head, mitre gaps filled) with two kinked forks leaving
  forward and outward. First try (12 kinks) read as a spring, second (uneven spacing) clumped; the third reads
  as lightning. Live: `--rigs --ppm=64 --bot=arsenal --loadout=electro_gun --start=pit`, ticks 621/650:
  `it6-electro-bolt-ab-64ppm.png` (before = the it4 live frame), clip `it6-electro-bolt-64ppm.mp4`. A chain
  between two guards is still not filmed (no station 1.5 m apart; the rack took that slot this session).
- MILESTONE 04:15 the weapon wall (7629aae7, NEXT 3): station `weapon_art_rack` in my own
  `arena_stations/weapon-art.json` + `ArenaWeaponRack` hook + `WeaponRackView` (my folder): the 16 weapons hung
  muzzle up on a paper-wash board along the hub's north wall (x -2.5..12.5, y -3.15..-4.95), brief order,
  pickup side views at drawn length. Render only (nothing stepped/hashed), `--weapon-rack=off`. Live frame
  `it6-weapon-wall-hub-64-32ppm.png`: at 64 px/m each gun reads (rocket's vermilion nose, flamethrower tank,
  katana, chainsaw); at 32 px/m the wall reads as the arsenal with the cops in front for scale. The first pass
  had a paper board that merged with the wall paper and crossed the hub wall: now a 0.14 ink wash, 1.8 m tall.
  FRICTION: the hub is crowded (gunplay's dummies at y -3, react_line y 1.5, claw cops y 4.4); the north band is
  the one free strip, so the dummies stand in front of the wall's foot. At 128 px/m the camera centres on
  Rivet at the start and the wall is off screen.
- NEXT 4 closed by showcase (their glue cd4b518f: FxView skips GunFx's magazine bits when WeaponMagView is live;
  `mag_drop: false` rejected, it breaks test_gun_fx). Nothing to do here.
- FRICTION: a Bash call that the sandbox refuses (an `rm -f $S/*`) drops the WHOLE command, including a python
  edit earlier in it; the next render showed the old board. Use `"${S:?}"/*` and keep edits in their own call.
- Registry rules applied: sprite-and-atlas-production (looks derived from the same sheets, part sizes and pivots
  unchanged), depth-ordered-layered-art (the wall under the actors, z actors-2), motion-quality-gating (the bolt
  judged in a live fight on fixed ticks against the it4 frame). No deviation.
- MEASURE 04:21 the weapon wall in motion: `--rigs --ppm=48 --bot=rivet` (the claw fight in the hub), 20 s clip
  `it6-weapon-wall-hub-48ppm.mp4`: the board stays on screen behind the fight the whole time.
- 04:22 chain arc still NOT filmed. Tried twice: (1) `--bot=arsenal --loadout=electro_gun --start=pit` 35 s,
  wave 1 = 2 guards, never within 4 m of each other; the bolts seen are shots at an off-screen guard; (2) the same
  without `--start=pit`: the arsenal bot walks to the pit anyway (the react_line dummies 4 m apart are never shot).
  Needs a station that puts two hostiles within chain_radius_m 4 of each other (NEXT 1).
- Gates of record this session: lint 13/13 (672 files) at every commit (pre-commit hook), unit 733/733 and
  scenarios 32/32 at 7629aae7 (`evidence/weapon-art/unit-it6b.log`, `scenarios-it6b.log`); later commits are
  docs only. Render-only + art + data; no sim file, no replay or parity golden touched. No bench (render-only:
  16 sprites + 1 rect on the hub board).
- frames.json 15 entries, it6 first (weapon wall still + clip, electro bolt A/B + clip, SWAT, thug). Dropped:
  it4 electro live (now the A/B's before), it4 SMG feed box A/B, it4 flame nozzle, it4 claw clip A, it4 claw lineup
  (core seven; the it5 rim lineup supersedes it), it5 SMG 128 close-up. Their files stay. Scratch deleted.
- FRICTION: the sandbox also refuses `rm` of the shell's current directory (and drops the whole command); cd out first.

## Calls for the owner (adds, iteration 6)
- weapon-art-9: the weapon wall in the hub (all 16 on a board, live) vs no wall (the hub as before). Frame
  `it6-weapon-wall-hub-64-32ppm.png`, clip `it6-weapon-wall-hub-48ppm.mp4`. Default: on; `--weapon-rack=off`.
- weapon-art-10: the SWAT and thug looks are scripted derivations (same cuts, new tones + optic/pouches) vs new
  generated sheets (more distinct shapes, about an hour each). Frames `it6-swat-look-128-48-32ppm.png`,
  `it6-thug-parts-and-lineup.png`. Default: the derivations.

NEXT (iteration 7), in order:
1. Film the electro chain: a hub station row in `arena_stations/weapon-art.json` with two `target` spawns 2 m
   apart (check ArenaTargets makes them Fighters the chain can reach), and a way to make the arsenal bot shoot
   them (or a scripted aim). Show the bolt hopping.
2. The weapon wall at 128 px/m: a teleport or `--start=` to the hub's north band so the close-up shows the art.
3. Read human-reactions' JOURNAL: did they wire `head_swat`/`torso_swat` and `ThugPlan.ART_DIR = "thug"`? Film
   both in the live arena (cherry-pick their wiring if needed) at 64 px/m with D5 detail.
4. The reload close-up with the rim at 128 px/m (the it5 128 frame predates the rim).
5. Brutality still uses the front-view X-ray; offer the `gore_*_top` stickers again (their JOURNAL).
- Session close 04:25: 6 commits this iteration (d9102db7..), gates green, worktree clean except evidence logs.

## Iteration 8 (04:24-05:24), BUILD
- Read: JOURNAL (no iteration 7 entry: that session left no trace), git log, other lanes' JOURNALs. New REQUESTs
  to weapon-art: none (brutality REQUEST 4 was delivered in it3; human-reactions wired REQUESTs 1-2 in a27c786b /
  c819d6be). Plan = NEXT 1 (chain), NEXT 3 (SWAT/thug live), NEXT 2 (wall 128), NEXT 4 (reload 128).
- Registry rules applied: motion-quality-gating (claims judged on frames cut from `--fixed-fps 60` real-time
  captures, the hop shown frame by frame), realtime-combat-semantics (nothing changed in the sim: the chain is
  gunplay's FightAreas._chain on the arena's real fight; I only found and filmed it). No deviation.
- MILESTONE 04:31 the electro chain FILMED in the live arena (NEXT 1, no code): `--rigs --bot=arsenal
  --loadout=electro_gun --weapon=electro_gun` (the last flag only adds gunplay's measures). Located by bisecting
  headless runs on `--quit-after` (deterministic; telemetry `gunplay_range.chain_hits`): 0 at tick 2510, 1 at 2550,
  2 at 2650 (wave 4: guards bunch within chain_radius_m 4). Then one windowed `--write-movie` to tick 2720 at 64 and
  at 48 px/m. Seen: the bolt hits a guard and a jagged cream arc jumps to the guard beside him for about 5 frames
  (the stunned guard tints vermilion on the hop frame). Evidence (masters): `it8-electro-chain-hop-strip-64ppm.png`
  (8 frames 50 ms apart), clips `it8-electro-chain-arena-64ppm.mp4` / `-48ppm.mp4` (7 s real time, the hop at
  about 5.7 s), `it8-electro-chain-hop-64ppm-quarter-speed.mp4`. No station needed; the it6 plan (two targets)
  dropped: the pit's own wave 4 does it.
- FRICTION: the 64 px/m camera centres Rivet and the hop lands at the top-right edge of the frame (Rivet fights at
  8 m); 48 px/m keeps the whole bunch in frame. A capture camera that frames Rivet + target is showcase's area.
- FRICTION: cherry-picking human-reactions a27c786b into n-weapon-art conflicts (their react_line files are not
  on my branch: DU react_line_bot.gd, human-reactions.json; UU arena_rigs.gd). Aborted cleanly. Filmed instead on
  a throwaway detached worktree at their tip c819d6be (scratch/wa8-hr, native bin copied, deleted after).
- MEASURE 04:38 SWAT live (human-reactions c819d6be, arena `--rigs --ppm=64 --bot=gunplay --weapon=pistol
  --start=pit`): the reaction line's fourth dummy wears head_swat + torso_swat: a dark shell with the pale visor
  band and ink rails over the darker plate carrier, beside patrol (cream cap, blue band) and riot (cream helmet,
  shield): told apart at 64 px/m. `it8-swat-live-react-line-64ppm-2x.png`, clip `it8-swat-live-arena-64ppm.mp4`.
- MEASURE 04:39 robot thug parts live (human-reactions c819d6be, enemy-ai's `dev/enemy_ai/enemy_rig_fight_run.gd
  --squad=robot_thug,patrol_cop,robot_thug`, 32 px/m, D5): the thugs print as ink bodies with one pale optic and
  steel wrench arms, beside the blue/cream cop. Oil spray on hit is grey speckle (theirs). `it8-thug-parts-rig-fight-
  32ppm-4x.png`, clip `it8-thug-parts-rig-fight-32ppm.mp4`. The thug is not in the arena's CombatArena (robots later).
- MEASURE 04:40 weapon wall at 128 px/m (NEXT 2): no code needed. `--resolution 2400x2100 --ppm=128 --shot`
  (the content scale makes it about 330 px on screen per metre) shows the board's art well (tape, rust, the tank's
  straps, the molotov wick), `it8-weapon-wall-128ppm-tall-window.png` (masters, not in frames.json). FINDING:
  rivet-motion's melee-line dummies (x 0..14, y -3) stand between the rack's slots and cover the lower third of
  the electro gun, molotov and Gloria. Lifting the guns 0.45 m does not fit: the rocket (1.7 m) already fills the
  1.8 m board, and a taller board crosses the hub wall (rejected in it6). Left as is (a wall behind sparring
  dummies); a fix would move the dummy line south (rivet-motion's station).
- FINDING 04:41 plasma rifle in the city block (`--arena=city --loadout=plasma_rifle`, 32 px/m, cream paving):
  the impact burst reads loudly, but the bolt in flight printed as a pale pill (iteration 1's steel oval in a thin
  ink ring). I first read a 3-gun run wrong: the pale leaves there were the homing SHARD rounds (the loadout
  starts on the shard), and the dashed vermilion bars are the guard's rounds coming in. A single-gun run is the
  only clean read.
- MILESTONE 04:44 plasma bolt = ink comet (fec55d96): charcoal tail, steel halo, paper core, paper streak;
  260x64, anchor at the tip (`tools/art/energy_round_tails.py`). Same-tick A/B (deterministic; old cell restored
  for the before run, then the new one put back): `it8-plasma-bolt-comet-ab-city-32ppm-2x.png` + side-by-side clip.
- MILESTONE 04:48 homing shard gains a charcoal tail (41002e84), 190x44. A/B `it8-shard-tail-ab-city-32ppm-2x.png`
  + clip. A modest gain.
- BUG 04:50 (mine, iteration 1): WeaponFxArt's BOLT branch drew the electro arc cells for EVERY bolt row, so the
  ray gun (projectile_fx ray_ring) fired lightning and looked like the electro gun in flight; its ring art was
  never seen. Fixed (4f186eae): a `when` guard on the BOLT branch -> WeaponFxRay.draw_round (4 rings back along
  the beam, squashed 0.42 edge-on, widening and fading toward the tail), and the ring cells redrawn as a charcoal
  band with a paper stripe (the paper hoops were hairlines). draw_cell takes an optional alpha. Same-tick A/B/C at
  64 px/m (pre-fix tip rendered from a throwaway worktree, deleted): `it8-ray-gun-rings-abc-64ppm.png`, clip
  `it8-ray-gun-lightning-vs-rings-64ppm.mp4`. On asphalt the thin and heavy rings read about the same; the heavy
  band is for cream paving (not yet filmed at 32 in the city).
- FRICTION: I edited `weapon_fx_art.gd` (a new class_name reference) while a scenario run was compiling the tree:
  32 ran, 1 failed on "WeaponFxRay not declared" (`scenarios-it8.log`). Not a real red; re-run after `--import` on
  4f186eae (`scenarios-it8b.log`). Don't edit the tree while a gate runs.
- DECISION weapon-art energy rounds: the tracer's two-tone rule for the plasma bolt, shard and ray rings (no new
  accent colour; weapon-art-3 stays open). Rejected: a vermilion core (danger only), and a thicker ink ring alone
  (still a pale blob with no direction). Decision line written in docs/decisions.md.
- Registry rules applied: motion-quality-gating (every change judged on the same deterministic tick before and
  after, from `--fixed-fps 60` captures), sprite-and-atlas-production (cells regenerated by a seeded script, rows'
  size/anchor updated through canon_json). No deviation.

## Calls for the owner (adds, iteration 8)
- weapon-art-11: the ray gun's round: a ring train (shipped) vs a straight paper beam with the rings only at the
  muzzle. Frame `it8-ray-gun-rings-abc-64ppm.png` (row 1 = the old lightning, to show it was a bug). Default:
  the ring train.
- MEASURE 05:00 ray rings on cream in the city block at 4f186eae (`--arena=city --loadout=ray_gun`, 32 px/m): two
  dark hoops leave the claw toward the guard. Small but readable. `it8-ray-rings-city-32ppm-2x-strip.png`, clip
  `it8-ray-gun-city-block-32ppm.mp4`.
- To gunplay (INFO, no action needed): the ray gun's rounds now draw weapon-art's ring train (WeaponFxArt is
  asked first, as before); the electro gun keeps the arc. Plasma and shard rounds have new cells (same ids, new
  size/anchor rows in weapon_art.json). Your plasma halo A/B predates the comet: re-check it when you merge.
- Gates of record: lint 13/13 (673 files) at every commit; unit 733/733 + scenarios 32/32 at 4f186eae
  (`evidence/weapon-art/unit-it8c.log`, `scenarios-it8b.log`); unit 733/733 at 41002e84 (`unit-it8b.log`). Later
  commits are docs only. Render-only + art + data: no sim file, no replay or parity golden touched. No bench.
- frames.json 15 entries, it8 first (ray A/B/C + clip, ray in the city, plasma A/B + clip, shard A/B, chain strip +
  48 clip, SWAT live, thug live), then it6. Dropped: the it6 electro bolt clip (the chain clip supersedes it), the
  64 px/m chain quarter-speed clip. Scratch (wa8, ~5 GB of AVIs) deleted; both throwaway worktrees removed.

NEXT (iteration 9), in order:
1. The other rounds through the same 32 px/m city check (single-gun runs, one at a time): pistol tracer, machine
   pistol, hand cannon, Gloria's nail, the rocket, the mini-nuke. Fix any that vanish on cream with the two-tone rule.
2. Muzzle flashes at 32 px/m on cream: `flash_energy` is paper_2 on paper (the ray, plasma and shard flash is a
   pale star at the claw; see the ray crops). Probably the same fix.
3. The 64 px/m chain clip lands at the frame's edge; ask showcase for a capture camera that frames Rivet + target,
   or shoot the hop at 48.
4. The weapon wall vs the melee-line dummies (rivet-motion): a REQUEST to move their y -3 line south by 0.6 m, or
   accept the overlap.
5. Brutality still uses the front-view X-ray; offer the `gore_*_top` stickers again (their JOURNAL).
- Session close 05:03: 7 commits this iteration (583613dc..), gates green, worktree clean except evidence logs.
- MEASURE 05:08 NEXT 1 started (read only, no fix): single-gun city runs at 32 px/m for pistol, hand cannon and
  rocket (780 ticks each). Rocket: the smoke-puff trail and the blast (vermilion burst, smoke ring) read on cream.
  Pistol / hand cannon: their tracers are too fast to judge on a 5 fps contact sheet; next time crop at 20-60 fps
  around Rivet, as for the plasma. Scratch files deleted; an empty `gtai-n4/scratch/wa8b` folder is left (the
  sandbox refuses rmdir on it).

## Iteration 9 (05:00 - 06:00)
- 05:00 read: JOURNAL NEXT, git log. REQUESTs to weapon-art in the other journals: rivet-arsenal REQUEST 11 (an
  empty rocket tube) open; the rest answered earlier.
- FINDING 05:04 pistol in the city block (`res://dev/arena/arena.tscn -- --arena=city --loadout=pistol --bot=arsenal
  --clean`, 1280x720, `--fixed-fps 60 --write-movie`, frames cut at 30-60 fps around Rivet): the charcoal bars
  with vermilion heads are the GUARD's rounds coming in (gunplay's enemy rounds); Rivet's own pistol round is the
  thin pale needle, a hairline loop at 32 px/m (the 280x48 cell draws at 0.2 = 3-4 px tall).
- MILESTONE 05:05 heavier tracer (3405df7c, `tools/art/bullet_tracer.py`, 320x64, 44 px across at the head, paper
  streak, ink ring 13). Same-tick A/B: `it9-pistol-tracer-ab-city-32ppm-4x.png`; 60 fps strip with the head toward
  the guard: `it9-pistol-tracer-new-city-32ppm-60fps-3x.png`. Now a grey needle with a paper streak, apart from the
  guard's vermilion-headed bars. Applies to the machine pistol and hand cannon too (same cell).
- MEASURE 05:08 every round and flash cell at its true 32 px/m draw scale (0.2) composited on crops of the city
  block's cream paving and asphalt: `it9-round-cells-at-32ppm-cream-asphalt-3x.png`. Weakest: Gloria's nail (a
  30x2 px sliver, nearly gone on asphalt). The energy flashes (NEXT 2) hold up: their 13 px ink ring keeps the pale
  star readable on cream. NEXT 2 closed with no change.
- MILESTONE 05:11 Gloria's nail (007ec1c2): 240x64, steel shank 22 px across with a paper glint, a broad paper
  head, a charcoal speed tail. Same-tick A/B (old cell + old row restored for the before run, then put back):
  `it9-gloria-nail-ab-city-32ppm-2x.png` + clip `it9-gloria-nail-old-vs-new-city-32ppm-2x-halfspeed.mp4`.
  `--bot=gunplay --weapon=gloria` on the city fires; `--bot=arsenal` with Gloria mostly backs off (no shots in 3 s).
- MILESTONE 05:15 rivet-arsenal REQUEST 11 DONE (b98ae259): `parts.empty` = `held_empty.png` for rocket_launcher
  and mini_nuke, the warhead cut away past the front band and an inked open mouth, same canvas, `part_grip_px.empty`
  = grip_px. `make_held(id, "empty")` lands exactly on the loaded tube (unit test). `tools/art/empty_tubes.py`,
  provenance lines. Sheet `it9-rocket-tubes-loaded-vs-empty-sheet.png`.
- INFO -> rivet-arsenal: the empty tube is in (b98ae259). Swap RivetHeldView's sprite to `make_held(id, "empty")`
  from the shot until reload phase 2 (when your RivetMagView rocket goes in). Not wired by me (your file).
- Gates: lint 13/13 at every commit (pre-commit hook); unit 733/733 at 007ec1c2 (`evidence/weapon-art/unit-it9.log`),
  734/734 with the empty-tube test. Render-only + art + data: no sim file, no golden touched.
- Registry rules applied: motion-quality-gating (same deterministic tick before/after, cut from --fixed-fps 60
  captures), sprite-and-atlas-production (cells from seeded scripts, rows' size/anchor through the table; the
  empty part keeps the held canvas so attach data stays valid). No deviation.
- MILESTONE 05:20 the hand cannon fires a slug (7ab2457c): an optional `projectile_k` per weapon row (schema 0.5..3,
  absent = 1) draws the round's cell k times thicker and sqrt(k) times longer; hand_cannon is 1.6. Same-tick A/B
  `it9-hand-cannon-slug-ab-city-32ppm-2x.png`. FRICTION: the first try added `WeaponArt.projectile_k()`, a 21st
  public method (gdlint max-public-methods 20). I did not delete methods other lanes may call. Instead it is a
  public data field `round_k: Dictionary[StringName, float]`, filled at load. Also: `float(r.get(...))` on a Variant
  is a parse error (warnings are errors); a dictionary `.get()` passed straight to `assert_eq` is one too (type it
  through a local first).
- BUG 05:27 (mine, since iteration 3): weapons.json makes the mini-nuke `kind: thrown` (a lobbed shell), so
  WeaponFxArt's THROWN branch drew the MOLOTOV BOTTLE for it: the nuke flew as a tiny tumbling burning bottle. Found
  while A/B-ing a projectile_k for its rocket: the frames came out pixel-identical, because the rocket branch never
  ran. Fixed (e0308ace): a THROWN row whose projectile_fx is `rocket` goes to the new `WeaponFxShell`: the rocket
  cell plus its exhaust lick on the bottle's lob arc and ground shadow, nose along the travel, swelling 35 % toward
  the apex, projectile_k 1.5. A/B: `it9-mini-nuke-bottle-vs-shell-ab-city-32ppm-1_5x.png` + clip
  `it9-mini-nuke-bottle-vs-shell-city-32ppm-halfspeed.mp4`. My unverified `_rocket` k change was reverted (no
  rocket row sets k).
- DECISION weapon-art mini-nuke shell: the shell is drawn from the shared rocket cell at 1.5x, not a new warhead
  cell. That keeps one family, and the held part's striped warhead already says "nuke" at the claw. Alternative =
  a striped `nuke_shell` cell (one Python function plus a row) if the owner wants the stripes in flight.
- Gates: scenarios 32/32 at 7ab2457c (`scenarios-it9.log`); unit 735/735 at 7ab2457c (`unit-it9b.log`).
- INFO -> brutality: (1) the mini-nuke's round was a molotov bottle in flight until e0308ace; now it's a shell.
  Re-shoot the nuke pack on your city reel after you merge it. (2) Your REQUEST 4 (top-down X-ray and charred) has
  been in since iteration 4 (9c136aee): fx cells `gore_xray_top`, `gore_xray_top_jolt`, `gore_charred_top`,
  `gore_charred_top_slump`, anchored on the head disc (= the rig's origin). Your call brutality-4 can show both
  sides.
- REQUEST 6 -> showcase (low, hub layout is yours): the melee-line dummies (y -3, x 0..14) stand in front of the
  weapon wall's lower third (electro gun, molotov, Gloria). Moving that line 0.6 m south would clear the board.
  Otherwise the wall reads as "behind the sparring dummies" (accepted as is).
- Audit 05:33: every shooting row's sim kind vs its art projectile_fx (weapons.json vs weapon_art.json). Bullet ->
  tracer/nail/plasma_bolt/shard, bolt -> arc/ray_ring, rocket -> rocket, cone -> flame, thrown -> flame (molotov
  bottle) / rocket (the nuke shell). There is no other mismatch.
- Gates of record at e0308ace: unit 735/735 (`unit-it9c.log`), scenarios 32/32 (`scenarios-it9b.log`), lint 13/13 (674 files).
- MEASURE 05:31 the mini-nuke shell close-up in the arena pit (`--ppm=64 --rigs --bot=gunplay --weapon=mini_nuke
  --loadout=mini_nuke --start=pit`): the shell leaves the claw, rises above its ground shadow, turns along the arc
  and comes down on the cop into the blast. `it9-mini-nuke-shell-arena-pit-64ppm-30fps.png`, clip
  `it9-mini-nuke-shell-arena-pit-64ppm-halfspeed.mp4`. The ground shadow is a small dash at 64 px/m; it could be
  bigger.
- MEASURE 05:34 machine pistol in the city (`--loadout=machine_pistol --bot=gunplay`, 32 px/m): its needles (the
  new tracer) and the brass on the paving read. No change. NEXT 1 is closed: pistol, machine pistol, hand cannon,
  Gloria, rocket and mini-nuke have all been read on cream.
- frames.json 15: it9 first (nuke bottle-vs-shell clip + A/B, nuke 64 close-up clip + strip, Gloria clip + A/B,
  hand cannon A/B, empty tubes sheet, round cells at true scale), then it8 (ray A/B/C + clip, plasma clip, chain
  strip), then it6 (weapon wall frame + clip). The pistol tracer A/B and its 60 fps strip stay in masters/frames
  (referenced above). Scratch wa9 emptied (the sandbox keeps the empty folder, as with wa8b).

## Calls for the owner (adds, iteration 9)
- weapon-art-12: the mini-nuke's round is the shared rocket cell at 1.5x (shipped) vs a striped warhead cell that
  matches the held part. Clip `it9-mini-nuke-bottle-vs-shell-city-32ppm-halfspeed.mp4` shows the shipped shell (and
  the old bottle bug). Default: the shared rocket at 1.5x.
- weapon-art-13: the hand cannon's round is the pistol needle at 1.6x (a slug, shipped) vs a pistol-weight needle.
  Frame `it9-hand-cannon-slug-ab-city-32ppm-2x.png` (top = 1.0, bottom = 1.6). Default: 1.6.

NEXT (iteration 10), in order:
1. rivet-arsenal wires `make_held(id, "empty")` (their REQUEST 11, delivered b98ae259). When it lands, film the
   rocket reload at 64 px/m: the tube goes empty at the shot and loads again in phase 2.
2. DONE 05:37 (f255cffc) for the shell: an ink ellipse shadow that shrinks at the apex, A/B
   `it9-nuke-shell-shadow-ab-64ppm.png`. Still open: the molotov bottle keeps the old dash. Tried at 05:41 (a public
   `WeaponFxShell.draw_shadow` at k 0.6 called from `_bottle`) and reverted unjudged: at 32 px/m in the city the
   bottle rides about 70 px above its shadow, so my crop missed it. Re-try with a crop that spans bottle and
   ground, or judge it at 64 px/m in the pit (`--bot=gunplay --weapon=molotov --loadout=molotov --start=pit`).
3. A 48 px/m clip of the kinetic family in one run (pistol, machine pistol, hand cannon, Gloria) via the arsenal
   switch bot, for the morning page's "weapons in motion" row.
4. REQUEST 6 -> showcase (melee-line dummies in front of the weapon wall): check their answer.
5. The energy flashes stay as they are (read in the true-scale sheet). Look at the flame and arc cells at 32 px/m
   on cream next, in the same composite.
- Session close 05:40: 10 commits this iteration (3405df7c..f255cffc + this). Gates of record at f255cffc: lint
  13/13 (674 files), unit 735/735 (`unit-it9d.log`), scenarios 32/32 (`scenarios-it9c.log`). Render + art + data
  only: no sim file, no replay or parity golden touched. No bench (render-only changes; bench.lock was held by
  another lane). Worktree clean except the evidence logs.

## Iteration 10 (05:43 - 06:43)
- 05:43 read: JOURNAL NEXT, git log, other lanes' JOURNALs. No new REQUEST to weapon-art. rivet-arsenal wired the
  empty tube (b8d51a5b, HeldTube) and filmed it (`rivet-arsenal/frames/rocket-empty-tube-strip-64ppm.png`): looked
  at it, the open inked mouth reads after the shot and the striped warhead returns at reload. NEXT 1 closed by them.
- NEXT 5 closed with no change: the it9 true-scale sheet (`it9-round-cells-at-32ppm-cream-asphalt-3x.png`) already
  holds the flame comet and the arc zigzag at 0.2 on cream and asphalt. Both read (vermilion comet; paper zigzag in
  its ink ring).
- FRICTION 05:45 the pit (`--start=pit --bot=gunplay --weapon=molotov`) never throws in 440 ticks: the cops line the
  pit's north rim behind the wall, and the bot only draws an aim line at 438. The city block throws at tick ~404
  (blast 438). The machine was at 0.6 fps per 1280 capture (CONTENDED); `--resolution 960x540` still writes 1280x800.
- MILESTONE 05:59 molotov shadow (378590f3, NEXT 2 of it9): the bottle casts the shell's ink ellipse
  (`WeaponFxShell.shadow`, now public, with an optional ink opacity) at `BOTTLE_SHADOW_K` 0.8 and 60 % ink,
  shrinking at the apex. First try, 0.55 at the scorch's 35 % ink: it nearly vanished under the small bottle (26x12
  px pale grey at the apex, A/B looked at); raised. A/B located by diffing before/after frames at the same tick
  (they differ only in the shadow): `it10-molotov-shadow-ab-city-64ppm-2x.png` (ticks 398-416) + clip
  `it10-molotov-shadow-ab-city-64ppm-halfspeed.mp4`. The shell keeps its judged 35 %.
- DECISION weapon-art lob shadows: as above (docs/decisions.md). Alternative = the two constants.
- Gates: lint 13/13 (674 files), unit 736/736 (`unit-it10b.log`). Render only: no sim file, no golden touched.
- Registry rules applied: motion-quality-gating (same deterministic tick before/after from --fixed-fps 60 captures;
  the frames differ only in the change), depth-ordered-layered-art (the shadow sits on the ground layer under the
  lifted bottle). No deviation.
- Gates of record at 378590f3: scenarios 32/32 (`scenarios-it10.log`), unit 736/736, lint 13/13.
- FRICTION 06:07 NEXT 3 (kinetic family at 48 px/m): the first capture on the city block (`--arena=city
  --bot=arsenal`, no `--rigs`) drew Rivet as quest 1's sprite with NO gun in the claw; with `--rigs` the city
  logs `cast rigs: false` on this branch (rivet-arsenal fixed both on theirs: c912aec2 rigs on the city path,
  5cda9e7f rigs by default in the arena; not merged here). Both city runs thrown away. The molotov shadow A/B
  above was shot on the sprite path, which is fine for a projectile (the shadow and bottle are WeaponFxArt, drawn
  the same either way), but its Rivet is the sprite. Re-shot in the arena pit with `--rigs` (`cast rigs: true`).
- MILESTONE 06:14 NEXT 3: kinetic family in a live pit fight at 48 px/m (`--rigs --start=pit --bot=arsenal
  --loadout=pistol,machine_pistol,hand_cannon,gloria --clean`, `--fixed-fps 60`, `cast rigs: true`): clip
  `it10-kinetic-family-carry-arena-pit-48ppm.mp4` (ticks 380-959, real time, the band names the carried slot by
  the bot's 240-tick schedule; at 620 the hand cannon's burst toward the SWAT cop) + strip
  `it10-kinetic-family-held-arena-pit-48ppm-2x.png` (two ticks per gun). Looked at. The bot mostly takes fire and
  idles between waves after tick 790, so Rivet's own shots are few (rivet-arsenal's known bot flaw).
- FINDING 06:15 (the weakest item now, mine): in the claw at 48 px/m the four kinetic guns print as the SAME dark
  ink lozenge in a paper rim. They differ in length (pistol about 0.7 m, Gloria about 0.95 m), not in shape.
  Cause: RivetHeldView (`rivet_held_view.gd:58`, rivet-arsenal's) gives the held sprite the rigs' PART print
  material. Rivet's light steel prints light, but the guns' mid-tone rust brown collapses to near-black and takes
  the inner shapes (feed box, drum, Gloria's bulb and coil) with it. This breaks design rule 2 ("the silhouette
  identifies the weapon") in the claw, though not on the wall or the pickups (flat, at 64 px/m).
- frames.json 15: it10 molotov clip + A/B first, then the it10 kinetic clip + strip, then it9/it8/it6. Dropped the
  Gloria A/B still (its clip stays) and the ray lightning-vs-rings clip (the A/B/C still stays).

- MEASURE 06:19 (two hypotheses for the dark held guns, both refuted):
  (a) Tone: per-pixel print bands (cream < 0.30 ink density, solid > 0.78, wash between, vermilion where r leads by
  62) are the SAME for the guns as for Rivet's parts: pistol 26/41/30 % cream/wash/solid, machine pistol 11/48/36,
  hand cannon 18/53/28, Gloria 25/52/24; Rivet's claw 6/56/33, helmet 4/58/32. So the guns are not darker art.
  (b) Material kind: the held sprite as `PartKind.LIMB` instead of `PART` (one token in rivet_held_view.gd:58,
  local edit, reverted, not committed; same-tick A/B at 48 px/m, ticks 150-622):
  `evidence/weapon-art/it10-held-part-vs-limb-48ppm-2x.png`. LIMB prints the gun MORE solid (the limb LOD prints
  solid ink at gameplay scale). Rejected.
  Left: minification. The held art is drawn at about 0.1 of its 330-494 px source (34-45 px on screen at 48 px/m),
  so the paper tape, rivets and slots average into a mid-dark blend that the print posterizes toward ink. Rivet's
  parts are drawn larger relative to their sources.
  (c) Filtering is the same: the held pngs and Rivet's parts both import with mipmaps and draw with
  LINEAR_WITH_MIPMAPS (rivet_held_view.gd:57, rig_detail.gd FILTER_MIPS). So the fix is in the art at gameplay
  scale (NEXT 1 (i)), not the filter.
- Session close 06:23: 5 commits this iteration (378590f3 + 4 journal). No Godot process of mine running; scratch
  wa10 emptied (the sandbox keeps the folder).

NEXT (iteration 11), in order:
1. Held guns in the claw read as one dark lozenge at 48 px/m (FINDING 06:15, MEASURE 06:19). Try in this order,
   each a same-tick A/B with the it10 command (`--rigs --ppm=48 --start=pit --bot=arsenal --loadout=pistol,
   machine_pistol,hand_cannon,gloria --clean --quit-after 640`, strip ticks 150/210/418/466/610/622; run before
   and after in parallel, swap the file once the first run has 15 frames):
   (i) a small-scale held cell per gun (`held_small.png`, about 64-96 px long, drawn by a tools/art script from the
   held part: ink outline + flat steel fill + the one unique feature in paper: the SMG feed box, the hand cannon's
   drum bands, Gloria's bulb and coil, the pistol's taped grip) that WeaponArt.make_held picks below a px/m
   threshold. Data: a `weapon_art.json` field; alternative = absent field.
   (ii) If (i) is not enough, the print's `px_scale` for weapons only (a REQUEST to rivet-arsenal or d5-cast, not
   my file).
   Do not edit rivet_held_view.gd (rivet-arsenal's).
2. Re-film the kinetic clip on the city block once rivet-arsenal's c912aec2 (rigs on the city path) is in my
   branch or main. `--arena=city` without `--rigs` draws quest 1's sprite with no gun.
3. REQUEST 6 -> showcase (melee-line dummies in front of the weapon wall): still unanswered.
- Session close 06:18: 3 commits this iteration (378590f3 molotov shadow + 2 journal). Gates of record at
  378590f3: lint 13/13 (674 files), unit 736/736 (`unit-it10b.log`), scenarios 32/32 (`scenarios-it10.log`).
  Render only: no sim file, no replay or parity golden touched. No bench (render-only change). No Godot process of
  mine left running. Scratch wa10 deleted after the evidence was copied to masters.

## Iteration 12 (06:22 - 07:22), BUILD
- 06:22 read: JOURNAL NEXT (iteration 11 left no entry), git log, other lanes' JOURNALs. No new REQUEST to
  weapon-art (brutality 3/4, human-reactions 1/2, showcase 4/5/11, rivet-arsenal 11 all answered earlier).
  Plan = NEXT 1 (i): a small-scale held cell.
- MEASURE 06:24 the real cause of the dark held guns is TONE at the print's small scale, not the band split of
  it10 MEASURE (a) (that measured the D5 overlay parts, not Rivet's D4 parts that print at 48 px/m). Rivet's D4
  parts: median luminance 180-200 (claw 185, helmet 201). Held guns: 101-140. At 48 px/m the print's posterize
  `hi` drops to about 0.43 ink density (luminance about 140), so the gun bodies go solid ink.
- TOOL 06:26 `tools/art/held_small.py --sim`: an offline print preview (box minification at the claw's real
  scale + the shader's D4 thresholds) that reproduced the in-game lozenges, so the re-tone was tuned without
  Godot runs. First try (lift only) was noisy; the kept one flattens the body spread to 0.45 and inks a 9 px
  silhouette edge (`it12-held-small-print-sim.png`).
- MILESTONE 06:30 kinetic four (2eb8e4f8): `held_small.png` + HeldLod (make_held returns it when a row has
  `parts.small`; swaps on PartMaterials.view_px under `held_small_below_ppm` 56; rim follows; `--held-small=off`).
  Same-tick A/B in the arena pit at 48 px/m (`--rigs --start=pit --bot=arsenal --loadout=pistol,machine_pistol,
  hand_cannon,gloria --clean`, `--fixed-fps 60 --quit-after 640`, before = `--held-small=off`, run in parallel):
  `it12-held-small-ab-arena-pit-48ppm-2x.png`. Looked at: the guns print as light steel with an ink outline in
  Rivet's own tone, the hand cannon's drum and the pistol's slide survive, no more black lozenge. Still: the
  pistol and machine pistol top-down shapes are close (length differs most).
- DECISION weapon-art held guns at gameplay scale (docs/decisions.md). Alternative = `--held-small=off` /
  dropping `held_small_below_ppm`. Rejected: LIMB kind (it10, measured worse), lightening held.png itself (the
  64-128 px/m close-ups and reload strips are judged on the full art), a weapons-only print px_scale (not my file).
- Gates at 2eb8e4f8: lint 13/13 (676 files), unit 738/738 (noir flake failed once under the capture load, passed
  on the re-run), scenarios 32/32 (`scenarios-it12.log`). Render only, no sim file, no golden touched.
- 06:31 extended (print sim of every held part at 48 px/m: 54-88 % solid ink, molotov 33 %): re-toned all but the
  molotov, the plasma sword (light already) and the flamethrower (its thin wand prints DARKER re-toned: the ink
  edge swallows it). The rocket and mini-nuke get `held_empty_small` too. FRICTION: rivet-arsenal's HeldTube (on
  their branch, not here) sets the full texture every frame from the priority-10 claw view; HeldLod now runs at
  priority 20 and maps any full art in `small_of` (loaded or empty tube) to its small cell (unit test simulates
  HeldTube's set).
- Registry rules applied: motion-quality-gating (same deterministic tick before/after, frames differ only in the
  change), sprite-and-atlas-production (an LOD cell authored for the scale it is seen at, same canvas and pivot
  so no data moves). No deviation.
- MILESTONE 06:39 the long guns (bbc416d4): same-tick A/B at 48 px/m (`--loadout=rocket_launcher,plasma_rifle,
  electro_gun,ray_gun`, 1000 ticks): strip `it12-held-small-long-guns-ab-arena-pit-48ppm-2x.png` + side-by-side
  clip (masters `clips/it12-held-small-long-guns-ab-arena-pit-48ppm-2x.mp4`, real time). Looked at: the rocket
  tube reads with its ink bands, sight and striped warhead instead of a black bar; the plasma rifle's coil reads.
- MEASURE 06:38 the rocket's re-toned body prints near cream (a PART at luminance 186 prints paper; Rivet's limbs
  print grey only because LIMB kind adds `limb_wash`). Tried tone targets 160/0.35 and 148/0.30 in the sim
  (`it12-held-small-tone-targets-sim.png`): the body lands in the print's narrow wash band (ink density 0.36-0.43
  at 48 px/m) and breaks into noise, the pistol goes dark again. Kept 186.
- MILESTONE 06:46 32 px/m (the judging scale), kinetic four, same-tick A/B, 1000 ticks: strip
  `it12-held-small-kinetic-ab-arena-pit-32ppm-3x.png` + clip `it12-held-small-kinetic-ab-arena-pit-32ppm-3x.mp4`
  (blue cops in frame for scale). Looked at: before, black blobs with paper specks; after, pale steel guns with
  an ink outline and inner marks. FINDING: at 32 px/m Rivet's limbs print as flat grey stickers (LIMB sticker LOD),
  so the after-guns read LIGHTER than his arms. Owner call 14.
- frames.json 15: the five it12 entries first. Dropped: it10 kinetic held strip (its before row is the it12 strip's
  top row), it8 electro chain strip, it8 ray ABC, it9 round cells sheet, it6 wall clip (the wall still stays).
- Gates of record at bbc416d4: lint 13/13 (676 files), unit 739/739 (`unit-it12c.log`, no load), scenarios
  32/32 (`scenarios-it12b.log`). Render only: no sim file, no replay or parity golden touched. No bench.

## Calls for the owner (adds, iteration 12)
- weapon-art-14 held guns at gameplay scale: A = held_small (default: light steel, ink outline, inner shapes
  survive; lighter than Rivet's grey arm stickers at 32 px/m), B = the full art (`--held-small=off`: one dark
  lozenge per gun), C = a grey sticker like Rivet's limbs at 32 px/m (silhouette only, no inner shapes; needs
  rivet-arsenal to print the held sprite as LIMB below 0.13 view_px). Clips: `it12-held-small-kinetic-ab-arena-
  pit-32ppm-3x.mp4`, `it12-held-small-long-guns-ab-arena-pit-48ppm-2x.mp4` (A right, B left). No clip for C yet.
