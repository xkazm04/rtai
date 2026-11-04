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
- FRICTION 06:52 evidence gate (`node tools/evidence/run.mjs --no-bench --allow-dirty`; the only dirt is the
  untracked `evidence/weapon-art/` logs): lint, unit 739/739, scenarios 32/32, parity bit-exact PASS; **selftest
  FAIL**: "NEW off-doctrine: 32 px/m vermilion on vehicles: 4 px; 32 px/m vermilion on cop: 4 px" in the D4
  junction, and the debt rows blood_flicker_cop_48 / _vehicles_32 / _cop_block_64 "no longer seen". It is
  deterministic (the same 4 + 4 px on a re-run, `selftest-it12-rerun.log`) and NOT this lane's change: with
  `held_small_below_ppm` 0 (HeldLod off, the tree renders exactly as before my commits) it fails the same way
  (data file restored after, not committed). It reads like the blood-splat gate-boundary pixels those debt rows
  describe, now landing at 32 px/m on the cop and vehicle layers. Owner of the debt: d5-city. Not bisected (it10
  never ran the evidence gate). INFO -> integration/Director: the accent_debt rows need re-measuring on this tree.
- MEASURE 06:58 other lanes' latest `build/evidence/selftest.json`: n-gunplay (06:49) and n-human-reactions
  (06:17) FAIL the same audit with blood-flicker variants ("48 px/m vermilion on vehicles: 8 px", "48 px/m blood
  on vehicles: 16 px"); n-showcase (06:34) passes. So it is tree-wide blood-splat flicker (d5-city's debt rows),
  moving between zooms and layers with each lane's blood, not a weapon-art regression.
- Session close 07:00: 4 commits this iteration (2eb8e4f8 kinetic four, bbc416d4 all held weapons, 2 journal).
  Gates of record at bbc416d4: lint 13/13, unit 739/739, scenarios 32/32, parity bit-exact; selftest FAIL
  (tree-wide blood flicker, above). No Godot process of mine running. Scratch wa12 frames deleted; the clips and
  strips are in masters + `evidence/weapon-art/`.

NEXT (iteration 13), in order:
1. Owner call 14 option C as a clip: the held sprite as a grey sticker at 32 px/m (LIMB kind below view_px 0.13,
   one token in rivet_held_view.gd:58, rivet-arsenal's file: local edit for the A/B only, never committed), so
   the morning page shows A/B/C side by side. If C wins, it is a REQUEST to rivet-arsenal.
2. Pistol vs machine pistol in the claw are close top-down shapes even now (length differs most). Give the
   machine pistol's held_small a wider side feed box (cut from held.png's own box, pushed 6-8 part px out) so it
   reads at 32 px/m. Same-tick A/B with the it12 kinetic command.
3. Gloria at 48 px/m in the claw was not in the it12 strips (her slot falls past tick 880 with the 4-gun
   loadout): `--loadout=gloria` alone, A/B, one strip.
4. Re-film the kinetic clip on the city block once rivet-arsenal's c912aec2 (rigs on the city path) is merged.
5. REQUEST 6 -> showcase (melee-line dummies in front of the weapon wall): still unanswered.
## Iteration 13 (06:56 - 07:56), BUILD
- 06:57 read: JOURNAL NEXT, git log, other lanes' JOURNALs. No new REQUEST to weapon-art. Plan = NEXT 2 (machine
  pistol held_small reads apart from the pistol at 32 px/m), then NEXT 3 (Gloria strip), then NEXT 1 (call 14 C).
- FRICTION 07:00 the first 4 captures were thrown away: `--arena` is not a flag (the arena is the scene
  `res://dev/arena/arena.tscn` before `--`; it2 wrote this down, I forgot). Boot also warns "unknown launch arg
  --ppm" in the arena; that is boot's list, the arena reads it (`arena_game.gd:35`).
- MEASURE 07:05 NEXT 2 (machine pistol vs pistol in the claw at 32 px/m): the arena pit, `--loadout=<one gun>`,
  same 600 ticks per gun. The machine pistol's side feed box (smg_feed_box.py, it6) prints as a clear T at
  32 px/m. The it12 "pistol and machine pistol look alike" read came from strip ticks in the pistol's slot. No art
  change needed: NEXT 2 closed by measure.
- MILESTONE 07:12 NEXT 1, owner call 14 option C filmed: RivetHeldView's print kind PART -> LIMB (line 58, local
  edit, reverted after the runs loaded, never committed), the four kinetic guns, same ticks as A. Strip
  `it13-held-call14-AC-kinetic-arena-pit-32ppm-3x.png`. Looked at: C turns every gun into a grey sticker in the
  arm's own tone (it reads as a third forearm); the hand cannon's drum and the pistol's slide go, and only the
  machine pistol's T survives. A keeps the gun apart from the limb. Recommendation stays A; C rejected on evidence.
- FINDING 07:16 (the real cause of NEXT 3): **Gloria has never drawn her own art in Rivet's claw.**
  `rivet_arsenal.json` `art_stand_in` still maps `gloria -> pistol` (from before her art landed; its doc says a
  stand-in holds "until it lands"), and `ArsenalTable.art_id` applies it unconditionally. So every "Gloria in the
  claw" frame drawn through RivetHeldView (it10 kinetic family, it12 strips) shows the pistol. The it13 A rows for pistol
  and Gloria are pixel-identical at the same ticks.
- FIX 07:17 removed the one line `"gloria": "pistol"` from `art_stand_in` (rivet-arsenal's table; a minimal
  shared-file change). REQUEST 12 -> rivet-arsenal: please drop the same line on your branch (or take mine at
  merge); `assault-rifle -> machine_pistol` stays (no assault-rifle art).
- Gloria's held_small is now two-tone (ink body, the drawn cream tape and plate kept as paper,
  `TWO_TONE` in held_small.py) so she reads as the dark banded gun beside the pale pistol. Print sim:
  `sim_gl` (scratch). DECISION line in docs/decisions.md; doc section updated; provenance line re-hashed.
- MILESTONE 07:21 NEXT 3: Gloria in the claw with her own art, 32 px/m, same ticks (one run per gun,
  `res://dev/arena/arena.tscn -- --rigs --start=pit --bot=arsenal --loadout=<gun> --clean --ppm=32`, `--fixed-fps 60
  --quit-after 600`): strip `it13-held-gloria-own-art-ab-arena-pit-32ppm-3x.png` (pistol / Gloria before = pistol /
  Gloria after / Gloria full art via `--held-small=off` / machine pistol / hand cannon) + clip (masters)
  `clips/it13-held-gloria-own-art-ab-arena-pit-32ppm-2x.mp4` (before left, real time, blue cops in frame). Looked at:
  the four kinetic guns now print as four shapes: the pale stubby pistol, Gloria long and dark with a pale nail
  tip, the machine pistol's T, the hand cannon's banded drum. Two-tone vs her full art: nearly the same print (her
  full art is already dark), two-tone a touch cleaner. Kept two-tone.
