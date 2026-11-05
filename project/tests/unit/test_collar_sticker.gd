extends GutTest
## n5-cast: Rivet's collar sticker at gameplay scale prints r2_c3's hazard breaks (lod_fill 3),
## and the shader keeps the vermilion share dominant (vermilion is Rivet's collar).


func test_collar_material_uses_the_hazard_fill() -> void:
	var m: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.COLLAR, false, 0)
	var fill: float = m.get_shader_parameter("lod_fill")
	assert_eq(fill, PartMaterials.COLLAR_LOD_FILL)
	assert_true(PartMaterials.COLLAR_LOD_FILL > 2.5, "3 = hazard breaks; 1 = the old flat ring")


func test_core_and_limb_fills_are_unchanged() -> void:
	var core: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.CORE, false, 0)
	var limb: ShaderMaterial = PartMaterials.get_mat(PartMaterials.PartKind.LIMB, false, 0)
	var core_fill: float = core.get_shader_parameter("lod_fill")
	var limb_fill: float = limb.get_shader_parameter("lod_fill")
	assert_eq(core_fill, 2.0)
	assert_eq(limb_fill, 0.0)


func test_collar_ink_share_stays_below_half() -> void:
	var sh: Shader = load(PartMaterials.SHADER_PATH) as Shader
	assert_lt(_default(sh.code, "collar_ink"), 0.5)
	assert_between(_default(sh.code, "collar_stripes"), 4.0, 8.0, "coarse enough for 32 px/m")


func _default(code: String, uniform: String) -> float:
	var re: RegEx = RegEx.create_from_string("uniform float " + uniform + " = ([0-9.]+);")
	var hit: RegExMatch = re.search(code)
	assert_not_null(hit, uniform)
	return hit.get_string(1).to_float() if hit != null else -1.0
