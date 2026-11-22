extends GutTest

const WEAPON: StringName = &"test_hostile_blast"
const RADIUS: float = 4.0
const DAMAGE: float = 20.0

var arena: CombatArena


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(22).stream(&"combat"))
	arena.rivet.radius_m = 0.5
	arena.rivet.hp = 100.0
	EnemyRounds.override_for_test(WEAPON, Shot.LARGE, RADIUS, DAMAGE)


func after_each() -> void:
	EnemyRounds.reset()


func test_damage_falls_linearly_from_the_edge_of_rivets_body() -> void:
	for offset: float in [0.0, 0.25, 0.5, 1.5, 2.5, 4.5, 5.0]:
		var hp: float = arena.rivet.hp
		var wanted: float = DAMAGE * clampf(1.0 - (offset - 0.5) / RADIUS, 0.0, 1.0)
		var at: Vector2 = arena.rivet.pos + Vector2.RIGHT * offset
		assert_eq(RivetBlast.burst(arena, at, WEAPON, 8), wanted)
		assert_eq(arena.rivet.hp, hp - wanted)
		assert_eq(arena.areas.blasts[-1], Vector3(at.x, at.y, RADIUS))
		assert_eq(arena.areas.blast_ticks[-1], arena.tick)


func test_high_solids_block_on_the_far_side_of_either_face() -> void:
	for kind: String in ["wall_high", "cover_high"]:
		var prop: ArenaStation.Prop = ArenaStation.Prop.new()
		prop.kind = kind
		prop.size = Vector2(1.0, 3.0)
		var station: ArenaStation = ArenaStation.new()
		station.props.append(prop)
		var stations: ArenaStations = ArenaStations.new()
		stations.stations.append(station)
		arena.walls = ArenaWalls.from_stations(stations, Vector2(7.0, 5.0))
		assert_eq(arena.walls.kinds, [kind])
		for dir: Vector2 in [Vector2.RIGHT, Vector2.LEFT]:
			var center: Vector2 = Vector2(7.0, 5.0)
			arena.rivet.pos = center + dir * 1.5
			var far_face: Vector2 = center - dir * 0.5
			assert_eq(RivetBlast.burst(arena, far_face - dir, WEAPON, 8), 0.0)
			assert_eq(RivetBlast.burst(arena, far_face, WEAPON, 8), 0.0)
			assert_gt(RivetBlast.burst(arena, center + dir * 0.5, WEAPON, 8), 0.0)
	assert_eq(arena.areas.blasts.size(), 12, "even a shielded blast leaves its ring")


func test_wall_face_blocks_a_diagonal_that_exits_close_to_the_corner() -> void:
	arena.walls = ArenaWalls.new()
	arena.walls.boxes.append(Rect2(0, 0, 1, 1))
	arena.walls.kinds.append("wall_high")
	arena.rivet.pos = Vector2(1, -1)
	var at: Vector2 = Vector2(0, 0.001)
	assert_eq(RivetBlast.burst(arena, at, WEAPON, 8), 0.0)
	arena.rivet.pos = Vector2(-1, -1)
	assert_gt(RivetBlast.burst(arena, at, WEAPON, 8), 0.0)


func test_blast_inside_a_prop_ignores_only_that_prop() -> void:
	arena.walls = ArenaWalls.new()
	arena.walls.boxes.append(Rect2(-1, -1, 2, 2))
	arena.walls.kinds.append("wall_high")
	arena.rivet.pos = Vector2(3, 0)
	assert_gt(RivetBlast.burst(arena, Vector2.ZERO, WEAPON, 8), 0.0)
	arena.walls.boxes.append(Rect2(1.5, -1, 0.25, 2))
	arena.walls.kinds.append("cover_high")
	assert_eq(RivetBlast.burst(arena, Vector2.ZERO, WEAPON, 8), 0.0)


