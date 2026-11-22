extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func after_each() -> void:
	PlayerActions.shipped().install()


func _contact() -> PrologueGame:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	game.world.set_process(false)
	var stage: ArenaStage = game.stage
	var patrol: ProloguePatrol = game.encounter.patrol
	stage.step(1, TickInput.new())
	stage.arena.rivet.pos = Vector2(32, 24)
	stage.arena.damage(patrol.dale, 1.0, 0, &"claw")
	stage.step(2, TickInput.new())
	for officer: ProloguePatrol.Officer in patrol.officers:
		officer.body.pos = stage.arena.rivet.pos + Vector2.LEFT * 2.0
		stage.arena.damage(officer.body, 1.0, 0, &"claw")
	stage.step(3, TickInput.new())
	var battle: PrologueBattle = game.encounter.battle
	assert_false(battle.ranged)
	assert_lt(battle.last_action_tick, 0)
	assert_lt(battle.exposed_until, 0)
	assert_lt(battle.died_tick, 0)
	return game


func _ranged(game: PrologueGame) -> void:
	var stage: ArenaStage = game.stage
	var use: int = 1 << stage.pilot.actions.bit(&"interact")
	for tick: int in range(stage.tick + 1, stage.tick + 1600):
		stage.step(tick, TickInput.new(use if tick % 2 == 0 else 0))
		if game.encounter.battle.ranged:
			return
	fail_test("Did not reach the ranged stage")


func test_authored_contact_orders_the_flank_and_the_volley_after_their_tells() -> void:
	var game: PrologueGame = _contact()
	var stage: ArenaStage = game.stage
	var battle: PrologueBattle = game.encounter.battle
	var line: PrologueFormation = battle.formation
	assert_eq(line.members.size(), 8)
	assert_eq(line.shields.size(), 3)
	assert_eq(line.rifles.size(), 4)
	var gate: Vector2 = (stage.plan as PrologueYard).gate
	for h: Fighter in line.members:
		assert_gt(h.pos.y, gate.y)
	assert_eq(battle.orders[0], {"line": "b2_l01_mulroney_line_up", "tick": stage.tick})
	assert_eq(battle.due_tick, stage.tick + battle.spec.attacks[&"line_up"].windup)
	var due: int = battle.due_tick
	for tick: int in range(stage.tick + 1, due):
		stage.step(tick, TickInput.new())
	assert_false(line.pushing)
	stage.step(due, TickInput.new())
	assert_true(line.pushing)
	assert_true(line.boss.exposed)
	assert_true(stage.pilot.carry.ground.items.is_empty())
	_ranged(game)
	assert_eq(
		game.lines.shown.slice(-5),
		[
			"b2_l01_mulroney_line_up",
			"b2_l02_cop_arrest",
			"b2_l03_rivet_laws",
			"b2_l04_ghosts_kill",
			"b2_l05_mulroney_shoot"
		]
	)
	var issued: int = battle.orders[1]["tick"]
	assert_eq(issued, stage.tick)
	assert_eq(stage.pilot.carry.ground.items.size(), 1)
	assert_eq(stage.pilot.carry.ground.items[0].pos, game.encounter.patrol.officers[1].body.pos)
	_check_volley(stage, battle)


func _check_volley(stage: ArenaStage, battle: PrologueBattle) -> void:
	var volley: BossAttack = battle.spec.attacks[&"volley"]
	assert_eq(battle.due_tick, stage.tick + volley.windup)
	var due: int = battle.due_tick
	for tick: int in range(stage.tick + 1, due):
		stage.step(tick, TickInput.new())
	assert_eq(battle.fire.volleys, 0)
	stage.step(due, TickInput.new())
	assert_eq(battle.last_action_tick, due)
	assert_eq(battle.exposed_until, due + volley.punish)
	assert_eq(battle.due_tick, -1)
	assert_eq(battle.fire.volleys, 1)
	assert_eq(stage.arena.shots.size(), battle.formation.rifles.size())
	for shot: Shot in stage.arena.shots:
		assert_eq(shot.weapon, &"rifle")
	stage.arena.rivet.pos = Vector2(4, 4)
	var again: int = due + volley.recovery + battle.spec.phases[0].gap
	for tick: int in range(due + 1, again):
		stage.step(tick, TickInput.new())
	assert_eq(battle.orders.size(), 2, "No second tell during recovery or the inter-order gap")
	stage.step(again, TickInput.new())
	var order: Dictionary = battle.orders.back()
	assert_eq(order, {"line": "b2_l01_mulroney_line_up", "tick": again})
	assert_eq(battle.due_tick, again + battle.spec.attacks[&"line_up"].windup)


