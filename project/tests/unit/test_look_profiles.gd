extends GutTest
## Look profiles as data (core/render/README.md): the table resolves D4 at gameplay zoom, D5 at
## arena zoom, a smooth blend between, pinned ids, `off`, and the golden-frame diff.

var _looks: LookProfiles


## The table without its overlays: the base blend is tested here whether or not d5-close's
## look_d5 is in the tree (test_look_overlay covers the overlay path).
func before_all() -> void:
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LookProfiles.TABLE))
	@warning_ignore("return_value_discarded")
	d.erase("overlays")
	_looks = LookProfiles.from_json(JSON.stringify(d))


func test_the_table_has_the_three_directions_and_the_blend() -> void:
	for id: StringName in [&"d1", &"d4", &"d5"]:
		assert_true(_looks.profiles.has(id), String(id))
	assert_eq(_looks.default_id, LookProfiles.AUTO)
	assert_eq(_looks.blend_from, &"d4")
	assert_eq(_looks.blend_to, &"d5")


func test_every_profile_sets_every_world_uniform() -> void:
	var keys: Array = _looks.profiles[&"d4"].world.keys()
	assert_gte(keys.size(), 17)
	for id: StringName in _looks.profiles:
		assert_eq(_looks.profiles[id].world.keys().size(), keys.size(), String(id))


func test_auto_is_d4_at_gameplay_zoom_and_d5_at_arena_zoom() -> void:
	assert_true(_looks.resolve(&"auto", 32.0).equals(_looks.profiles[&"d4"]))
	assert_true(_looks.resolve(&"auto", 48.0).equals(_looks.profiles[&"d4"]))
	assert_true(_looks.resolve(&"auto", 64.0).equals(_looks.profiles[&"d5"]))
	assert_true(_looks.resolve(&"auto", 96.0).equals(_looks.profiles[&"d5"]))


func test_the_blend_is_between_and_monotonic() -> void:
	var lo: float = _looks.profiles[&"d4"].world[&"grime"]
	var hi: float = _looks.profiles[&"d5"].world[&"grime"]
	var prev: float = lo
	for ppm: float in [50.0, 54.0, 56.0, 60.0, 63.0]:
		var g: float = _looks.resolve(&"auto", ppm).world[&"grime"]
		assert_between(g, minf(lo, hi), maxf(lo, hi))
		assert_true((g - prev) * (hi - lo) >= 0.0, "monotonic at %s" % ppm)
		prev = g


func test_a_pinned_id_ignores_zoom_and_off_disables_the_print() -> void:
	assert_true(_looks.resolve(&"d5", 32.0).equals(_looks.profiles[&"d5"]))
	assert_false(_looks.resolve(LookProfiles.OFF, 48.0).printed)
	assert_true(_looks.resolve(&"nope", 32.0).equals(_looks.profiles[&"d4"]))
	assert_true(_looks.has(&"d1") and _looks.has(&"off") and not _looks.has(&"d2"))


func test_apply_pushes_vectors_and_floats_into_the_material() -> void:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/look_d4.gdshader")
	_looks.profiles[&"d5"].apply(mat, null)
	var grime: float = mat.get_shader_parameter(&"grime")
	var shift: Vector2 = mat.get_shader_parameter(&"verm_shift")
	assert_almost_eq(grime, 0.45, 0.0001)
	assert_eq(shift, Vector2(3, -2))


func test_the_golden_diff_is_zero_on_itself_and_counts_a_change() -> void:
	var a: Image = Image.create_empty(8, 8, false, Image.FORMAT_RGB8)
	a.fill(Color(0.5, 0.5, 0.5))
	var same: Dictionary = GoldenDiff.compare(a, a.duplicate() as Image, 0.1)
	var same_mean: float = same["mean"]
	assert_eq(same_mean, 0.0)
	var b: Image = a.duplicate() as Image
	b.fill_rect(Rect2i(0, 0, 4, 8), Color(1, 1, 1))
	var diff: Dictionary = GoldenDiff.compare(a, b, 0.1)
	var far: float = diff["far"]
	assert_almost_eq(far, 0.5, 0.0001)
	var missing: bool = GoldenDiff.compare(a, null, 0.1)["found"]
	assert_false(missing)


func test_every_profile_prints_in_the_palette_tokens() -> void:
	var pal: PaletteTokens = PaletteTokens.shared()
	for id: StringName in _looks.profiles:
		var p: LookParams = _looks.profiles[id]
		var tones: Dictionary[StringName, StringName] = {
			&"ink_tone": &"ink", &"paper_tone": &"paper", &"wash_tone": &"wash"
		}
		for u: StringName in tones:
			var c: Color = pal.color(tones[u])
			var got: Vector3 = p.world[u]
			assert_eq(got, Vector3(c.r, c.g, c.b), "%s world %s" % [id, u])
		var ink: Color = pal.color(&"ink")
		var item_ink: Vector3 = p.item[&"ink_tone"]
		assert_eq(item_ink, Vector3(ink.r, ink.g, ink.b), "%s item ink" % id)


func test_the_print_shaders_declare_every_tone_uniform() -> void:
	var names: Array[String] = []
	for shader_path: String in ["look_d4", "look_d4_item"]:
		var sh: Shader = load("res://assets/shaders/%s.gdshader" % shader_path)
		for u: Dictionary in sh.get_shader_uniform_list():
			names.append("%s.%s" % [shader_path, u["name"]])
	for u: String in ["ink_tone", "paper_tone", "wash_tone"]:
		assert_has(names, "look_d4." + u)
	for u: String in ["ink_tone", "paper_tone"]:
		assert_has(names, "look_d4_item." + u)


func test_the_world_print_has_no_accent_plate_where_the_palette_forbids_it() -> void:
	var looks: LookProfiles = LookProfiles.shared()
	var pal: PaletteTokens = PaletteTokens.shared()
	var plates: Dictionary[StringName, StringName] = {&"verm": &"vermilion", &"teal": &"teal"}
	for id: StringName in looks.profiles:
		for plate: StringName in plates:
			if not pal.allowed(plates[plate], &"world"):
				var amount: float = looks.profiles[id].world[plate]
				assert_eq(amount, 0.0, "%s world %s" % [id, plate])
