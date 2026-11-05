extends GutTest
## The look overlay plug-in (core/render/look_overlay.gd, look_profiles.json `overlays`): a row
## goes live only when its files exist, then its looks resolve to the base profile, its amount
## ramps by zoom (0 at gameplay zoom) and it sits on the print_overlay band.

## Stand-ins that exist in every tree (the loader only checks the files exist).
const ROW: Dictionary = {
	"amount_ppm": [[48, 0], [64, 1]],
	"base": "d4",
	"doc": "t",
	"full_looks": ["d5"],
	"id": "t_overlay",
	"params": "res://data/tables/camera.json",
	"params_key": "none",
	"shader": "res://assets/shaders/look_d4.gdshader",
	"zoom_looks": ["auto"],
}


func _table(row: Dictionary) -> LookProfiles:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LookProfiles.TABLE))
	d["overlays"] = [row]
	return LookProfiles.from_json(JSON.stringify(d))


func test_a_present_overlay_puts_its_looks_on_the_base() -> void:
	var looks: LookProfiles = _table(ROW)
	assert_eq(looks.overlays.size(), 1)
	var d4: LookParams = looks.profiles[&"d4"]
	for ppm: float in [32.0, 48.0, 56.0, 64.0, 96.0]:
		assert_true(looks.resolve(&"auto", ppm).equals(d4), "auto at %d" % ppm)
	assert_true(looks.resolve(&"d5", 64.0).equals(d4), "pinned d5 = d4 + the overlay")
	assert_true(looks.resolve(&"d1", 32.0).equals(looks.profiles[&"d1"]), "d1 untouched")


func test_a_missing_overlay_keeps_the_placeholder_blend() -> void:
	var row: Dictionary = ROW.duplicate()
	row["shader"] = "res://assets/shaders/no_such_overlay.gdshader"
	var looks: LookProfiles = _table(row)
	assert_eq(looks.overlays.size(), 0)
	assert_true(looks.resolve(&"auto", 64.0).equals(looks.profiles[&"d5"]))


func test_the_amount_ramps_by_zoom_and_look() -> void:
	var ramp: PackedVector2Array = LookOverlay.ramp_stops(ROW["amount_ppm"])
	assert_eq(LookOverlay.amount_for(ROW, ramp, &"auto", 32.0), 0.0)
	assert_eq(LookOverlay.amount_for(ROW, ramp, &"auto", 48.0), 0.0, "pure D4 at 48 px/m")
	assert_almost_eq(LookOverlay.amount_for(ROW, ramp, &"auto", 56.0), 0.5, 0.0001)
	assert_eq(LookOverlay.amount_for(ROW, ramp, &"auto", 80.0), 1.0)
	assert_eq(LookOverlay.amount_for(ROW, ramp, &"d5", 32.0), 1.0)
	assert_eq(LookOverlay.amount_for(ROW, ramp, &"d4", 64.0), 0.0)
	assert_eq(LookOverlay.amount_for(ROW, ramp, LookProfiles.OFF, 64.0), 0.0)


func test_the_overlay_node_sits_on_its_band_and_hides_at_zero() -> void:
	var o: LookOverlay = autofree(LookOverlay.create(ROW))
	assert_eq(o.z_index, RenderLayers.z(&"print_overlay"))
	assert_eq(RenderLayers.canvas_of(&"print_overlay"), RenderLayers.canvas(&"print"))
	o.update(&"auto", 32.0, Vector2.ZERO)
	assert_false(o.visible)
	o.update(&"auto", 64.0, Vector2.ZERO)
	assert_true(o.visible)
	assert_eq(o.amount, 1.0)


func test_the_shipped_rows_point_at_the_d5_close_files() -> void:
	# n5-look: two rows on the same shader, d5_riso (auto, d5) and d5_world (today, d5_today)
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LookProfiles.TABLE))
	var rows: Array = d["overlays"]
	assert_eq(rows.size(), 2)
	var claimed: Array[String] = []
	for row: Dictionary in rows:
		var shader: String = row["shader"]
		var base: String = row["base"]
		assert_eq(shader, "res://assets/shaders/look_d5.gdshader")
		assert_eq(base, "d4")
		var looks: Array = row["zoom_looks"] + row["full_looks"]
		for id: String in looks:
			assert_false(claimed.has(id), "look %s is claimed by one overlay only" % id)
			claimed.append(id)
	assert_has(claimed, "auto")
	assert_has(claimed, "today")


func test_the_overlay_gets_the_palette_print_inks() -> void:
	var o: LookOverlay = autofree(LookOverlay.create(ROW))
	var mat: ShaderMaterial = null
	for c: Node in o.get_children():
		if c is ColorRect:
			mat = (c as ColorRect).material
	assert_not_null(mat)
	var ink: Color = PaletteTokens.shared().color(&"ink")
	var got: Vector3 = mat.get_shader_parameter(&"ink_tone")
	assert_eq(got, Vector3(ink.r, ink.g, ink.b))