func test_low_station_cover_stops_blast_only_while_in_stance() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	var cover: PlayerCover = stage.pilot.motion.cover
	cover.enabled = true
	stage.arena.rivet.pos = Vector2(4, 11.65)
	stage.step(stage.tick + 1, TickInput.new(1 << stage.pilot.actions.bit(&"cover")))
	assert_not_null(cover.spot)
	if cover.spot == null:
		return
	assert_true(cover.spot.low)
	assert_same(stage.arena.walls, stage.walls)
	var box: Rect2 = cover.spot.box
	var n: Vector2 = cover.spot.normal
	var at: Vector2 = box.get_center() - n * (0.5 * box.size.dot(n.abs()) + 0.25)
	assert_eq(RivetBlast.burst(stage.arena, at, WEAPON, 8), 0.0)
	cover.interrupt()
	assert_gt(RivetBlast.burst(stage.arena, at, WEAPON, 8), 0.0)


func test_roll_and_tonnage_apply_through_arena_damage() -> void:
	var at: Vector2 = arena.rivet.pos + Vector2.LEFT * 2.5
	watch_signals(arena)
	arena.rivet.exposed = false
	assert_eq(RivetBlast.burst(arena, at, WEAPON, 8), 0.0)
	assert_eq(arena.rivet.hp, 100.0)
	assert_signal_not_emitted(arena, "struck")
	arena.rivet.exposed = true
	arena.rivet.damage_k = 0.3
	arena.tick = 27
	arena.struck_charged = true
	assert_almost_eq(RivetBlast.burst(arena, at, WEAPON, 8), 3.0, 0.00001)
	assert_almost_eq(arena.rivet.hp, 97.0, 0.00001)
	assert_eq(arena.rivet.hurt_tick, 27)
	assert_eq(arena.rivet.hurt_dir, Vector2.RIGHT)
	assert_eq(arena.hit_at, arena.rivet.pos + Vector2.LEFT * 0.5)
	assert_false(arena.struck_charged)
	assert_eq(arena.areas.blast_ticks[-1], 27)
	assert_signal_emit_count(arena, "struck", 1)


func test_zero_radius_and_zero_damage_do_not_wound() -> void:
	assert_eq(RivetBlast.burst(arena, Vector2.ZERO, &"pistol", 8), 0.0)
	assert_null(arena.areas)
	EnemyRounds.override_for_test(WEAPON, Shot.LARGE, RADIUS, 0.0)
	var hurt_tick: int = arena.rivet.hurt_tick
	assert_eq(RivetBlast.burst(arena, Vector2.ZERO, WEAPON, 8), 0.0)
	assert_eq(arena.rivet.hurt_tick, hurt_tick)
	assert_eq(arena.areas.blasts.size(), 1)


func test_burst_reports_remaining_hp_on_lethal_damage_and_spares_hostiles() -> void:
	var other: Fighter = arena.spawn_guard(arena.rivet.pos)
	var hp: float = other.hp
	arena.rivet.hp = 1.25
	watch_signals(arena)
	assert_eq(RivetBlast.burst(arena, arena.rivet.pos, WEAPON, other.id), 1.25)
	assert_eq(arena.rivet.hp, 0.0)
	assert_eq(other.hp, hp)
	assert_signal_emitted_with_parameters(
		arena, "struck", [arena.rivet, Vector2.ZERO, true, WEAPON]
	)
	assert_eq(RivetBlast.burst(arena, arena.rivet.pos, WEAPON, other.id), 0.0)
	assert_signal_emit_count(arena, "struck", 1)


func test_a_grazing_blast_signals_even_a_fractional_hp_hit() -> void:
	# At 0.125 m inside the blast edge Rivet takes 0.625 hp.
	var at: Vector2 = Vector2.LEFT * (arena.rivet.radius_m + RADIUS - 0.125)
	watch_signals(arena)
	assert_eq(RivetBlast.burst(arena, at, WEAPON, 8), 0.625)
	assert_signal_emitted_with_parameters(
		arena, "struck", [arena.rivet, Vector2.RIGHT, false, WEAPON]
	)


func test_rivets_own_rocket_can_land_at_his_feet() -> void:
	arena.areas = FightAreas.new()
	var rocket: Shot = Shot.new()
	rocket.spec = WeaponTable.shipped().weapon(&"rocket_launcher")
	arena.areas.land(arena, rocket, null, arena.rivet.pos)
	assert_almost_eq(arena.rivet.hp, 78.0, 0.00001)
	assert_eq(arena.areas.blasts.size(), 1)
