extends GutTest

const AT: Vector2 = Vector2(4, 0)
const FRONT: Vector2 = Vector2(-0.8, -0.6)

var stage: ArenaStage
var arena: CombatArena
var squad: ArenaSquad
var kerf: KerfStage


func before_each() -> void:
	stage = ArenaStage.new(ArenaPlan.new(), ArenaStations.new(), ArenaArgs.new())
	var rng: RandomNumberGenerator = RngRegistry.new(23).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	stage.arena = arena
	arena.walls = stage.walls
	arena.guard_map = GuardRouteMap.new(Rect2(-15, -15, 30, 30), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	kerf = KerfStage.shipped()


func _spawn(id: StringName) -> Fighter:
	var h: Fighter = squad.spawn_member(arena, AT, id)
	h.pos = AT
	h.facing = FRONT
	# Let even a full rear slice survive, so damage is observable without overkill clipping.
	h.max_hp = 1000.0
	h.hp = h.max_hp
	return h


func _offset(h: Fighter) -> float:
	return kerf.num(&"behind_m") + h.radius_m


func _uses() -> int:
	var wave: Dictionary = {}
	arena.move_tally.append_wave(wave)
	var moves: Dictionary = wave.get("moves", {})
	return moves.get("kerf_blink_behind", 0)


func _blink(h: Fighter) -> float:
	var hp: float = h.hp
	var aim: Vector2 = arena.rivet.pos.direction_to(h.pos)
	@warning_ignore("return_value_discarded")
	kerf.drive(stage, not kerf.on(), true, aim, Vector2.ZERO)
	return hp - h.hp


func _rear(h: Fighter, multiplier: float) -> void:
	var uses: int = _uses()
	var rear: Vector2 = h.pos - h.facing * _offset(h)
	assert_almost_eq(_blink(h), kerf.num(&"human_damage") * multiplier, 0.00001)
	assert_eq(arena.rivet.pos, rear)
	assert_true(arena.rivet.facing.is_equal_approx(h.facing))
	assert_true(h.hurt_dir.is_equal_approx(h.facing))
	assert_eq(_uses(), uses + 1)


func _legacy(h: Fighter, multiplier: float) -> void:
	var ray: Vector2 = arena.rivet.pos.direction_to(h.pos)
	var landing: Vector2 = stage.walls.push_out(h.pos + ray * _offset(h), arena.rivet.radius_m)
	assert_almost_eq(_blink(h), kerf.num(&"human_damage") * multiplier, 0.00001)
	assert_eq(arena.rivet.pos, landing)
	assert_eq(arena.rivet.facing, landing.direction_to(h.pos))
	assert_eq(h.hurt_dir, ray)
	assert_eq(_uses(), 0)


func test_shield_carrier_takes_the_rear_slice_and_counts_each_landing_once() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	var mate: Fighter = _spawn(&"swat")
	mate.pos = h.pos - h.facing
	_rear(h, 1.0)
	assert_eq(mate.hp, mate.max_hp)
	var row: EnemyRoster.Archetype = squad.pit.roster.archetype(h.archetype)
	assert_eq(squad.shield_cover.multiplier(h, h.facing, arena, row), 1.0)
	for i: int in PowerDef.ticks(kerf.num(&"gap_s")):
		@warning_ignore("return_value_discarded")
		kerf.drive(stage, false, false, Vector2.RIGHT, Vector2.ZERO)
	arena.rivet.pos = Vector2.ZERO
	_rear(h, 1.0)
	assert_eq(_uses(), 2)


func test_optional_path_cut_uses_travel_direction_and_counts_only_the_landing() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	var other: Fighter = _spawn(&"shield_robot")
	var rear: Vector2 = h.pos - h.facing * _offset(h)
	other.pos = rear * 0.5
	other.facing = -rear.normalized()
	kerf.attacks.block(KerfStage.GHOST)["path_cut_m"] = 0.5
	_rear(h, 1.0)
	assert_eq(kerf.slices, 2)
	assert_true(other.hurt_dir.is_equal_approx(rear.normalized()))
	assert_almost_eq(other.max_hp - other.hp, kerf.num(&"human_damage") * 0.2, 0.00001)


func test_sentry_turret_has_a_blocking_front() -> void:
	_rear(_spawn(&"sentry_turret"), 1.0)


func test_blink_from_east_lands_behind_and_faces_the_target() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	arena.rivet.pos = h.pos + Vector2(3, 0)
	h.facing = Vector2.RIGHT
	_rear(h, 1.0)
	assert_eq(arena.rivet.facing, arena.rivet.pos.direction_to(h.pos))


func test_war_machine_takes_its_existing_rear_multiplier() -> void:
	_rear(_spawn(&"war_machine"), 1.5)


func test_open_war_machine_plate_does_not_redirect_the_blink() -> void:
	var h: Fighter = _spawn(&"war_machine")
	squad.mind_for(h).walker.cracked_at = arena.tick
	_legacy(h, 1.0)


func test_ohm_lowered_shield_does_not_redirect_the_blink() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	assert_true(OhmShortCircuit.strike(arena, h, arena.tick, 10))
	_legacy(h, 1.0)


func test_riot_cop_takes_the_ordinary_slice() -> void:
	_legacy(_spawn(&"riot_cop"), 1.0)


func test_unarmoured_target_keeps_the_original_blink() -> void:
	_legacy(_spawn(&"contractor"), 1.0)


func test_target_facing_away_keeps_the_original_blink_even_with_rear_armour() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	h.facing = -FRONT
	squad.pit.roster.archetype(h.archetype).rear_mult = 0.75
	_legacy(h, 0.75)


func test_wall_at_rear_spot_keeps_the_legacy_path_and_front_damage() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	var rear: Vector2 = h.pos - h.facing * _offset(h)
	stage.walls.boxes.append(Rect2(rear - Vector2(0.05, 0.05), Vector2(0.1, 0.1)))
	_legacy(h, 0.2)


func test_rivet_needs_body_clearance_even_when_the_rear_centre_is_free() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	var rear: Vector2 = h.pos - h.facing * _offset(h)
	stage.walls.boxes.append(Rect2(rear + Vector2(0, 0.3), Vector2(0.3, 0.4)))
	assert_false(stage.walls.blocks(arena.rivet.pos, rear))
	_legacy(h, 0.2)


func test_wall_across_only_the_new_blink_line_keeps_the_legacy_path() -> void:
	var h: Fighter = _spawn(&"shield_robot")
	var rear: Vector2 = h.pos - h.facing * _offset(h)
	stage.walls.boxes.append(Rect2(rear * 0.5 - Vector2(0.05, 0.05), Vector2(0.1, 0.1)))
	assert_false(stage.walls.blocks(arena.rivet.pos, h.pos))
	assert_eq(stage.walls.push_out(rear, arena.rivet.radius_m), rear)
	_legacy(h, 0.2)


func test_rear_spot_outside_the_street_boundary_keeps_the_legacy_path() -> void:
	squad.pit.bounds = Rect2(-10, -10, 20, 10.5)
	_legacy(_spawn(&"shield_robot"), 0.2)


func test_disabled_row_keeps_the_legacy_path_against_a_raised_shield() -> void:
	var source: DataTable = DataTable.open(CombatTuning.TABLE, CombatTuning.SCHEMA)
	var row: Dictionary = source.object(source.object(source.raw, "moves"), "kerf_blink_behind")
	row["enabled"] = false
	squad.moves = MoveTable.from_table(source)
	assert_eq(squad.moves.errors, [])
	_legacy(_spawn(&"shield_robot"), 0.2)
