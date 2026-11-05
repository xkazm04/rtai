extends GutTest

const FLOOR: Rect2 = Rect2(10.0, -40.0, 50.0, 6.0)


func _zone() -> LookZone:
	return LookZone.create(FLOOR, 6.0, {"wash_lo": 0.6})


func _params() -> LookParams:
	var p: LookParams = LookParams.new()
	p.world[&"wash_lo"] = 0.3
	p.world[&"wash_mid"] = 0.9
	return p


func test_weight_is_full_on_the_floor_and_fades_outside() -> void:
	var z: LookZone = _zone()
	assert_eq(z.weight(FLOOR.get_center()), 1.0)
	assert_almost_eq(z.weight(Vector2(FLOOR.end.x + 3.0, -37.0)), 0.5, 0.001)
	assert_eq(z.weight(Vector2(FLOOR.end.x + 7.0, -37.0)), 0.0)


func test_apply_blends_only_its_uniforms_and_keeps_the_shared_row() -> void:
	var p: LookParams = _params()
	var out: LookParams = _zone().apply_to(p, 0.5)
	var lo: float = out.world[&"wash_lo"]
	var mid: float = out.world[&"wash_mid"]
	var shared_lo: float = p.world[&"wash_lo"]
	assert_almost_eq(lo, 0.45, 0.0001)
	assert_eq(mid, 0.9)
	assert_eq(shared_lo, 0.3, "the resolved profile is shared: never edited in place")


func test_zero_weight_returns_the_profile_itself() -> void:
	var p: LookParams = _params()
	assert_same(_zone().apply_to(p, 0.0), p)


func test_the_alley_row_loads_and_only_names_print_uniforms() -> void:
	var t: DataTable = DataTable.open(AlleyHook.TABLE, AlleyHook.SCHEMA)
	var row: Dictionary = t.raw["print"]
	var world: Dictionary = row["world"]
	assert_true(world.has("wash_lo"))
	var shader: String = FileAccess.get_file_as_string("res://assets/shaders/look_d4.gdshader")
	for k: String in world:
		assert_true(shader.contains("uniform float %s" % k), "%s is a look_d4 uniform" % k)
