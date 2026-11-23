extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func _game() -> PrologueGame:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	game.world.set_process(false)
	return game


func after_each() -> void:
	PlayerActions.shipped().install()


func test_arrival_members_enter_the_gate_before_they_fan_out() -> void:
	var game: PrologueGame = _game()
	var patrol: ProloguePatrol = game.encounter.patrol
	var gate: Vector2 = (game.stage.plan as PrologueYard).gate
	var counts: Dictionary[StringName, int] = {}
	for officer: ProloguePatrol.Officer in patrol.officers:
		var h: Fighter = officer.body
		assert_gt(h.pos.y, gate.y)
		assert_true(patrol.squad.owns(h))
		counts[h.archetype] = counts.get(h.archetype, 0) + 1
	assert_eq(counts, {&"patrol_cop": 7, &"appliance_warden": 3})
	for tick: int in 500:
		game.world.loop().step()
	assert_lt(patrol.dale.pos.y, gate.y)
	assert_eq(game.encounter.phase, PrologueEncounter.Phase.TALK)
	assert_eq(game.stage.arena.rivet.hp, game.stage.arena.rivet.max_hp)
	assert_eq(patrol.squad.shot_tick, -1)


func _strike_dale(game: PrologueGame) -> void:
	var stage: ArenaStage = game.stage
	var patrol: ProloguePatrol = game.encounter.patrol
	stage.arena.rivet.pos = patrol.dale.pos + Vector2.LEFT * 1.2
	var controls: PlayerActions = stage.pilot.actions
	var primary: int = (
		(1 << controls.bit(&"fire")) | PlayerCommand.pack_aim(Vector2.RIGHT, controls)
	)
	for tick: int in 12:
		stage.step(tick, TickInput.new(primary))
	assert_false(patrol.dale.alive())
	assert_eq(stage.arena.kill_weapon, &"claw")


func test_early_strike_interrupts_dialogue_and_hands_wave_keeps_the_same_survivors() -> void:
	var game: PrologueGame = _game()
	var encounter: PrologueEncounter = game.encounter
	var patrol: ProloguePatrol = encounter.patrol
	var survivor: Fighter = patrol.officers[1].body
	_strike_dale(game)
	assert_eq(encounter.phase, PrologueEncounter.Phase.HANDS)
	assert_gt(encounter.dale_died, 0)
	assert_eq(game.lines.shown, ["b1_l01_warden_three_down"])
	assert_eq(game.lines.events.size(), 12)
	for entry: Dictionary in game.lines.events:
		var skipped: bool = entry.get("skipped", false)
		assert_true(skipped)
	assert_eq(game.stage.arena.hostiles_alive(), 9)
	assert_same(patrol.officers[1].body, survivor)
	assert_true(survivor.exposed)
	assert_eq(survivor.weapon, &"pistol")
	assert_true(game.stage.arena.rifle_drops.is_empty())
	assert_eq(game.stage.pilot.wheel.order(), [&"hands"])


func _die(game: PrologueGame, tick: int) -> int:
	var arena: CombatArena = game.stage.arena
	arena.damage(arena.rivet, arena.rivet.max_hp, 99, &"pistol")
	var before: int = game.stage.deaths
	for delta_tick: int in 120:
		game.stage.step(tick + delta_tick, TickInput.new())
		if game.stage.deaths > before:
			return tick + delta_tick
	fail_test("Rivet never respawned")
	return tick + 120


func test_death_restores_the_current_checkpoint_and_only_the_last_cop_clears_it() -> void:
	var game: PrologueGame = _game()
	game.stage.step(0, TickInput.new(1 << game.stage.pilot.actions.bit(&"interact")))
	assert_eq(game.lines.current, "draft_mulroney_radio")
	var tick: int = _die(game, 1)
	assert_eq(game.lines.current, "b1_l01_warden_three_down")
	assert_eq(game.stage.arena.rivet.pos, game.stage.plan.rivet_start)
	assert_eq(game.stage.arena.hostiles_alive(), 10)
	var encounter: PrologueEncounter = game.encounter
	var arena: CombatArena = game.stage.arena
	arena.damage(encounter.patrol.dale, 1.0, arena.rivet.id, &"claw")
	game.stage.step(tick + 1, TickInput.new())
	arena.damage(encounter.patrol.officers[1].body, 1.0, arena.rivet.id, &"claw")
	tick = _die(game, tick + 2)
	assert_eq(encounter.phase, PrologueEncounter.Phase.HANDS)
	assert_eq(encounter.deaths, 2)
	assert_eq(arena.rivet.pos, encounter.patrol.wave_start)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)
	assert_eq(arena.hostiles_alive(), 9)
	assert_eq(game.lines.current, "")
	for i: int in range(1, encounter.patrol.officers.size()):
		assert_eq(encounter.phase, PrologueEncounter.Phase.HANDS)
		arena.damage(encounter.patrol.officers[i].body, 1.0, arena.rivet.id, &"claw")
		game.stage.step(tick + i, TickInput.new())
	assert_eq(encounter.phase, PrologueEncounter.Phase.BEAT_TWO)
	assert_eq(game.lines.current, "b2_l01_mulroney_line_up")
	assert_eq(encounter.done_tick, tick + 9)
	assert_true(arena.rifle_drops.is_empty())


func test_an_unanswered_pistol_and_pole_wave_can_kill_rivet() -> void:
	var game: PrologueGame = _game()
	var stage: ArenaStage = game.stage
	var encounter: PrologueEncounter = game.encounter
	# Start with the actual cast on their marks, as after an unskipped conversation.
	for tick: int in 2400:
		stage.step(tick, TickInput.new())
		if encounter.strike_ready:
			break
	assert_true(encounter.strike_ready)
	var first: int = stage.tick + 1
	stage.arena.damage(encounter.patrol.dale, 1.0, stage.arena.rivet.id, &"claw")
	for tick: int in range(first, first + 120 * SimClock.TICK_RATE):
		stage.step(tick, TickInput.new())
		if stage.deaths > 0:
			break
	assert_eq(stage.deaths, 1)
	assert_eq(encounter.phase, PrologueEncounter.Phase.HANDS)
	assert_eq(stage.arena.hostiles_alive(), 9)
	var first_catch: int = (stage.arena as PrologueCombat).first_catch_tick
	assert_gt(first_catch, encounter.dale_died)
	var taught: Array[String] = []
	for hint: Dictionary in encounter.prompts.history:
		taught.append(str(hint["id"]))
		if hint["id"] == "roll":
			var shown: int = hint["tick"]
			assert_gt(shown, first_catch)
	for id: String in ["strike", "claw", "guard", "roll"]:
		assert_true(taught.has(id), id)
