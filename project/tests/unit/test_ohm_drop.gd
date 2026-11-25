extends GutTest
## n31 ghost 10: Ohm's drop-mode deploy (one press, a short charge, a full-circle discharge).

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
	row = ghost.strike.attacks.deploy[&"ohm"]
	pilot.ghosts.forms.selected = &"ohm"
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


func _bolt() -> float:
	return pilot.ohm.num(&"bolt_damage")


func test_shipped_row_carries_a_quick_charge_at_the_aim() -> void:
	var shipped: GhostAttacks.DeployRow = GhostAttacks.shipped().deploy[&"ohm"]
	assert_eq(shipped.press_mode, &"drop", "n31: one press, a charge, a full circle")
	assert_eq(shipped.drop_at, &"aim")
	assert_eq(shipped.charge_ticks, 18, "0.3 s: Ohm is the quick caster")
	assert_lt(shipped.charge_ticks, ghost.strike.attacks.deploy[&"tonnage"].charge_ticks)
	assert_eq(shipped.radius_m, 5.0, "g10 lab: the smallest radius with an 8-cop share >= 75 %")
	assert_eq(shipped.life_ticks, 66)


func test_one_press_stands_at_once_and_hits_only_on_the_dump_tick() -> void:
	var foe: Fighter = _spawn(Vector2(10, 0))
	_drive(key)
	var pressed: int = stage.tick
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "no aiming phase")
	assert_eq(ghost.form, &"ohm")
	assert_eq(ghost.spot, Vector2(row.range_m, 0))
	assert_eq(ghost.cooldowns[&"ohm"], row.cooldown_ticks)
	assert_eq(ghost.start_tick, pressed)
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive(key)  # holding the key changes nothing
		assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
		assert_eq(foe.hp, foe.max_hp, "nothing is hit while he charges")
	_drive()
	assert_eq(stage.tick, pressed + row.charge_ticks)
	assert_eq(foe.max_hp - foe.hp, _bolt())
	assert_eq(ghost.strike.release_tick, stage.tick, "release_tick is the discharge tick")
	_drive()
	assert_eq(foe.max_hp - foe.hp, _bolt(), "one discharge only")


func test_the_circle_is_judged_on_the_dump_tick_all_round_with_body_radius() -> void:
	var leaves: Fighter = _spawn(Vector2(10, 0))
	var arrives: Fighter = _spawn(Vector2(25, 0))
	var behind: Fighter = _spawn(Vector2(25, 5))
	var edge_in: Fighter = _spawn(Vector2(25, -5))
	var edge_out: Fighter = _spawn(Vector2(25, 9))
	_press_and_charge()
	var spot: Vector2 = ghost.spot
	leaves.pos = spot + Vector2(row.radius_m + leaves.radius_m + 0.5, 0)
	arrives.pos = spot + Vector2(1, 1)
	behind.pos = spot + Vector2(-row.radius_m + 0.5, 0)
	edge_in.pos = spot + Vector2(0, row.radius_m + edge_in.radius_m - 0.01)
	edge_out.pos = spot + Vector2(0, -(row.radius_m + edge_out.radius_m + 0.01))
	_drive()
	assert_eq(leaves.hp, leaves.max_hp, "walked out before the discharge")
	assert_lt(arrives.hp, arrives.max_hp, "walked in before the discharge")
	assert_lt(behind.hp, behind.max_hp, "a full circle")
	assert_lt(edge_in.hp, edge_in.max_hp, "the rim plus the body counts")
	assert_eq(edge_out.hp, edge_out.max_hp)


func test_a_machine_inside_is_shorted_and_rivet_is_never_hit() -> void:
	var human: Fighter = _spawn(Vector2(2, 0), &"contractor", 1.0)
	var turret: Fighter = _spawn(Vector2(3, 1), &"sentry_turret")
	turret.facing = Vector2.RIGHT
	_press_and_charge(2.0)
	assert_eq(squad.mind_for(turret).stun_until, 0, "no short before the discharge")
	_drive()
	assert_false(human.alive())
	assert_eq(turret.max_hp - turret.hp, _bolt())
	var short: MoveTable.ShortCircuit = squad.moves.ohm_short_circuit
	assert_eq(squad.mind_for(turret).stun_until, stage.tick + short.stun_ticks)
	assert_eq(ghost.strike.release_stuns, 1)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp, "Rivet stands inside the circle unhurt")


func test_rivet_dying_mid_charge_cancels_the_discharge() -> void:
	var foe: Fighter = _spawn(Vector2(10, 0))
	_drive(key)
	arena.rivet.hp = 0.0
	for i: int in row.charge_ticks + 2:
		_drive()
	assert_eq(foe.hp, foe.max_hp)
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_true(ghost.cooldowns.has(&"ohm"), "the cooldown stays spent")


func test_hold_mode_keeps_the_old_centre_distance_strike_at_the_release() -> void:
	row.press_mode = &"hold"
	var rim: Fighter = _spawn(Vector2(row.range_m, row.radius_m + 0.2))
	_drive(key)
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_eq(rim.hp, rim.max_hp, "hold mode counts the centre only")
	assert_eq(ghost.strike.release_tick, stage.tick)
