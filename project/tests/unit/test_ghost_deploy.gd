extends GutTest

var stage: CollectCallStage
var pilot: StagePilot
var ghost: GhostDeploy
var actions: PlayerActions
var q: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	actions = PlayerActions.shipped(false)
	pilot = StagePilot.new(actions)
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	# This file pins the hold-aim-release flow (main before n31). Tonnage ships press_mode drop
	# (test_tonnage_drop.gd); the selected Tonnage here is switched back to hold on purpose.
	ghost.strike.attacks.deploy[&"tonnage"].press_mode = &"hold"
	q = 1 << actions.bit(&"ghost_deploy")


func _drive(bits: int = 0, reach: float = 0.0, move_x: int = 0) -> void:
	stage.tick += 1
	stage.intent.clear()
	var word: int = PlayerCommand.pack_aim(Vector2.RIGHT, actions, reach)
	pilot.drive(stage, TickInput.unpack(TickInput.new(word | bits, move_x, 0).pack()))


func _state() -> PackedByteArray:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(out)
	return out.data_array


func test_cursor_uses_wire_32_tracks_the_mouse_and_stops_at_the_wall() -> void:
	assert_eq(q, 1 << 32)
	_drive(q, 3.6)
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	assert_almost_eq(ghost.spot.x, 3.6, 0.001)
	assert_false(_state().is_empty())
	var short_aim: PackedByteArray = _state()
	_drive(q, 18.0)
	assert_eq(ghost.spot, Vector2(6, 0))
	assert_ne(_state(), short_aim)
	stage.arena.walls = ArenaWalls.new()
	stage.arena.walls.boxes.append(Rect2(3, -1, 0.2, 2))
	_drive(q, 18.0)
	assert_lt(ghost.spot.x, 3.0)
	assert_eq(ghost.spot, Vector2(2.99853515625, 0), "the clipped position enters the replay hash")
	_drive(0, 18.0)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_false(stage.arena.walls.blocks(stage.arena.rivet.pos, ghost.spot))


func test_life_and_cooldown_start_on_release_and_expire_on_the_exact_tick() -> void:
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[&"tonnage"]
	for tick: int in 50:
		_drive(q)
		assert_true(ghost.cooldowns.is_empty())
	_drive()
	var released: int = stage.tick
	assert_eq(ghost.ticks_left, row.life_ticks)
	assert_eq(ghost.cooldowns[&"tonnage"], row.cooldown_ticks)
	var started: PackedByteArray = _state()
	for age: int in range(1, row.life_ticks):
		_drive()
		assert_eq(ghost.ticks_left, row.life_ticks - age)
		assert_eq(ghost.last_refusal, &"", "an idle tick never retries the consumed release")
		assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_ne(_state(), started)
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_eq(ghost.form, &"")
	assert_eq(ghost.spot, Vector2.ZERO)
	assert_false(_state().is_empty(), "cooldown still affects the replay state")
	while stage.tick < released + row.cooldown_ticks - 4:
		_drive()
	_drive(q)
	_drive()
	assert_eq(ghost.last_refusal, &"cooldown")
	assert_eq(ghost.cooldowns[&"tonnage"], 2)
	_drive(q)
	assert_true(ghost.cooldowns.has(&"tonnage"), "one cooldown tick remains before release")
	_drive()
	assert_eq(stage.tick - released, row.cooldown_ticks)
	assert_eq(ghost.last_refusal, &"")
	assert_eq(ghost.ticks_left, row.life_ticks)


func test_locked_disabled_and_empty_selection_refuse_without_spending_a_cooldown() -> void:
	var forms: GhostForms = pilot.ghosts.forms
	forms.apply_locks([])
	forms.selected = &"dent"
	_drive(q)
	_drive()
	assert_eq(ghost.last_refusal, GhostLocks.LOCKED)
	forms.selected = &""
	_drive(q)
	_drive()
	assert_eq(ghost.last_refusal, GhostLocks.LOCKED)
	forms.selected = &"ohm"
	ghost.strike.attacks.deploy[&"ohm"].enabled = false
	_drive(q)
	_drive()
	assert_eq(ghost.last_refusal, &"disabled")
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_true(ghost.cooldowns.is_empty())


