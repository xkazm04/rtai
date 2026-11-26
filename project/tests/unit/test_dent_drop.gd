extends GutTest
## n31 ghost 15: Dent's drop-mode deploy (one press, no marker, a short wind-up, then the ram
## along the lane laid on the press from Rivet's side to the aim point).

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
	row = ghost.strike.attacks.deploy[&"dent"]
	pilot.ghosts.forms.selected = &"dent"
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _spawn(at: Vector2) -> Fighter:
	var foe: Fighter = squad.spawn_member(arena, at, &"contractor")
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = 100.0
	foe.hp = 100.0
	return foe


func _drive(bits: int = 0, reach: float = 18.0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, reach)
	pilot.drive(stage, TickInput.new(aim | bits))


## Press on one tick, then idle up to (not including) the ram tick.
func _press_and_wind_up() -> void:
	_drive(key)
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()


func _jab() -> float:
	return ghost.strike.attacks.num(&"dent", &"jab_damage")


func test_shipped_row_is_a_quick_charger_drop() -> void:
	var shipped: GhostAttacks.DeployRow = GhostAttacks.shipped().deploy[&"dent"]
	assert_eq(shipped.press_mode, &"drop", "n31: one press, a wind-up, the ram")
	assert_eq(shipped.charge_ticks, 15, "0.25 s: Dent is the charger")
	assert_lt(shipped.charge_ticks, GhostAttacks.shipped().deploy[&"ohm"].charge_ticks)
	assert_eq(shipped.life_ticks, shipped.charge_ticks + 42, "the old 42 ticks after the ram")


func test_one_press_is_active_with_no_aiming_and_rams_only_on_its_tick() -> void:
	var foe: Fighter = _spawn(Vector2(4, 0))
	_drive(key)
	var pressed: int = stage.tick
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "no aiming phase")
	assert_eq(ghost.held_form(pilot.ghosts.forms), &"", "no marker: nothing is held")
	assert_eq(ghost.origin, Vector2.RIGHT.orthogonal() * arena.rivet.radius_m, "Rivet's side")
	assert_eq(ghost.spot, Vector2(row.range_m, 0), "the aim point clipped to range_m")
	assert_eq(ghost.cooldowns[&"dent"], row.cooldown_ticks)
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive(key)  # holding the key changes nothing
		assert_eq(foe.hp, foe.max_hp, "nothing is hit during the wind-up")
	_drive()
	assert_eq(stage.tick, pressed + row.charge_ticks)
	assert_eq(foe.max_hp - foe.hp, _jab())
	assert_eq(ghost.strike.release_tick, stage.tick, "release_tick is the ram tick")
	assert_almost_eq(foe.pos.x, 4.0 + ghost.strike.attacks.num(&"dent", &"jab_knock_m"), 0.05)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp, "Rivet stands on the lane unhurt")
	_drive()
	assert_eq(foe.max_hp - foe.hp, _jab(), "one ram only")


func test_the_lane_is_frozen_at_the_press() -> void:
	var leaves: Fighter = _spawn(Vector2(4, 0))
	var stays: Fighter = _spawn(Vector2(6, 0))
	var new_lane: Fighter = _spawn(Vector2(4, 5))
	_press_and_wind_up()
	var lane: Array[Vector2] = [ghost.origin, ghost.spot]
	leaves.pos = Vector2(4, row.ram_half_m + leaves.radius_m + 0.5)
	arena.rivet.pos = Vector2(0, 5)  # Rivet walking off does not drag the lane
	_drive()
	assert_eq([ghost.origin, ghost.spot], lane)
	assert_eq(leaves.hp, leaves.max_hp, "stepped out during the wind-up")
	assert_lt(stays.hp, stays.max_hp)
	assert_eq(new_lane.hp, new_lane.max_hp, "the lane did not follow Rivet")


func test_the_body_counts_at_ram_half_m_and_not_past_it() -> void:
	arena.rivet.radius_m = 0.0  # an axis-aligned lane from (0, 0) to (range_m, 0)
	row.ram_half_m = 1.0
	var edge_in: Fighter = _spawn(Vector2(4, 1.5))
	var edge_out: Fighter = _spawn(Vector2(5, -1.55))
	var cap_in: Fighter = _spawn(Vector2(row.range_m + 1.5, 0))
	for foe: Fighter in [edge_in, edge_out, cap_in]:
		foe.radius_m = 0.5
	_press_and_wind_up()
	_drive()
	assert_lt(edge_in.hp, edge_in.max_hp, "ram_half_m plus the body radius is inside")
	assert_eq(edge_out.hp, edge_out.max_hp, "+0.05 m is outside")
	assert_lt(cap_in.hp, cap_in.max_hp, "the far end cap counts the body too")


func test_rivet_dying_mid_wind_up_cancels_the_ram() -> void:
	var foe: Fighter = _spawn(Vector2(4, 0))
	_drive(key)
	arena.rivet.hp = 0.0
	for i: int in row.charge_ticks + 2:
		_drive()
	assert_eq(foe.hp, foe.max_hp)
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_true(ghost.cooldowns.has(&"dent"), "the cooldown stays spent")


func test_hold_mode_keeps_the_centre_lane_at_the_release() -> void:
	row.press_mode = &"hold"
	var touching: Fighter = _spawn(Vector2(4, row.ram_half_m + 0.2))
	var inside: Fighter = _spawn(Vector2(6, 0))
	_drive(key)
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	_drive()
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_eq(touching.hp, touching.max_hp, "hold mode counts the centre only")
	assert_lt(inside.hp, inside.max_hp)
	assert_eq(ghost.strike.release_tick, stage.tick)
