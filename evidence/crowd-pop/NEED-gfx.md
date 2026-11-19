# Preserve the actor's build on the baked quad

The anim shader accepts the simulation slot plus one in the people instance's custom.y. Zero draws the canonical bake. Slot 15 has a live body scale of 1.13628 and the bake rig has a scale of 0.99759. At 64 px/m the slot's hat measures 115 px on its live rig and 101 px on the repaired atlas until the writer supplies the slot.

On n19-gfx after 268960380, apply these two replacements to the **people body** writes.

| File and line | Replacement |
|---|---|
| `native/sim_core/src/render.cpp:95` (anim base line 78) | `put(bufs[RL_PEDS] + np * RL_STRIDE, body, WHITE, (float)cell, (float)(i + 1));` |
| `project/features/city/sim/sim_render.gd:64` (anim base line 68) | `_tint(SimConst.RL_PEDS, Color.WHITE, _frame_cell(i), i + 1)` |

The people shader looks up the slot in the same scale table used by live street walkers. The car writer already uses this channel for its own state. The two body replacements preserve the 16-float stride. Rebuild the native DLL and check slots 0, 15 and 511, including a rigged slot skipped between two baked slots.

The `gfx-preview` stills use the native buffer unchanged except for that single float on its sole baked instance. Hat, riot and overalls keep heights of 115, 118 and 122 px respectively across ticks 32 and 33. The `anim` stills show the actual branch with the field at zero.

## Experimental noir frames

`project/dev/noir/noir_frames.gd` replaces the production material when its optional crowd ink is enabled. Its custom vertex stage only selects UVs. For this dev consumer, use the same geometry as the production shader:

1. In `project/assets/shaders/look_noir_crowd.gdshader`, replace the `cols` and `rows` uniform declarations and the entire `vertex()` with one `#include "res://features/characters/crowd_atlas_vertex.gdshaderinc"` immediately after `shader_type canvas_item;`. Keep the ink uniforms and fragment function.
2. In `NoirFrames._ink_crowd()`, remove the `old` material variable and replace the two `set_shader_parameter` calls with `_characters.rigs.atlas.configure_material(m)`. Use just `m.shader.resource_path` in the dev log, or retain `old` for the log.

The shared include reads the bake's anchors, projection and actor scale uniforms. The ordinary city material already uses it.
