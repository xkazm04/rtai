extends GutTest

var stage: ArenaStage
var arena: CombatArena
var row: MoveTable.Overkill


func before_each() -> void:
	stage = ArenaStage.new(ArenaPlan.new(), ArenaStations.new())
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var rng: RandomNumberGenerator = RngRegistry.new(23).stream(&"combat")
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, rng)
	stage.arena = arena
	arena.squad_ai = ArenaSquad.new(GuardRouteMap.new(Rect2(-15, -15, 30, 30), [], null, 0.45))
	row = arena.squad_ai.moves.overkill_carry


func _foe(x: float, hp: float) -> Fighter:
	var foe: Fighter = Fighter.make(
		Fighter.Kind.GUARD, arena.hostiles.size() + 1, Vector2(x, 2), hp
	)
	arena.hostiles.append(foe)
	return foe


func _uses() -> int:
	var wave: Dictionary = {}
	arena.move_tally.append_wave(wave)
	var moves: Dictionary = wave.get("moves", {})
	return moves.get("overkill_carry", 0)


func test_first_hostile_at_the_nearest_distance_gets_only_the_scaled_remainder() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	var dead: Fighter = _foe(4, 3)
	var far: Fighter = _foe(1, 10)
	var near: Fighter = _foe(6, 10)
	var tied: Fighter = _foe(2, 10)
	dead.damage_k = 0.5
	row.carry_k = 0.5
	arena.hit_dir = Vector2.DOWN
	arena.hit_at = dead.pos
	arena.damage(dead, 14, arena.rivet.id, &"claw")
	assert_eq(near.hp, 8.0)
	assert_eq(near.hurt_dir, Vector2.RIGHT)
	assert_eq(tied.hp, 10.0)
	assert_eq(far.hp, 10.0)
	assert_eq(arena.hit_dir, Vector2.DOWN)
	assert_eq(arena.hit_at, dead.pos)
	assert_eq(dead.hurt_dir, Vector2.DOWN)
	assert_eq(_uses(), 1)


func test_exact_kill_and_out_of_range_have_no_carry() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	var first: Fighter = _foe(0, 3)
	var near: Fighter = _foe(2, 3)
	var far: Fighter = _foe(5.01, 3)
	var last_hurt: int = near.hurt_tick
	arena.damage(first, 3, arena.rivet.id, &"pistol")
	assert_eq(near.hp, 3.0)
	assert_eq(near.hurt_tick, last_hurt)
	arena.damage(near, 30, arena.rivet.id, &"pistol")
	assert_eq(far.hp, 3.0)
	assert_eq(_uses(), 0)


func test_rank_one_at_its_radius_kills_once_in_signal_order() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	var first: Fighter = _foe(4, 2)
	var second: Fighter = _foe(7, 2)
	var third: Fighter = _foe(8, 2)
	var deaths: Array[StringName] = []
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(
		func(v: Fighter, w: StringName, _dir: Vector2, _at: Vector2, _kind: StringName) -> void:
			deaths.append(w)
			assert_true(v.alive())
			if v == second:
				assert_false(first.alive())
	)
	arena.damage(first, 10, arena.rivet.id, &"katana")
	assert_eq(deaths, [&"katana", &"overkill_carry"])
	assert_eq(arena.kills, 2)
	assert_eq(arena.kills_now, 2)
	assert_eq(third.hp, 2.0)
	assert_eq(_uses(), 1)


func test_rank_two_carries_twice_at_four_and_a_half_metres() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	assert_true(MoveCarry.grant(stage, 2))
	var a: Fighter = _foe(0, 2)
	var b: Fighter = _foe(4.5, 3)
	var c: Fighter = _foe(9, 4)
	var d: Fighter = _foe(10, 5)
	arena.damage(a, 12, arena.rivet.id, &"rocket_launcher", &"blown")
	assert_eq(b.hp, 0.0)
	assert_eq(c.hp, 0.0)
	assert_eq(d.hp, 5.0)
	assert_eq(_uses(), 2)


func test_armour_applies_on_both_the_initial_hit_and_the_jump() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	var first: Fighter = _foe(4, 1)
	var second: Fighter = _foe(2, 10)
	first.archetype = &"shield_robot"
	second.archetype = &"shield_robot"
	first.facing = Vector2.UP
	second.facing = Vector2.RIGHT
	arena.hit_dir = Vector2.DOWN
	var front: float = arena.squad_ai.pit.roster.archetype(&"shield_robot").shield_front_mult
	arena.damage(first, 20.0, arena.rivet.id, &"pistol")
	assert_almost_eq(second.hp, 10.0 - (20.0 * front - 1.0) * front, 0.00001)
	assert_eq(second.hurt_dir, Vector2.LEFT)
	assert_eq(_uses(), 1)


