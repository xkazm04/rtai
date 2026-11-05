extends GutTest
## n5-cast: Rivet's core and helmet stickers at gameplay scale print r2_c3's tan work plates, not
## the cream of the slab under him; limbs, the collar, King's core and every human part keep theirs.


func test_tan_core_and_head_print_tan() -> void:
	var kinds: Array[PartMaterials.PartKind] = [
		PartMaterials.PartKind.TAN_CORE, PartMaterials.PartKind.HEAD
	]
	for kind: PartMaterials.PartKind in kinds:
		var m: ShaderMaterial = PartMaterials.get_mat(kind, false, 0)
		var tan: float = m.get_shader_parameter("core_tan")
		assert_eq(tan, PartMaterials.CORE_TAN, "kind %d" % kind)


func test_other_kinds_stay_untinted() -> void:
	var kinds: Array[PartMaterials.PartKind] = [
		PartMaterials.PartKind.PART,
		PartMaterials.PartKind.LIMB,
		PartMaterials.PartKind.COLLAR,
		PartMaterials.PartKind.CORE,
	]
	for kind: PartMaterials.PartKind in kinds:
		var m: ShaderMaterial = PartMaterials.get_mat(kind, false, 0)
		var tan: float = m.get_shader_parameter("core_tan")
		assert_eq(tan, 0.0, "kind %d" % kind)


func test_tan_core_is_a_core_sticker() -> void:
	var tan: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.TAN_CORE, false, 0)
	var core: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.CORE, false, 0)
	for param: String in ["lod_fill", "noir_keep"]:
		var a: float = tan.get_shader_parameter(param)
		var b: float = core.get_shader_parameter(param)
		assert_eq(a, b, param)
	assert_true(PartMaterials.is_core(PartMaterials.PartKind.TAN_CORE))


func test_only_rivet_wears_the_tan() -> void:
	assert_true(RivetPlan.build().core_tan, "Rivet")
	assert_false(KingPlan.build().core_tan, "King keeps the cream core")
	assert_false(ThugPlan.build().core_tan, "thug")


func test_tan_is_a_light_value_below_cream() -> void:
	assert_between(PartMaterials.CORE_TAN, 0.0, 1.0, "0 = cream, 1 = TAN")
	var sh: Shader = load(PartMaterials.SHADER_PATH) as Shader
	assert_true(sh.code.contains("const vec3 TAN"), "the tan is one shader constant")
