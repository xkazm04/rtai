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
