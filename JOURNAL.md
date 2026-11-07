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
