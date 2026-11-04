extends GutTest


func test_swat_is_a_cop_in_its_own_parts() -> void:
	var v: RigVariant = RigVariant.crowd(RigVariant.SWAT)
	assert_eq(v.kind, BodyPlan.Kind.COP)
	assert_eq(v.head, "head_swat")
	assert_eq(v.torso, "torso_swat")
	assert_false(v.shield, "the riot cop carries the shield")
	for art: String in ["cop", "d5/cop"]:
		var path: String = "res://features/characters/art/%s/head_swat.png" % art
		assert_true(ResourceLoader.exists(path), path)


func test_the_atlas_prints_swat_as_patrol() -> void:
	assert_eq(RigVariant.atlas_look(RigVariant.SWAT), 5)
	assert_eq(RigVariant.atlas_look(3), 3)
	var swat: int = CrowdAtlas.cell_for(RigVariant.SWAT, CrowdAtlas.Clip.WALK, 0.3)
	assert_eq(swat, CrowdAtlas.cell_for(5, CrowdAtlas.Clip.WALK, 0.3))
	assert_lt(swat, CrowdAtlas.LOOKS * CrowdAtlas.FRAMES_PER_LOOK, "inside the atlas")


func test_pit_squads_mix_all_three_cop_looks() -> void:
	var seen: Dictionary[int, int] = {}
	for id: int in 30:
		var look: int = RigVariant.squad_index_for(id)
		assert_true(look in [5, 6, RigVariant.SWAT], str(look))
		seen[look] = seen.get(look, 0) + 1
	assert_eq(seen.size(), 3, "patrol, riot and SWAT all appear")
	assert_eq(RigVariant.squad_index_for(7), RigVariant.squad_index_for(7), "stable, no RNG")
