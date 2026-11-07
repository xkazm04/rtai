# d9 rivet JOURNAL

Lane `rivet`, branch `d9-rivet`. Rivet as whole-figure drawn frames per pitch, every weapon in his hands.

## Iteration 3 (09:48-10:48), the first real session

- FRICTION 09:48: iterations 1 and 2 exited in 5 s on billing (api / api2 credit too low, `gtai-d9/logs/run.log`);
  iteration 3 is the first that ran. No JOURNAL existed; created here.
- Read: brief, `rivet-final/README.md`, catalog notes for rivet_70_v3 / rivet_70_left_v4 / rivet_55_v2 /
  rivet_55_left / the plasma sword rows, `StreetWalkerCards` (n8 street's whole-figure pattern), `RigCardSets`,
  `RigHeadCard`, `CutRig.drive`, `RivetHeldView._process`, `RigClips`.
- Registry rules applied (sprite-and-atlas-production): one uniform cell per strip, a common foot line
  and a common anchor (helmet centre) so frames do not swim when they swap; premultiplied resampling
  (no dark keyed fringe); every strip reproducible from a manifest (the redraw is a one-line swap).
  (motion-quality-gating / depth-ordered-layered-art / realtime-combat-semantics: owed to the runtime
  step: judged in motion, the shot origin and the hit read must not move.)
- MILESTONE 10:30 `f852d9b3`: `tools/art/rivet_frames.py` + `tools/art/rivet_frames.json` cut all 36 owner-picked
  sheets into strips under `project/features/characters/art/view/<p70|p55>/`:
  - `rivet_frames.png`: 14 cells = facings 0-4 (front, 3/4 right toward, right profile, 3/4 right away,
    back; the RigHeadCard frame order) + drawn left 0-2 (3/4 left toward, left profile, 3/4 left away)
    + walk, sprint, roll, claw strike, hit, death.
  - `rivet_eq_<weapon>.png`: 8 cells = facings 0-4 + fire/swing right, fire/swing at the camera, at rest.
  - Figure height 110 px for the facings' median (so 64 px/m close-ups downsample, never upscale).
  - Anchor: cell centre column = helmet centre; feet PAD=2 px above the cell bottom.
  - Action-row scale: helmet-width ratio to the facings, measured; outside [0.55, 1.0] (a claw or blade
    merged into the dome) it takes `act_k` (manifest) else 0.75. Base sheets use act_k 0.97 (the
    composed play set, same scale). Ten sheets fell back to 0.75 (printed by the tool).
  - Contact sheets: `C:\Users\kazda\kiro\gtai-masters\d9\rivet\rivet_strips_p70_contact_cut_fig110.jpg`, `..._p55_...`.
    Looked: consistent across the set; katana / plasma_sword / chainsaw action rows read a touch small
    (tune their act_k by eye next).
- MILESTONE `69e6a8b2`: 36 provenance lines in `steam/ai-provenance/2026-11.jsonl` (round + prompt_hash per sheet).

### DECISIONs
- DECISION rivet/strips: whole figures as one strip per sheet per art key (`p70`, `p55`), cut by a
  manifest, not hand-placed cells; the anchor is the helmet centre (a gun or blade never shifts the
  body). Rejected: per-cell JSON offsets (more data, no gain once the cut anchors).
- DECISION rivet/table: the frame map (state -> cell, weapon -> strip) lives as GDScript consts in the
  runtime class, the precedent of `StreetWalkerCards.ROWS/WALKS`; the card-set schema rows describe head
  cards (`[strip, anchor_y, width, bust, raw]`) and do not fit a 14-cell figure strip. Rejected: a new
  JSON table + schema this session (cost, no balance data in it).
- DECISION rivet/left-equipped: equipped sheets have only the five right-turned facings. Two-handed holds
  (gatling, rocket_launcher, plasma_rifle, flamethrower, gloria, mini_nuke, katana, chainsaw,
  plasma_sword) may mirror for the left octants (both hands on the weapon; the brief forbids mirroring a
  one-handed hold). One-handed holds (pistol, machine_pistol, hand_cannon, molotov, electro_baton,
  electro_gun, ray_gun, homing_shard) draw the base drawn-left facing + today's held part (the brief's
  fallback, logged) until drawn equipped left views exist. One flag per weapon (`mirror` / `base`).

