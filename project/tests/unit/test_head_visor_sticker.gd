extends GutTest
## n5-cast: Rivet's helmet sticker at gameplay scale could print a welder-visor ink slot (front)
## (lod_fill 4, r2_c7 at game scale); d7-calls cast-8: the owner picked the plain head (lod_fill 2).
## Humans keep the plain part print on their heads.


func test_head_material_uses_the_head_fill() -> void:
	var m: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.HEAD, false, 0)
	var fill: float = m.get_shader_parameter("lod_fill")
	assert_eq(fill, PartMaterials.HEAD_LOD_FILL)
	assert_almost_eq(
		PartMaterials.HEAD_LOD_FILL, 2.0, 0.01, "cast-8: plain head; 4 = the visor slot"
	)


func test_head_keeps_the_core_noir_light() -> void:
	var m: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.HEAD, false, 0)
	var keep: float = m.get_shader_parameter("noir_keep")
	assert_eq(keep, PartMaterials.NOIR_KEEP_CORE)


func test_visor_slot_is_a_front_band_not_the_whole_head() -> void:
	var sh: Shader = load(PartMaterials.SHADER_PATH) as Shader
	assert_between(
		_default(sh.code, "visor_x0"), 0.5, 0.8, "the art faces +x; the slot is the front third"
	)
	assert_between(_default(sh.code, "visor_hy"), 0.1, 0.35, "a slot, not the full head height")


func _default(code: String, uniform: String) -> float:
	var re: RegEx = RegEx.create_from_string("uniform float " + uniform + " = ([0-9.]+);")
	var hit: RegExMatch = re.search(code)
	assert_not_null(hit, uniform)
	return hit.get_string(1).to_float() if hit != null else -1.0


func test_only_rivet_wears_the_visor_slot() -> void:
	assert_true(RivetPlan.build().head_visor, "Rivet's helmet faces +x and carries the visor")
	assert_false(KingPlan.build().head_visor, "King's star crown has no visor")
	assert_false(ThugPlan.build().head_visor, "thugs have no collar core")
