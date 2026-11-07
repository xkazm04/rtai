# JOURNAL: d9 lane `seams`

Branch `d9-seams` (cut from main 3982af1a). Evidence: `C:\Users\kazda\kiro\gtai-masters\d9\seams\`.
Scratch: `C:\Users\kazda\kiro\gtai-d9\scratch\seams\` (film.sh, raw avi). APPDATA `gtai-d9/appdata/seams`.

## Iteration 1 (09:49-10:49)

Read: brief, AGENTS.md, decisions tail, view/city n8 REPORTs (the barrier FOUND), the city patch,
view's lying WIP. Registry (resolved through index.json): `depth-ordered-layered-art` (the order is a
measurement: I measured which node draws the corpse before choosing the fix, and judged the frame,
not the counter; "reading a zero as a clean picture": city's 0 crowd patches meant the wrong source,
not a clean frame), `engine-integration-safety` (judge by what the run said: every Godot run's log
grepped for SCRIPT ERROR, 0 each), `motion-quality-gating` / `generative-artifact-gating` (looked at
every still myself; boards labelled before/after), `vehicle-archetype-balance` and
`top-down-vehicle-handling-model` read by heading for item 3 (a bike is a sidegrade: lighter and
quicker to turn, lower top speed; acceptance by measured scenarios, not by feel).

- 09:55 FRICTION: city's `extra` patch applies clean on main; wired PropCrowdOccluders (finds
  CityOcclusion under the layer by type) -> 47 arena props fed, but `crowd 0 patches` and the frame
  unchanged. Debug logs: no dead at all in the city sim snapshot near the barrier.
- 10:00 MILESTONE (measured cause): hiding every dead CutRig at tick 880 emptied the frame: the two
  dead cops behind the barrier are still full RIGS (the n8 notes blamed the crowd atlas). Their
  ground point is north of the barrier (y 25416 vs edge 25473 px) and they fell south, so
  PropOcclusion's standing box (feet up the screen) never met the barrier.
- 10:02 MILESTONE item 1: `PropLying` boxes a dead rig from its ground point to its drawn head
  (+0.45 m); PropOcclusion redraws the prop over it, no silhouette. View-lab occlusion 2 -> 95
  body-frames hidden over 901 frames; 0 SCRIPT ERROR. City's `extra` seam kept and fed (the baked
  crowd walking behind a barrier is the same class of bug). Commit 38a90b52.
  Evidence: `kerb_corpse_before_after_tilt70_32ppm_seed5_f900.png` (+ `_crop3x`),
  `kerb_corpse_before_after_tilt70_48ppm_seed5_f900_crop2x.png`.
- 10:08 MILESTONE item 2 (quick half): the cream backing under the King's legs is NOT in the PNGs
  (ink outline only, checked); it is RivetPlan's `leg_rim` sticker halo, inherited by KingPlan.
  Off under every card view; `top` keeps it (`KingPlan.LEG_RIM_TOP`), so look goldens hold.
  Commit 493d845c. Evidence: `king_legs_rim_before_after_combo_64ppm_seed2_f150_x2.png`,
  `king_legs_rim_before_after_combo_32ppm_seed2_f150_x3.png` (+ full frame), filmed with
  `--boss=king --phase=3 --bot=boss --seed=2 --rigs --view=combo --boss-cam` (boss-cam only to
  frame him; the game keeps the follow camera).

DECISION item 1: fix the lying rig in PropOcclusion (PropLying) rather than city's crowd path, because
the measured source is the rig; city's `extra` list lands too (agreed seam, cheap: 47 rects/frame).
Rejected: a fixed 1 m lying square (view's WIP: missed the cop fallen 2.3 m from his ground point).
Off = `PropLying.ON` / `PropCrowdOccluders.ON` false.
DECISION item 2: drop the leg rim under card views (one bool, `KingPlan.LEG_RIM_TOP` for `top`).

### REQUESTs
- REQUEST to assets: `king_legs_55` and `king_legs_70` (the King's drawn legs under his approved 2.0x
  bust card; owner 2026-11-07 "redesign legs of the character"). One PNG per pitch, camera as
  `king_bust_card` at that pitch (p55 / p70), transparent or #00B140 chroma, INK OUTLINE ONLY (no
  cream/white rim, no backing), the King's palette (plum tights, gold riveted bands, gold sabatons, as
  the current leg parts; no teal, no police blue, no red). Layout: 5 columns = the bust card's five
  facings in its order (front, 3/4 front-right, right profile, 3/4 back-right, back; left is the
  mirror) x 5 rows: row 0 standing, rows 1-4 one walk cycle (contact, pass, contact other leg, pass).
  Cell width = the bust card's cell width at that pitch (p55 218 px, p70 246 px), so the legs scale
  with the bust; the hip line in the top ~12% of the cell (the bust's hem overlaps it), the soles on
  the bottom ~6%; squat, wide-set legs (a boss on a 2.0x bust: short stocky legs, not Rivet's long
  pistons). Why: under the card views the bust stands on his old top-down leg parts; they read as
  parts, not a figure.

NEXT:
1. Item 6 (release_compile per-worktree/pid temp dir) is small: do it next.
2. Item 3 sim bike: native C++ + GDScript twin (parity 1200 steps), vehicle tables, art id 9,
   small traffic share; top-down print for `top` from the bike's top facing.
3. Item 2 second half when `king_legs_*` lands (check catalog.json); item 4 planter; item 5 armed walk.
4. Not yet run this iteration: full no-arg unit run, scenarios/evidence, director reel x3.