### REQUESTs
- REQUEST to assets: `rivet_eq_<id>_70_left` (then 55) for the one-handed holds, pistol first, then
  machine_pistol, hand_cannon, electro_gun, ray_gun, homing_shard, electro_baton, molotov: three drawn
  left facings (3/4 left toward, left profile, 3/4 left away) holding the weapon in his RIGHT hand (the
  cable claw with the cream spike the near arm, as rivet_70_left_v4), the camera and size of
  rivet_70_left_v4. Why: a mirrored facing would swap the weapon hand (owner's hand rule); without them
  3 of 8 directions fall back to the base figure + pasted held part.

NEXT:
1. Runtime `RivetFrames` (features/characters/rivet_frames.gd, <200 LOC), called from `CutRig.drive` after
   `StreetView.step` for `plan.art_dir == "rivet"` under a view with cards and a strip for the art key
   (`top`: nothing runs). Pattern = `StreetWalkerCards`: reuse `rig.head_card` (set texture, hframes =
   cells, offset (-cw/2, -(ch-2))), hide every other CanvasItem of the rig (HID/WAS metas), release on
   art change. Scale s = HEIGHT_M * CharacterRigs.PX_PER_M / 110 (HEIGHT_M ~1.1 => ~35 px at 32 px/m).
   Cell pick: octant (RigHeadCard.OCT_FRAME) 0,1,2 / 6,7 -> facings 2,1,0 / 4,3; octants 3,4,5 -> left
   cells 5,6,7 (base). State: dead/dying -> 13 (death, hold 1.0 s veil is view's), clips.rolling() -> 10,
   strike/punch active -> 11, hit_t > 0 -> 12, speed > MOVING: walk cell 8 / sprint cell 9 alternating with
   the facing by rig.phase (the sheet has one walk drawing: a 2-frame step = facing / walk cell, flipped to
   the travel side), else the facing.
2. Weapon: `RivetHeldView._process` sets `rig.set_meta(&"rivet_weapon", pilot.hold.held)` (and "" when away)
   and hides `_sprite` while `RivetFrames.owns(rig)`; equipped strip `rivet_eq_<weapon>.png` when gun_out:
   facing cells 0-4, fire cell 5 (or 6 when aiming at the camera, octants 1-3) for ~0.12 s after c_recoil>0 or
   while a strike is active, rest cell 7 between shots when not moving. Check the weapon ids
   (ArsenalTable) against the 17 names (gloria etc.).
3. Then: muzzle origin from the frame (HeldPitchArt.publish_muzzle), smear, ghost-form hide, hit flash
   (RigHeadCard.on_tint already tints head_card), shadow, depth sort, occlusion silhouette.
4. Film: city block tilt70 32/64 px/m, King/Servo combo swap, before/after vs main. Gates.

### Iteration 3, continued (10:00-10:45)
- (Time note: I misread the clock at 10:00 as 10:34 and wrote the NEXT above early; the session went on.)
- MILESTONE `26aed6b4`: `RivetFrames` in the game (called from `StreetView.step`, not CutRig: the debt
  ratchet holds cut_rig.gd at 265 lines). RivetHeldView publishes the held id as rig meta `rivet_weapon` and
  hides its part while the drawn frame carries the weapon (`owns_weapon`). Net-zero lines in RivetHeldView.
- FRICTION: `node tools/godot/check.mjs` on cut_rig.gd / street_walker_cards.gd fails "depended scripts"
  even on untouched files (cyclic class refs under --check-only); the unit run compiles everything: trust it.
- MILESTONE: the city block pistol at 48 px/m: the drawn Rivet holds the pistol, the fire cell on shots.
- `19ddf549`: p55 height 1.3 (the King engage showed him small at p55; street's x1.18 step).
- Gates: unit 1691/0; director reel 19/19 down in tilt70, combo, top; 0 SCRIPT ERROR (`evidence/d9/`).
- Before/after 32 + 64 px/m and reel crops in `gtai-masters/d9/rivet/` (frames.json 4 entries).
- Found in the reel at 48 px/m: the flamethrower's back tank still drew beside him -> `_back_tank` gated on
  `owns_weapon` (uncommitted until the evidence gate finishes, then commit).
- REPORT skeleton `docs/day/2026-11-07/rivet/REPORT.md` with Calls 1-3 (size, walk, left one-handed).

NEXT (supersedes the NEXT above; items 1-2 there are done):
1. Commit the `_back_tank` gate after `node tools/evidence/run.mjs --no-bench` reports (log in
   `gtai-d9/scratch/rivet/evidence-it3.log`); copy its summary into `evidence/d9/`.
2. Shot origin + muzzle flash from the drawn frame: a per-strip muzzle point per cell (measure in
   rivet_frames.py: the flash's centroid in the fire cells, the weapon tip in the facings) -> JSON sidecar,
   `HeldPitchArt.publish_muzzle` from it. The sim's shot origin must not move (view only).
3. Film the combo swap at the King and Servo engage (`--boss=king --view=combo`, `--boss=servo`), 48 px/m.
4. Ghost forms (Rivet hidden: check the swap back), death beat 1.0 s in the sprawl cell, roll spin, hit flash,
   occlusion silhouette, cast shadow length for Rivet.
5. Tune act_k for katana / plasma_sword / chainsaw action rows by eye; plasma sword `_v3` swap when it lands.
6. Every weapon fired once at each pitch (`--loadout=<id>`), frame cost under the bench lock.

### Iteration 3, end (10:35)
- MILESTONE `6f6ddce4`: the back tank (flamer / gatling) hides while the drawn frame carries the weapon;
  verified on the city block at 48 px/m (`gtai-masters/d9/rivet/rivet_flamethrower_city_..._t120_200_280_350.png`).
- Gates on 19ddf549 (`evidence/d9/gates-it3.md`): scenarios 52/0 (replay incl.), look goldens 11/11, parity
  exact + planted caught, unit 1691/0, reel 19/19 x3 views, 0 SCRIPT ERROR.
- FRICTION/BLOCKED (~0 min lost, gate owed): evidence's release-compile refuses
  `%TEMP%\gtai-release-compile` ("exists but was not created by release_compile"): a dir this lane did not
  make (probably another lane's run); left alone. Re-run `node tools/tests/release_compile.mjs` next session;
  if still there, ask the Director.
- Combo swap filmed at the King engage (art p55 at tick 32): `rivet_combo_swap_king_engage_..._48ppm_x2_...png`.
- frames.json: 6 entries.
- Registry rules applied: sprite-and-atlas-production (uniform cells, one anchor, premultiplied resample,
  manifest-reproducible); motion-quality-gating (judged in motion on the real scenes: city block, reel,
  King engage; the swap frame checked frame by frame); depth-ordered-layered-art (the whole figure takes
  the head card's z; the hidden parts keep their nodes so release restores them).

NEXT (supersedes both NEXT above):
1. Fire state for streams and auto weapons: the flamer shows no fire cell (no recoil kick). Plan: replace
   `rig.set_meta(RivetFrames.WEAPON, ...)` in RivetHeldView._process with ONE call
   `RivetFrames.publish(rig, pilot.hold.held, arena)` (keeps _process at 40 lines) that also sets
   `rivet_fire` = trigger.cooldown > spec.interval_ticks - 7 when `arena.gun.trigger.spec.id == held`;
   `cell_of` reads it beside the recoil. RivetFrames is at 200 lines: fold `falls_back` into an `_oct(rig)`
   helper shared with `cell_of` to make room (debt ratchet: files_past_soft_cap must not grow).
2. Shot origin + muzzle flash from the drawn frame (per-cell muzzle point measured in rivet_frames.py ->
   JSON sidecar -> HeldPitchArt.publish_muzzle). View only: the sim's origin does not move.
3. Servo engage film; ghost form swap back; death beat in the sprawl cell; roll spin; hit flash; occlusion.
4. act_k by eye for katana / plasma_sword / chainsaw; watch for the plasma sword `_v3` (asset lane).
5. Every weapon at each pitch (`--loadout=<id>`), the frame cost under the bench lock, the release-compile gate.
6. Check the asset lane's answer to the equipped-left REQUEST (gtai-art/library catalog, ids rivet_eq_*_left).

## Iteration 6 (10:34-11:34)
- Read: JOURNAL, git log, d9-seams JOURNAL (no REQUEST to rivet; its REQUESTs go to assets), the asset lane's
  JOURNAL + catalog. Iterations 4-5 left no commits here (this session picked up from the it3 NEXT).
- The asset lane DELIVERED: the 8 one-handed `rivet_eq_<id>_70_left` (pistol, machine_pistol, hand_cannon,
  ray_gun, molotov A; homing_shard B `_s`, electro_gun B `_s`, electro_baton B; v2 of the last two coming),
  and the plasma sword redraw (equipped 70_v2 A, 55_v3 B). 55 left views queued there (round 1155).
- MILESTONE `1e00b083`: left views as their own 3-cell strips `rivet_eq_<id>_left.png` (manifest rows, counts "3");
  `RivetFrames.left_of` picks them for octants 3-5 of a one-handed hold, else the base left + held part (logged
  once per weapon and art key). `weapon_of` is "" while he is down (the death cell lives on the base strip only;
  before, a dying Rivet with a gun out could index cell 13 of an 8-cell strip). New `test_rivet_frames.gd` (4 tests).
  Seen at 64 px/m (`--bot=rivet --loadout=pistol`): the pistol in his far right claw pointing left, cable arm near.
- MILESTONE `b2614b45`: plasma sword redraw swapped in (manifest one line per pitch, as designed). Seen at 64 px/m
  (`--bot=gunplay --weapon=plasma_sword`): both hands on the hilt, the long amber blade, the swing at the camera.
- MILESTONE (blade rows): act_k by eye: p70 katana 1.0, plasma_sword 0.95, chainsaw 0.82; p55 katana 0.95,
  plasma_sword 0.85, chainsaw 1.0 (the tool's helmet measure is fooled by the top fin: by eye on contact sheets,
  two rounds). The p55 sword's side swing had lost its blade to the next cell (blades overlap in x): new `--cc`
  band option cuts by connected component with per-figure masks. Provenance sha256 refreshed for the 6 re-cut strips.
- Provenance: 10 new lines (8 left strips, 2 sword strips).
- Gates it6: lint 15/15; unit 1695 passed / 0 failed (full run). Reel + evidence not re-run this session (strips
  and the left-strip pick only; `top` never reaches RivetFrames: strip_of("") = "").
- frames.json: 9 entries (2 stills + 1 contact added).
- FRICTION (~4 min): a Python heredoc wrote `\r` in Windows paths as CR into REPORT.md; fixed in binary mode.
- Registry rules applied: sprite-and-atlas-production (one manifest, per-figure masks when shapes overlap,
  one anchor so the left strip and the equipped strip do not swim at the swap); motion-quality-gating (judged in
  motion at 64 px/m on the arena, frame grids, not on the strip alone); generative-artifact-gating (the left
  sheets checked against the hand rule before use: weapon hand, cable arm near, size beside the right facings).
- DECISION rivet/left-strips: own 3-cell strip per weapon per art key (docs/decisions.md).

### Iteration 6, continued (10:52-11:25; the 10:52 entry above was written early, the clock was ahead of me)
- MILESTONE `657a4b28`: the fire cell for streams and autos: `RivetFrames.publish(rig, held, gun)` (replaces the
  set_meta line in RivetHeldView, net 0 lines there) flags a shot within FIRE_TICKS=7 from the trigger's cooldown;
  the strip pick moved to `RivetStrips` (rivet_strips.gd: DIR, BASE, ONE_HAND, strip_of, left_of) to stay under 200.
  Seen: the flamer stream holds the fire-at-camera cell through frames 328-354, no flicker.
- The asset lane delivered the 8 one-handed 55 left views (5 A, 3 B) and 70 left v2 for electro_gun (A) and
  electro_baton (B, `_s`): manifest rows + provenance; p55 no longer falls back (Servo film: 0 fallback lines).
- Found in the Servo fight at 48 px/m: a reload magazine floating at his helmet under the drawn figure
  (WeaponMagView rides the hidden off claw; first suspected RivetMagView, filmed `top` to see it was the reload).
  Fixed: `RivetFrames.drawn(rig)` turns both magazine views off under the drawn figure. Verified by film.
- Combo swap filmed at Servo's engage (p55 at tick 32): `rivet_combo_swap_servo_engage_48ppm_x2_t26_30_32_40.png`.
- FRICTION (~3 min): my reels ran while I edited rivet_frames.gd; the combo reel caught the mid-edit parse error.
  Killed my own process tree (PIDs from my reels.sh parent, never by name), re-ran on committed code. Rule for me:
  no .gd edit while a gate runs from this worktree.
- FRICTION: the top reel at `--quit-after 14000` ended before the last two chapters (headless top runs uncapped;
  ticks per frame drift with load); 20000 frames: 19/19. Recorded in evidence/d9/gates-it6.md.
- Gates it6 (evidence/d9/gates-it6.md): unit 1695/0 (full), director reel 19/19 x3 views, 0 SCRIPT ERROR; the
  magazine fix after that: `--changed` 1679/0 + lint. evidence/run.mjs (goldens/parity/scenarios) owed.
- To check (not mine?): a cream-outlined grey blob near Rivet in the Servo fight at t270/t450-510 (first film).

NEXT (supersedes every NEXT above):
1. `node tools/evidence/run.mjs --no-bench` (scenarios, look goldens, parity) and release-compile on HEAD; the
   reel in top with `--quit-after 20000`. No .gd edits while they run.
2. Reload under the drawn figure: he shows the bare base figure while reloading (gun_out false?). Use the
   equipped strip's at-rest cell during the reload so the weapon stays in his hands.
3. Shot origin + muzzle flash from the drawn frame (per-cell muzzle point measured in rivet_frames.py -> JSON).
4. The grey blob in the Servo fight (above): identify it in `top` vs combo; REQUEST to seams if it is theirs.
5. Ghost form swap back; death beat; occlusion silhouette; King engage re-film with the 55 left views; every
   weapon at each pitch; frame cost under the bench lock; a combined 30-90 s clip; Rivet's dialogue face.

NEXT (it6 early, superseded below the continued entry):
1. Gates on HEAD: director reel `--quit-after 14000` in top, tilt70, combo (0 SCRIPT ERROR, 19/19) and
   `node tools/evidence/run.mjs --no-bench`; re-try `node tools/tests/release_compile.mjs` (the foreign temp dir).
2. Fire state for streams/auto weapons (flamer shows no fire cell): `RivetFrames.publish(rig, held, arena)` from
   RivetHeldView (see it3 NEXT 1). rivet_frames.gd is at 200 lines: make room first.
3. Shot origin + muzzle flash from the drawn frame (per-cell muzzle point in rivet_frames.py -> JSON sidecar).
4. Watch the asset lane: 55 left views (round 1155) -> manifest rows `rivet_eq_<id>_left` under p55; electro_gun /
   electro_baton 70_left v2 (round 1205) -> swap the sheet names. Re-run the manifest + provenance.
5. Servo engage film; ghost form swap back; death beat; occlusion silhouette; every weapon at each pitch;
   frame cost under the bench lock; a combined clip 30-90 s.
- BLOCKED (11:22-11:29, 7 min, and since it3): `node tools/evidence/run.mjs --no-bench` stops at release-compile on
  `%TEMP%\gtai-release-compile` (not made by this lane, no marker); scenarios/goldens/parity on it6 code owed.
  Ask the Director who owns that dir (or run release_compile with a lane-private TEMP: `TEMP=<lane dir> node ...`
  next session, if the tool honours TEMP). Session end 11:30; everything committed.

## Iteration 7 (11:31-12:31)
- Read: JOURNAL (it6 NEXT), git log, d9-seams JOURNAL (no REQUEST to rivet; seams fixed release_compile's
  default dir on its branch, 6e49a298, per-worktree/pid).
- MILESTONE gates on feb56ca2 (`evidence/d9/gates-it7.md`): `node tools/evidence/run.mjs --no-bench` with TEMP/TMP
  set to a lane-private dir: lint 15/15, unit 1695/0, scenarios 52 (replay incl.), parity exact + planted caught,
  look goldens 11/11 + block 5/5, release-compile 599 loaded / 0 failed. EXIT 0 in 8 min. The it3-it6 BLOCKED is
  cleared for this lane (the foreign `%TEMP%\gtai-release-compile` stays; seams' fix lands with the merge).
- Found by film (64 px/m, `--bot=gunplay --weapon=pistol --view=tilt70 --seed=3`): under the drawn figure nothing
  published HeldMuzzle (the held part is hidden), so the muzzle flash printed on the ground ~1.3 m off his gun
  (WeaponFxArt's GUN_SIDE_M fallback) and the tracer left from there.
- MILESTONE `f7334278` RivetMuzzle: `tools/art/rivet_muzzle.py` measures each equipped strip's fire cells (5, 6:
  the drawn flash's root = the biggest pale-hot blob's pixel nearest the body, off the visor, right of the body in
  the side cell so a launcher's back-blast loses) and each left strip's gun tip (leftmost px in the arm band) ->
  `data/tables/rivet_muzzle.json` (gtai.rivet-muzzle/1, 76 points; blades, baton, bottle excluded). RivetFrames.publish
  publishes the current cell's point (mirrored with flip_h) as HeldMuzzle; a facing cell keeps the fallback.
  Three measure rounds judged on contact sheets (round 1 took flash tips, round 2 the visor and chest highlights).
  Before/after: `gtai-masters/d9/rivet/rivet_muzzle_before_after_pistol_left_tilt70_64ppm_seed3_f290_297.png`
  (the flash now bursts from the drawn pistol's muzzle; the tracer leaves from it). New test_rivet_muzzle (3).
- Seen (flamer, 64 px/m): firing to his left-down, the drawn side cell's flame points left while the game's jet
  tongues go down-left from the wand: two flames for one stream when the aim sits between octants. Candidate:
  for streams, the facing cell (no drawn flame) + the game jet, which needs a facing muzzle point. Open.
- Seen (machine_pistol reload, frames 324-396): the bare base figure, no weapon, through the whole reload.
- Gates on f7334278 (`evidence/d9/gates-it7.md`): unit 1698/0 (full); director reel `--quit-after 20000` 19/19
  chapters fully down in tilt70, combo, top; 0 SCRIPT ERROR. Commit 876042e4.
- Reload check: re-filmed machine_pistol frames 318-402 (tilt70, 64 px/m) and `top` with the same seed: frames
  330-396 are the reload, and they ARE the equipped strip (its back views carry the small gun barely visible at his
  right claw). The it6 "bare base figure" note was wrong; no reload path drops gun_out for Rivet in the arena
  (ArenaRigs keeps GUN_OUT while armed). A tried `weapon_of` change (reload_k keeps the strip) fixed nothing
  measured and would hide the HIT cell on a reload-hit: reverted, not committed.
- MILESTONE `126b6a8c` muzzle round 5: the visor test now needs a flat blob (p55's chest-high flashes sat inside
  the helmet span above 58% and were dropped); fire cells with no hot flash (p70 gatling at camera: a whirl)
  take the arm band's tip (side) / centre at 0.7 (camera). 84 points; all 48 gun fire cells judged on a contact
  sheet (`gtai-masters/d9/rivet/rivet_muzzle_points_fire_cells_p55_p70_contact.png`).
- Seen p55 (Servo, combo, 48 px/m, gatling, frames 340-402): the game flash and the tracer leave from the drawn
  barrels in the side, mirrored side and at-camera cells (`rivet_muzzle_servo_gatling_combo_p55_48ppm_seed2_f340_402_x1.7.png`).
- frames.json: 15 entries (3 muzzle entries added; the p55 strip contact dropped from the list, file kept: REPORT cites it).
- REPORT: muzzle item, gates it7, What does not updated (flamer double flame; facing cells have no muzzle point;
  reload note corrected).
- FRICTION (~0): `node tools/godot/check.mjs` fails "depended scripts" on rivet_frames.gd AND on the untouched
  rivet_held_view.gd (the check-only path vs human_react's dependencies); unit runs and films are the real check.
- Registry rules applied: realtime-combat-semantics (the sim's shot origin untouched: view-only HeldMuzzle; the hit
  read, the tracer, now leaves from the drawn barrel); generative-artifact-gating (the measure judged on contact
  sheets each round, 5 rounds; the drawn sheets' own flashes are the source of truth for the muzzle);
  motion-quality-gating (judged in motion on the arena at 64 px/m and in the Servo fight at 48, frame by frame);
  sprite-and-atlas-production (the point data reproducible from the strips: `rivet_muzzle.py --check`).
- DECISION rivet/muzzle: the drawn fire cells' own flash roots are the muzzle (measured, a data table), not a hand-
  placed point per weapon or the hidden claw's: it follows the drawing at both pitches and re-measures in one
  command when a sheet is swapped. Rejected: the hidden held part's tip (off the drawing), per-weapon offsets by hand.

NEXT (supersedes every NEXT above):
1. The flamer between octants (two flames): for streams (flame, gatling?) keep the facing cell + the game jet, or
   pick the fire cell only within ~22 deg of side/camera. Needs a facing-cell muzzle: extend rivet_muzzle.py to cells
   0-4 (the barrel tip along the facing) and judge on a contact sheet.
2. The grey blob in the Servo fight (it6 note, t270/t450-510): identify it in top vs combo; REQUEST to seams if theirs.
3. Ghost form swap back; death beat in the sprawl cell; roll spin; hit flash; occlusion silhouette; King engage
   re-film with the 55 left views.
4. Every weapon at each pitch (`--loadout=<id>`), the frame cost under the bench lock, a combined 30-90 s clip.
5. Rivet's dialogue face (a bust from rivet_70_v3 frame 0 or a REQUEST to assets), the armory showing him holding each.
- 12:15 the it6 Servo "grey blob" (`gtai-d9/scratch/rivet/it6/servo_zoom.png`): a cream-rimmed top-down PART with a
  claw-like silhouette, beside and over the drawn figure; the parts' sticker rim says it is a rig/weapon part, not
  a card. Suspects for NEXT 2: Rivet's cable-claw shot / claw-strike part (a node outside the rig that
  RivetFrames' hide list misses), or a dropped hand part. Film `--boss=servo --view=top` vs combo at the same seed
  and frame to see what it is in top.
- Session end 12:16: everything committed (16da537f + this note); scratch PNG sequences deleted (5.7 GB).

## Iteration 10 (director it10, 12:14-13:14), BUILD
- Read: JOURNAL it7 NEXT, git log, d9-seams JOURNAL (no REQUEST to rivet), the library catalog (plasma sword
  v3 B / v4 A at round 1135/1145; this lane swapped the redraw in at b2614b45, nothing new owed).
- MILESTONE `5f3c583d` the flamer's one flame (it7 NEXT 1): `RivetFrames.fires_drawn(weapon, octant)`: the cone
  weapon (`RivetStrips.CONE` = flamethrower) fires its drawn flame cell only along octants 0, 2, 4 (side, camera,
  side mirrored); off them the facing cell fires and the game's jet leaves the drawn nozzle. `rivet_muzzle.py`
  now measures the flamer's 5 facing cells (the wand points right in all five drawn facings: the rightmost px in
  FACE_BAND 0.38-0.86; p70 holds the wand low). A generic facing rule for every hold was tried first and failed
  on the contact sheet (the pistol is drawn at image left in cell 0, cell 0 is three-quarter, not camera): so
  facing points are the flamer's only. 10 points judged on
  `gtai-masters/d9/rivet/rivet_muzzle_flamer_facing_points_p70_p55_contact.png` (all on the nozzle ring).
  Film (`--bot=gunplay --weapon=flamethrower --view=tilt70 --ppm=64 --seed=3`, before = CONE emptied for the run):
  `rivet_flamer_one_flame_before_after_tilt70_64ppm_x1.1_seed3_f344_364.png`: before, a drawn flame points
  left while the jets go down-left; after, one stream from the drawn nozzle. New tests (2). Unit full 1700/0.
- 12:25 The it6 Servo "grey blob" (it7 NEXT 2): re-filmed `--boss=servo --bot=boss --view=combo --ppm=48 --seed=1`
  and `--view=top` on HEAD (540 frames each). Combo's occlusion log equals it6's first film exactly (18 body-frames,
  frames 32-49), so the same run: the blob is not there at f270 or at bay 4 (f436-538). `top` f0 shows what it was
  made of: his top-down rig parts (grey claws, cream sticker rim). Most likely the reload magazine on the hidden
  claw, which f3038865 hid under the drawn figure (it6). Closed:
  `gtai-masters/d9/rivet/rivet_servo_grey_blob_was_the_reload_mag_it6_vs_it10_combo_48ppm.png`.
- Found (same film): under combo the Servo bay's apron NUMBER prints over Rivet's body (f466-478,
  `gtai-masters/d9/rivet/servo_bay_number_prints_over_rivet_combo_48ppm_x4_seed1_f466_472_478.png`). In `top`
  he stands over it. Cause: n8-view's `ServoDepotDraw.marks_apart` draws the marks on ServoBodyView._marks at
  z = vehicles + 1 (201), over the actors band (100 + depth sort), so the van no longer hides bay 3 but every
  body walking on a bay is printed through. Not this lane's file.
  REQUEST to seams: Servo bay number (servo_body_view.gd:39) draws over every actor under a card view. Suggest
  the marks at `actors - 1` (under bodies) and the van's own card skips/fades the bay rect it covers, or draw
  the number only where no rig's screen box meets it. Evidence above; repro `--boss=servo --bot=boss
  --view=combo --ppm=48 --seed=1`, frames 466-478.
- Seen (both films, combo, f0-f1): for the first frame Rivet's top-down parts show a pale outline at his feet
  under the drawn figure (RivetFrames' first step runs after the first draw). One frame at spawn; noted, not fixed.
- MILESTONE ghost form swap back + roll (it7 NEXT 3), filmed `--boss=king --bot=boss --ghost=kerf --view=combo
  --ppm=48 --seed=1 --loadout=pistol` (720 frames, 0 SCRIPT ERROR): Kerf from ~f60; the drawn figure returns
  inside the exit ring (f434-442) with the pistol strip, fires by f464; the roll ball spins f606-624.
  `gtai-masters/d9/rivet/rivet_ghost_kerf_swap_back_and_roll_king_combo_p55_48ppm_x1.5_seed1_f404_632.png`.
- Seen in that film: his cast shadow was the hidden parts' plan (hip_z 250: a 1.8 m figure's shadow from a 1.1 m
  robot) and stayed a full upright shadow under the roll ball.
- MILESTONE `61fbbdf8` the shadow from the drawing: `RigCastShadows.CAST_HIP` (a meta any card rig can publish;
  `RigCastShadows.hip_px` reads it, else the plan's hip): RivetFrames.place publishes HEIGHT_M (by art key) x the
  plan's sprawl/tuck factor, the roll ball 0.45; PropOcclusion's silhouette takes the same height. top unchanged
  (no cast shadows there; RivetFrames releases and removes the meta). Before/after King combo 48 px/m:
  `rivet_shadow_drawn_height_and_roll_before_after_king_combo_48ppm_x1.5_seed1.png`; the city at 32 beside a cop:
  `rivet_shadow_drawn_height_beside_cop_city_tilt70_32ppm_x4_seed5_f60.png` (his shadow now shorter than the
  cop's, as his height). `--changed` unit 1684/0. DECISION rivet/shadow (docs/decisions.md).
- MILESTONE the combined clip (owed since it3): `gtai-masters/d9/rivet/rivet_d9_set_city32_flamer64_king_servo48_combined_35s.mp4`
  (34.7 s: city 32 px/m, flamer 64, King with Kerf + roll 48, Servo 48; centre crops, captions). Looked at a frame
  from each segment. frames.json: 15 entries (the clip first; shadow, ghost, flamer before/after in; the strips
  contact, blades contact and muzzle contact out of the list, files kept: REPORT cites them).
- Scratch sequences deleted (6.2 GB).
- GATES it10 (`evidence/d9/gates-it10.md`): director reel 19/19 fully down in tilt70, combo, top, 0 SCRIPT ERROR
  (on 61fbbdf8). `node tools/evidence/run.mjs --no-bench` on dfb7a4de (lane-private TEMP): lint PASS, scenarios 52
  PASS, parity exact + planted caught PASS, look goldens 11/11 + block 5/5 PASS (top did not move), release-compile
  600/0 PASS; unit 1700/0 but the stage reads FAIL "tree changed during run": I wrote tools/art/rivet_portrait.py
  while it ran. FRICTION (mine, ~0 min lost): no file writes in the worktree while evidence runs, not only .gd.
- MILESTONE `f599a528` the frame cost (`evidence/d9/rivet-frame-cost-it10.md`): rig_bench --view=tilt70, before =
  RivetFrames.ENABLED false for one run: 50 people p50 0.866 -> 0.774 / 0.781 ms, 200 people 1.276 -> 1.147 /
  1.090 ms. The drawn figure adds no rig cost. CONTENDED: the bench lock was held by `perf` (from 12:35) and
  `handheld` before it; every run fails the hard-limit judge alike on this machine state.
- MILESTONE `2b41bdeb` Rivet's dialogue face (brief item 6): portraits.json row `rivet` = the front facing of the
  approved rivet_55_v2 sheet cut at the chest (`tools/art/rivet_portrait.py`, 274x225 at the sheet's own
  resolution, bottom 22 px faded; `--check` reproduces it). Judged beside the King's and the gunsmith's busts
  (`gtai-d9/scratch/rivet/it10/port_cmp.png`): crisp, the amber visor, the collar. His 9 quest-1 lines now show
  a face. test_hud_dialogue's "rivet has no row" asserts moved to lady-cathode + a new rivet test (10/10).
  Provenance line added.
  REQUEST to assets: portrait_rivet_55 (A or B), the dialogue bust in the cast portraits' frame (as
  portrait_gunsmith_55 / portrait_mertz_55: chest-up, front three-quarter, transparent, ~300x320), Rivet exactly
  as rivet_55_v2 (amber eye-bar visor, hazard collar, rust plates); and a mood variant (visor narrowed). Why: the
  interim is cut from a production sheet's front facing, so it is a straight-on figure crop, not a composed
  portrait; the swap is one file (`project/features/hud/art/portraits/rivet.png`).
- Seen live (quest 1, `-s res://dev/frames/quest1_clip.gd -- --view=tilt70 --rigs --stills=2250..3850`, 1080p,
  0 SCRIPT ERROR): the face fades in on his first payphone line (t3050), where Patch's payphone sits; crisp,
  the faded cut blends into the paper: `gtai-masters/d9/rivet/rivet_dialogue_face_quest1_payphone_tilt70_32ppm_1080p_t3450.png`
  (frames.json: in, the duplicate Servo-swap entry out, file kept).
- The death beat, filmed `--boss=king --bot=boss --bot-stand --view=combo --ppm=48 --seed=1 --loadout=pistol`
  (1420 frames; headless probe: "Rivet destroyed: back at the hub", tick 1322): the ink veil darkens f1314-1326,
  then he is at the hub in the drawn DEATH sprawl cell and stays in it through f1416 (1.5 s+, the film's end).
  And a grey, cream-rimmed, torn-edged splat lies fixed on the ground near him at the hub: the it6 "grey blob" is
  BACK, so it was not (only) the reload magazine; the it10 "closed" note above is wrong.
  `gtai-masters/d9/rivet/rivet_death_respawn_sprawl_held_and_grey_part_king_combo_48ppm_x3_seed1_f1290_1338_1416.png`.
- FOUND by that film's log: `Index p_frame = 3 is out of bounds (vframes * hframes = 3)` from RigHeadCard._place
  every step a one-handed hold turned left (its own facing frame on my 3-cell left strip, before RivetFrames set
  the right one). Engine ERRORs, not SCRIPT ERRORs: the reel counts never saw them (61 in the Kerf film). FIXED
  `cfe5eea4`: RigHeadCard.step leaves the card to RivetFrames while it owns it. Probe: 18 ERROR lines -> 2 (a
  shader-compiler note in kill_char_fx and the exit leak, not this lane's). Unit (rivet + head card + rigs) 33/0.
  Rule for me: count `^ERROR` too, not only SCRIPT ERROR.

NEXT (it10 end, 13:03; supersedes every NEXT above):
1. The grey splat (above): film `--boss=king --bot=boss --bot-stand --view=top --seed=1` to f1420 and compare
   with combo at the hub; grep the arena for ground decals spawned on Rivet's death/respawn (kill_char_fx char
   marks? a dust/landing decal? a dropped item at the hub). If it is the top-down parts' char silhouette, it
   should take the drawn figure (or skip) under a card view.
2. After the respawn he lies in the DEATH sprawl at the hub 1.5 s+: check `top` for the same hold (the death beat
   is meant as 1.0 s in his sprawl at the death spot with the veil). If the sprawl should end at the teleport, key
   cell_of's DEATH on react.dying only while the veil is up.
3. Gates: the reels on cfe5eea4 are done (it10b, 19/19 x3); owed `node tools/evidence/run.mjs --no-bench` on the head
   (do not write in the worktree while it runs).
4. The spawn frame: f0 draws his top-down parts' pale rim under the figure (the rig draws once before its first
   drive). Hide the parts at build under a card view, or run RivetFrames once at rig attach.
5. Every weapon fired once at each pitch (`--bot=gunplay --weapon=<id>` at tilt70 and combo), a contact per
   pitch; the armory/rack showing him holding each weapon (brief item 6).
6. The frame cost under the bench lock (it10 numbers are CONTENDED: `evidence/d9/rivet-frame-cost-it10.md`).
7. Watch assets for portrait_rivet_55 (REQUEST it10): swap `project/features/hud/art/portraits/rivet.png`,
   provenance; and seams for the bay-number REQUEST.
- Session end 13:03: everything committed; scratch sequences deleted.
- Deleted `gtai-masters/d9/rivet/rivet_servo_grey_blob_was_the_reload_mag_it6_vs_it10_combo_48ppm.png` (its name
  made the claim the death film disproved; not in frames.json; REPORT no longer cites it).
- Registry rules applied it10: motion-quality-gating (every change judged in motion on the arena, the King and
  Servo fights and quest 1, before/after at the same seed and frame; the 35 s clip); generative-artifact-gating
  (the flamer nozzle points and the bust cut judged on contact sheets; the generic facing rule rejected on sight);
  depth-ordered-layered-art (the shadow and the occlusion silhouette follow the drawn figure, not the hidden
  parts; the bay number's z vs the actors band sent to seams); realtime-combat-semantics (view only: the flamer's
  jet keeps the true aim and the sim's shot origin; the drawn flame yields to it); sprite-and-atlas-production
  (the portrait cut at the sheet's own resolution, reproducible with `--check`; provenance per file).
- 13:05 gates it10b on cfe5eea4: director reel 19/19 x3, 0 SCRIPT ERROR, 0 p_frame (evidence/d9/gates-it10.md). Session end.

## Iteration 13 (director it13, 13:07-14:07), BUILD
- Read: JOURNAL it10 NEXT, git log, d9-seams JOURNAL (ACK: the bay-number REQUEST served at 3f4732db on d9-seams; no REQUEST to rivet), catalog (no portrait_rivet_55 yet).
- FRICTION (~4 min): filmed the death beat with the boss flags but without the scene: `--boss/--bot/--loadout` are the
  arena's (`res://dev/arena/arena.tscn`), boot ignores them ("unknown launch arg") and the main scene films the city.
  Every arena film needs `res://dev/arena/arena.tscn` before `--`.
- MILESTONE `988c0329` NEXT 1 + 2 in one root cause: Rivet's rig latched `clips.die()` from the DEAD flag and nothing
  ended it on the respawn (he respawns on the same rig, same actor id): he lay in the sprawl at the hub while he
  walked, with his gun out, so the drawn BASE figure (DEATH cell) did not own the weapon and RivetHeldView drew the
  top-down held part beside him: that was the "grey, cream-rimmed splat". `RigInput.revive` (Rivet's row only: a
  dead row never turns live for any other kind) clears death_t / dead / sprawl / a dying reaction when his row is
  alive again. test_rig_revive (fails without the fix, planted by hand). Film on the fix, King combo 48 px/m seed 1
  (`res://dev/arena/arena.tscn -- --boss=king --bot=boss --bot-stand --view=combo --ppm=48 --seed=1 --loadout=pistol
  --rigs`, 1440 frames, 0 SCRIPT ERROR, 0 ERROR but the exit leak): the veil f1314-1326, he stands at the hub from
  f1334, no grey part. Before/after: `gtai-masters/d9/rivet/rivet_respawn_stands_before_after_king_combo_48ppm_x3_seed1_f1290_1338_1416.png`.
  The same film in `top` stands up too (the top-down rig after the cut matches its pose before the death).
- MILESTONE `6438394e` NEXT 4 the spawn frame: a rig acquired on a frame that did not pose it (no tick due; a half or
  quarter-rate rank skips its first tick) drew its hidden parts once: f0 of the King combo film showed the parts'
  cream rim under the figure. CharacterRigs.step_ticks poses any rig with t_alive 0 once under a card view (top
  unchanged; at 144 Hz most frames have no tick due, so this was every newly selected rig there, cops and peds too).
  Test (tilt70 posed, top not), fails without the change.
- 13:39 GATES it13: `node tools/evidence/run.mjs --no-bench` on cc7f418b (lane-private TEMP, no worktree writes while
  it ran): lint 15/15, unit 1704/0, scenarios 52, parity exact + planted caught at step 629, look goldens 11/11 + block
  5/5 (top did not move), release-compile 600/0: all PASS.
- FRICTION / not done (~25 min lost): NEXT 5 (every weapon fired once at each pitch). Tried a batch: 17 weapons x
  {tilt70 (p70), tilt (p55: the `tilt` row's art key)} gunplay films (`res://dev/arena/arena.tscn -- --bot=gunplay
  --weapon=<id> --view=<v> --ppm=64 --seed=3 --rigs`), an automatic picker on the PNGs, frames deleted after each.
  Three pickers failed: (1) warm-bright pixels = the arena's cream road paint scores as high as a flash (the
  measured pistol/flamer flash colours are cream, 240/208/176); (2) strict saturated colours = 0 everywhere;
  (3) motion inside a box round the screen centre minus the ring: at a 640x640 window the camera leads his aim and
  he is not in the centre at all. Also: the first batch respawned Godot as each one was killed (a bash for-loop over
  weapons); killing needs the loop's bash first (Windows PIDs, `Stop-Process` on every films.sh/bash match).
  Rule for me: do not pick shots from pixels; read the game's own state.
- The Servo bay number REQUEST: served by seams at 3f4732db on d9-seams (their JOURNAL ACK); REPORT updated.
- Library: no portrait_rivet_55 yet (catalog), nothing new for rivet.
- MILESTONE `c80d3107` NEXT 5, the guns: `FireStills` (dev, `project/dev/arena/fire_stills.gd`, `--fire-stills=<prefix>`
  hooked in arena_game.gd under --rigs): each frame Rivet's card shows an equipped FIRE_SIDE (c5) / FIRE_CAM (c6) cell,
  it saves a 320 px crop round his figure (3 stills, 20 ticks apart, then quits; a run that never fires quits at
  tick 1500 with exit 1). The game's state, not pixels. 34 runs (17 x {tilt70 = p70, tilt = p55}), 64 px/m, seed 3,
  real time 1280x800, 4 in parallel, ~3 min in all; 0 SCRIPT ERROR; every run 3 stills. Contacts (looked at both):
  `gtai-masters/d9/rivet/rivet_every_weapon_fires_drawn_p70_tilt70_64ppm_seed3_firestills.png` and `..._p55_tilt_...`:
  all 13 guns fire a drawn cell with the flash at the drawn weapon (side cells for pistol, gloria, plasma rifle,
  gatling, rocket, flamer; camera cells for machine pistol, hand cannon, molotov, electro gun, ray gun, nuke; homing
  shard side at p55, camera at p70). Debt baseline: accepted the dev rise (a new dev tool; 2 lines in arena_game.gd).
  Found: the 4 melee ids are not in weapons.json, so `--bot=gunplay --weapon=katana` silently films Gloria (WARN
  "the arena keeps Gloria"); the contact marks them "not captured" instead of showing a mislabelled shot.
  Seen (both pitches): the flamer's drawn flame points left while a red jet streaks down-left ~30-40 deg off it;
  not judged (a burning target or the it10 two-flame case on a side octant).
  frames.json: the two contacts in at 3 and 4; the Servo gatling muzzle and the p55 left pistol out (files kept).

- 13:55 MILESTONE NEXT 1 done in-session, the melee four: `--bot=pit --loadout=<id> --fire-stills` catches their
  swing cells (strike_t -> FIRE cells): katana, electro_baton, chainsaw, plasma_sword at tilt70 and tilt, 8 runs, 0
  SCRIPT ERROR (chainsaw 2 stills each, the rest 3). Both contacts now show all 17 weapons (looked at both): the katana
  swing with its smear, the chainsaw toward the camera, the long amber plasma blade (the v3 redraw) in both hands;
  the electro baton reads weakly (a small spark, the baton barely shows) at 64 px/m.

NEXT (it13 end, 13:56; supersedes every NEXT above):
1. The electro baton's swing reads weakly at 64 px/m (every-weapon contact): film it in motion at 48 and 64
   (`res://dev/arena/arena.tscn -- --bot=pit --loadout=electro_baton --view=tilt70 --ppm=64 --seed=3 --rigs`) and
   judge the drawn strike cell vs the facing (a REQUEST to assets if the cell itself hides the baton).
2. The flamer's red jet in the every-weapon contact (t369, both pitches): film `--bot=gunplay --weapon=flamethrower
   --view=tilt70 --ppm=64 --seed=3` t340-400 and judge: a burning target, or the drawn side flame plus the game jet
   on a diagonal aim (then fires_drawn's octant test needs the aim, not the head's octant).
3. The frame cost under the bench lock (it10 numbers are CONTENDED: `evidence/d9/rivet-frame-cost-it10.md`).
4. The armory/rack showing him holding each weapon (brief item 6): FireStills' crops are the drawn cells already;
   the rack itself is hud's.
5. Watch assets for portrait_rivet_55 (REQUEST it10): swap `project/features/hud/art/portraits/rivet.png`, provenance.
6. A facing (non-fire) cell's muzzle for the other holds (REPORT does-not 1).
- Registry rules applied it13: motion-quality-gating (the respawn judged on the real King fight at the same seed and
  frame, before/after; every gun fired in the arena at both pitches, not in a lineup); generative-artifact-gating
  (every contact looked at; the melee tiles caught as mislabelled before they shipped); realtime-combat-semantics
  (view only: revive reads the sim's alive row, never writes it; FireStills reads the card); depth-ordered-layered-art
  (no hidden part drawn on a rig's first frame); sprite-and-atlas-production (the strips unchanged; the capture keys
  by the view's art key through --view).
- Session end 13:58: everything committed (92577499 + this note); scratch stills deleted (composited into the two
  masters contacts); the capture scripts kept in gtai-d9/scratch/rivet/it13/tools (fs_one.sh guns, fs_melee.sh melee,
  fs_contact.py the sheets).

## Iteration 16 (director it16, 14:00-15:00), BUILD
- Read: JOURNAL it13 NEXT, git log, d9-seams JOURNAL (no REQUEST to rivet; their 13:52 merge-seam trial with
  d9-rivet: disjoint hunks in prop_occlusion.gd, gate green), the library catalog (new for rivet: portrait_rivet_v2 A
  (the it10 REQUEST), rivet_eq_plasma_sword_v4 55 A supersedes v3 B).
- MILESTONE `e978f01f` the dialogue face = the library's portrait_rivet_55_v2 (A): neutral + mood bust cut by the cast's
  own tools/art/portrait_cut.py (267x320, 308x320, the cast's 320 px); looked beside the interim cut on one sheet
  (scratch). Mood bust on rivet-feels-good and rivet-sorry-not-sorry (his "other voice" lines). The interim
  rivet_portrait.py retired. test_hud_dialogue checks the mood line (10/0). Provenance x2.
- MILESTONE `a2f9c77e` plasma sword p55 = rivet_eq_plasma_sword_55_v4 (A): cut with v3's params (act_k 0.85, --cc=1),
  judged on a 3-row sheet (current v3 / v4 / v4 default act_k: the default shrinks the actions, rejected); filmed
  `--bot=pit --loadout=plasma_sword --view=tilt --ppm=64 --seed=3 --rigs --fire-stills`: 3 swing cells, both claws on
  the haft, the long amber blade. `gtai-masters/d9/rivet/rivet_plasma_sword_55_v4_swings_tilt_p55_64ppm_seed3_t282_302_322.png`.
- MILESTONE `ebacd1ab` the library audit (every rivet_frames.json row vs the catalog's newer, better-graded sheets):
  3 p55 left strips had A redos waiting: electro_baton_left_v2 (the tip spark), homing_shard_left_v2 and
  molotov_left_v2 (the gun/bottle in the far claw in view 3, the hand rule). Swapped. FOUND on the contact: 7 of 16
  left strips (p55 hand cannon, homing shard, machine pistol, ray gun; p70 baton sparks, molotov flame, pistol)
  carried a neighbour figure's gun bell / flame / spark at a cell edge: the column cut crosses touching figures; in
  play a floating piece beside him on a left turn. All left rows now cut by component (`cc: "0"`), except p55
  electro_baton_left (its figures split into several big components: the component cut misassigned them; column cut
  clean). Re-cut deterministic (only the left strips moved). Muzzles re-measured: the hip-held shard (p55 v2 view 3)
  read the cable spike, pinned at the bell by eye on a x5 zoom (rivet_muzzle.py LEFT_PINNED). Every left muzzle point
  judged on a contact. Provenance x16. Masters: `rivet_left_strips_before_after_component_cut_p55_p70_16strips.png`.
- Dialogue face seen live (quest 1, `-s res://dev/frames/quest1_clip.gd -- --view=tilt70 --rigs --stills=3050..9050`,
  0 SCRIPT ERROR): the neutral bust on "Nobody calls a payphone" t3050-3650, crisp. The stills did not reach his mood
  lines (TUCK-IN is later); the line mapping is covered by test_hud_dialogue. Masters
  `rivet_dialogue_face_before_after_portrait_v2_quest1_payphone_tilt70_32ppm_1080p_t3350.png` (frames.json entry 6
  replaced: the it10 interim's entry; its file kept as the before).
- MILESTONE `90c46dfc` NEXT 2 the flamer's red jet = the it10 two-flame case on a diagonal: filmed `--bot=gunplay
  --weapon=flamethrower --view=tilt70 --ppm=64 --seed=3 --rigs` 420 frames: at t368-371 the head read octant 4
  (screen left: drawn flame left) while the jet left at ~124 deg (down-left). fires_drawn now also needs the aim
  (rig.aim_at) within 22.5 deg of the drawn flame. After (same seed): t371 shows the facing cell, the jet from the
  nozzle; t368 still shows a short drawn flame (the fire cell outlives the last shot by FIRE_TICKS while the aim swings
  left; accepted, a one-frame tail). Masters `rivet_flamer_drawn_flame_needs_aim_before_after_gunplay_tilt70_64ppm_seed3_t359_380.png`.
  The red of the jet itself is the owner-picked teardrop tongues (d7 look-14), not this lane's art.
- DECISIONs rivet/portrait-v2, rivet/left-cut, rivet/cone-aim (docs/decisions.md).
- REQUEST to assets: rivet_eq_electro_baton, 70 and 55 (and the _left sheets to match), the baton reads as part of
  his forearm at 32-64 px/m: the rod is the same rust-brown value as his arm plating, so in the facings and the strike
  cells only the white tip spark reads (it13 every-weapon contact; it16 strips). Ask: the rod a dark steel (near the
  ink value) with the bright copper coil and a pale charged glow along the prongs, angled OUT from the claw so its
  silhouette separates from the arm, about 1.3x longer; holds, hand rule (right claw, cable arm with the cream spike
  on his left), poses and pitch as rivet_eq_electro_baton_70_v2 / _55_v2; no blue, no teal, no red. Why: the owner's
  d8 note (no weapon looked natural in his hand) needs every weapon to read at play zoom; the baton is the one that
  does not.
- 14:3x GATES it16 on 90c46dfc: director reel 19/19 fully down in tilt70, combo, top; 0 SCRIPT ERROR; 0 p_frame; the 2
  known ^ERROR lines each. Unit full no-arg 1705/0. Lint 15/15. Evidence run not re-run (it13 PASS; view-only since).
  `evidence/d9/gates-it16.md`.
- Seen in play: the p55 homing shard's left facings on the component cut (`--bot=gunplay --weapon=homing_shard
  --view=tilt --ppm=64 --seed=3 --rigs`, 480 frames, 0 SCRIPT ERROR): the gun in his right claw, the cable arm near,
  no floating bell. `gtai-masters/d9/rivet/rivet_homing_shard_left_p55_component_cut_gunplay_tilt_64ppm_x3_seed3_t276_296.png`.
- FRICTION (~3 min): a heredoc with backslash paths broke a python str.replace of REPORT.md; used Edit instead.
- 14:28 MILESTONE NEXT 3 the frame cost under the bench lock (gtai-n5/bench.lock held, 3 before / 3 after
  interleaved, rig_bench --view=tilt70): median p50 50 people 0.943 -> 0.776 ms, 200 people 1.319 -> 1.179 ms; no
  added cost. `evidence/d9/rivet-frame-cost-it16.md`. FRICTION (~1 min): an `&&` chain stopped on the bench's
  expected exit 1 and left `RivetFrames.ENABLED = false` in the tree; caught by `git diff --stat` and reverted before
  anything else ran or was committed. Rule for me: toggle-run-restore with `;`, and check the diff after.
- 14:36 GATES it16 evidence run on 0ee23a95 (code 90c46dfc): all PASS, look goldens 11/11 + block 5/5 (top did not
  move), parity exact, scenarios 52, unit 1705/0, release-compile 600/0. (The "14:3x" gates line above was 14:24.)
- Scratch: the frame sequences (flm, flm2, hs, q1, fs; ~2.8 GB) deleted; composites in masters.
- Registry rules applied it16: sprite-and-atlas-production (the strips re-cut from the manifest, deterministic, only
  the left rows moved; provenance per file; the library audit for newer graded sheets); generative-artifact-gating
  (every swapped sheet and every re-cut judged on a contact before it shipped; the component cut rejected for the p55
  baton on sight); motion-quality-gating (the plasma sword, the left holds and the flamer judged in the arena at
  64 px/m, before/after at the same seed and frame; the face live in quest 1); realtime-combat-semantics (view only:
  fires_drawn reads rig.aim_at, the shot origin and the jet are the sim's); depth-ordered-layered-art (no stray
  neighbour piece drawn beside the figure).

NEXT (it16 end, 14:37; supersedes every NEXT above):
1. Watch assets for the electro baton REQUEST (it16): when rivet_eq_electro_baton_70/55 (+ _left) land A/B, swap the
   manifest rows, re-cut (`python -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json`; check the
   left rows' cc on a contact), provenance, film `--bot=pit --loadout=electro_baton --fire-stills` at tilt70 + tilt.
2. DONE in-session (e6a74d74), see below.
3. A facing (non-fire) cell's muzzle for the other holds (REPORT does-not 1).
4. The mood bust live in quest 1 (the stills reached t9050, Gloria's hand-over; rivet-feels-good comes at the TUCK-IN
   fire): film later ticks.
5. A new combined clip of the set (the 35 s one is from it10: no left-strip cleanup, no v4 sword, no portrait v2).
6. The armory/rack showing him holding each weapon (brief item 6; the rack is hud's): FireStills' crops are the cells.
- Session end 14:45: everything committed; scratch sequences deleted (flm3 too); the phantom-flame crop in masters
  (not in frames.json: a does-not still). frames.json: 15 entries, entry 6 = the portrait before/after.
- 14:44 MILESTONE `e6a74d74` NEXT 2 done in-session: a flamer burst that went off its drawn flame keeps the facing
  cell to its end (RivetStrips.draws_fire, rig meta rivet_cone_off); fires_drawn / aim_of / CONE_TOL moved to
  RivetStrips (rivet_frames.gd 200 -> 185). Test fails with the latch planted out (by hand), passes with it. Filmed
  the same seed: t368-370 show the left facing with the wand, no phantom flame. Masters
  `rivet_flamer_phantom_flame_before_after_tilt70_64ppm_x1.5_seed3_t362_373.png` (the before-only crop replaced).
  Gates it16b: reels 19/19 x3, 0 SCRIPT ERROR, 0 p_frame; unit --changed 1690/0; lint 15/15.
- Session end 14:46: everything committed; scratch sequences deleted.

## Iteration 19 (14:48-15:48, BUILD)
- Read: JOURNAL NEXT (it16 end), git log, seams JOURNAL (no REQUEST to rivet), the asset lane's JOURNAL (it read my
  journal at 14:17, before the it16 baton REQUEST: not served yet; it reads the d9 journals every iteration).
- NEXT 3 (a facing cell's muzzle) re-judged: every non-cone weapon draws its fire cell while a shot is up
  (RivetStrips.draws_fire is true for them in every octant), so the facing-cell muzzle only matters for a flash's
  tail past FIRE_TICKS. Low value; parked behind the clip.
- FRICTION (~4 min): `--arena=city --bot=reel --reel=director --view=tilt70` filmed the top view of the city (the
  rigs drawn top-down, no drawn figure), although the log has the occlusion line. Not chased (the gate reels run
  without --arena=city and their tilt70/combo logs differ from top); filmed the city with it10's gunplay args.
- MILESTONE the combined clip, it19 (owed since it16 NEXT 5): 8 films on 4cc9e4ab (`--fixed-fps 60
  --write-movie`, 0 SCRIPT ERROR each): city 32 tilt70 (gunplay pistol, seed 5), gatling 70 (gunplay), katana 70
  (pit), plasma sword v4 p55 (pit, `--view=tilt`), rocket launcher p55 (gunplay), King combo 48 (the swap at ~f31,
  judged on a crop f10-300: p70 at f30, p55 at f33), Servo combo 48. Fixed crops x1-x2.5 to 1280x800, captions.
  `gtai-masters/d9/rivet/rivet_d9_set_it19_city32_gatling_katana_sword_rocket64_king_servo48_combined_31s.mp4`
  (30.8 s); looked at a frame of every segment. frames.json entry 0 replaced; the it10 clip deleted.
- Seen in the films: the pit's guards and the city block's cops are the arena's top-down rigs (with dev rings)
  beside the drawn Rivet under tilt70; that is ArenaRigs (not this lane's art, the same in it10's stills). The pit bot
  mostly walks (one gatling shot in 300 frames); gunplay is the bot for firing.
- (clock: `date` read 15:08 at the clip commit; the session started 14:48. Times below by `date`.)
- 15:09 Quest 1 stills t13000-18750 step 250 (`-s res://dev/frames/quest1_clip.gd -- --view=tilt70 --rigs`, 1080p,
  0 SCRIPT ERROR, ran to the payout): his lines caught at Dock 9 (sorry-not-sorry t13750), b5 (everybody-screamed
  t17000-17250) and b6 (i-have-a-job t18500-18750). The mood bust at t13750 looked washed out: the portrait fades in
  over HudDialogue.ENTER_S on drawn frames only, and the stills mode draws no frame between stills, so a line's first
  still is its fade's first frame (both art files measured: same alpha and value). Re-run t13660-13900 step 20: faint
  at t13660 only, crisp from t13680. NEXT 4 done. Masters
  `rivet_dialogue_face_live_quest1_mood_t13680_vs_neutral_t17250_t18750_tilt70_1080p.png` (REPORT; not in frames.json).
- 15:10 NEXT 1: the asset lane served the baton REQUEST (rounds 20261107-1555/-1600): rivet_eq_electro_baton_55_v3 A,
  _70_v3 B (named fix: the rod still continues the forearm line; the away views keep a short rod), _70_left_v3 A,
  _55_left_v3 A. ACK assets: taken, all four.
- MILESTONE `6443bc82` the baton v3 in the game: manifest swapped, re-cut (deterministic: only the 4 baton strips
  moved). Contact old/new (scratch `it19/baton_v3_contact.png`): the dark rod reads in every row; p55 eq cell 4 had
  cell 3's tip spark floating at its lower left (the column cut) -> that row cut by component (`cc: "0"`), clean.
  Muzzle table re-measured: unchanged (no-flash weapon). Provenance x4. Lint 15/15; the rivet unit files 31/0.
- FRICTION (~2 min): the first baton film showed the OLD strips: a game run (`--path project`, no editor) does not
  re-import a changed PNG; ran `--import` once and re-filmed. Rule for me: `--import` after every re-cut, before
  filming (the class-cache auto-import only fires on a stale class cache).
- Filmed before/after `--bot=pit --loadout=electro_baton --view=tilt70|tilt --ppm=64 --seed=3 --rigs --clean` (361
  frames each, 0 SCRIPT ERROR): the rod reads in the strikes at both pitches and in the p55 facings; the p70 facings
  only a little better; the p70 side strike lost the old sheet's drawn swing arc (no game smear for the baton
  there). Masters `rivet_electro_baton_v3_before_after_pit_tilt70_p70_and_tilt_p55_64ppm_x2_seed3_f60_150_300_310_330_350.png`
  (frames.json entry 4; the pistol-muzzle entry out, file kept: REPORT cites it). DECISION rivet/baton-v3.
- REQUEST to assets: rivet_eq_electro_baton_70_v4, 70, copy by example of rivet_eq_electro_baton_70_v3 with
  rivet_eq_electro_baton_55_v3 as image 2 (your it85 NEXT): the rod ANGLED OUT from the claw in all five facings with
  a background gap from the forearm (as 55 v3), the away views (views 4-5) the same long rod; keep the drawn swing
  arc (the pale crescent) in the side strike and the follow-through (cells 6 and 8), as rivet_eq_electro_baton_70_v2
  drew it; holds, hand rule, poses, pitch as v3; no blue, no teal, no red. Why: at 32-64 px/m the p70 facings still
  read the rod as part of the forearm, and v3's side strike has no motion read.
- Item 6 (the armory/rack showing him holding each weapon) designed, not built: under a card view the hub's weapon
  wall (WeaponRackView, n8-hud's) would get a row above the board with each weapon's equipped strip REST cell (17
  drawn Rivets). It reads as a lineup of clones in the world, so it is a look the owner should pick: a Call, not a
  default; FireStills' crops (the every-weapon contacts in masters) already show him holding each weapon.
- 15:26 GATES it19 on 6443bc82 (`evidence/d9/gates-it19.md`): director reel 19/19 fully down in top, tilt70, combo
  (the baton chapter 1/1), 0 SCRIPT ERROR, 0 p_frame, the 2 known ^ERROR lines each; unit full 1706/0; lint 15/15.
  FRICTION (~3 min): the first reel run used the brief's `--quit-after 14000`, which ends headless at chapter 17-18,
  before the baton chapter; re-ran at 20000 (as it16). Rule: count the chapters, not the "down" lines.
- Scratch: every film and still sequence deleted (it19 holds contacts only, 129 MB).
- Registry rules applied it19: sprite-and-atlas-production (the baton re-cut from the manifest, deterministic, only
  its 4 strips moved; provenance per file; re-import before filming); generative-artifact-gating (the v3 sheets
  judged on an old/new contact before shipping; the stray tip spark caught there and cut away); motion-quality-gating
  (the baton judged in the pit at 64 px/m at both pitches, before/after at the same seed and frames; the combined
  clip judged per segment; the mood bust judged in quest 1, with the stills-mode fade told apart from the art);
  realtime-combat-semantics (art only: the muzzle table re-measured unchanged; the reel's kills unchanged);
  depth-ordered-layered-art (no stray neighbour piece beside the figure).

NEXT (it19 end, 15:27; supersedes every NEXT above):
1. Watch assets for the REQUEST rivet_eq_electro_baton_70_v4 (it19): when it lands A/B, swap the p70 manifest line,
   re-cut (`python -I tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json`), check a contact,
   `--import`, provenance, film `--bot=pit --loadout=electro_baton --view=tilt70 --ppm=64 --seed=3` before/after.
2. The armory (Call 6): build only if the owner picks the wall row (WeaponRackView's row above the board, the
   equipped strips' REST cell, under a form only; top unchanged).
3. A facing cell's muzzle for the other holds (REPORT does-not 1): low value, as non-cone weapons always draw the
   fire cell while a shot is up; only a flash's tail past FIRE_TICKS falls back.
4. `--arena=city --bot=reel` films the top view under `--view=tilt70` (it19 friction): find why if a city reel
   film is wanted; the city films use `--bot=gunplay`.
5. At the freeze: the exe (`build/export/windows/RTAI.exe`), the final REPORT.
- Session end 15:27: everything committed.
- 15:32 FOUND (read, not built): under the drawn figure the game's melee smear is never drawn: RivetHeldView returns
  before `_feed_smear` when RivetFrames.owns_weapon (rivet_held_view.gd l.88), so a swing's arc is the sheet's own
  drawing (the katana, chainsaw and sword sheets draw one; the baton at p55 never did, at p70 v3 no longer does).
  NEXT 6: if the 70 v4 does not bring the arc back, feed MeleeSmearView for strips without a drawn arc (a per-strip
  flag in RivetStrips, the smear's root at the drawn claw: the muzzle table's measure), never on top of a drawn arc.
  REPORT does-not updated. Session end 15:33: everything committed.

## Iteration 20 (15:30-, BUILD)
- Read: JOURNAL NEXT (it19 end), git log, seams JOURNAL (no REQUEST to rivet), the asset lane's JOURNAL (it88 read
  my journal at 15:10, before the it19 baton 70 v4 REQUEST: not served yet; it drew showcase_plasma_sword_70_v3b A,
  a showcase sheet: not a strip of mine).
- 15:30 NEXT 6 built (the baton swings with no arc under the drawn figure).
- MILESTONE `a6d6ea6e` the game smear under the drawn figure for a strike drawn with no arc: `RivetStrips.NO_ARC`
  (per art key; the electro baton at p55 and p70) makes `RivetStrips.hides_held` false, so RivetHeldView keeps
  posing the hidden held part; `RivetMuzzle.feed_smear` roots the crescent on the figure's axis at the strike cell's
  measured tip height (`rivet_muzzle.py` STRIKE_TIP: cell 5's arm-band tip, checked on a crop: the spark's edge at
  both pitches), as long as the drawn reach, z just under his card (head_z - 1). Top: no strip -> z 0 and the held
  grip/length as before. rivet_held_view 288 -> 287 lines (debt baseline tightened).
- Judged in three films (pit, `--loadout=electro_baton --seed=3 --ppm=64 --fixed-fps 60`, tilt70 + tilt, f324-345):
  1. the hidden part's own grip and length: the crescent floated out past the drawn tip, detached (rejected);
  2. rooted on the drawn figure: attached, ends at the tip, but drawn over him (covered the baton);
  3. under his card: the baton and body read over the crescent (shipped). The refactor into feed_smear re-filmed:
     pixel-identical to film 3 at 5 frames.
- Test: `test_a_strip_with_no_drawn_arc_keeps_the_held_part_posing_for_the_smear` fails with the p70 entry planted
  out ("baton at p70"), passes with it; every NO_ARC strip has its strike tip measured.
- Masters `rivet_electro_baton_smear_under_drawn_figure_before_after_pit_tilt70_p70_tilt_p55_64ppm_x2_seed3_f324_345.png`
  (before = the flag off at the same seed and frames). frames.json entry 3; the flamethrower-city entry out (entry
  11 covers the flamer; file kept: JOURNAL cites it). DECISION rivet/no-arc-smear.
- FRICTION (~2 min): `tools/godot/check.mjs` on rivet_muzzle.gd failed with only "Compilation failed" (depended
  scripts); the unit run in the full project compiled it clean. FRICTION (~4 min): backslash paths in a heredoc
  became `\r` in REPORT.md (twice: python and sed); forward slashes instead.
- 15:58 GATES it20 reels on a6d6ea6e: director reel 19/19 fully down in top, tilt70, combo (baton 1/1), 0 SCRIPT
  ERROR, 0 p_frame, the 2 known ^ERROR lines each. Unit --changed (= full suite) 1692/0. Lint 15/15.
- 16:07 Evidence run 1 on 5e… (a6d6ea6e + reel logs): look goldens 11/11 ok (top did not move), parity exact +
  planted caught, scenarios ran; then release-compile REFUSED: `%TEMP%\gtai-release-compile` exists without its
  marker (another run's, not mine; not touched). BLOCKED ~0 min: re-run with a lane-private TEMP (as it7).
- 16:17 GATES it20 evidence run 2 on 3c588ddb (code a6d6ea6e), lane-private TEMP: all PASS: lint 15/15, unit
  1708/0, scenarios 52, parity exact + planted caught (step 629), look goldens 11/11 + block 5/5 (top did not move),
  release-compile 600/0.
- ACK assets: rivet_eq_electro_baton_70_v5 (A, round 20261107-1625, prompt_hash 813b8fb2b5fb) taken; it goes in next
  iteration. Views 2-3 trailing the rod backward: judged in the game first, no redraw asked yet.
- 16:18 v5 cut tried (manifest p70 line -> v5, re-cut: only the p70 baton strip moved): the facings carry the L hold,
  the side strike (cell 5) and the follow-through (cell 7) carry the drawn arcs; cell 4 has a stray speck left of
  the figure (a column-cut neighbour piece, as p55 cell 4 in it19). Not enough session left to cut by component,
  film and gate: REVERTED (`git restore` of the strip and the manifest); the branch stays at the gated state.
- Registry rules applied it20: motion-quality-gating (the smear judged in the pit at 64 px/m at both pitches, three
  candidates filmed at the same seed and frames, the shipped one before/after; the refactor proved pixel-identical);
  depth-ordered-layered-art (the crescent under his card so the drawn weapon reads over it; no game arc over a drawn
  one); realtime-combat-semantics (view only: the smear's `on` is MeleeSwing.cutting as before; reels 19/19 x3);
  sprite-and-atlas-production (the v5 re-cut deterministic, judged on a contact before shipping: a stray caught);
  generative-artifact-gating (v5 judged on a v3/v5 sheet contact and on the cut strip).

NEXT (it20 end, 16:20; supersedes every NEXT above):
1. The baton 70 v5 (A): in `tools/art/rivet_frames.json` p70 `rivet_eq_electro_baton` set `"sheet":
   "rivet_eq_electro_baton_70_v5.png"` and `"cc": "0"` (cell 4's stray speck); re-cut (`python -I
   tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json`), check the strip on a contact (no speck, the
   arcs in cells 5 and 7 whole), `--import`; drop "p70" from `RivetStrips.NO_ARC` (v5 draws its arc: no game smear
   over it) and move `test_a_strip_with_no_drawn_arc...` to `ViewMode.of("tilt")` (p55); `python -I
   tools/art/rivet_muzzle.py` (the p70 tip stays measured: harmless) + `--check`; provenance line (round
   20261107-1625, prompt_hash 813b8fb2b5fb, grade A); film `--bot=pit --loadout=electro_baton --view=tilt70 --ppm=64
   --seed=3 --rigs --clean` before/after (f60, 150, 300, 324-345); judge views 2-3 (the rod trails backward).
2. The armory (Call 6): only if the owner picks the wall row.
3. At the freeze: the exe (`build/export/windows/RTAI.exe`), the final REPORT.
- Session end 16:21: everything committed but this JOURNAL tail (committed next).

## Iteration 21 (16:19-, BUILD)
- Read: JOURNAL NEXT (it20 end), git log, seams JOURNAL (it9: no REQUEST to rivet; it notes Rivet at 1.1 m reads
  small beside the cops = my Call 1), the asset lane's JOURNAL (it89: no REQUEST open; it offers a v5 views 2-3
  mirror if the backward trail reads wrong in the game).
- 16:20-16:32 NEXT 1 built. MILESTONE `613490f1` the p70 electro baton = the library's v5 (A): manifest line ->
  v5 + `cc: "0"`, re-cut (only that strip moved), checked on a v3/v5 contact and a 2x crop of cells 2-4 (no speck;
  arcs whole in cells 5 and 7), `--import`; p70 out of `RivetStrips.NO_ARC`; the test moved to p55 and now asserts
  the p70 baton hides the held part (fails with p70 back in NO_ARC: checked); muzzle table re-measured (p70 strike
  tip 175,109 -> 211,113: unused now); provenance (catalog id rivet_eq_electro_baton_v5, round 20261107-1625,
  prompt_hash 813b8fb2b5fb, A). Figure heights measured on every p70 strip: ~110 px, v5 in line.
- Filmed before/after (arena scene, `--bot=pit --loadout=electro_baton --view=tilt70 --ppm=64 --seed=3 --rigs
  --clean`, 361 frames, 0 SCRIPT ERROR each; before = the it20 strip + flag + muzzle restored for the run, then put
  back and re-imported). Judged: the rod reads as its own stick in every facing; the side strike's drawn arc reads
  under the rod; the toward-camera strike (f300) loses the game's chevron smear (it read as an odd pentagon from
  above: accepted); the right-facing views trail the rod (carried low: accepted, no redraw asked). Masters
  `rivet_electro_baton_70_v5_before_after_pit_tilt70_64ppm_x2_seed3_f60_150_300_324_345.png` (frames.json entry 5,
  replacing the v3 entry; that file kept: REPORT cites it). DECISION rivet/baton-v5.
- FRICTION (~4 min): the first films ran the main scene (city crossing, "unknown launch arg --bot=pit"): I left out
  `res://dev/arena/arena.tscn` before `--` (the it13 rule, JOURNAL l.389). The first before film also had the new
  muzzle table: re-filmed with all three files restored.
- 16:40 READ for Call 2 (the walk): the base strips' drawn walk (cell 8, toward the camera) and sprint (cell 9,
  picture right) are cut but never picked by `RivetFrames.cell_of`; one direction each, so no 8-way stride from
  them (a 2-frame step toward the camera only would read uneven against the other seven octants). Not built.
- REQUEST to assets: rivet_walk_70, 70, a 4-frame walk stride for bare-claw Rivet in your game-ready walk-cells
  layout (as `deliveries/seams_ped_walk_cells_it85.md`: 20 tight cells `r_c.png`, rows = facings toward, 3/4
  toward, profile, 3/4 away, away; columns = frames 1-4, contact feet then passing), copy by example of
  rivet_70_v3 (the five facings, row 1 of the sheet) + its walk cell; the cable claw and the cream spike stay his
  LEFT in every row (image right when he faces the camera), the vermilion collar band, the amber eye-bar visor;
  plus rivet_walk_70_left: the three drawn left facings (rivet_70_left_v4) the same way (3 rows x 4), never a
  mirror. Why: the owner's Call 2 (frames per stride); today he walks as one facing card with a built bob and
  sway, the only character in the city without drawn legs moving. If served by 17:45 I wire it as a strip picked
  by phase while he walks bare-claw (the default stays the bob until the owner picks).
- 16:35 GATES it21 on 613490f1 (`evidence/d9/gates-it21.md`, `5af5db29`): director reel 19/19 fully down in top,
  tilt70, combo (electro_baton 1/1), 0 SCRIPT ERROR, 0 p_frame, the 2 known ^ERROR lines; unit 1708/0; lint 15/15.
  FRICTION (~1 min): the first evidence run refused a dirty tree (the uncommitted reel logs); committed, re-run.
- 16:37 Next (raise the weakest item): Call 1 (his size) has no options still for the owner, and seams (it9) also
  reads him small beside the cops. Plan: `--rivet-height=<m>` (CastFlags, LaunchArgs) scales his drawn height at
  every art key (p55 in proportion), so each Call option is one flag in the exe; film the city block at 32 px/m
  tilt70 at 1.1 / 1.25 / 1.4 m beside the cast.
- 16:45 MILESTONE `129e3745` `--rivet-height=<m>` (CastFlags -> RivetFrames.height_k; view only; p55 in proportion;
  KNOWN_FLAGS; test in test_cast_flags). Filmed the city block (`--arena=city --weapon=pistol --bot=gunplay --clean
  --rigs --cam=fight --reach=6 --view=tilt70 --seed=5 --ppm=32`, 420 frames, 0 SCRIPT ERROR, no unknown arg) at 1.1
  / 1.25 / 1.4: the three runs differ only in pixels around Rivet (diff boxes measured at f120/300/400: the sim is the
  same). Judged f300 beside a cop and two pedestrians: 1.1 reads smaller than all three, 1.25 a pedestrian's
  height, 1.4 the cop's. Masters `rivet_size_options_1p1_1p25_1p4_beside_cop_and_peds_city_tilt70_32ppm_x2_seed5_f300.png`
  (frames.json entry 2). REPORT Call 1 updated (exe line; recommendation 1.25 m; default unchanged). DECISION
  rivet/height-flag. frames.json: the stale 10:26 reel still (`rivet_reel_director_tilt70_48ppm_..._t60-3080.png`)
  fell out at 15 entries (file kept on disk): a fresh reel still is owed (NEXT).
- FRICTION (~1 min): the REPORT path's backslashes became CR again (python string this time): fixed `64953f9b`.
  Rule for me: forward slashes in every path I write into docs.
- 17:01 GATES it21 evidence run 2 on 64953f9b: ALL PASS (`evidence/d9/gates-it21.md`).
- ACK assets (it92 16:46): the walk REQUEST is being drawn (round 1750: rivet_walk_70, _b, _left; not yet graded).
- `tools/art/rivet_walk.py` (new, not yet used by the game): packs the walk-cells delivery (20 `r_c.png` + 12 left)
  into one 4 x 8 grid in RivetFrames' base cell order (rows 0-4 facings, 5-7 drawn left), one scale for every cell
  (no size pulse), helmet-centred, feet PAD above each cell's bottom. Tried on ped_cap_walk_70's cells: feet on one
  line, strides alternate.
- Registry rules applied it21: sprite-and-atlas-production (the v5 re-cut by component, judged on a contact and a
  2x crop; figure heights measured across all p70 strips, ~110 px; the walk packer: one scale per grid, a common
  foot line); motion-quality-gating (the baton judged in motion at 64 px/m, before/after at the same seed and
  frames; the size options at the shipped 32 px/m beside the cast); generative-artifact-gating (v5's speck caught
  on the contact before shipping); realtime-combat-semantics (view only: reels 19/19 x3; the sim identical across
  heights, measured); depth-ordered-layered-art (no game arc over a drawn one).

NEXT (it21 end, 17:05; supersedes every NEXT above):
1. The walk (Call 2), when the asset lane writes `DELIVERED to rivet:` (deliveries/rivet_walk_70_it92.md):
   `python -I tools/art/rivet_walk.py <lib>/keyed/rivet/rivet_walk_70_cells <lib>/keyed/rivet/rivet_walk_70_left_cells
   project/features/characters/art/view/p70/rivet_walk.png`, look at it on a contact (the claw/spike on his LEFT in
   every row against rivet_frames.png cells 0-7), `--import`, provenance (per row, from the delivery). Wire a new
   `RivetWalk` (own file; rivet_frames.gd is 187 lines): `RivetFrames.step` takes `DIR/<art>/rivet_walk.png` when
   weapon_of == &"" and speed_now > MOVING and no roll/claw/hit/death and the strip exists and
   `RivetWalk.enabled` (`--rivet-walk=bob` the before, KNOWN_FLAGS); `_set_strip`: hframes 4, vframes 8, offset y =
   PAD - tex_h / 8; `cell_of` for hframes 4 -> BASE_OCT[o] * 4 + int(posmod(rig.phase, 1.0) * 4.0) (phase = one full
   stride: the bob's abs(sin) gives two lifts per cycle); `place`: no bob/sway on a drawn stride; `owns_weapon`
   false for the walk strip. Test: frame by phase and octant; the bob flag keeps the base strip. Film quest 1 /
   the city block at 32 and 64 px/m bob vs drawn; DECISION; REPORT Call 2. p55: only if a 55 walk is served.
2. A fresh director-reel still (tilt70 48 px/m, the claw, pistol, flamer, electro, molotov, katana chapters) for
   frames.json (the 10:26 one is stale).
3. At the freeze (18:30): the exe `build/export/windows/RTAI.exe` (`"$GODOT_BIN" --headless --path project
   --export-release windows-showcase ../build/export/windows/RTAI.exe`), the final REPORT by 18:40.
- 17:05-17:12 NEXT 1's wiring built ahead of the art (inert until `art/view/<art>/rivet_walk.png` exists):
  `RivetWalk` (path_of: bare-claw, moving, no roll/hit/strike/punch/death, flag on, strip exists; frame_of: BASE_OCT
  row x 4 + the stride phase column), `RivetFrames.step` takes it, `_set_strip` 4 x 8 with the per-frame offset
  and frame 0 before a swap, `cell_of` for the grid, no bob/sway on a drawn stride, `owns_weapon` false for it;
  `--rivet-walk=bob` (CastFlags, KNOWN_FLAGS) keeps the before. test_rivet_walk (frame by octant + phase; no grid
  with a weapon out, standing, or the bob flag). FRICTION (~1 min): `posmod` is int-only in GDScript; `fposmod`.
  Gates: reels 19/19 x3, 0 SCRIPT ERROR, 0 p_frame; unit 1711/0; lint 15/15.
NEXT (17:13; replaces NEXT 1 of 17:05, the rest stands): 1. When the walk cells are DELIVERED: run the packer (line
  above), contact-check the hand side per row, `--import`, provenance; film bob vs drawn (`--rivet-walk=bob` the
  before) in the city block and quest 1 at 32 and 64 px/m; judge the stride rate (one phase cycle = one stride:
  check the feet do not skate); pick the default (DECISION), REPORT Call 2; evidence run hands off.
- Session end 17:13: everything committed.

## it22 (17:13-, BUILD)
- Read: JOURNAL NEXT (17:13), git log, d9-seams JOURNAL (no REQUEST to rivet), the asset lane's JOURNAL it94
  (DELIVERED rivet_walk_70 + _left; OFFER rivet_walk_55 + _left, `deliveries/rivet_walk_55_it94.md`).
- ACK assets: rivet_walk_70 (it94) taken as delivered (rows 1,2,3,5 rivet_walk_b B, row 4 rivet_walk B, left
  rivet_walk_left A). The r2fresh / left_r1fresh alternatives NOT taken: r2fresh's frame 1 is ~8 % taller, and the
  packer keeps one scale per grid, so it would pulse in size each stride. ACK the 55 offer: taken (below).
- 17:14 packed p70 (`python -I tools/art/rivet_walk.py <lib>/keyed/rivet/rivet_walk_70_cells
  <lib>/keyed/rivet/rivet_walk_70_left_cells project/features/characters/art/view/p70/rivet_walk.png`, 428 x 1024,
  cells 107 x 128, scales 0.64/0.64). Contact x2 on grey (`evidence/d9/rivet_walk_70_contact_x2.png`): spike
  picture right in rows 0-2, picture left in row 4, hidden in row 3 (as the delivery says); the near arm in the 3
  drawn left rows. Feet on one line, no size pulse.
- FRICTION (~12 min): finding a bare-claw walk to film. The arena always arms Rivet (ArenaRigs: Gloria by default,
  GUN_OUT whenever a gun exists), so `--arena=city --bot=rivet` bob vs drawn differed in 1 of 10 frames. Quest 1
  clip mode was slow (72 frames in 500 s at 1080p); stills mode is fast (14 s): stills t700-1800 step 100 found
  his walk at ~t760-900 (dumpster to payphone). quest1_clip refused `--rivet-walk=bob` (its own KNOWN_FLAGS):
  added `--rivet-walk` and `--rivet-height` there (debt dev_loc +3, accepted with a reason).
- Judged (quest 1 stills t740-920 step 4, tilt70, 32 and 64 px/m, drawn vs `--rivet-walk=bob`, 0 SCRIPT ERROR):
  at 64 px/m the bob reads as a card sliding along, the drawn legs read as walking; at 32 px/m the alternation still
  shows in the silhouette. The facing row is the same octant as the bob's card in every frame (I first misread a
  back view; checked at 2x). Patch's ghost walks over him in that stretch (a cleaner stretch is owed for the clip).
  Masters `rivet_walk_70_bob_vs_drawn_quest1_tilt70_64ppm_x1_32ppm_x2_t812_856.png` (frames.json entry 2; the
  pistol-left entry out, file kept).
- MILESTONE `c36631bc` the drawn walk at p70 (art, provenance, test pins the 4 x 8 grid, quest1_clip flags).
  DECISION rivet/drawn-walk (default drawn; `--rivet-walk=bob` the before). REPORT Call 2 rewritten.
- p55: packed the 55 offer the same way (400 x 984, cells 100 x 123); contact `evidence/d9/rivet_walk_55_contact_x2.png`:
  hand side right in every row; the three left rows are a shade darker and leaner than the right rows (noted in
  REPORT). Not filmable in the arenas (always armed); in the boss fights it shows only with no gun out.
- 17:38 GATES it22 (`evidence/d9/gates-it22.md`, `e2400dc4`): director reel 19/19 fully down in top, tilt70, combo,
  0 SCRIPT ERROR, 0 p_frame, the 2 known ^ERROR lines; unit 1712/0. MILESTONE `e2400dc4` p55 walk + docs.
- Checked the facing rows against the base strip side by side (base cells 0-7 over grid rows 0-7, p70): same
  facing per row; the base profile (cell 2) is drawn from a steeper camera (dome-heavy, visor at the edge), which
  is why the bob's card read as a back view in the 64 px/m film. Mapping right; no change.
- Masters: `rivet_walk_70_bob_vs_drawn_quest1_tilt70_64ppm_x2_32ppm_x3_t748_920_15fps.mp4` (11.7 s, bob | drawn,
  64 x2 then 32 x3, real time; frames.json entry 2, the respawn entry out, file kept). Seen: he "walks" on the
  drawn stride while climbing out of the dumpster (moving above MOVING; the bob did the same). Scratch .avi deleted.
- 17:47 evidence run on e2400dc4: ALL PASS (goldens 11/11: `top` did not move; release-compile 601/0).
- Registry rules applied it22: sprite-and-atlas-production (one scale per grid, a common foot line, the hand side
  checked per row on a contact, the r2fresh alternative refused for its 8 % size pulse); motion-quality-gating
  (judged in motion at 64 and the shipped 32 px/m, before/after at the same ticks); generative-artifact-gating
  (the p55 left rows' tone/lean mismatch caught on the contact, noted rather than hidden); realtime-combat-semantics
  (view only; reels 19/19 x3, parity exact); depth-ordered-layered-art (the walk grid is the same card: the same
  sort, shadow and occlusion path as the facings).
- 17:50 Masters: a fresh director-reel still (NEXT 2 of it21): `rivet_reel_director_tilt70_48ppm_claw_pistol_mp_rocket_flamer_electro_molotov_katana_it22.png`
  (`--write-movie --quit-after 3200 -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70 --ppm=48`,
  0 SCRIPT ERROR, chapters claw..katana all down; frames 230-2900, 1:1 crops). frames.json entry 4 (the p55 baton
  smear entry out, file kept). Seen: the reel camera frames the targets, Rivet sits left of centre; every chapter
  shows him as one drawn figure with the weapon in his hands. .avi deleted.
- 17:52 Trial exe export on a5ee24ac (26 s, 0 SCRIPT ERROR; `RTAI.exe --headless --quit-after 300 -- --rigs
  --view=tilt70` exit 0). REPORT `## Exe for the owner` with the command lines.

NEXT (it22 end; supersedes every NEXT above):
1. FREEZE 18:30: re-export `build/export/windows/RTAI.exe` on the final commit (`"$GODOT_BIN" --headless --path
   project --export-release windows-showcase ../build/export/windows/RTAI.exe`, 26 s), smoke it (line above), update
   REPORT `## Exe for the owner` with the commit; commit.
2. REPORT final by 18:40: rewrite the header ("in progress" -> final), What works (add the walk: p70 + p55, the
   clip and still; reels 19/19 x3 it22; evidence ALL PASS on e2400dc4), What does not (the walk only bare-claw; the
   p55 left rows' tone; a weapon-out walk keeps the bob), what blocked (FRICTION lines today), Calls (1 size, 2 walk:
   drawn built), Next steps.
3. If time before the freeze: a REQUEST to assets to tone-match rivet_walk_55_left rows to the right rows (the
   it22 contact shows them darker/leaner); a 1-flag swap. Do not start new Godot-side work after 18:20.
- Session end ~17:55: everything committed.
- 17:54 ACK assets it94: rivet_walk_70 + _left taken as delivered (in the game at p70, `c36631bc`); the 55 offer
  (rivet_walk_v4 A + rivet_walk_left_v2 B) taken too (p55, `e2400dc4`). Thank you.
- REQUEST to assets: rivet_walk_55_left (tone), 55, the three drawn left walk rows re-toned to match the right
  rows of rivet_walk_v4 (the same rust-brown value and saturation, the same lean build; ONE-PART copy, no pose
  change, cells in the same `keyed/rivet/rivet_walk_55_left_cells/` layout). Why: on my contact
  (`C:/Users/kazda/kiro/gtai-wt/d9-rivet/evidence/d9/rivet_walk_55_contact_x2.png`, rows 6-8 vs 1-5) the left rows
  are darker and stockier, so he changes colour as he turns left in a boss fight. Low priority; if served before
  18:25 I re-pack (one file), else it is the next run's.
- 17:57 The walk's frame cost: NOT measured (bench.lock held by another run at 17:56; unmeasured is not zero). By
  code: the grid swaps the card's texture only when the walk starts or stops (path change -> _build), each stride
  frame is a `.frame` set like the facings. The it16 rig_bench numbers stand for the rest (REPORT).
- No open REQUEST to rivet in d9-seams or the asset lane (read 17:57). REPORT updated: What works (the walk),
  What does not (walk limits), Exe (trial).
NEXT (17:58; NEXT 1-3 of 17:53 stand): 0. If bench.lock is free before 18:20: rig_bench `--view=tilt70` with a
  walking bare-claw Rivet is not in the bench (it arms him), so skip; say "unmeasured" in the final REPORT.
- Session end 17:58: everything committed.

## it25 (17:57-18:10, BUILD into the freeze)
- Read: JOURNAL it22 NEXT, git log, d9-seams tail (no open REQUEST to rivet), the library catalog (plasma sword:
  p70 v2 A / p55 v4 A already in the game since it6/it16; rivet_walk_55_left tone match not served yet).
- 17:58 MILESTONE `261f9fac` the frame cost re-checked under the bench lock (free at 17:58; want + lock taken and
  removed): 3 runs on 0f8bc386, median p50 50 people 0.811 ms, 200 people 1.079 ms, inside it16's after band
  (0.776 / 1.179) and under it16's before (0.943 / 1.319). The bench arms Rivet: the walk grid stays unmeasured.
  `evidence/d9/rivet-frame-cost-it25.md`.
- 18:00 FREEZE export on 261f9fac: `"$GODOT_BIN" --headless --path project --export-release windows-showcase
  ../build/export/windows/RTAI.exe` exit 0 in 13 s, 0 SCRIPT ERROR; smokes tilt70 and `--view=combo --boss=king`
  exit 0, 0 SCRIPT ERROR. Everything after is docs only.
- 18:05 REPORT final: header, the it25 frame cost, Exe (final export + smokes + the boss swap command lines), a
  new `## What blocked (and for how long)`, Next steps. masters frames.json: 15 entries, every file present.
- Registry rules applied it25: motion-quality-gating / sprite-and-atlas-production (cost measured under the lock,
  the unmeasured walk said so, not zero); realtime-combat-semantics (no code change at the freeze).
NEXT (it25 end, for the next run): see REPORT `## Next steps` (Calls 1-2 to land as defaults; the seams merge;
  main's combo switch; a walk per hold family; the p55 left walk tone; reload frame; armory row if picked).
- Session end ~18:08: everything committed; no Godot work after the freeze export.
- 18:03-18:07 The one missing deliverable, the boss before/after at 48 px/m against main: King, combo, seed 1,
  pistol, `--write-movie --fixed-fps 60 --quit-after 420` twice (before = `RivetFrames.ENABLED = false` for that run
  only, reverted with `git checkout -- project/features/characters/rivet_frames.gd`, status clean after); 0 SCRIPT
  ERROR both. Masters `rivet_before_after_main_vs_drawn_king_combo_p55_48ppm_x1.5_seed1_f40_120_200_300.png`
  (frames.json entry 6; the ghost/Kerf entry out, file kept; still 15). Seen: the drawn figure holds and fires the
  pistol; he reads smaller and darker than the cream head card on the asphalt (feeds Call 1). Scratch frames and
  .avi deleted (the empty `gtai-d9/scratch/rivet_it25` dir stays: the harness refused to rmdir it).
- 18:08 ACK seams NOTE (d9-seams l.717, 16:01; missed until now): HeldMuzzle is keyed to the render frame. Judged
  by code for the drawn figure: RivetHeldView._process (rivet_held_view.gd:79) calls RivetFrames.publish ->
  RivetMuzzle.publish EVERY process frame, so the drawn cell's muzzle is fresh at any refresh rate (60/144/240 Hz);
  the flash's own life is in ticks. The one frame-keyed light, the molotov rag (`_light_rag`), only shows while the
  held part is visible, i.e. never under the drawn figure. Not filmed above 60 Hz (unfilmed is not proven): a
  `--max-fps 144` check is next steps. No change.
- 18:08-18:11 Servo before/after (same method as King; ENABLED flipped for the before run only, reverted, status
  clean): masters `rivet_before_after_main_vs_drawn_servo_combo_p55_48ppm_x1.5_seed1_f60_200_300_400.png`
  (frames.json entry 7; the flamer one-flame entry out, file kept; still 15). And the NOTE filmed: King at
  `--fixed-fps 144`, the flash at the drawn pistol's muzzle in his hands (frame ~479), not the ground fallback:
  `evidence/d9/rivet_muzzle_144hz_king_combo_48ppm_seed1_f470_505_step3.png`. 0 SCRIPT ERROR in all three runs.
  Scratch deleted. No more Godot work after this (18:11).
- 18:12 Read d9-seams and the asset lane journal again: no new REQUEST/NOTE to rivet; the p55 left walk tone
  match not served (stays in REPORT Next steps). `git diff 261f9fac..HEAD -- project tools` is empty: the freeze
  exe (on 261f9fac) is the code at HEAD.
NEXT (it25 end, final for d9; supersedes every NEXT above): the REPORT is final (`## Next steps` there). For the
  next run: 1. land the owner's picks for Call 1 (size; 1.25 m recommended) and Call 2 (walk; drawn built);
  2. after the Director merges d9-seams, re-run the reels x3 + evidence on the merge; 3. main's switch to combo;
  4. a drawn walk per hold family (REQUEST to assets); 5. the p55 left walk tone, a drawn reload, the facing-cell
  muzzles, the armory row if picked.
- Session end 18:12: everything committed; no Godot process of mine running; scratch deleted.

## it26 (18:13-18:17, BUILD; 17 min to the freeze)
- 18:13 Read JOURNAL tail, git log, d9-seams JOURNAL (it19 session: no REQUEST/NOTE to rivet; its trial merge vs
  dacaac88 holds) and the asset lane JOURNAL (rounds 1905/1915 are weapon showcases, nothing for rivet).
- 18:15 Checked at the freeze: `build/export/windows/RTAI.exe` present (18:00 export on 261f9fac);
  `git diff 261f9fac..HEAD -- project tools` empty, so the exe is HEAD's code. Plasma sword: the catalog's
  newest equipped are 70_v2 A and 55_v4 A, both already shipped (REPORT What works, b2614b45 / a2f9c77e); no newer
  redraw landed. Tree clean.
- No code change: a change needs the gates again (unit + evidence + 3 reels), which is more than the 15 min left.
  Registry rules applied it26: motion-quality-gating (nothing claimed without its run; the exe stays the gated
  code).
NEXT (it26 end): unchanged from the it25 final NEXT above; the REPORT is final.

## it27 (18:16-18:19, BUILD; 14 min to the freeze)
- 18:16 Read JOURNAL tail, git log, d9-seams JOURNAL (its it20 freeze check: no REQUEST/NOTE to rivet; trial merge
  vs dacaac88 holds).
- 18:17 Freeze check: `build/export/windows/RTAI.exe` present (18:00 export on 261f9fac);
  `git diff 261f9fac..HEAD -- project tools` empty, so the exe is HEAD's code. Asset library: no new rivet sheet
  since it26 (plasma sword newest still the shipped 70_v2 / 55_v4 A; the 55 left walk tone fix still not served).
  Tree clean.
- No code change: the gates (unit + evidence + 3 reels) do not fit in the 13 min left. Registry rule applied:
  motion-quality-gating (the exe stays the gated code; nothing claimed without its run).
NEXT (it27 end): unchanged from the it25 final NEXT; the REPORT is final.

## it28 (18:23-18:26, BUILD; 7 min to the freeze)
- 18:23 Read JOURNAL tail, git log, d9-seams JOURNAL (its it21 freeze check: no REQUEST/NOTE to rivet; trial merge
  vs 3a3d25a1 holds).
- 18:24 Asset library: the it22 REQUEST (p55 left walk tone) was served at 18:16 as
  `keyed/rivet/rivet_walk_55_left_tone_cells/` (tone-matched v2 cells; the drawn v3 overshot the tone and was not
  delivered, catalog l.20172). Not swapped in: the gates (unit + evidence + 3 reels) do not fit before 18:30.
  REPORT Next steps item 5 now names the cells. Exe `build/export/windows/RTAI.exe` (18:00, 261f9fac) is still
  HEAD's code (`git diff 261f9fac..HEAD -- project tools` empty).
- Registry rule applied: motion-quality-gating (an ungated art swap does not go into the freeze exe).
NEXT (it28 end): the it25 final NEXT, with the tone cells swapped in first (one strip rebuild for the p55 left walk
  rows, then the gates and a 48 px/m King engage clip to compare).

## it29 (18:30-18:33, STABILIZE; report 18:40)
- 18:30 Read JOURNAL tail, git log, d9-seams JOURNAL (its it21 freeze check: no REQUEST/NOTE to rivet; trial merge
  vs 3a3d25a1 holds).
- 18:31 Stabilize check: `build/export/windows/RTAI.exe` present (18:00 export on 261f9fac);
  `git diff 261f9fac..HEAD -- project tools` empty, so the exe is HEAD's code and its gates (lint, unit, evidence
  --no-bench, the reels in top/tilt70/combo) still stand. Masters `frames.json`: 15 entries, every file present.
  No Godot process of mine running. Tree clean.
- No code change: the p55 left walk tone cells (served 18:16) are an art swap, not a bug fix, and the gates do not
  fit before 18:40; they stay REPORT Next steps item 5. REPORT.md is final.
- Registry rule applied: motion-quality-gating (nothing ungated enters the freeze build).
NEXT (it29 end, final for d9): 1. swap in `keyed/rivet/rivet_walk_55_left_tone_cells/` (p55 left walk rows), gates,
  a 48 px/m King engage clip; 2. land the owner's Call 1 (size) and Call 2 (walk) picks; 3. after the Director merges
  d9-seams, re-run the reels x3 + evidence on the merge (expected conflicts: JOURNAL.md add/add, debt baseline);
  4. main's switch to combo; 5. a drawn walk per hold family, a drawn reload, facing-cell muzzles, the armory row.

## it30 (18:40-18:45, REPORT)
- 18:40 Read JOURNAL tail, git log. REPORT phase: nothing built.
- 18:42 Path check: every cited path in the REPORT exists (35 masters files, 16 `evidence/d9/` paths; the `<view>`
  logs as top/tilt70/combo), plus `build/export/windows/RTAI.exe` and masters `frames.json`. `git diff
  261f9fac..HEAD -- project tools` is empty (the exe is HEAD's code).
- REPORT header set to final 18:40; copied to the lane root as `REPORT.md` (same text; seams keeps its at the root too).
- FRICTION (~3 min): a heredoc wrote a backslash literal wrong, and a CRLF header failed a byte match; done with Edit.
NEXT (it30, final for d9): unchanged from the it29 NEXT (tone cells for the p55 left walk, the owner's Calls 1-2,
  re-gate on the merge with d9-seams, main's switch to combo, a walk per hold family).
