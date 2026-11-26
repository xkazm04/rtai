extends GutTest
## n31 ghost 6: the two edges of Tonnage's drop that the mutants found open: a zero charge and
## the circle's rim (victim radius added, the rim itself is inside).


func _foe(at: Vector2, radius: float) -> Fighter:
	var foe: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, at, 5.0)
	foe.radius_m = radius
	return foe


func test_arm_with_no_charge_lands_on_the_press_tick_and_stays_idle() -> void:
	var dump: TonnageDump = TonnageDump.new()
	assert_true(dump.arm(0), "zero charge: the caller lands the dump now")
	assert_false(dump.pending())
	assert_false(dump.count(), "nothing counts down afterwards")
	assert_false(dump.arm(3))
	assert_true(dump.pending())
	assert_true(dump.arm(-2), "a negative charge is a zero charge")
	assert_false(dump.pending())


func test_arm_with_a_charge_lands_only_on_the_last_counted_tick() -> void:
	var dump: TonnageDump = TonnageDump.new()
	assert_false(dump.arm(2))
	assert_false(dump.count())
	assert_true(dump.count())
	assert_false(dump.pending())


func test_a_row_with_no_charge_hits_on_the_press_tick_itself() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	var arena: CombatArena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	var squad: ArenaSquad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	var pilot: StagePilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	var ghost: GhostDeploy = pilot.ghosts.deploy
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[&"tonnage"]
	row.charge_ticks = 0
	pilot.ghosts.forms.selected = &"tonnage"
	var foe: Fighter = squad.spawn_member(arena, Vector2(3, 0), &"contractor")
	foe.pos = Vector2(3, 0)
	foe.max_hp = 100.0
	foe.hp = 100.0
	stage.tick += 1
	var key: int = 1 << pilot.actions.bit(&"ghost_deploy")
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 4.0)
	pilot.drive(stage, TickInput.new(aim | key))
	assert_false(ghost.dump.pending())
	assert_eq(100.0 - foe.hp, row.dump_damage, "hit on the press tick")
	assert_eq(ghost.strike.release_tick, stage.tick)


func test_a_foe_exactly_on_the_rim_is_hit_and_one_step_beyond_is_not() -> void:
	var spot: Vector2 = Vector2(2, 1)
	var radius: float = 6.5
	var body: float = 0.5
	var on_rim: Fighter = _foe(spot + Vector2(radius + body, 0), body)
	var beyond: Fighter = _foe(spot + Vector2(0, radius + body + 0.05), body)
	var hostiles: Array[Fighter] = [on_rim, beyond]
	var hit: Array[Fighter] = TonnageDump.victims(hostiles, spot, radius)
	assert_eq(hit.size(), 1)
	assert_true(hit.has(on_rim))
	assert_false(hit.has(beyond))


func test_the_dead_are_never_victims() -> void:
	var foe: Fighter = _foe(Vector2.ZERO, 0.5)
	foe.hp = 0.0
	var hostiles: Array[Fighter] = [foe]
	assert_eq(TonnageDump.victims(hostiles, Vector2.ZERO, 6.5).size(), 0)


func test_a_one_tick_charge_is_pending_and_lands_on_the_next_count() -> void:
	var dump: TonnageDump = TonnageDump.new()
	assert_false(dump.arm(1))
	assert_true(dump.pending())
	assert_true(dump.count())
	assert_false(dump.pending())
