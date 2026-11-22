extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func test_yard_loads_and_wrecks_stop_rivet_and_shots() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	var stage: ArenaStage = game.stage
	var plan: PrologueYard = stage.plan as PrologueYard
	assert_eq(plan.yard.size, Vector2(60.0, 34.0))
	assert_gte(plan.wrecks.size(), 2)
	assert_eq(stage.arena.walls, stage.walls)
	for wreck: PrologueYard.Wreck in plan.wrecks:
		var box: Rect2 = wreck.footprint
		var middle: Vector2 = box.get_center()
		assert_not_null(load(wreck.art) as Texture2D, wreck.id)
		assert_eq(
			stage.walls.push_out(middle, stage.arena.rivet.radius_m), stage.collide_preview(middle)
		)
		assert_false(box.has_point(stage.collide_preview(middle)), wreck.id)
		assert_true(stage.arena.walls.blocks(middle - box.size, middle + box.size), wreck.id)
	var first: Rect2 = plan.wrecks[0].footprint
	var west: Vector2 = Vector2(first.position.x - 1.0, first.get_center().y)
	stage.arena.rivet.pos = west
	game.world.loop().set_input(PrologueGame.WalkPilot.new())
	for tick: int in SimClock.TICK_RATE:
		game.world.loop().step()
	assert_gt(stage.arena.rivet.pos.x, west.x)
	assert_almost_eq(stage.arena.rivet.pos.x, first.position.x - stage.arena.rivet.radius_m, 0.001)
	PlayerActions.shipped().install()


func test_gate_and_entire_crossing_are_clear_in_both_directions() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	var stage: ArenaStage = game.stage
	var plan: PrologueYard = stage.plan as PrologueYard
	var radius: float = stage.arena.rivet.radius_m
	for side: float in [-1.0, 0.0, 1.0]:
		var x: float = plan.gate.x + side * (plan.gate_width_m * 0.5 - radius)
		var outside: Vector2 = Vector2(x, plan.street.end.y - radius)
		var inside: Vector2 = Vector2(x, plan.gate.y - 3.0)
		assert_false(stage.walls.blocks(outside, inside))
		assert_false(stage.walls.blocks(inside, outside))
		for metre: int in range(ceili(inside.y), floori(outside.y)):
			var p: Vector2 = Vector2(x, metre)
			assert_eq(stage.collide_preview(p), p)
	assert_true(stage.walls.blocks(plan.gate + Vector2(-6, 2), plan.gate + Vector2(-6, -2)))
	PlayerActions.shipped().install()
