extends GutTest
## d7-calls: the owner's Rivet picks are the defaults; CastFlags brings the old ones back.


func after_each() -> void:
	PartMaterials.head_lod_fill = PartMaterials.HEAD_LOD_FILL
	PartMaterials.core_tan = PartMaterials.CORE_TAN
	RivetPlan.form = RivetPlan.FORM_BASE


func test_defaults_are_the_owner_picks() -> void:
	assert_almost_eq(RivetPlan.build(RivetPlan.FORM_BASE).size_k, 0.89, 0.001, "cast-1: 1.1x")
	assert_almost_eq(PartMaterials.HEAD_LOD_FILL, 2.0, 0.001, "cast-8: the plain head")
	assert_almost_eq(PartMaterials.CORE_TAN, 0.6, 0.001, "cast-9: the light tan")


func test_flags_bring_back_the_old_defaults() -> void:
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-form=wide", "--rivet-visor", "--rivet-tan=1"]))
	assert_eq(RivetPlan.form, RivetPlan.FORM_WIDE)
	assert_almost_eq(RivetPlan.build().size_k, 0.97, 0.001, "n5-cast's 1.2x")
	assert_eq(PartMaterials.head_lod_fill, PartMaterials.HEAD_VISOR_FILL)
	assert_eq(PartMaterials.core_tan, 1.0)
