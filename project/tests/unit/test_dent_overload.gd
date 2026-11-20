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
