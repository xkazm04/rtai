# features/characters

Feature `characters`: the cutout rig and its D4 parts (F-09, F-09b). Depends only on `core/` and
WorldContext (LAY-05). Ported from the spike (`gtai-spike/evolve/project/game/cutrig.gd`,
`chardefs.gd`, the cutout lane's v2 rig).

- **Rig (`cut_rig.gd` + `rig_*.gd`):** a Node2D of plain Sprite2D parts with shared materials.
  The host writes velocity, facing, aim and flags; the rig solves the gait (`rig_gait.gd`,
  world-planted feet, 3D two-bone IK), the upper body and springs (`rig_pose.gd`), the arms
  (`rig_arm.gd`, aim IK, end-on cells), Rivet's hose (`rig_hose.gd`) and the authored clips
  (`rig_clips.gd`: Rivet punch, roll, death; cop shoot, hit).
- **Body plans:** `rivet_plan.gd` (the lane's tuned numbers), `human_plan.gd` (cop, ped from
  `art/*/parts.json`), looks in `rig_variant.gd` (8 crowd looks = the city's clip variants).
- **LOD and pooling (`character_rigs.gd`):** full rigs for the 16 nearest within 14 m
  (`rig_select.gd`), pools per body plan prewarmed at load (`rig_pool.gd`), everyone else from
  the baked crowd atlas (`crowd_atlas.gd`, `crowd_baker.gd`, `crowd_atlas.gdshader`). The host
  fills a `RigFeed` each tick.
- **Print:** `print_part.gdshader` with the D4 flat-tint mode; the cream halos are the sticker rim.
- **Render-side only:** rigs step on the 60 Hz tick from `ctx.clock`, draw no RNG stream and
  write no replay state.
