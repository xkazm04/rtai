extends GutTest
## d7-calls: the owner's Rivet picks are the defaults; CastFlags brings the old ones back.


func after_each() -> void:
	PartMaterials.head_lod_fill = PartMaterials.HEAD_LOD_FILL
	PartMaterials.core_tan = PartMaterials.CORE_TAN
	RivetPlan.form = RivetPlan.FORM_BASE
	RivetFrames.height_k = 1.0


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


func test_rivet_height_scales_his_drawn_height_at_every_art_key() -> void:
	# n9: the owner's 1.65 m is the default (d9 built 1.1); --rivet-height=<m> brings an option.
	assert_almost_eq(RivetFrames.height_k, 1.0, 0.0001, "1.65 m built")
	assert_almost_eq(RivetFrames.HEIGHT_M, 1.65, 0.0001, "the owner's +50 %")
	assert_almost_eq(RivetFrames.HEIGHT_BY_ART["p55"], 1.95, 0.0001, "p55 in proportion")
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-height=1.4"]))
	assert_almost_eq(RivetFrames.height_k * RivetFrames.HEIGHT_M, 1.4, 0.0001)
	CastFlags._read = false
	CastFlags.apply(PackedStringArray(["--rivet-height=9"]))
	assert_almost_eq(RivetFrames.height_k * RivetFrames.HEIGHT_M, 2.5, 0.0001, "clamped")


func test_every_walk_before_reaches_its_switch() -> void:
	# n15 tools: c8d71e34a moved these into _walk(), but apply() routed only --rivet-walk=,
	# --rivet-swipe and --rivet-bob there: --rivet-walk-armed=off, --rivet-stride=off did nothing.
	var befores: PackedStringArray = [
		"--rivet-walk=bob",
		"--rivet-walk=4",
		"--rivet-walk=walk8",
		"--rivet-walk-armed=off",
		"--rivet-stride=off",
		"--rivet-swipe=off",
		"--rivet-bob=drawn",
	]
	CastFlags._read = false
	CastFlags.apply(befores)
	var got: Array = [
		RivetWalk.enabled,
		RivetWalk.frames,
		RivetWalk.run,
		RivetWalk.armed,
		RivetStride.enabled,
		RivetSwipe.enabled,
		RivetBob.enabled,
	]
	_restore_walk()
	assert_eq(got, [false, 4, false, false, false, false, false])


func _restore_walk() -> void:
	RivetWalk.enabled = true
	RivetWalk.frames = 8
	RivetWalk.run = true
	RivetWalk.armed = true
	RivetStride.enabled = true
	RivetSwipe.enabled = true
	RivetBob.enabled = true


func test_every_other_before_reaches_its_switch() -> void:
	# n15 tools: mutate on cast_flags.gd left these lines unkilled (60 %): no test applied them.
	var befores: PackedStringArray = [
		"--gun-grey",
		"--rivet-flame=cone",
		"--rivet-flame=side",
		"--rivet-flame=all",
		"--rivet-knock=off",
		"--rivet-reload=off",
		"--rivet-windup=off",
		"--ghost-voice=facing",
		"--rivet-tan=-3",
	]
	CastFlags._read = false
	CastFlags.apply(befores)
	var got: Array = [
		PartMaterials.gun_tan,
		RivetStrips.cone == RivetStrips.CONE_D9,
		RivetStrips.diag,
		RivetStrips.flame_all,
		RivetKnock.enabled,
		RivetReload.enabled,
		RivetWindup.enabled,
		GhostApparition.clear_figure,
		PartMaterials.core_tan,
	]
	_restore_others()
	assert_eq(got, [0.0, true, false, true, false, false, false, false, 0.0])


func _restore_others() -> void:
	PartMaterials.gun_tan = PartMaterials.GUN_TAN
	RivetStrips.cone = []
	RivetStrips.diag = true
	RivetStrips.flame_all = false
	RivetKnock.enabled = true
	RivetReload.enabled = true
	RivetWindup.enabled = true
	GhostApparition.clear_figure = true
