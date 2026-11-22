extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func after_each() -> void:
	PlayerActions.shipped().install()


func test_walking_over_the_mark_teaches_bound_controls_and_leaving_clears_the_wheel() -> void:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	game.world.set_process(false)
	var stage: ArenaStage = game.stage
	stage.step(1, TickInput.new())
	var carry: RivetCarry = stage.pilot.carry
	var pistol: ProloguePistol = ProloguePistol.new(&"pistol")
	var prompts: ProloguePrompts = game.encounter.prompts
	var at: Vector2 = stage.arena.rivet.pos + Vector2.RIGHT * 2.0
	pistol.mark(carry, at, 2)
	stage.step(2, TickInput.new())
	assert_eq(carry.ground.items[0].pos, at)
	assert_eq(carry.ground.items[0].id, pistol.id)
	assert_false(prompts.active("wheel"))
	stage.arena.rivet.pos = at
	stage.step(3, TickInput.new())
	pistol.observe(carry, prompts, 3)
	assert_true(carry.ground.items.is_empty())
	assert_eq(carry.slots[carry.slot_of(pistol.id)], pistol.id)
	assert_eq(pistol.picked_tick, 3)
	assert_true(prompts.active("wheel"))
	assert_false(prompts.active("fire"))
	assert_string_contains(prompts.words(true), ObjectiveHint.pad_name(&"weapon_next"))
	stage.step(4, TickInput.new(1 << stage.pilot.actions.bit(&"weapon_next")))
	assert_eq(stage.arena.rivet.weapon, pistol.id)
	assert_not_null(stage.arena.gun)
	pistol.observe(carry, prompts, 4)
	assert_false(prompts.active("wheel"))
	assert_true(prompts.active("fire"))
	assert_string_contains(prompts.words(false), ObjectiveHint.key_name(&"fire"))
	assert_eq(prompts.history.size(), 2)
	pistol.leave(stage)
	assert_true(pistol.left)
	assert_eq(stage.pilot.wheel.order(), [&"hands"])
	assert_eq(stage.pilot.wheel.selected(), &"hands")
	assert_eq(stage.arena.rivet.weapon, &"")
	assert_null(stage.arena.gun)
