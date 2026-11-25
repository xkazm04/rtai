# n30 combat 04b: the explosion light rim patch (NEED for the Director: `project/core/render/**` is not this lane's)

Not applied. Written against `199faedc7`.

## How the bands are drawn today (`project/assets/shaders/light_ink.gdshader`, found from `light_layer.gd` `SHADER`)
One pooled MultiMesh quad per light on the `light` canvas, `render_mode blend_add`. Per instance (written by
`LightPool.write`, `project/core/render/light_pool.gd:64-81`): `COLOR.rgb` = the kind's ink (`color`, or `alt_color` on the
odd half-period of a flicker when `flicker_hz > 0`), `COLOR.a` = `intensity * fade`; `INSTANCE_CUSTOM` =
`(steps, cone half-angle rad, 0, 0)`: `.z` and `.w` are free.
Fragment: `r = length(UV*2-1)`, `v = 1 - r`, `k = v * steps`, `band = floor(k)`; the band edge is a 45-degree world-locked
hatch (`hatch_px` 5) that adds 1 to `band` as `fract(k)` nears the next band; `level = band / steps`;
`COLOR = page_age(COLOR.rgb) * level * COLOR.a`. For the explosion (`steps` 3, radius 6 m): r in (2/3, 1) is band 0 = adds
nothing except the hatch strokes into band 1; r in (1/3, 2/3) is band 1 (level 1/3) = the faint outer ring; band 2 (2/3) the
middle; the centre point band 3. So the visible "rim" is everything with `band <= 1` after the hatch step (band 1 plus the
hatched fringe), and it is the same single ink as the core: there is no second colour anywhere in the light path.

## The smallest change: a per-kind `rim` flag, the alt ink packed into the instance custom data
`.z` = rim on (1.0 / 0.0), `.w` = the alt colour packed as a 24-bit integer `r8*65536 + g8*256 + b8` (exact in a float32:
integers up to 2^24). Only kinds with `"rim": true` and `flicker_hz` 0 set it (a flicker kind keeps swapping its whole colour
as now). The alt ink stays per light, so any later kind (fire, a plasma blast) can have its own rim without a new uniform.
Rejected: a per-kind shader uniform `rim_color` (one material for the whole MultiMesh: only one rim colour could ever exist);
a second MultiMesh per rim kind (a second draw for one ring).
Risk to check once applied: if the renderer stores MultiMesh custom data below float32 (it is float32 in the 4.x buffer layout
`MultiMesh.buffer` documents), the packed colour would band; then fall back to `.w` = one 8-bit-per-channel hue index into a
small `uniform vec3 rim_inks[4]`.

### `project/assets/shaders/light_ink.gdshader` (lines 36-37)
```diff
 	band += step(line, smoothstep(0.6, 1.0, f));
 	float level = band / steps;
-	COLOR = vec4(page_age(COLOR.rgb) * level * COLOR.a, 1.0);   // a paper light adds the aged paper
+	// a rim kind (INSTANCE_CUSTOM.z 1) prints its lowest lit band (band 1 and its hatched fringe) in the alt ink
+	// packed in INSTANCE_CUSTOM.w (r8 * 65536 + g8 * 256 + b8)
+	float p = custom.w;
+	vec3 alt = vec3(floor(p / 65536.0), mod(floor(p / 256.0), 256.0), mod(p, 256.0)) / 255.0;
+	vec3 ink = mix(COLOR.rgb, alt, custom.z * step(band, 1.0));
+	COLOR = vec4(page_age(ink) * level * COLOR.a, 1.0);   // a paper light adds the aged paper
```
(`page_age` on the alt ink too: the whole page ages together, like the accents in `grade_ink`.)

### `project/core/render/light_pool.gd` (`write`, lines 70-80, plus one static helper)
```diff
 		var hz: float = k["flicker_hz"]
 		var alt: bool = hz > 0.0 and floori(age * SimClock.TICK_DT * hz * 2.0) % 2 == 1
 		var col: Color = k["alt_color"] if alt else k["color"]
+		var rim: bool = hz <= 0.0 and k.get("rim", false) == true
+		var ink: float = pack_rgb(k["alt_color"]) if rim else 0.0
 ...
-		mm.set_instance_custom_data(n, Color(steps, deg_to_rad(cone), 0.0, 0.0))
+		mm.set_instance_custom_data(n, Color(steps, deg_to_rad(cone), 1.0 if rim else 0.0, ink))
```
```gdscript
## A colour as one float the light shader unpacks (r8 * 65536 + g8 * 256 + b8; exact in a float32).
static func pack_rgb(c: Color) -> float:
	return float(c.r8 * 65536 + c.g8 * 256 + c.b8)
```
(`write` grows by 2 lines: still under 40.)

### `project/data/tables/lights.json` (explosion row) and `project/data/schemas/lights.schema.json` (`kinds.items.properties`)
```diff
       "life_ticks": 36,
       "radius_m": 6,
+      "rim": true,
       "steps": 3,
```
```diff
+          "rim": {
+            "type": "boolean"
+          },
           "steps": {
```
(`LightLayer._load` already duplicates the whole row into `kinds`, so `k["rim"]` arrives with no change there; the doc of
the `lights` table / `core/render/README.md` light model gains one line: "`rim`: the outermost lit band prints in `alt_token`".)

### Stale doc to fix with it
`project/features/combat/weapons/arena_combat_lights.gd:6` still says "paper core, vermilion rim": becomes "paper core, amber
rim (lights.json `rim`)".

## The test that pins it: `project/tests/unit/test_light_pool_rim.gd`
```gdscript
extends GutTest
## The explosion light prints its outer band in its alt ink (lights.json `rim`): LightPool packs the
## alt colour into the instance custom data; a non-rim kind and a flicker kind leave .z/.w at 0.

const AMBER: Color = Color8(0xED, 0xAB, 0x42)


func _write_one(kind: StringName) -> Color:
	var lights: LightLayer = autofree(LightLayer.new())
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.instance_count = 1
	var pool: LightPool = LightPool.new(1)
	pool.set_light(0, kind, Transform2D(), 0, 36)
	assert_eq(pool.write(mm, lights.kinds, 0), 1)
	return mm.get_instance_custom_data(0)


func test_the_explosion_packs_its_amber_rim() -> void:
	var c: Color = _write_one(&"explosion")
	assert_eq(c.b, 1.0, "rim on")
	assert_eq(int(c.a), 0xED * 65536 + 0xAB * 256 + 0x42, "amber packed")  # 15575874


func test_the_pack_round_trips_every_channel() -> void:
	var p: int = int(LightPool.pack_rgb(AMBER))
	assert_eq(Color8(p >> 16, (p >> 8) & 255, p & 255), AMBER)


func test_a_plain_and_a_flicker_kind_have_no_rim() -> void:
	for k: StringName in [&"muzzle_flash", &"siren"]:
		var c: Color = _write_one(k)
		assert_eq(c.b, 0.0, "%s rim off" % k)
		assert_eq(c.a, 0.0, "%s no ink" % k)
```
Plus `test_light_explosion_amber.gd` gains one assert: the explosion row has `"rim": true`. Evidence after landing: the c04b
on/off take (`--chapter=rocket_launcher,mini_nuke --ppm=64`, ticks 480-504, see `explosion_rim.md` `## Probe (c04b)`) before
vs after the patch: the outer ring should move from pale yellow toward amber/orange; note that over the nuke's own amber floor
an additive amber ring only brightens amber (it reads most over the charcoal street outside the blast fill).