func test_cover_full_damage_last_man_gate_and_pistol_handoff() -> void:
	var game: PrologueGame = _contact()
	var stage: ArenaStage = game.stage
	var arena: CombatArena = stage.arena
	var battle: PrologueBattle = game.encounter.battle
	var line: PrologueFormation = battle.formation
	_ranged(game)
	var due: int = battle.due_tick
	var yard: PrologueYard = stage.plan as PrologueYard
	arena.rivet.pos = yard.gate + Vector2.UP * (arena.rivet.radius_m + 0.01)
	for tick: int in range(stage.tick + 1, due):
		stage.step(tick, TickInput.new(0, 0, TickInput.AXIS_MAX))
	assert_lt(arena.rivet.pos.y, yard.gate.y)
	assert_false(line.boss.exposed)
	arena.damage(line.boss, 0.5, 0, &"pistol")
	assert_eq(line.boss.hp, line.boss.max_hp)
	stage.step(due, TickInput.new())
	arena.damage(line.boss, 0.5, 0, &"pistol")
	assert_eq(line.boss.hp, line.boss.max_hp - 0.5)
	arena.damage(line.boss, 99.0, 0, &"pistol")
	assert_eq(line.boss.hp, line.last_stand_hp)
	# Leave the volley lane so this check can observe the whole recovery window.
	arena.rivet.pos = Vector2(4.0, 4.0)
	for tick: int in range(stage.tick + 1, battle.exposed_until + 1):
		stage.step(tick, TickInput.new())
	assert_false(line.boss.exposed)
	_finish_line(game)
	assert_true(yard.exit_open)
	assert_eq(game.encounter.phase, PrologueEncounter.Phase.STREET)
	assert_true(battle.pistol.left)
	assert_eq(battle.died_tick, stage.tick)
	assert_eq(stage.pilot.wheel.order(), [&"hands"])
	assert_true(stage.pilot.carry.first_seen.is_empty())
	assert_true(stage.pilot.carry.ground.items.is_empty())
	assert_null(stage.arena.gun)
	assert_false(game.encounter.prompts.active("fire"))
	arena.rivet.pos = yard.gate + Vector2.UP * (arena.rivet.radius_m + 0.1)
	for tick: int in range(stage.tick + 1, stage.tick + 50):
		stage.step(tick, TickInput.new(0, 0, TickInput.AXIS_MAX))
	assert_gt(arena.rivet.pos.y, yard.gate.y)


func _finish_line(game: PrologueGame) -> void:
	var stage: ArenaStage = game.stage
	var line: PrologueFormation = game.encounter.battle.formation
	var from: Vector2 = stage.arena.rivet.pos
	stage.arena.rivet.pos = stage.pilot.carry.ground.items[0].pos
	stage.step(stage.tick + 1, TickInput.new())
	stage.step(stage.tick + 1, TickInput.new(1 << stage.pilot.actions.bit(&"weapon_next")))
	assert_eq(stage.arena.rivet.weapon, &"pistol")
	stage.arena.rivet.pos = from
	for shield: Fighter in line.shields:
		stage.arena.damage(shield, 99.0, 0, &"claw", &"melee")
	assert_true(line.boss.exposed)
	stage.arena.damage(line.boss, 10.0, 0, &"pistol")
	assert_true(line.boss.alive())
	for rifle: Fighter in line.rifles:
		stage.arena.damage(rifle, 99.0, 0, &"pistol")
	stage.arena.damage(line.boss, 1.0, 0, &"pistol")
	stage.step(stage.tick + 1, TickInput.new())


func test_death_rebuilds_the_eight_and_returns_the_picked_pistol_to_its_mark() -> void:
	var game: PrologueGame = _contact()
	_ranged(game)
	var stage: ArenaStage = game.stage
	var battle: PrologueBattle = game.encounter.battle
	var carry: RivetCarry = stage.pilot.carry
	var mark: Vector2 = carry.ground.items[0].pos
	stage.arena.rivet.pos = mark
	stage.step(stage.tick + 1, TickInput.new())
	assert_true(game.encounter.prompts.active("wheel"))
	assert_eq(carry.first_seen, [&"pistol"])
	var previous: Fighter = battle.formation.boss
	stage.arena.damage(battle.formation.rifles[0], 99.0, 0, &"pistol")
	stage.arena.damage(stage.arena.rivet, 1000.0, 999, &"rifle")
	for tick: int in range(stage.tick + 1, stage.tick + 120):
		stage.step(tick, TickInput.new())
		if battle.deaths > 0:
			break
	assert_eq(battle.deaths, 1)
	assert_eq(game.encounter.deaths, 1)
	var beat: int = game.encounter.spans.back()["beat"]
	assert_eq(beat, 2)
	assert_eq(game.lines.current, "b2_l01_mulroney_line_up")
	assert_eq(stage.arena.hostiles_alive(), 8)
	assert_eq(battle.last_action_tick, -1)
	assert_eq(battle.exposed_until, -1)
	assert_eq(battle.fire.volleys, 0)
	assert_false(battle.ranged)
	assert_false(stage.arena.hostiles.has(previous))
	assert_eq(carry.ground.items.size(), 1)
	assert_eq(carry.ground.items[0].pos, mark)
	assert_eq(stage.pilot.wheel.order(), [&"hands"])
