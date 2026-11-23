# City art references for the factory yard

- The D4 ground tiles are 768 × 768 px for 8 × 8 m, or 96 source px/m. One tile occupies 256 screen px at 32 px/m and 512 at 64 px/m. `project/features/city/art/README.md`
- The prologue's quay apron has a cream wash, fine cracks and continuous square joints. The same 8 m cell repeats across the whole yard. `project/features/city/art/d5/ground/quay_apron.png`
- The city uses broader ink joints every 4 m on plazas. The retained pavement lines are 3 source px at RGB 64,60,58, about one screen pixel at 32 px/m. Reserve that contrast for deliberate structural breaks. `project/features/city/art/README.md`
- Road variants share their outer wash, with wear inside the markings. The city builds plain asphalt from the road interior and keeps the crossing on its own transparent strip. `tools/art/city_marks.py`
- D4 roofs and base street props target 80 source px/m. The warehouse plate is 1312 × 672 px, about 16.4 × 8.4 m at that density. Its vents, parallel ribs and pale roof stand out at gameplay scale. `project/features/city/art/roofs/building_warehouse.png`
- The fuel tank has broad cream highlights and dark bracket outlines. The scrap skip reads through its rim, deep interior shadow and a single worn chevron. `project/features/city/art/props/dock_fuel_tank.png`, `project/features/city/art/props/dock_scrap_skip.png`
- The pen work lives in the art. Shipped world textures use lossless import and mipmaps for the zoomed-out print pass. `project/features/city/art/README.md`
- The light comes from upper left. Ground shadows fall down-right. The city prop bake offsets contact by 0.18 m, and standing boxes draw a dark translucent footprint under the raised top. `project/features/city/view/chunk_lift.gd`, `project/features/city/view/prop_box.gd`
- Generate the factory front with roof and south face visible at 70° above horizontal. The film uses tilt70, and the camera compresses the ground vertically by sin(70°), about 0.94. `project/dev/prologue/capture/film.ps1`, `project/core/render/view_mode.gd`
- City prop cards use alpha-tight facings aligned to a common bottom edge, with 256 px maximum cell height. Single-view kit pieces are trimmed individually. Keep daylight between separate pieces on the source sheet. `tools/art/city_prop_cut.py`
- For ground, supply a clean repeatable material and separate large cracks, scorch and debris. For cover, compose the silhouette to the authored metre box so the picture meets its collision edge. `project/data/tables/prologue_stage.json`, `project/boot/prologue/prologue_floor.gd`
