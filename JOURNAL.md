# d8-bosses JOURNAL (lane: bosses; branch d8-bosses)

## Iteration 1 (2026-11-06 14:09-15:09, BUILD)

- 14:10 Read: AGENTS.md, view.json (`tilt` is already pitch 55: no change), RigHeadCard, KingAccents,
  KingBodyView, the angle sheets (`king_55.png`) and NOTES.md. Other lanes' JOURNALs are empty so far.
- Registry rules applied (from the brief's slugs):
  - `concept-scene-parity`: the King's card is regenerated FROM the approved 55 sheet (image 1 = the
    sheet), so the in-game bust matches the concept the owner approved; judged in the live arena.
  - `generative-artifact-gating`: every generated strip is looked at, keyed, measured (frame count,
    bbox per frame) before it ships; the sheet's known defect (blood-red crown cap) is fixed in the prompt.
  - `sprite-and-atlas-production`: one strip per head variant, 5 drawn facings + 3 mirrored in code.
  - `depth-ordered-layered-art`: accents that stay drawn keep their z over the rig; the card replaces them.
  - `motion-quality-gating`: judged in motion (boss bot, fixed seed) at 32 and 64 px/m.
- 14:14 DECISION art keying: the shared `RigHeadCard.CARDS` belongs to `chars`, so the boss art per
  view lives in the bosses lane: `features/bosses/king/art/p<pitch>/` picked by the active view row's
  pitch (55 today; a 70 strip drops in beside it as `p70/`), swapped onto the built card by the King's
  own code. `top` draws no card at all, so it is untouched. Alternative (one data move away): a
  `card_set` per view row read by RigHeadCard (REQUEST to chars below).
- 14:15 Image round r1 started (King bust 55, gang head 55), lock taken by gen.mjs.

