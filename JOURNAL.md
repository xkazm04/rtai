# JOURNAL - n8 lane `hud` (branch n8-hud)

## Iteration 1 (BUILD, 20:28-21:28)

- 20:30 Read: git log (main at 8e9eeb78, d8 merged), AGENTS.md, decisions.md tail (owner's d8 verdicts:
  combo pitch, Rivet + held weapons frozen, two weapon art forms), `pickups_view.gd`, `pickup_look.gd`,
  `weapon_rack_view.gd`, `arena_weapon_rack.gd`, `arena_armory.gd`, `weapon_art.gd`, `view_mode.gd`.
  Library: `LIBRARY.md`, `catalog.json` (no weapon showcase sheet; `hud_icons_55` A is the HUD frame
  look; 13 portraits at 55, of which 7 are DESIGN PROPOSALS), the asset lane's JOURNAL tail
  (`tools/mk_round_weapon_icons.py` is READY but references the game's OLD held.png, not the
  owner-approved r2 designs). Other n8 journals: no REQUEST to hud yet.
- 20:34 Looked at `rivet-r2/out/arm_hand_cannon.png`: the approved weapon is drawn in Rivet's claw
  across 8 poses; the claw overlaps the grip in every pose, so a clean showcase cut from it is not
  possible -> the showcase sheets must be drawn fresh (as the brief says).

REQUEST to assets: weapon_showcase_<class>, 70 + 55 + icon, the SHOWCASE form of the 12 owner-approved
weapons (rivet-r2 triage, 2026-11-06 evening), drawn ALONE as display pieces. Four sheets, one per
weapon class, each a 3 x 3 grid on green #00B140 (anything teal/green in magenta #FF00FF):
rows = the three weapons, columns = (1) the weapon lying on the ground seen from a 70-degree camera
(three-quarter from above, its top AND a sliver of its side body, muzzle pointing right), (2) the same
at 55 degrees (more side body), (3) a flat pure side-profile icon, muzzle right, for the HUD
(the `hud_icons_55` A ink weight). Same design, parts and colours as the weapon in the reference
`C:/Users/kazda/kiro/gtai-art/rivet-r2/out/arm_<id>.png` (attach that sheet; the claw is NOT drawn).
  - `weapon_showcase_sidearms`: pistol, machine_pistol, hand_cannon
  - `weapon_showcase_long`: gloria, plasma_rifle, gatling
  - `weapon_showcase_heavy`: rocket_launcher, flamethrower, molotov (the bottle standing for 70/55)
  - `weapon_showcase_melee`: katana, electro_baton, chainsaw
  NOT the five in redesign (electro_gun, homing_shard, ray_gun, mini_nuke, plasma_sword): they keep
  their shipped parts until the owner picks. Please do NOT run `mk_round_weapon_icons.py` as is: it
  draws the OLD held.png designs, which the owner rejected. Where I will read them:
  `keyed/weapon/weapon_showcase_<class>_<pitch>.png` (any path is fine; name it in your journal).
  Why: vendors, crates, floor pickups and the HUD icon are all cut from one drawing per weapon per
  pitch (the owner's 19:10 split: a) showcase, b) equipped).

REQUEST to assets: portrait emotion for the quest-1 cast (don_fax is voice-only: no face needed).
Low priority, after the showcase sheets: a 70 twin is NOT needed for portraits (the dialogue box is
screen space, one drawing serves every pitch).

Registry rules applied (read the index; per slug): `sprite-and-atlas-production` (one source drawing
per subject per pitch, cuts derived by tool, never hand-painted variants), `depth-ordered-layered-art`
(the pickup's shadow draws under the art, the art over the disc), `generative-artifact-gating` (no C
sheet enters; design proposals stay on contact sheets).
