# REPORT: night n11, lane combat (bodies, reactions, shadows, projectiles, pickups, HUD)

DRAFT written at it21 (02:40). The freeze session (07:30) must refresh the gate lines, the HEAD
and anything after it21. Branch `n11-combat`, cut from main `812a0b06`. Journal: `JOURNAL.md`.
Frames: `C:\Users\kazda\kiro\gtai-masters\n11\combat\frames.json` (15 entries, best first).

## What works, with evidence

1. **Dead bodies** (owner: "a lot of bugs").
   - *Bodies moving after rest.* Reproduced with a probe: drawn bodies hopped up to 0.8 m after
     settling (rig reset to its sim point on skipped pose ticks), drifted with the decay sink, and
     glided up to 2.4 m in 8 ticks off their neighbours. Fixed: `c7a045d5` (RigCarry), `0da58aed`,
     `ee0905f4`, `ceed87d2`. Worst body path 71.7 m before, 2.92 m after (including the fall itself).
     Tests: `test_corpse_rests_steady` and others.
   - *Bigger than alive.* Three causes, in order: every near corpse was drawn twice at combo (a
     fall frame plus a plan pose, `corpse_double_ab.png`); the lying poses were 1.0-1.41 x the card
     (`LYING_K` 0.72, `dead_size_ab_crop.png`); the fall art was delivered at 1.9-2.2 x standing
     (`street_fall_between.py` caps it, `landing_scale_ab.png`). At it21 the last size step inside
     a death: the thrown-back hit cell drew at 0.65 x the walker, then the fall grew back
     (`hit_scale_ab.png`, `78f79a8f`).
   - *Collision with the player.* A knocked-down person (`M_DOWN`) still blocked and was shoved;
     fixed in `sim_body.gd` and `body.cpp` (`50b47690`, parity exact). The dead were already
     skipped. Tests: `test_downed_person_walkable`, `test_dead_bodies_walkable`.
   - Also: the fall goes through drawn in-betweens for all 13 street kinds (`fall_inbetween_ab.png`,
     `hood_fall_ab` superseded by `hit_scale_ab.png`), a drawn rifle lands with the body on the
     shooter's side (`rifle_land_ab.png`), and the blood pool spreads under the chest
     (`pool_under_chest_ab.png`).
2. **Ground pickups x2** (`c7450890`, `88d07829`): floor pickups and the hub armory floor at x2,
   laid out on a grid so they do not pile. Pickup reach unchanged. `pickups_ground_after.png`,
   `armory_x2_after.png`.
3. **Ghost selector** (`80b8c621`): no paper; four avatars on transparent ground, docked bottom
   left, 244 x 128 px against 360 x 158. Selected, cooling and locked states read on bright and
   dark ground: `hud_ghost_states_after.png`.
4. **Cursor per weapon** (`d25fafb1`): a hardware cursor per weapon class and per ghost form, drawn
   in code (`tools/art/cursor_draw.py`), `cursors_sheet.png`. Not seen in a live window: a frame
   capture does not include the mouse.
5. **Shadows, projectiles, reactions.**
   - Shadows: `cast_k` 0.35 on combo and tilt70 (no long casts), a soft contact ellipse under
     standing figures (`4007f09b`, `shadow_city_ab_crop.png`).
   - Projectiles: tapered hit streak, flash x1.45 (`shot_trail_ab_crop.png`). The least advanced
     of the three.
   - Reactions: a shot man is thrown back off the planted boot, away from the shot, in a drawn
     cell for all 13 kinds (`death_hit_cell_ab.png`); a living wound draws a shoulder clutch or a
     gut fold for the patrol cop; drawn falls as above.
   - Rocket kill (it32, `156a8507`): the victim is thrown from the first frame of the blast. Before,
     he stood upright in his living pose inside the fireball for 4 ticks (the gib row's own hold,
     run after the camera's hit-stop). Same ticks before and after:
     `rocket_onset_ab.png` (also `evidence/n11-combat/it32/`).
   - A man on fire (it32, `8dba1173`, `464314c8`): at combo his flames sat on the pavement up to a
     metre off his boots, a calm man beside a floor fire; now they burn over his waist, chest and
     head (`burning_over_ab.png`). He still aims calmly while he burns (see below).

## What does not work, or is not shown

- Projectiles per weapon class (plasma, flame, rockets, impacts by surface, casings) were barely
  touched; energy rounds still read as bullets (see Calls).
- Vehicle shadows were never judged. Every reaction judgement is from stills and 60 fps tick
  sheets, plus one clip (`film/it19_clip`).
- The cursor has not been seen in a live window.
- Item 6 (a full arena fight and a city street fight, frame by frame) was not reached as a loop.
- UNMEASURED: the riot frame cost of tonight's effects under the bench lock.

## Calls for the owner

1. **How long a dead body lies.** With its arms forward, a body at the size it knelt at is 1.3 to
   1.5 x as long as the standing figure is tall (head and torso match). If you read length as
   size, `LONG_CAP` 1.06 in `tools/art/street_fall_between.py` gives the shorter, thinner body.
   Side by side: `landing_scale_ab.png`.
2. **The thrown-back hit cell's camera.** At its new size (`hit_scale_ab.png`) the shot man shows
   his face and legs, drawn from a shallower camera than everything around him. It reads as
   thrown back; a redraw at the strip's camera would remove the seam.
3. **The hanging weapon wall in the hub** stays at x1: the note said "on ground". It needs a longer
   wall to go x2.
4. **An accent colour for energy rounds** (open since 2026-11-04, weapon-art-3): colour law leaves
   plasma a charcoal needle like a bullet. The alternative already exists as a flag:
   `--fx-colour=on` (the round 2 colour sheet) draws an amber comet that reads as energy.
   Side by side at the same ticks: `plasma_accent_ab.png` (top shipped ink, bottom colour sheet).
   Picking it for plasma only would be one cell path in `data/tables/weapon_art.json` (`plasma_bolt`).
5. **The dropped rifle's distance from the body** (`GroundRifle.TOWARD_M` 0.5 or 0.35):
   `rifle_land_ab.png` shows 0.5; the 0.35 pair is not filmed yet.

## Gates

it21 draft: the last full green is `8cc57abe` (01:51). Gates on `78f79a8f` are running at the time
of writing. Bench not run under the lock this night (see above).

## Merge notes

- Native: `body.cpp` changed (`50b47690`); rebuild both DLL targets after the merge.
- Look goldens were re-blessed once, deliberately (dated line in `docs/decisions.md`).
- `project/override.cfg` is git-excluded; `ASSETS-REPLIES.md` is the asset lane's, untracked here.
