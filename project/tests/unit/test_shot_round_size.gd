extends GutTest


func test_a_typed_round_keeps_its_size_when_the_enemy_id_names_another_size() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat")
	)
	var row: CombatTuning.Weapon = CombatTuning.Weapon.new()
	row.id = &"cannon"
	row.round = Shot.SMALL
	var shooter: Fighter = arena.spawn_guard(arena.rivet.pos + Vector2.RIGHT * 8.0)
	var shot: Shot = Shot.fire(shooter, Vector2.RIGHT, row)
	assert_true(shot.size_known)
	arena.shots.append(shot)
	ArenaProjectiles.step_shots(arena)
	assert_eq(shot.size, Shot.SMALL, "the weapon row already resolved the round")


func test_explicit_size_and_unresolved_default_both_start_small() -> void:
	var shot: Shot = Shot.new()
	assert_eq(shot.size, Shot.SMALL)
	assert_false(shot.size_known)
	shot.size = Shot.SMALL
	assert_true(shot.size_known)
	shot.size = Shot.LARGE
	assert_eq(shot.size, Shot.LARGE)
	assert_true(shot.size_known)
