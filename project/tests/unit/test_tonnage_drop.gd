extends GutTest
## n31 ghost 2: Tonnage's drop-mode deploy (one press, a short charge, a full-circle dump).

var stage: CollectCallStage
var arena: CombatArena
var squad: ArenaSquad
var pilot: StagePilot
var ghost: GhostDeploy
var row: GhostAttacks.DeployRow
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	arena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	row = ghost.strike.attacks.deploy[&"tonnage"]
	pilot.ghosts.forms.selected = &"tonnage"
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _spawn(at: Vector2, id: StringName = &"contractor", hp: float = 100.0) -> Fighter:
	var foe: Fighter = squad.spawn_member(arena, at, id)
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = hp
	foe.hp = hp
	return foe


func _drive(bits: int = 0, reach: float = 18.0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, reach)
	pilot.drive(stage, TickInput.new(aim | bits))


## Press on one tick, then idle up to (not including) the dump tick.
func _press_and_charge(reach: float = 18.0) -> void:
	_drive(key, reach)
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()


func test_shipped_row_is_a_drop_with_a_short_charge_and_a_wide_circle() -> void:
	assert_true(row.drops())
	assert_eq(row.drop_at, &"aim")
	assert_eq(row.charge_ticks, roundi(0.45 * SimClock.TICK_RATE))
	assert_eq(row.radius_m, 6.5)
	assert_eq(row.dump_damage, 3.0)
	assert_eq(row.life_ticks, row.charge_ticks + 54, "the old aftermath follows the charge")


func test_one_press_stands_at_once_and_hits_only_on_the_dump_tick() -> void:
	var foe: Fighter = _spawn(Vector2(7, 0))
	_drive(key)
	var pressed: int = stage.tick
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "no aiming phase")
	assert_eq(ghost.form, &"tonnage")
	assert_eq(ghost.spot, Vector2(6, 0))
	assert_eq(ghost.cooldowns[&"tonnage"], row.cooldown_ticks)
	assert_eq(ghost.start_tick, pressed)
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive(key)  # holding the key changes nothing
		assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
		assert_eq(foe.hp, foe.max_hp, "nothing is hit while he charges")
		assert_lt(ghost.dump.strike_age(ghost, stage.tick), 0)
	_drive()
	assert_eq(stage.tick, pressed + row.charge_ticks)
	assert_eq(foe.max_hp - foe.hp, row.dump_damage)
	assert_eq(ghost.strike.release_tick, stage.tick, "release_tick is the dump tick")
	assert_eq(ghost.dump.strike_age(ghost, stage.tick), 0)
	_drive()
	assert_eq(foe.max_hp - foe.hp, row.dump_damage, "one dump only")


func test_the_circle_is_judged_on_the_dump_tick_all_round_with_body_radius() -> void:
	var leaves: Fighter = _spawn(Vector2(8, 0))
	var arrives: Fighter = _spawn(Vector2(25, 0))
	var behind: Fighter = _spawn(Vector2(25, 5))
	var edge_in: Fighter = _spawn(Vector2(25, -5))
	var edge_out: Fighter = _spawn(Vector2(25, 9))
	_press_and_charge()
	var spot: Vector2 = ghost.spot
	leaves.pos = spot + Vector2(row.radius_m + leaves.radius_m + 0.5, 0)
	arrives.pos = spot + Vector2(1, 1)
	behind.pos = spot + Vector2(-4, 0)
	edge_in.pos = spot + Vector2(0, row.radius_m + edge_in.radius_m - 0.01)
	edge_out.pos = spot + Vector2(0, -(row.radius_m + edge_out.radius_m + 0.01))
	_drive()
	assert_eq(leaves.hp, leaves.max_hp, "walked out before the dump")
	assert_lt(arrives.hp, arrives.max_hp, "walked in before the dump")
	assert_lt(behind.hp, behind.max_hp, "a full circle, not the old half-disc")
	assert_lt(edge_in.hp, edge_in.max_hp)
	assert_eq(edge_out.hp, edge_out.max_hp)


func test_rivet_inside_the_circle_is_never_hit() -> void:
	var foe: Fighter = _spawn(Vector2(3, 0), &"contractor", 1.0)
	_press_and_charge(2.0)
	_drive()
	assert_false(foe.alive())
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)
	row.drop_at = &"rivet"
	ghost.cooldowns.clear()
	while ghost.phase != GhostDeploy.Phase.IDLE:
		_drive()
	_drive(key)
	assert_eq(ghost.spot, arena.rivet.pos, "drop_at rivet stands him on Rivet")
	for i: int in row.charge_ticks:
		_drive()
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_bond_is_recorded_once_on_the_dump_tick_with_its_kills() -> void:
	var bond: GhostBond = pilot.ghosts.forms.bond
	bond.enabled = true
	var per_kill: float = pilot.ghosts.forms.table.per_kill
	@warning_ignore("return_value_discarded")
	_spawn(Vector2(6, 2), &"contractor", 1.0)
	@warning_ignore("return_value_discarded")
	_spawn(Vector2(6, -2), &"contractor", 1.0)
	_press_and_charge()
	assert_eq(bond.value(&"tonnage"), 0.0, "nothing recorded on the press")
	_drive()
	assert_eq(ghost.strike.release_kills, 2)
	assert_almost_eq(bond.value(&"tonnage"), 2.0 * per_kill, 0.0001)
	for i: int in 10:
		_drive()
	assert_almost_eq(bond.value(&"tonnage"), 2.0 * per_kill, 0.0001)


func test_a_walker_in_the_circle_still_cracks_open() -> void:
	var walker: Fighter = _spawn(Vector2(3, 0), &"war_machine")
	walker.facing = Vector2.RIGHT
	_press_and_charge()
	_drive()
	assert_eq(walker.max_hp - walker.hp, row.dump_damage)
	assert_true(
		TonnageCrack.is_open(squad.mind_for(walker), squad.moves.tonnage_armour_crack, stage.tick)
	)


func test_death_cancels_the_pending_dump() -> void:
	var foe: Fighter = _spawn(Vector2(7, 0))
	_press_and_charge()
	arena.rivet.hp = 0.0
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_false(ghost.dump.pending())
	assert_eq(foe.hp, foe.max_hp)
	assert_true(ghost.cooldowns.has(&"tonnage"), "the press spent the cooldown")


func test_the_pending_dump_enters_the_replay_state() -> void:
	_drive(key)
	var a: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(a)
	_drive()
	var b: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(b)
	assert_ne(a.data_array, b.data_array)
	ghost.dump.cancel()
	var c: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(c)
	assert_ne(c.data_array, b.data_array)


func test_hold_mode_keeps_the_old_release_flow() -> void:
	row.press_mode = &"hold"
	var front: Fighter = _spawn(Vector2(7, 0))
	_drive(key)
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_false(ghost.dump.pending())
	assert_eq(front.max_hp - front.hp, pilot.hauler.form.num(&"stomp_damage"))