## REQUESTs
- REQUEST to chars (RigHeadCard owner): resolve card strips per view row (e.g. a `card_set` /
  pitch folder `art/view/p<pitch>/<name>.png`, fallback to today's path) so boss strips need no
  swap hook in the bosses lane. Until then bosses swap the King/gang card texture after `_build`.
- 14:20 MILESTONE King bust card (p55): Codex strip from king_55.png (85 s, usable first try), cut
  5 x 218x256 raw (no print snap: the wider palette survives), crimson cap -> plum (hue shift, 17k px).
  Width 1.5x the shared card (1.0 drew the bust narrower than his press arms at 64 px/m).
  The rig's shoulder megaphone part hides under the card (the card draws its own horn).
- 14:25 MILESTONE gang head card (p55): steel helmet, plum band, gold-framed shades, gold rope chain
  with an emerald medallion (71 s, first try); width 1.25. KingAccents skips its drawn gang chain
  when the court strip exists (the card wears it). Commit 3bf2f0d9.
- 14:30 MILESTONE King limbs (p55): a top-view part sheet (plate, piston, plum sleeve, thigh, shin,
  boot, horn; 87 s, first try) cut to today's part boxes (tools/art/king_parts_pitch.py, 19 parts)
  so the pivots hold; drawn raw, re-dressed each step (the rig swaps end-on / toe-off textures).
  The slam tell's drawn plates now use the engraved plate art and rise 5.5 m with the tell under
  a tilt (they lay flat at his feet before). Commit 3f2c7d68.
- Draw order measured by eye per frame in the 64 px/m slam strip: the plates (z 40, KingAccents)
  draw over the bust card (head z) - intended, the plates are raised in front of him; the cape fan
  (KingCape) still draws flat on the ground behind him under tilt: owed.
- FRICTION `node tools/godot/check.mjs` fails on unchanged files too ("Failed to compile depended
  scripts") in this worktree; used the live arena runs (0 SCRIPT ERROR) and GUT instead.
- 14:42 MILESTONE gang bodies (p55): a top-view gang part sheet (torso, sleeve, piston forearm,
  gold-knuckle fist / thigh, shin, gold-toe boot, buckled hips; 87 s, first try) cut to the gang's
  part boxes (`--set=gang`, 20 parts), plum-shifted. Commit 9660cbc2.
- 14:44 DECISION cape under tilt (A/B `KingArt.CARD_CAPE`, default true): with a court strip the bust
  card wears the cape and KingCape's drawn fan stands down (it lay flat on the ground under the
  tilt, a white-rimmed decal behind the upright bust). Cost: the drawn cape's sway and charge
  flare are gone under tilt. Owner call (still: gtai-masters/d8/bosses/call_cape_car_fan_vs_card_48.png).
  Commit 7d9251a0.
- 14:45 GATES on 7d9251a0: lint 15/15; unit 1413/1413 (full run); scenarios 51/52 raw, the one miss
  is city_chase's 2 ms wall-clock nav budget (5.1 ms with 4 lanes running; sim code, untouched here),
  re-run alone through run_scenarios.mjs: 1 passed. Director reel headless `--loadout=pistol --rigs`:
  tilt 19/19 down 0 SCRIPT ERROR, top 19/19 down 0 SCRIPT ERROR (needs --quit-after 8000: chapter 19
  starts at tick 6570). top is untouched by construction: every KingArt path returns at pitch >= 90.
- 14:47 READ chars 8e557502: RigHeadCard now resolves `features/characters/art/view/<ViewMode.art>/`.
  After the merge the court card strips can move there (file names king_bust_card.png /
  gang_head_card.png; rows: king anchor 0.80 width 2.4*1.5 = 3.6 bust raw; gang 0.84, 1.4*1.25 =
  1.75, raw) and KingArt keeps only the limbs + cape. Until then KingArt swaps on this branch.
  Fixed for view70's combo: the part cache is keyed by pitch (a live pitch re-asks). Known gap
  under combo: a card swapped once keeps its strip if the pitch moves mid-fight (fix = the merge above).
- 14:51 MILESTONE Servo (p55): a top-view part sheet from servo_55.png (95 s, first try; 9 parts in the
  asked order) cut to today's part sizes, head turned to the rig's front-down convention
  (tools/art/servo_parts_pitch.py); `ServoArt.path` picks p55 when present (two load lines in
  ServoRig, no growth). Kept main's art: the 2-row rack (layout differs), the drones and crates
  (ServoDraw). Commit a546faca. Still at 64 px/m: gtai-masters/d8/bosses/servo_tilt64_before_after.png.

NEXT (iteration 2, in order):
1. The throne-car as a sprite stack from art (item 2): slices from a simple Blender model rendered
   to PNG (or generated) with our gilded grille (not a maker's trade dress), amber tail lamps, drapes,
   the hood cannon, the throne; replace KingCarStack's code slices under a court pitch only. Film the
   procession and the ram.
2. Fold the court card strips into chars' `ViewMode.art` route once merged (rows in this JOURNAL,
   14:47) and keep KingArt for the limbs + cape; re-dress the card when the pitch moves (combo).
3. Servo: the 2-row rack in the new palette (cut the top two rows of the 3-row rack art), the drones
   (ServoDraw drone_tex/crate_tex through ServoArt); film the drone launch and the rotor dash at 64.
4. Close combat at 64 px/m: the King vs Rivet's claw and the katana chapter (`--loadout=katana`
   in the arena boss fight), Servo the same; check the hit flash on the raw parts (one frame of
   print-through possible when the flash ends: KingArt re-nulls on the next step).
5. A combined clip of the set (30-90 s) for frames.json; cape A/B clip for the call.
6. Rivet's claw / katana chapter 64 px/m checks; then the King's own cape motion under tilt if the
   owner keeps the drawn fan (CARD_CAPE false) - a draped, upright cape layer instead of the fan.
- 14:56 MILESTONE Servo's 2-row rack wing from the p55 3-row rack (bottom row cut), both wings match
  (11af64a8; still servo_tilt32_both_racks_after.png). NEXT item 3 shrinks to the drones/crates.
- Evidence: gtai-masters/d8/bosses/ frames.json (15 entries, best first), combined clip
  bosses_d8_it1_combined.mp4 (37 s). Raw avis deleted; scratch renders stay in gtai-d8/scratch/bosses.
- Calls for the owner (for REPORT): (1) CARD_CAPE: the card's cape only (default) vs the drawn fan
  under tilt (call_cape_car_fan_vs_card_48.png; `KingArt.CARD_CAPE = false`); (2) the bust's width
  1.5x (`KingArt.STRIPS["king"][2]`); (3) the emeralds key toward grey (the chroma despill clamps
  green): regenerate gem accents on magenta if the owner wants green gems.
- Watch item: an arm can cross the bust card at melee range (king_vs_katana_64_close.png frame 2):
  the rig's arm z draws over the card. Measure per frame next iteration (RigDepthSort is chars').