func test_each_hop_uses_its_own_remainder_and_multiplier() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	assert_true(MoveCarry.grant(stage, 2))
	row.carry_k = 0.5
	var a: Fighter = _foe(1, 4)
	var b: Fighter = _foe(2, 1)
	var c: Fighter = _foe(3, 10)
	b.damage_k = 0.5
	arena.damage(a, 16, arena.rivet.id, &"claw")
	# A leaves 12. B takes 12 * 0.5 * 0.5 and leaves 2. C takes 2 * 0.5.
	assert_eq(c.hp, 9.0)
	assert_eq(_uses(), 2)


func test_unheld_enemy_ghost_and_disabled_kills_leave_neighbours_untouched() -> void:
	var neighbour: Fighter = _foe(2, 10)
	arena.damage(_foe(1, 1), 6, arena.rivet.id, &"claw")
	assert_true(MoveCarry.grant(stage, 1))
	arena.damage(_foe(1, 1), 6, neighbour.id, &"pistol")
	for ghost: StringName in [OhmStage.WEAPON, &"kerf_slice", &"ram", DentJab.WEAPON]:
		arena.damage(_foe(1, 1), 6, arena.rivet.id, ghost)
	stage.pilot.ghosts.forms.from_id = OhmStage.GHOST
	arena.damage(_foe(1, 1), 6, arena.rivet.id, &"gloria")
	stage.pilot.ghosts.forms.from_id = GhostForms.BASE
	stage.pilot.ghosts.forms.phase = GhostForms.ENTERING
	arena.damage(_foe(1, 1), 6, arena.rivet.id, &"claw")
	stage.pilot.ghosts.forms.phase = GhostForms.SETTLED
	row.enabled = false
	arena.damage(_foe(1, 1), 6, arena.rivet.id, &"pistol")
	assert_eq(neighbour.hp, 10.0)
	assert_eq(_uses(), 0)


func test_a_carried_hit_that_does_no_damage_records_no_use() -> void:
	assert_true(MoveCarry.grant(stage, 1))
	var first: Fighter = _foe(0, 1)
	var second: Fighter = _foe(1, 1)
	second.damage_k = 0.0
	arena.damage(first, 3, arena.rivet.id, PlayerShock.WEAPON)
	assert_eq(second.hp, 1.0)
	assert_eq(_uses(), 0)


func test_rank_is_the_only_carry_state_written_to_the_replay() -> void:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	assert_eq(stage.hooks.size(), 0)
	assert_false(MoveCarry.grant(stage, 2))
	assert_true(MoveCarry.grant(stage, 1))
	var carry: MoveCarry = arena.squad_ai.carry
	carry.write_state(out)
	assert_eq(out.data_array, PackedByteArray([1]))
	var first: Fighter = _foe(0, 1)
	var second: Fighter = _foe(1, 5)
	arena.damage(first, 3, arena.rivet.id, &"gloria")
	assert_eq(second.hp, 3.0)
	carry.write_state(out)
	assert_true(MoveCarry.grant(stage, 2))
	carry.write_state(out)
	row.enabled = false
	carry.write_state(out)
	assert_eq(out.data_array, PackedByteArray([1, 1, 2]))
	assert_eq(stage.hooks.size(), 1)


func test_rank_two_tuning_loads_from_its_own_row() -> void:
	var source: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var raw: Dictionary = source.object(source.object(source.raw, "moves"), "overkill_carry")
	raw["rank_2"] = {"radius_m": 7.25, "hops": 3}
	raw["arc_s"] = 0.25
	var table: MoveTable = MoveTable.from_table(source)
	assert_eq(table.errors, [])
	assert_eq(table.overkill_carry.second.radius_m, 7.25)
	assert_eq(table.overkill_carry.second.hops, 3)
	assert_eq(table.overkill_carry.arc_ticks, 15)
	raw["rank_2"] = {"radius_m": 4.5, "hops": 1.5}
	table = MoveTable.from_table(source)
	assert_false(table.errors.is_empty())
	assert_false(table.overkill_carry.enabled)
