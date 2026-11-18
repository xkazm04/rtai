extends GutTest
## The same city slot across a LOD transition. The sim's art id 7 fits a ped's body plan.


func test_cops_with_ped_art_keep_their_actor_look_across_lods() -> void:
	for id: int in [1, 6]:
		var cop_look: int = RigVariant.crowd_index_for(id, BodyPlan.Kind.COP)
		_check_lods(id, BodyPlan.Kind.COP, 7, cop_look)


func test_ped_with_look_seven_keeps_overalls() -> void:
	_check_lods(1, BodyPlan.Kind.PED, 7, 7)


func test_swat_keeps_its_full_rig_and_bakes_as_patrol() -> void:
	_check_lods(3, BodyPlan.Kind.COP, RigVariant.SWAT, RigVariant.SWAT)


func _check_lods(id: int, kind: BodyPlan.Kind, supplied: int, expected: int) -> void:
	var rigs: CharacterRigs = CharacterRigs.new()
	add_child_autofree(rigs)
	rigs.setup(World.build_context(Events, Data, 18))
	var row: int = rigs.feed.put(0, id, kind, Vector2.ZERO, Vector2.ZERO)
	rigs.feed.looks[row] = supplied
	rigs.step_ticks(1)
	var near: CutRig = rigs.rig_for(id)
	assert_not_null(near)
	if near == null:
		return
	var tag: String = near.variant.tag
	assert_eq(tag, RigVariant.crowd(expected).tag, "full rig look")
	rigs.focus = Vector2(32 * (CharacterRigs.RADIUS_M + 1), 0)
	for tick: int in CharacterRigs.SELECT_EVERY:
		rigs.step_ticks(1)
	assert_false(rigs.full_row(row))
	var cell: int = rigs.baked_cell(row, 0.25)
	var atlas_row: int = floori(float(cell) / CrowdAtlas.FRAMES_PER_LOOK)
	assert_eq(RigVariant.crowd(atlas_row).kind, kind, "baked body plan")
	assert_eq(atlas_row, RigVariant.atlas_look(expected), "baked atlas row")
	if expected != RigVariant.SWAT:
		assert_eq(RigVariant.crowd(atlas_row).tag, tag, "same actor across LODs")
