# The city people writer still draws foot cops as civilians

At heat 3 and seed 18, the live native people MultiMesh submitted 58 cop instances across ticks 120, 240 and 360 at 16 px/m. All 58 used atlas row 7 (overalls-bald). The character-path preview went from 58 civilians to 25 patrol and 33 riot looks on those same instances. The native readback still had 58 civilians after the character fix. At 32 px/m the corresponding counts were 36 civilians in the city, and 17 patrol plus 19 riot in the fixed preview.

| Writer | Location | Change |
| --- | --- | --- |
| Native city | `native/sim_core/src/render.cpp:44`, `CityCore::frame_of` | Replace the raw variant/clamp used for `vr` with an actor-kind-aware atlas lookup before computing `b`. The slot `i` is the actor ID used by the rigs. |
| Reference city | `project/features/city/sim/sim_render.gd:116`, `CitySimRender._frame_cell` | Apply the identical mapping to `_s.variant[i]`, `_s.kind[i]` and slot `i` when selecting the clip-table row. The reference writer runs when the native library is unavailable. |

Match `RigVariant.look_for`, `crowd_index_for` and `atlas_look` in `project/features/characters/rig_variant.gd`. Cast looks 5, 6 and 8 fit a cop. The other supplied looks fit a pedestrian. For an incompatible look, compute `h = ((uint64_t(i) * 2654435761ULL) >> 13) & 0x7fffffffULL`. Cops take `5 + h % 2`. Peds take index `h % 6` from `[0,1,2,3,4,7]`. Map the resulting SWAT look 8 to baked patrol row 5, or clamp the resulting look to the baked range 0–7. Handle the feed's auto sentinel 255 by choosing the actor's stable look for either kind. Preserve clip selection, phase and frame indexing, and keep the original sim variants in state.

Cop 49 at tick 360 is an on-screen example in the actual near feed. At 16 px/m its native cell was 186 (row 7, frame offset 11). The preview drew cell 136 (row 5, same offset). A ped supplied with 7 should still use row 7. Once both city writers are fixed, repeat the probe with each backend and compare their submitted rows against the character path.

## Reproducing the readback

Run `res://dev/sim/far_cop_rows.tscn` in Godot with `--rendering-driver d3d12 --position 0,1440 --windowed --resolution 1280x800 --fixed-fps 60 --path project` and the lane's APPDATA and GODOT_BIN. Set `FAR_COP_OUT` to the output directory and `FAR_COP_PPM` to 16 or 32. Set `FAR_COP_CLIP=1` for 600 native city ticks, with one PNG per four ticks. The probe uses the city spawner with 40 rioters, 24 foot cops and 24 cars, and raises the real CityHeat meter to 3.

Each observation is an uploaded body instance. Counts include the render margin. At 16 px/m, 50 of the 58 origins were inside the viewport and nine instances were inside the live 18 m rig feed. Beyond that feed, the probe requests the same actor's row through the city adapter. The first draw reads custom.x from the untouched sim buffer. The second draw freezes that tick, substitutes the row from `CharacterRigs.baked_cell` and retains the sim's clip and frame. Both images and both cell readbacks are saved. The summary counts the second draw. `sim_render` counts the first.

The two JSON files here are the 16 px/m runs. The 32 px/m JSONs, unmarked frames, annotated crops, pairs and movies are under `C:/Users/kazda/kiro/gtai-masters/n19/anim/farcop`. Run `python tools/art/far_cop_stills.py <farcop-directory> --after` to regenerate the labeled pairs.