func test_g_cycles_loaded_ghost_and_one_out_at_a_time() -> void:
	_drive(q | (1 << actions.bit(&"power_gearbox")))
	_drive()
	assert_eq(ghost.form, &"dent")
	var end: Vector2 = ghost.spot
	_drive(q | (1 << actions.bit(&"power_gearbox")))
	_drive()
	assert_eq(ghost.last_refusal, &"busy")
	assert_eq(ghost.form, &"dent")
	assert_eq(ghost.spot, end)
	for tick: int in ghost.ticks_left:
		_drive()
	_drive(q)
	_drive()
	assert_eq(ghost.form, &"kerf")
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_gt(ghost.cooldowns[&"dent"], 0)


func test_rivet_walks_at_full_speed_fires_and_swings_through_deployment() -> void:
	stage.arena.rivet.weapon = &"gloria"
	var fire: int = 1 << actions.bit(&"fire")
	for tick: int in 60:
		_drive(q | fire, 6.0, TickInput.AXIS_MAX)
	var walk: float = stage.arena.tuning.rivet["walk_mps"]
	assert_almost_eq(stage.intent.move_by.length(), walk * SimClock.TICK_DT, 0.001)
	assert_true(stage.intent.fire_at.is_finite())
	_drive(fire, 6.0, TickInput.AXIS_MAX)
	assert_true(stage.arena.rivet_fire(stage.intent.fire_at))
	assert_almost_eq(stage.intent.move_by.length(), walk * SimClock.TICK_DT, 0.001)
	_drive(1 << actions.bit(&"melee"))
	assert_eq(pilot.melee_swings, 1)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))


func test_an_enemy_round_crosses_the_ghost_and_damages_rivet() -> void:
	_drive(q)
	_drive()
	var arena: CombatArena = stage.arena
	assert_true(arena.hostiles.is_empty())
	var shooter: Fighter = arena.spawn_guard(Vector2(9, 0))
	shooter.pos = Vector2(9, 0)
	var bullet: Shot = Shot.fire(shooter, Vector2.LEFT, arena.tuning.weapon(shooter.weapon))
	arena.shots.append(bullet)
	var hp: float = arena.rivet.hp
	for tick: int in 30:
		ArenaProjectiles.step_shots(arena)
		if arena.shots.is_empty():
			break
	assert_lt(arena.rivet.hp, hp)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)


func test_rivet_can_raise_guard_while_aiming_and_keep_it_up_after_release() -> void:
	actions = PlayerActions.shipped(true)
	pilot = StagePilot.new(actions)
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	var guard: int = 1 << actions.bit(&"guard")
	_drive(q | guard, 3.6)
	assert_true(pilot.guard.up())
	_drive(guard, 3.6)
	assert_true(pilot.guard.up())
	assert_true(pilot.ghosts.settled_in(GhostForms.BASE))
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)


func test_death_cancels_a_held_deployment() -> void:
	_drive(q)
	stage.arena.rivet.hp = 0.0
	_drive(q)
	stage.arena.rivet.hp = stage.arena.rivet.max_hp
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_eq(ghost.last_refusal, &"dead")
	assert_true(ghost.cooldowns.is_empty())


func test_old_tape_actions_never_create_deploy_state() -> void:
	var bits: int = (1 << 30) | (1 << 29) | (1 << actions.bit(&"power_gearbox"))
	var old: TickInput = TickInput.new(bits, -127, 41)
	assert_eq(old.pack(), (bits << 16) | (1 << 8) | 169)
	_drive(bits)
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_true(_state().is_empty())
