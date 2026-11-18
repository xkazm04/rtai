# Follow-up (resume): two fixes to item 1's evidence, then item 2

Director review of item 1: code, census and gates ACCEPTED (0f11a6936, 49146d65f, b22af79bb). Two gaps first, then the new work.

## A. Item 1 films do not show the mix (fix first, ~15 min)
In `districts-top.png` / `docks-tilt70-before-after.png` nearly every car in shot is a **kerb-parked generator prop** (the n14 parked cars by the kerb), not spawned traffic, so docks and downtown do not visibly differ in ten seconds. Re-shoot so the owner sees the mix:
- Frame a stretch of road where the **moving** traffic is dense (a junction or a long avenue, the camera still, not driving), and raise the traffic target for the film only (a dev-script flag, not game data) so 8+ moving cars are in frame.
- Burn a small label into each panel: zone, tick, and the count of moving traffic per art in frame (van/pickup/taxi/ambulance/sedans), read from the sim buffer of that tick.
- Outputs: `C:/Users/kazda/kiro/gtai-masters/n19/gfx/zones/districts2-top.png`, `districts2-tilt70.png` (docks | downtown | mixed, after, same tick) and one before/after per district at the same tick. Keep 10-40 s clips. Delete the old scratch panels nothing references and write `C:/Users/kazda/kiro/gtai-masters/n19/gfx/zones/frames.json` (8-15 entries, best first, `[{file,title,ppm,before,note}]`).

## B. Mutation on the lines you changed
Rerun `node tools/mutate/mutate.mjs --file=features/city/city_spawner.gd --lines=<the new/changed line numbers of _traffic_mix, _init and try_car's art line>`; if a survivor is in those lines and not equivalent, add the test that kills it. Quote killed/(killed+survived) for the changed lines.

## C. Item 2: the far-cop rows
Then do the brief below exactly as written (it is the next package).

# Brief n19-gfx-04-farcop: far foot cops draw as civilians (native + reference city writers)

Lane `gfx`, night run n19. Follow-up in the same session as item 1 (city spawner zones). You build; the director reviews.

## Environment
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every Godot run. One Godot at a time; `--rendering-driver d3d12` for rendering; windowed runs `--position 0,1440`. Kill only your own PIDs.
- Native build: `cd native && scons platform=windows arch=x86_64 target=template_debug` and `target=template_release` (and `scons tests` for the core tests), then one `"$GODOT_BIN" --headless --path project --import`. `native/godot-cpp` is present in this worktree. Only this lane rebuilds native tonight.

## The fault (filed by the anim lane, measured)
At heat 3, seed 18, 16 px/m: the native people MultiMesh submitted 58 foot-cop instances, **all on atlas row 7 (overalls-bald civilian)**. The character path (`RigVariant.look_for`) would draw 25 patrol + 33 riot. Cause: both city writers pick the clip-table row from the raw sim variant, without the kind check the rigs use.
- Native: `native/sim_core/src/render.cpp` ~line 44, `CityCore::frame_of`: `int vr = variant_[i] < CLIP_VARIANTS ? variant_[i] : 5;`
- Reference: `project/features/city/sim/sim_render.gd` ~line 116, `CitySimRender._frame_cell`: `var vr: int = _s.variant[i] if _s.variant[i] < SimConst.CLIP_VARIANTS else 5`

## The fix (match `project/features/characters/rig_variant.gd`: `look_for`, `crowd_index_for`, `atlas_look`; read it, do not edit it, it is the anim lane's file)
Looks 5 (patrol), 6 (riot), 8 (SWAT) are cop bodies; every other look is a pedestrian body. For the actor's kind (K_COP vs K_PED) and its sim variant v:
- if v is the auto sentinel 255, or v's body kind does not match the actor kind: `h = ((uint64(i) * 2654435761) >> 13) & 0x7fffffff`; cops take `5 + h % 2`; peds take `[0,1,2,3,4,7][h % 6]`. `i` = the sim slot (the actor id the rigs use; confirm that it is the same id `RigVariant.crowd_index_for` receives on the rig path, and say how you confirmed it).
- then the atlas row: 8 (SWAT) -> 5, else clamp to 0..7 (`atlas_look`).
- A ped with v 7 keeps row 7. Clip choice, phase and frame indexing are unchanged; the sim variant in state is unchanged (render-only).
Put the mapping in ONE helper on each side (C++ static inline function; GDScript static func in `features/city/sim/` e.g. `CitySimClips.row_of(kind, variant, slot)`), so the two are reviewable side by side.

## Tests
- A GDScript unit test that fails on today's code: a K_COP with variant 7 maps to row 5 or 6, a K_PED with variant 5 maps to a ped row, a ped with 7 keeps 7, SWAT 8 cop -> row 5, 255 -> the stable look; and a cross-check that the helper agrees with `RigVariant.atlas_look(RigVariant.crowd_index_for(id, kind))` for ids 0..999.
- Parity (`node tools/tests/run_parity.mjs`) must stay exact: native vs GDScript (if parity compares render buffers, it now checks the two helpers agree; say whether it does).
- The core tests (`scons tests`) if they cover `frame_of`; add a case there if cheap.
- A readback check of your own (headless is fine if the render buffer can be read without a GPU): spawn foot cops with civilian variants through the real spawner at heat 3 and count the people-layer rows: before = row 7, after = rows 5/6. Write it to `evidence/n19-gfx/farcop/rows.json` (before and after counts).

## Digests
If this moves any digest (render-cell hashes, replay, parity goldens), re-bless only what this moves and add ONE `docs/decisions.md` line `- [2026-11-18] DECISION city/far-cop-rows (n19 gfx item 2, anim NEED 22:12; re-bless): ...` naming each digest (file, old -> new). If item 1's decision line already exists and you are re-blessing the same digests again, say so in the new line ("second move tonight").

## Evidence
Same tick before/after frames at 16 and 32 px/m at heat 3 showing far cops in blue (patrol/riot) instead of civilians, top and tilt 70, to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/farcop/` (use `tools/film/`; `compare.mjs` for the side-by-side). If the windowed film path needs a scene you do not have, a city film at heat 3 via the existing kit is fine.

## Acceptance
`node tools/lint/lint.mjs`, full unit run, scenarios, parity, native debug+release built (commit nothing under `project/native/bin`? check `.gitignore`: commit DLLs only if they are tracked today). `node tools/gate/quick.mjs` before each commit. Commits: (a) the two helpers + tests + native rebuild, (b) any re-bless + decision line. Then `node tools/mutate/mutate.mjs --file=project/features/city/sim/sim_render.gd --max=15` (or the helper's file) and quote the score.

## Report back
Files, commits, the rows.json counts, digests moved (old -> new), test/parity/scenario results, mutate score, frame paths.