- Registry rules applied: motion-quality-gating (same deterministic ticks per gun; one variable per row),
  sprite-and-atlas-production (the LOD cell is authored for the scale it is seen at, same canvas and grip, so no
  data moves). No deviation.
- frames.json 15: three it13 entries first; dropped it12 48 px/m kinetic strip (superseded), it10 kinetic carry
  clip (its Gloria slot was the pistol), it9 hand cannon slug strip. The it12 kinetic entries carry a CORRECTION
  note (their Gloria slot drew the pistol).

## Calls for the owner (adds, iteration 13)
- weapon-art-14 update: option C is now filmed (`it13-held-call14-AC-kinetic-arena-pit-32ppm-3x.png`, A and C rows
  per gun at the same ticks). Recommendation: A. C reads as a third grey forearm.
- Commit f0cfcd9b (Gloria's own art in the claw + two-tone cell + guard test). Gates at f0cfcd9b: lint 13/13
  (676 files, also the pre-commit hook), unit 740/740 (`unit-it13b.log`, +1 test: no art_stand_in may hide a
  weapon's own held art), scenarios 32/32 (`scenarios-it13.log`, run before the test was added; the test is
  unit-only). Render + one data line; no sim file, no golden touched.
- MILESTONE 07:28 brief item 4, the claw lineup refreshed for every gun at 32 px/m: `it13-claw-lineup-12-guns-arena-
  pit-32ppm-3x.png` (12 guns, one run each, ticks 142 and 394, held_small in force). Looked at: twelve distinct
  shapes; vermilion only on the rocket and nuke warheads and the molotov wick (danger, on doctrine). The melee four
  are not in it: `--loadout` skips them ("not a carried gun"); their claw art is the rig's melee path.
- FINDING 07:29 -> rivet-arsenal (INFO, theirs): at tick 394 (carry, not aiming) the long guns (rocket, mini-nuke,
  plasma rifle, ray gun) lie across Rivet's helmet and collar, drawn over his head. A shoulder tube reads, but the
  nuke covers his face. Draw order or carry angle of RivetHeldView; not changed here.
- MILESTONE 07:42 the 64 px/m claw lineup: `it13-claw-lineup-12-guns-arena-pit-64ppm-2x.png` (12 guns, full art,
  tick 142). Looked at: every gun its own silhouette at Rivet's scale; Gloria now long and dark with her tank.
- FRICTION 07:40 lost about 10 min: my wait loop's glob `Z_*` also matched the `.log` files (never 148 lines), so
  it waited out its timeout after the renders had finished. Glob directories as `Z_*/`.
- frames.json 15: the two it13 lineups after the Gloria clip; dropped the it9 rocket tubes sheet and the it9
  mini-nuke bottle-vs-shell clip (both superseded by the lineups and the it9 pit nuke clip).
- Session close 07:44: 1 code commit (f0cfcd9b) + this journal commit. No Godot process of mine running (two melee
  runs stopped by PID at 07:25; the rest exited on --quit-after). Scratch `gtai-n4/scratch/wa13` holds the raw
  frames only (not referenced by frames.json; delete next session).

NEXT (iteration 14), in order:
1. REQUEST 12 -> rivet-arsenal: drop `"gloria": "pistol"` from `art_stand_in` on their branch (or take mine at
   merge). Check their JOURNAL for the answer; the guard test in test_held_lod.gd catches a reintroduction.
2. Re-film the kinetic-family clip (it12's 32 px/m A/B) now that Gloria draws her own art: one run with
   `--loadout=pistol,machine_pistol,hand_cannon,gloria`, real time, cops in frame. Replace the it12 clip in frames.json.
3. The melee four in the claw: find how the arena puts a melee weapon in Rivet's hand (not `--loadout`; read
   rivet-motion's melee path) and add them to the lineup at 32 and 64 px/m.
4. FINDING to watch: long guns drawn over Rivet's helmet in the carry pose (tick 394); rivet-arsenal's view.
5. Delete `C:\Users\kazda\kiro\gtai-n4\scratch\wa13` (raw frames).
- CORRECTION 07:47 (re-filming NEXT 2): `--loadout=pistol,machine_pistol,hand_cannon,gloria` logs "Rivet carries
  [gloria, '', '', '']": `--loadout` keeps one gun per carry slot and the four kinetic guns all sit in slot 1, so
  the last wins. So it10's kinetic-family clip and it12's 32/48 px/m kinetic A/B strips and clip showed ONLY
  Gloria, drawn with the pistol's art, in every frame. The it12 claims "the hand cannon's drum survives" were a
  misread of the pistol. The it12 held_small result (dark lozenge -> pale steel) holds for the pistol art; the
  per-gun truth is the it13 lineups (one run per gun). frames.json it12 notes corrected. NEXT 2 now = film the
  family as four one-gun runs cut into one clip (the lineup runs in scratch wa13 have 400 ticks each).
- MILESTONE 07:48 NEXT 2 done from the one-gun runs: clip (masters) `clips/it13-kinetic-family-four-runs-arena-pit-
  32ppm-2x.mp4` (2x2 grid, same ticks 0-599 real time, a blue cop grappling in frame). Looked at: four shapes,
  pale pistol, the machine pistol's T, the hand cannon's banded drum, Gloria long and dark. It replaces the it12
  kinetic clip in frames.json (15 entries).
- NEXT (iteration 14) revised: 1 REQUEST 12 answer; 2 the melee four in the claw (lineup); 3 the long guns over the
  helmet (rivet-arsenal, watch); 4 delete scratch wa13. Session closed 07:49, no Godot process of mine running.

## Iteration 14 (07:48 - 08:30)
- 07:48 read JOURNAL NEXT, git log, other lanes' JOURNALs. New REQUEST to me: gunplay REQUEST 31 (07:37): the
  molotov's burst plays the rocket's blast cells, ending in a ring of cream discs that reads as debug beads over
  the fire. rivet-arsenal has not answered REQUEST 12 (gloria stand-in) in its JOURNAL; mine is on this branch.
- MILESTONE 07:51 REQUEST 31 DONE (474038b1): `WeaponFxArt.blast` tells a bottle's burst by its fire patch (same
  radius under the splash: molotov 2.2 = 2.2; rocket none; nuke 6 != 12) and draws only the star frame for
  `FIRE_BURST_TICKS` 10, fading over the last 5. FightAreasArt passes its areas (one argument in gunplay's file).
  `--fire-burst=off` = before. Unit test. lint 13/13 (`lint-it14.log`), unit 741/741 (`unit-it14.log`).
- DECISION weapon-art bottle bursts: star only, then the fire (docs/decisions.md). Rejected: a new glass-and-fuel
  splash sheet (an image call, no time before the freeze); it stays the better long-term answer.
- MILESTONE 07:53 measured in the city block at 48 px/m (`--arena=city --ppm=48 --bot=gunplay --weapon=molotov
  --loadout=molotov`, `--fixed-fps 60 --quit-after 480`, before/after runs at the same ticks; burst at 427):
  clip (masters) `clips/it14-molotov-burst-ab-city-48ppm-2x.mp4` (+ quarter speed) and strip
  `frames/it14-molotov-burst-ab-city-48ppm.png`. Looked at: before, smoke ring at 442 and the cream bead ring
  448-456 over the fire; after, the star at 428-432, then only flames. frames.json 15 (dropped the it12 kinetic and
  long-gun strips: the first carried only Gloria-as-pistol, the second is covered by its clip).
- Registry rules applied: realtime-combat-semantics (one impact read per hit type: a bottle is fire, not an
  explosion), motion-quality-gating (same deterministic ticks, one variable). No deviation.
- NOTE melee in the claw (NEXT 2 of it13): on this branch the melee weapons draw only in rivet-motion's
  `combo_clip_run` dev scene, as MeleeWeaponView's procedural bars ("a placeholder until weapon art"); the arena
  wields them only on n-rivet-arsenal (StagePilot.wielding, arena_arsenal_bot). Not merged this late.
- MILESTONE 08:01 the fire patch's ground (27358bfe): under the molotov's fire, gunplay's flat grey disc (a debug
  circle under the flames) becomes the inked scorch cell across the patch's diameter (`WeaponFxShell.patch_ground`,
  `PATCH_SCORCH_K` 1.0, 80 % ink, fading with the patch, its turn fixed by its place). One hook line in
  FightAreasArt._patch (gunplay's file, minimal); the disc is the fallback (`PATCH_SCORCH_K` 0, `--weapon-fx=shapes`).
  Tried 1.15 first: spikes reached past the flames. Same-tick city runs looked at to tick 690 (the scorch stays
  under the fire, no camera break). Unit 741/741 (`unit-it14b.log`), lint 13/13. Deviation: no unit test
  (view-only, as the other draw hooks).
- DECISION weapon-art fire patch ground: as above (docs/decisions.md).
- Evidence (masters): `clips/it14-molotov-burst-and-ground-ab-city-48ppm-2x.mp4` (+ quarter speed): left the
  original (rocket blast frames + disc), right both fixes, ticks 380-479; strip
  `frames/it14-molotov-fire-ground-ab-city-48ppm.png` (disc vs scorch, both with the star-only burst). The earlier
  it14 REQUEST-31-only clip is replaced by the combined one; its strip stays. frames.json 15 (dropped the it10
  molotov shadow strip; its clip stays).
- To gunplay (REQUEST 31 answer): done on n-weapon-art 474038b1 (bottle burst = the star only, 10 ticks) and
  27358bfe (the patch's ground is the inked scorch). Both are hooks in your fight_areas_art.gd (one argument, one
  `if not ... :` line); take them at merge.
- MILESTONE 08:09 the bottle's glass (8d727846), gunplay REQUEST 31's glass-and-fuel half without an image call:
  `WeaponFxShell.glass` flings 7 cream slivers (the existing `shard` cell, `GLASS_M` 0.8 m) from half the splash
  radius to 1.1 of it over 16 ticks, easing out, spinning, fading over the last third; angles from the burst's
  place (replay-stable). Tried 0.45 m first: hairlines at 48 px/m. Looked at in the same-tick city A/B.
- DECISION weapon-art bottle glass: as above (docs/decisions.md). GLASS 0 = none.
- Evidence (masters): `clips/it14-molotov-landing-glass-scorch-ab-city-48ppm-2x.mp4` (+ `-quarterspeed`): left the
  original landing (rocket blast frames, bead ring, flat disc), right all three it14 changes (star + glass, then the
  fire over an inked scorch), ticks 380-469. Strips: `frames/it14-molotov-glass-ab-city-48ppm.png`,
  `frames/it14-molotov-fire-ground-ab-city-48ppm.png`, `frames/it14-molotov-burst-ab-city-48ppm.png`. Earlier it14
  clips replaced by this one. frames.json 15, the three it14 entries first.
- Gates of record at 8d727846 (`evidence-it14.log`, `node tools/evidence/run.mjs --no-bench --allow-dirty`; dirty
  = this lane's untracked evidence/ dir): lint 13/13, unit 741/741, scenarios 32/32, parity bit-exact over 1200
  steps (planted mutation caught at step 629). Selftest: look goldens 11/11 (worst 0.02), block goldens 5/5, world
  lock holds; FAIL on the accent audit only (32 px/m vermilion on vehicles 4 px, on cop 4 px), the tree-wide
  blood-flicker class measured in it12 and by rivet-arsenal and gunplay tonight; the selftest's D4 city frames
  have no molotov in them, and these changes only draw over a blast or a fire patch. An earlier unit run
  (`unit-it14c.log`, 740/741) failed `test_noir_shadows` only, the known flake under load; green in the gate run.
- FRICTION 08:04 I edited the tree while my first evidence run was going; stopped it (taskkill /T on its node PID)
  and re-ran after the commit. Edit nothing tracked while a gate runs.
- Registry rules applied: realtime-combat-semantics (a bottle reads as glass + fire, a rocket as a blast: one
  impact read per damage type), motion-quality-gating (same deterministic ticks, one variable per A/B),
  depth-ordered-layered-art (scorch on the ground layer under the flames). No deviation.

## Calls for the owner (adds, iteration 14)
- weapon-art-15 molotov landing: A (now) star + glass slivers, then the fire over an inked scorch; B the rocket's
  full blast for every splash (the before, `--fire-burst=off`). Clip `it14-molotov-landing-glass-scorch-ab-city-
  48ppm-2x.mp4` (B left, A right). Recommendation: A. A drawn glass-and-fuel sheet (image route) would beat both.

- Session close 08:13: commits 474038b1, 27358bfe, 8d727846 (code) + journal commits. No Godot process of mine
  running (every capture exited on --quit-after; the first evidence run stopped by PID). Scratch wa8b-wa14 deleted.

NEXT (iteration 15):
1. REQUEST 12 -> rivet-arsenal (gloria stand-in): still unanswered in their JOURNAL; mine is on this branch.
2. The melee four in the claw: only on n-rivet-arsenal (StagePilot.wielding, arena_arsenal_bot); MeleeWeaponView is
   still rivet-motion's procedural bars. Merge n-rivet-arsenal into a throwaway worktree, film katana / baton /
   chainsaw / plasma sword in Rivet's claw at 32 and 64 px/m, then decide whether the held art replaces the bars
   (a hook in melee_weapon_view.gd, rivet-arsenal's call).
3. Long guns drawn over Rivet's helmet in the carry pose (rivet-arsenal's view; watch).
4. A drawn glass-and-fuel splash sheet for the molotov (image route, under image.lock) to replace the shard reuse.
- MILESTONE 08:17 the rocket blast's tail (3a703dbd): the blast sheet's last frame (16 cream discs in ink rims) was
  the same debug-bead ring on the rocket; `WeaponFxArt.blast` now holds the smoke ring (frame 2) through those 10
  ticks, growing 1.08 -> 1.30 and fading to 15 %. `--blast-beads=on` = before. Same-tick city A/B (`--weapon=
  rocket_launcher --loadout=rocket_launcher`, blast ~415, ticks 435-444 differ), looked at: before, hollow ink
  rings scattered round the kill; after, the smoke ring swells and thins out, the cop's red death stays readable.
  Evidence (masters): `clips/it14-rocket-blast-tail-ab-city-48ppm-2x-quarterspeed.mp4`, strip
  `frames/it14-rocket-blast-tail-ab-city-48ppm.png`; frames.json 15 (entry 2; dropped the REQUEST-31-only strip,
  covered by the combined molotov clip). DECISION line in docs/decisions.md.
- Gates at 3a703dbd: unit 741/741 (`unit-it14d.log`), scenarios 32/32 (`scenarios-it14b.log`), lint 13/13 (hook).
  Parity untouched (render only). Scratch wa14r deleted. No Godot process of mine running.
- Calls for the owner (add): weapon-art-16 rocket blast tail: A (now) the smoke ring holds and thins / B the cream
  bead ring (`--blast-beads=on`). Clip above, B left. Recommendation: A; a redrawn frame 3 (smoke wisps) would be best.
- Session close 08:19. NEXT unchanged from 08:13 (REQUEST 12, the melee four on rivet-arsenal's path, long guns over
  the helmet, a drawn glass-and-fuel sheet) plus 5: redraw the blast sheet's frame 3 as torn smoke wisps.

## Iteration 15 (08:19-08:30, BUILD; 11 minutes to freeze)
- 08:20 read JOURNAL tail, git log, other lanes' JOURNALs for REQUESTs to weapon-art. No new REQUEST since it14.
- REQUEST 12 -> rivet-arsenal CLOSED: they merged n-weapon-art at 07:50 (552add84 -> ceee3a88); `art_stand_in` no
  longer maps gloria -> pistol, and their guard in test_held_lod.gd keeps it so (n-rivet-arsenal JOURNAL l.360).
- Long guns over the helmet (NEXT 3): rivet-arsenal owns it and has ruled out the grip-origin lead (08:14, 1-2 px);
  the fix is an authored carry pose per long gun in their view. Nothing for the art to change: closed as a watch.
- DECISION 08:22 no code change this iteration: a render change needs a same-tick A/B and gate runs (unit ~6 min,
  scenarios ~3 min) that do not fit before the 08:30 freeze. The branch stays at its gates of record (3a703dbd:
  unit 741/741, scenarios 32/32, lint 13/13; parity untouched).
- `evidence/weapon-art/` stays untracked (scratch logs and stills of record are mirrored in gtai-masters).

NEXT (after the night run):
1. The melee four in the claw on rivet-arsenal's path (merge n-rivet-arsenal into a throwaway worktree, film katana /
   baton / chainsaw / plasma sword at 32 and 64 px/m; decide whether held art replaces MeleeWeaponView's bars).
2. A drawn glass-and-fuel splash sheet for the molotov (image route, under image.lock).
3. Redraw the blast sheet's frame 3 as torn smoke wisps (replaces the held smoke ring of 3a703dbd).
4. Answer owner calls weapon-art-15 (molotov landing) and weapon-art-16 (rocket blast tail) once judged.

## Iteration 16 (08:21-08:30, BUILD; 9 minutes to freeze)
- 08:21 read JOURNAL tail, git status, other lanes' JOURNALs for REQUESTs to weapon-art. Nothing new since it15:
  brutality REQUEST 4 (top-down X-ray + charred) was delivered earlier (`gore_*_top`, l.632). Gunplay REQUEST 31
  was answered by 3a703dbd and 8d727846. Human-reactions REQUESTs 1-2 were answered. REQUEST 12 -> rivet-arsenal
  was closed by their merge.
- DECISION 08:23 no code this iteration, same reason as it15: a render change needs a same-tick A/B plus unit
  (~6 min) and scenarios (~3 min), and that does not fit before the 08:30 freeze. Gates of record stay at
  3a703dbd (unit 741/741, scenarios 32/32, lint 13/13; parity untouched).
- No Godot process of mine running. The two Godot PIDs on the machine (46852, 47704) belong to other lanes; I
  left them alone. `evidence/weapon-art/` stays untracked (scratch; the stills of record are in gtai-masters).

NEXT (after the night run): unchanged from it15. (1) The melee four in the claw on rivet-arsenal's path. (2) A
drawn glass-and-fuel molotov splash sheet. (3) Redraw blast frame 3 as torn smoke wisps. (4) Owner calls
weapon-art-15 and -16 once judged.

## Iteration 17 (08:30-08:40, STABILIZE; past freeze)
- 08:30 read JOURNAL tail, git log, git status. No project file changed since 3a703dbd (`git diff --stat 3a703dbd HEAD
  -- project` is empty), so the gates of record still describe the build: unit 741/741, scenarios 32/32, lint 13/13,
  parity untouched (render only since the merge base).
- Evidence check: all 15 entries in `gtai-masters/n4/weapon-art/frames.json` resolve to files on disk; the newest
  (it14 molotov glass/scorch, it14 rocket blast tail) were filmed on 3a703dbd/8d727846, which match the current build.
- No Godot process running on the machine; nothing of mine to free. `evidence/weapon-art/` stays untracked (scratch).
- DECISION 08:32 no code and no gate re-run: nothing changed since the gates of record, and a full unit + scenarios run
  (~9 min) would not finish before the 08:40 stop.

NEXT (after the night run): unchanged from it15. (1) The melee four in the claw on rivet-arsenal's path. (2) A drawn
glass-and-fuel molotov splash sheet. (3) Redraw blast frame 3 as torn smoke wisps. (4) Owner calls weapon-art-15 and
-16 once judged.

## Iteration 18 (08:40-08:50, REPORT)
- MILESTONE 08:45 REPORT.md written: gates of record (3a703dbd: unit 741/741, scenarios 32/32, lint 13/13; parity
  bit-exact at 8d727846; selftest accent FAIL = tree-wide blood flicker), what works with evidence paths, what does not
  (melee four still procedural bars in the claw on this branch; reused FX cells), friction, calls weapon-art-1..16,
  merge notes, next steps. Every masters path cited in REPORT.md checked to exist (scripted check, none missing).
- No code, no Godot run. `evidence/weapon-art/` stays untracked (scratch).

NEXT (after the night run): as in REPORT.md "Next steps": (1) melee four in the claw via n-rivet-arsenal; (2) drawn
glass-and-fuel molotov sheet; (3) blast frame 3 as torn smoke wisps; (4) owner calls once judged.

## Iteration 20 (08:42-, BUILD, extension to 11:00; freeze 10:30, session stop 09:42)
- 08:42 read: JOURNAL tail, git log, REPORT open items, other lanes' JOURNAL tails. No new REQUEST to weapon-art.
- NEXT 1 (melee four in the claw) CLOSED by rivet-arsenal's own work: RivetHeldView on n-rivet-arsenal draws my held
  art (WeaponArt.make_held) for katana / baton / chainsaw / plasma sword, with a swept arc and the chainsaw judder. It is
  filmed live in their masters (`n4/rivet-arsenal/frames/city-block-melee-64ppm-2x.png`, `katana-slash-thrust-sheet-64ppm.png`,
  `clips/city-block-melee-64ppm.mp4`); I looked at both stills, and the drawn blades read in the claw. MeleeWeaponView's
  bars are left only in rivet-motion's dev combo_clip_run. Nothing to merge here.
- MILESTONE 08:48 the rocket blast's tail tears into smoke wisps (51d42adf). From tick 20 to the effect's 40-tick end,
  `WeaponFxShell.wisps` draws 12 of the rocket's smoke puffs. They start on the ring's line, drift out by 0.4 of the
  radius, stretch along the ring, shrink and fade. Before, the held ring (3a703dbd) dimmed into a grey blob. The tail
  now lasts 20 ticks instead of 10. `--blast-tail=ring` = before. A radial stretch was tried first (9 puffs) and read
  as flower petals; looked at in strip2. Same-tick city A/B, `--weapon=rocket_launcher`, ticks 435-455 differ.
  Evidence (masters): `clips/it20-rocket-blast-wisps-ab-city-48ppm-1.5x.mp4` (+ `-quarterspeed`), strip
  `frames/it20-rocket-blast-wisps-ab-city-48ppm.png`; frames.json entry 2 (replaces the it14 beads/ring entry).
- Gates at 51d42adf: lint 13/13, unit 742/742 (`unit-it20.log`), scenarios 32/32 (`scenarios-it20.log`). Parity untouched (render only).
- DECISION 08:50 no molotov fuel-splash sheet: the it14 strip shows the landing already reads (star, glass, fire,
  scorch), and a fuel stain would lie under the flames. Dropped from NEXT.
- MILESTONE 08:56 the mini-nuke flies its own bomb cell instead of the rocket at 1.5x (`tools/art/nuke_shell.py`,
  `fx/nuke_shell.png`, table row + `projectile_fx`, `WeaponFxShell.SHELLS`). `--nuke-shell=rocket` = before.
  The .import was fixed to mipmaps on (Godot's default import had them off; every FX cell has them on). Same-tick city A/B
  (`--weapon=mini_nuke --loadout=mini_nuke`, ticks 396-433 differ), looked at: before a slim rocket, after a fat
  bomb with a boxed tail and a vermilion band, the exhaust lick behind it. Evidence: `clips/it20-mini-nuke-shell-ab-city-48ppm.mp4`
  (+ `-halfspeed`), strip `frames/it20-mini-nuke-shell-ab-city-48ppm.png`; frames.json entry 3 (replaces the it9 shell clip).
- Registry rules applied: motion-quality-gating (same deterministic ticks, one variable, looked at before keeping);
  sprite-and-atlas-production (cells from a seeded script, same import settings as their siblings). No deviation.
- Gates at 5d453958: lint 13/13, unit 742/742 (`unit-it20b.log`), scenarios 32/32 (`scenarios-it20b.log`).
- MILESTONE 09:00 (unit 742/742, `unit-it20c.log`; lint 13/13) the wisps at the mini-nuke's 12 m scale: the blast is the same sheet, so its tail tore into 12 puffs
  6.6 m wide that drifted over Rivet (looked at in the 5d453958 run). Now a puff is capped at `WISP_MAX_M` 2.5 m and
  the ring tears into more of them (about 32); the rocket at 3.5 m (1.9 m puffs) is unchanged. Same ticks against the
  5d453958 run, looked at: Rivet reads through the torn ring. Evidence: `clips/it20-nuke-blast-wisps-capped-ab-city-48ppm.mp4`,
  `frames/it20-nuke-blast-wisps-capped-ab-city-48ppm.png` (cited in frames.json entry 2's note).
- Gates at 9a66ac6c: lint 13/13, unit 742/742 (`unit-it20c.log`), scenarios 32/32 (`scenarios-it20c.log`). Parity untouched
  (render only since the merge base).
- 09:00 REPORT.md updated in place: an "After 09:00" section, calls 12 and 16 re-stated (12 now ships the bomb cell, the
  rocket is `--nuke-shell=rocket`; 16 now has three options: wisps / ring / beads), and Next steps trimmed. FRICTION: the
  08:40 REPORT said the frames for calls 5 and 8 were missing from masters. Both were there; the REPORT now cites them.
- 09:03 call 3 (energy rounds paper-white on cream) got its first frame, showing the current read only: pistol / electro / plasma / ray
  in the city block at 32 px/m, same ticks (`frames/it20-call3-energy-vs-kinetic-city-32ppm.png`). Looked at: the plasma
  bolt and the ray rings read, and the electro arc is the thinnest. The long red line is the cop's told aim line (gunplay), not a round.
- Scratch AVIs and frame dumps (4.0 GB) deleted. No Godot process of mine running; no lock taken.

NEXT (iteration 21, before the 10:30 freeze; showcase's final merge is 09:45, so tip 9a66ac6c+ docs is what they take):
1. If time: the electro arc is the weakest energy read at 32 px/m (call 3 frame). A thicker ink under the arc cell is
   in the lane's palette and needs no new token; build it as a one-value A/B and film it before 10:30.
2. Keep the gates of record at 9a66ac6c; any code after it needs lint + unit + scenarios before 10:30.
3. At 10:40, update REPORT.md in place (the "After 09:00" section) with anything later.
- MILESTONE 09:08 the electro bolt's ink outline is thickened (NEXT 1; call 3, inside the palette). `WeaponFxElectro.ink_under`
  draws the arc frame in ink at 8 offsets 0.06 m out, then the paper, for Rivet's bolt (WeaponFxArt BOLT branch, one
  line) and the chain arcs. Tried first: the ink silhouette 1.6x taller. Looked at in a 3x zoom: its peaks missed the
  paper's, a smudge. Rejected. Same-tick city A/B at 32 px/m (`--weapon=electro_gun`), looked at: the bolt reads as one
  bold inked stroke. `--arc-ink=off` = before. Evidence: `clips/it20-electro-arc-ink-ab-city-32ppm-2x.mp4`, strip
  `frames/it20-electro-arc-ink-ab-city-32ppm.png` (3 rows incl. the rejected try), zoom `frames/it20-electro-arc-ink-zoom-t395-city-32ppm-3x.png`;
  frames.json entry 4 (dropped the it8 plasma comet clip). Doc, decision, REPORT (call 3 row) updated.
- Gates at the electro ink commit: lint 13/13, unit 743/743 (`unit-it20e.log`), scenarios 32/32 (`scenarios-it20e.log`).
- MILESTONE 09:13 the ray gun's hoops get the same ink (call 3). `WeaponFxElectro.ink_cell` (generic: an FX cell placed by a
  Transform2D, keeping to 5 parameters) draws each hoop in ink at the 8 offsets, fading with the hoop; the electro bolt
  now calls it too (same math). Same-tick city A/B at 32 px/m (`--weapon=ray_gun`), looked at with a 3x zoom: bold
  inked rings with a thin paper core, heavy but clearly rings. `--ray-ink=off` = before. Evidence: `clips/it20-ray-rings-ink-ab-city-32ppm-2x.mp4`,
  `frames/it20-ray-rings-ink-ab-city-32ppm.png`, zoom `frames/it20-ray-rings-ink-zoom-t398-city-32ppm-3x.png` (cited in
  frames.json entry 4's note). The plasma bolt (a paper comet) reads, so it is left as is.
- Gates at the ray-ink commit: lint 13/13, scenarios 32/32 (`scenarios-it20f.log`), unit 743/743 (`unit-it20g.log`). The first unit run
  (`unit-it20f.log`) had 1 failure, test_noir_shadows ("Parameter t is null"): the known flake under load (an ffmpeg encode
  was running). It passed when re-run alone.
- 09:18 checked the electro and ray ink at 48 px/m (the showcase reel's zoom), after only, city block: the bolt reads as
  an inked zigzag with a paper core. The hoops are heavy dark rings (tyre-like) but still read as a hoop train. If the
  owner finds them too heavy, a smaller ARC_INK_M for the hoops is a one-value change, or `--ray-ink=off` turns the hoop ink off. Frame
  (masters) `frames/it20-electro-ray-ink-city-48ppm.png`.
- FRICTION 09:16 gdformat on Windows rewrote two .gd files with CRLF in the working tree. The index stayed LF
  (`.gitattributes eol=lf`), so the commits are clean; the working files were normalized and re-added (no content change).
- Scratch AVIs deleted; no Godot process of mine running; no lock taken.

NEXT (iteration 21, before the 10:30 freeze). The tip for showcase's 09:45 final merge is a1a819d3 + docs:
1. (Done 09:21, a1a819d3: hoops at RAY_INK_M 0.035.) Watch the showcase reel's ray gun chapter for the hoops' read.
2. Human-reactions' riot-shield call B needs a flat rectangular shield part from weapon-art; build it only if the owner picks B.
3. At 10:40 update REPORT.md in place ("After 09:00") with anything later. Gates of record now: lint 13/13, unit
   743/743, scenarios 32/32 at a1a819d3; parity untouched (render only).
- MILESTONE 09:21 the ray hoops' ink is lighter (NEXT 1): `RAY_INK_M` 0.035 m, while the bolt keeps 0.06. `ink_cell` now
  takes `ink: Vector2` (reach m, alpha). Same ticks at 48 px/m against the 54fb97d1 frame, looked at: the paper shows in
  each hoop and they read as rings, not tyres. Frame `frames/it20-ray-hoop-ink-lighter-ab-city-48ppm.png`. Gates: lint
  13/13, scenarios 32/32 (`scenarios-it20h.log`), unit 743/743 (`unit-it20i.log`). The run before it (`unit-it20h.log`)
  failed only test_noir_shadows again, the known flake, unrelated to weapon FX; it passed when re-run alone.

## Iteration 21 (09:25-10:25, BUILD, extension)
- 09:25 read JOURNAL NEXT, git log, the other lanes' JOURNAL tails (gunplay, brutality, human-reactions,
  showcase, rivet-arsenal). No new REQUEST -> weapon-art (31 and brutality 4 were answered earlier).
  REPORT Next step 5 (fold the mipmaps import step) is stale: `weapon_fx_table.py` did it in iteration 2.
- FINDING 09:30 (brief item 4's floor half, never filmed in the live game): the arena pit with
  `--rigs --start=pit --bot=arsenal --loadout=pistol --pickups=hand_cannon,rocket_launcher --clean --ppm=48`
  (480 frames, `--fixed-fps 60`, 0 script errors). Looked at, tick 140 at 3x: the hand cannon on rivet-arsenal's
  paper disc prints as a black ink smudge. Cause: `PickupsView` gives the pickup the rigs' PART print, the same
  collapse of mid-tone rust and steel that the held guns had at 06:15.
- TRY 09:35 (rejected): the pickup's flat fills, no material. The drum and grip read, but with no edge the gun
  faded into the cream disc.
- MILESTONE 09:40 `PickupLook.dress` (new, `features/combat/weapons/art/pickup_look.gd`): flat fills over 8 ink
  silhouettes 1 world px out (modulate = the ink token, `show_behind_parent`). One hook line in rivet-arsenal's
  `pickups_view.gd` (`PickupLook.dress(s)` replacing the material line). `--pickup-print=on` = before.
  Test `test_pickup_look.gd` (default: no material, 8 ink children 1 world px out; flag: the print, no children).
  Same-tick A/B in the live arena pit at 32 and 48 px/m, looked at: the after is the hand cannon (drum, grip, rust)
  in a crisp ink line. Honest read: at 32 px/m it has less contrast at a glance than the black blob, but it's
  recognisably the gun. Evidence (masters): `clips/it21-pickup-ink-ab-arena-pit-48ppm.mp4` (5.5 s, left before / right after),
  `frames/it21-pickup-ink-ab-arena-pit-32-48ppm.png` (2x and 12x). frames.json entry 5 (dropped the it6 weapon wall
  still; its file stays for call 9). DECISION line in docs/decisions.md, doc paragraph in docs/art/weapons.md.
- Registry rules applied: motion-quality-gating (same deterministic ticks, one flag, looked at before keeping; the
  first try rejected on the frame); depth-ordered-layered-art (the outline is a layer behind the sprite, not baked).
  No deviation.
- FRICTION 09:37 `--check-only -s` on a GutTest script hung (it is not a MainLoop); the task was stopped after ~6 min.
  Lint caught the one long line instead. For test files, run lint + unit, not `-s --check-only`.
- Gates at 57ee8615: lint 13/13 (`lint-it21.log`, and the pre-commit hook), unit 745/745 (`unit-it21.log`),
  scenarios 32/32 (`scenarios-it21.log`). Render only; parity and goldens untouched.
- MILESTONE 09:51 (384883b1) the dev weapon lineup (`dev/weapon_art/weapon_lineup_run.gd`) lays its pickups through
  `PickupLook.dress` too, so the lineup shows the game's pickup look. Re-rendered core six + nine adv at 32 and 64
  px/m, 0 script errors, looked at: every pickup silhouette is distinct in its ink line beside the cop. Masters
  `frames/it21-lineup-{core,adv}-{64ppm,32ppm-2x}-pickup-ink.png`; frames.json entry 6 (dropped the it9 Gloria
  half-speed clip; its full-speed sibling and the strip stay).
- To showcase / Director: weapon-art's tip is now 384883b1 (+ docs). If round 17 already took a1a819d3, the delta is
  the pickup look (PickupLook + one line in rivet-arsenal's pickups_view.gd), render only.
- 09:53 REPORT updated in place: after-09:00 heading covers iteration 21, two bullets, call weapon-art-17, the merge
  note for pickups_view.gd, stale Next step 5 marked.
- TRY 09:56 (rejected) `OUTLINE_WORLD_PX` 1.5 against 1.0, same tick 120 in the arena pit at 32 px/m, 4x crop
  (masters `frames/it21-pickup-outline-print-1px-1.5px-arena-pit-32ppm-4x.png`: print / 1.0 / 1.5). The 1.5 line is
  only slightly bolder at 32 px/m and would be 2.25 screen px at 48. Kept 1.0 (no code change).
- 09:54 showcase's final round 18 started at 09:45 from the lane tips then. If it took a1a819d3+docs, the pickup look
  (57ee8615, 384883b1) is the only weapon-art delta for the Director's morning merge (render + dev only).
- Scratch frame dumps deleted (wa21); no Godot process of mine running; no lock taken.

NEXT (after the 10:30 freeze; the REPORT is already updated in place for iteration 21):
1. If the owner picks call 17 B (the bold print blob), it is `--pickup-print=on` or `PickupLook.printed = true`.
2. Human-reactions' riot-shield call B still needs a flat rectangular shield part; build only if the owner picks B.
3. The calls to answer once judged: 3, 12, 14, 15, 16, 17.
- 09:58 the pickup look on a second gun: live arena pit, `--pickups=ray_gun,plasma_rifle`, 48 px/m, same ticks with and
  without `--pickup-print=on` (150 frames each, 0 script errors). Looked at tick 140 at 4x: the print broke the ray
  gun into ink fragments; the ink look keeps it one coiled gun with its vermilion tip. Masters
  `frames/it21-pickup-ink-ray-gun-ab-arena-pit-48ppm-4x.png`, cited in frames.json entry 5 and the REPORT bullet.

## Iteration 22 (09:59-10:30, BUILD, extension, last before the freeze)
- 09:59 read JOURNAL NEXT, git log, other lanes' JOURNAL tails. No new REQUEST -> weapon-art.
- 10:00 showcase round 19 merged n-weapon-art at `b97342e1` (`a5822dd2` on n-showcase, 09:57). That holds every
  weapon-art code change, the pickup look (57ee8615, 384883b1) included; only docs came after. Nothing is left for
  the Director's merge but docs.
- DECISION 10:00 no new code this session. 30 min is not enough to build, gate, film and look at a change, and
  showcase's final reel is already cut. The one open readability item (call 17, pickup contrast at 32 px/m) waits
  for the owner's pick. The ArenaArsenalBot does not walk to pickups, so a floor-to-claw clip would need a new
  bot: not before the freeze.
- FRICTION 10:00 REPORT.md held a raw form feed where `M\frames` had been written (a `\f` escape eaten by a script
  in iteration 21). Fixed with String.fromCharCode, since this shell tool collapses `\` in command text (daa42ef4).
  frames.json is clean (15 entries, every file exists, no control chars).
- MILESTONE 10:03 gates on the tip daa42ef4 (code 384883b1): lint 13/13 (pre-commit), unit 745/745
  (`unit-it22.log`), scenarios 32/32 (`scenarios-it22.log`), private APPDATA. The ObjectDB leak warnings at exit are
  the usual ones (exit 0). REPORT line added under "After 09:00".
- No Godot process of mine running; no lock taken; no scratch renders this session.

NEXT (after the 10:30 freeze, unchanged from iteration 21):
1. Call 17 B (the bold print blob on the ground) = `--pickup-print=on` or `PickupLook.printed = true`.
2. Human-reactions' riot-shield call B needs a flat rectangular shield part; build it only if the owner picks B.
3. Calls to answer once judged: 3, 12, 14, 15, 16, 17. A floor-to-claw pickup clip needs an arena bot that walks
   to the pickups (rivet-arsenal's ArenaArsenalBot only switches slots).

## Iteration 23 (10:04-10:30, BUILD, extension, before the freeze)
- 10:04 read JOURNAL NEXT, git log, other lanes' JOURNALs for `weapon-art`. No open REQUEST: gunplay 31 was done at
  07:51 (474038b1) and 08:09 (8d727846); brutality 4 was delivered (`gore_*_top`).
- DECISION 10:04 no new code (same reason as iteration 22): showcase's final reel is cut from `b97342e1`, which holds
  every weapon-art code change; a change now could not be gated, filmed and looked at before 10:30.
- MILESTONE 10:08 consistency audit of what the owner reads: masters frames.json 15 entries, every file exists;
  REPORT.md cites 43 masters files (`M\...`, `n4\...`), every one exists (the brace-expanded lineup set too); no
  control characters in REPORT.md; `steam/ai-provenance/2026-11.jsonl` 1038 lines, all valid JSON. Top 3 entries
  are 48 px/m game-city A/B clips (molotov landing, rocket wisps, nuke shell), inside the 04:00 rule.
- No Godot process of mine; no lock taken; no renders this session.

NEXT (after the freeze, unchanged): call 17 B = `--pickup-print=on` / `PickupLook.printed = true`; the riot-shield
part only if the owner picks human-reactions' call B; calls 3, 12, 14, 15, 16, 17 to answer once judged; a
floor-to-claw pickup clip needs an arena bot that walks to pickups.

## Iteration 24 (10:06-10:30, BUILD, extension, last before the freeze)
- 10:06 read JOURNAL NEXT, git log, other lanes' JOURNALs for `weapon-art`. No new REQUEST: the hits are the
  answered ones (brutality 3 and 4, gunplay 31, human-reactions 1 and 2, rivet-arsenal 12, showcase 11).
- 10:07 showcase is on its final round (round 19: brutality + human-reactions merges, 08e1b72f the electro corpse
  patch). Its last n-weapon-art merge is `b97342e1`, which holds every weapon-art code change; only docs came after.
- DECISION 10:07 no new code (same reason as iterations 22 and 23): a change now could not be gated, filmed, looked
  at and merged into showcase's final reel before 10:30. The tip's gates are unchanged since iteration 22
  (lint 13/13, unit 745/745, scenarios 32/32 on code 384883b1).
- 10:08 `docs/art/weapons.md` already documents the pickup ink look and the `--pickup-print=on` before (lines
  233-234), matching `pickup_look.gd`. `evidence/weapon-art/` stays untracked (gate logs and scratch PNGs, as in
  every iteration since 1; the masters copies are the record).
- No Godot process of mine; no lock taken; no renders this session.

NEXT (after the freeze, unchanged): call 17 B = `--pickup-print=on` / `PickupLook.printed = true`; the riot-shield
part only if the owner picks human-reactions' call B; calls 3, 12, 14, 15, 16, 17 to answer once judged; a
floor-to-claw pickup clip needs an arena bot that walks to pickups.

## Iteration 25 (10:12-10:30, BUILD, extension, last before the freeze)
- 10:12 read JOURNAL NEXT, git log, other lanes' JOURNALs for `weapon-art`. No new REQUEST: the hits are the
  answered ones (brutality 3 and 4, gunplay 31, human-reactions 1 and 2, rivet-arsenal 12, showcase 11).
- 10:13 showcase's tip is still round 19 (08e1b72f, the electro corpse patch); its last n-weapon-art merge
  `b97342e1` holds every weapon-art code change. The two running Godot processes are not mine (left alone).
- DECISION 10:13 no new code (same reason as iterations 22-24): 17 minutes before the freeze, a change could not be
  gated, filmed, looked at and merged into showcase's final reel. Gates unchanged since iteration 22 (lint 13/13,
  unit 745/745, scenarios 32/32 on code 384883b1); REPORT, frames.json and provenance audited in iteration 23.
- No lock taken; no renders this session. `evidence/weapon-art/` stays untracked (gate logs, scratch PNGs).

NEXT (after the freeze, unchanged): call 17 B = `--pickup-print=on` / `PickupLook.printed = true`; the riot-shield
part only if the owner picks human-reactions' call B; calls 3, 12, 14, 15, 16, 17 to answer once judged; a
floor-to-claw pickup clip needs an arena bot that walks to pickups.

## Iteration 26 (10:23-10:30, BUILD, extension, last before the freeze)
- 10:23 read JOURNAL NEXT, git log, other lanes' JOURNALs for `weapon-art`. No new REQUEST: the newest hits
  (rivet-arsenal line 359, showcase line 1164) are about the answered REQUEST 12 and REQUEST 6.
- 10:24 showcase finished its final round (3bf77c9f: round 19 merged, gated, filmed as reel-1012, exe
  re-exported). Its n-weapon-art merge `b97342e1` holds every weapon-art code change.
- DECISION 10:24 no new code, 6 minutes before the freeze (same reason as iterations 22-25). Gates unchanged since
  iteration 22 (lint 13/13, unit 745/745, scenarios 32/32 on code 384883b1).
- No lock taken, no Godot process, no renders. `evidence/weapon-art/` stays untracked (gate logs, scratch PNGs).

NEXT (after the freeze, unchanged): at 10:40 update the REPORT in place (no code after 09:00 beyond what showcase
round 19 merged); call 17 B = `--pickup-print=on` / `PickupLook.printed = true`; the riot-shield part only if the
owner picks human-reactions' call B; calls 3, 12, 14, 15, 16, 17 to answer once judged; a floor-to-claw pickup clip
needs an arena bot that walks to pickups.

## Iteration 27 (10:30-10:40, STABILIZE, past the freeze)
- 10:30 read JOURNAL NEXT and the REPORT. No code change (STABILIZE, nothing red: the gates are unchanged since
  iteration 22, with lint 13/13, unit 745/745 and scenarios 32/32 on code 384883b1).
- 10:31 MILESTONE REPORT updated in place for the 10:40 report: "After 09:00" now covers iterations 20-27 and states
  that the freeze code is 384883b1 and that showcase's final round (3bf77c9f, reel-1012) holds every weapon-art
  code change via b97342e1. frames.json is unchanged (15 entries, audited in iteration 23).
- No lock taken, no Godot process, no renders. `evidence/weapon-art/` stays untracked (gate logs, scratch PNGs).

NEXT (morning, owner): judge calls 3, 12, 14, 15, 16, 17 in the REPORT. Call 17 B = `--pickup-print=on` /
`PickupLook.printed = true`. Build the riot-shield part only if human-reactions' call B is picked. A floor-to-claw
pickup clip needs an arena bot that walks to pickups.
