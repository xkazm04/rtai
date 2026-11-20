extends GutTest


func test_spokes_recover_pre_shove_contact_for_killed_and_wounded_bodies() -> void:
	var stage: CollectCallStage = CollectCallPlay.begin().stage
	var dent: DentStage = DentStage.shipped()
	var view: DentOverload = DentOverload.new()
	add_child_autofree(view)
	view.bind(stage, dent)
	dent.blast_at = Vector2(6, 2)
	dent.blast_tick = 40
	var radius: float = dent.num(&"blast_radius_m")
	var contact: Vector2 = dent.blast_at + Vector2.RIGHT * radius * 0.5
	var after: Vector2 = contact + Vector2.RIGHT * dent.num(&"car_knock_m") * 0.5
	var guard: Fighter = Fighter.make(Fighter.Kind.GUARD, 11, after, 1.0)
	stage.arena.kill_landed.emit(guard, &"dent_car", Vector2.RIGHT, after, &"shot")
	assert_true(view._contact_m.is_empty())
	stage.arena.kill_landed.emit(guard, &"dent_blast", Vector2.RIGHT, after, &"shot")
	guard.pos = dent.blast_at + Vector2.UP * radius
	stage.arena.wounded.emit(guard, &"dent_blast")
	assert_eq(view._contact_m.size(), 2)
	assert_almost_eq(view._contact_m[0], contact, Vector2.ONE * 0.0001)
	assert_eq(view._landed_m[0], after)
	assert_eq(view._contact_m[1], guard.pos)
	dent.blast_tick = 100
	guard.pos = dent.blast_at + Vector2.LEFT * dent.num(&"car_knock_m")
	stage.arena.wounded.emit(guard, &"dent_blast")
	assert_eq(view._contact_m.size(), 1)
	assert_almost_eq(view._contact_m[0], dent.blast_at, Vector2.ONE * 0.0001)


func test_shock_reaches_preview_at_eight_ticks_and_ring_outlives_disc() -> void:
	assert_almost_eq(DentOverload.shock_extent(0, false), 0.32, 0.001)
	assert_almost_eq(DentOverload.shock_extent(4, false), 0.83, 0.001)
	assert_eq(DentOverload.shock_extent(8, false), 1.0)
	assert_eq(DentOverload.shock_extent(18, false), 1.0)
	assert_eq(DentOverload.shock_extent(0, true), 1.0)
	assert_almost_eq(DentOverload.shock_alpha(0, false), 0.55, 0.001)
	assert_almost_eq(DentOverload.shock_alpha(9, false), 0.275, 0.001)
	assert_eq(DentOverload.shock_alpha(17, true), 0.3)
	assert_eq(DentOverload.shock_alpha(18, true), 0.0)
	assert_eq(DentOverload.shock_alpha(18, false), 0.0)
	assert_eq(DentOverload.ring_alpha(18), 1.0)
	assert_almost_eq(DentOverload.ring_alpha(24), 1.0 / 3.0, 0.001)
	assert_eq(DentOverload.ring_alpha(27), 0.0)
