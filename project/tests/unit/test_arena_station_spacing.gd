extends GutTest

const STATIONS: String = '{"schema":"gtai.arena-station/1","lane":"arena","stations":[]}'
const AT: Vector2 = Vector2(4.0, 2.0)


func _spacing(city: Dictionary, on_city: bool = true) -> float:
	var data: Dictionary = JSON.parse_string(STATIONS)
	data["city"] = city
	var stations: ArenaStations = ArenaStations.new()
	stations.add_text(JSON.stringify(data), "arena.json", on_city)
	assert_eq(stations.errors.size(), 0)
	return stations.station_spacing_m


func _arena(boxes: Array[Rect2] = []) -> CombatArena:
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(7).stream(&"combat")
	)
	arena.guard_map = GuardRouteMap.new(Rect2(-16, -16, 32, 32), boxes, null, 0.45)
	return arena


func _guard(arena: CombatArena, spacing: float = 0.0) -> Fighter:
	var fighter: Fighter = arena.spawn_guard(AT)
	fighter.pos = AT
	fighter.station_spacing_m = spacing
	return fighter


func test_coincident_partners_separate_on_the_guard_path() -> void:
	var arena: CombatArena = _arena()
	var spacing: float = _spacing({"station_spacing_m": 1.65})
	var first: Fighter = _guard(arena, spacing)
	var second: Fighter = _guard(arena, spacing)
	arena.step(0)
	assert_almost_eq(first.pos.x, AT.x - spacing, 0.00001)
	assert_almost_eq(first.pos.distance_to(second.pos), spacing, 0.00001)
	first.pos = AT
	second.pos = AT
	arena.hostiles.reverse()
	arena.step(1)
	assert_almost_eq(second.pos.x, AT.x + spacing, 0.00001)
	assert_almost_eq(first.pos.distance_to(second.pos), spacing, 0.00001)


func test_missing_setting_and_noncity_ignore_spacing() -> void:
	for spacing: float in [_spacing({}), _spacing({"station_spacing_m": 1.65}, false)]:
		var arena: CombatArena = _arena()
		var first: Fighter = _guard(arena, spacing)
		var second: Fighter = _guard(arena, spacing)
		arena.step(0)
		assert_eq(first.pos, AT)
		assert_eq(second.pos, AT)


func test_partner_yields_to_live_wave_body_and_ignores_dead_guards() -> void:
	var arena: CombatArena = _arena()
	var partner: Fighter = _guard(arena, 1.5)
	var wave: Fighter = _guard(arena)
	wave.pos += Vector2(0, 0.5)
	var dead: Fighter = _guard(arena)
	dead.hp = 0.0
	dead.pos = AT + Vector2.UP
	arena.step(0)
	assert_eq(partner.pos, AT + Vector2.UP)
	assert_eq(wave.pos, AT + Vector2(0, 0.5))
	assert_eq(dead.pos, AT + Vector2.UP)


func test_push_into_wall_stops_the_body_at_its_near_face() -> void:
	var wall: Rect2 = Rect2(1, 1, 2.25, 2)
	var arena: CombatArena = _arena([wall])
	var partner: Fighter = _guard(arena, 1.65)
	var neighbour: Fighter = _guard(arena)
	GuardBrain.space_partner(partner, arena.hostiles)
	assert_eq(neighbour.pos, AT)
	assert_false(wall.has_point(partner.pos))
	assert_almost_eq(partner.pos.x, wall.end.x + partner.radius_m, 0.00001)


func test_push_cannot_cross_a_thin_wall_to_an_open_endpoint() -> void:
	var wall: Rect2 = Rect2(3, 1, 0.1, 2)
	var arena: CombatArena = _arena([wall])
	var partner: Fighter = _guard(arena, 1.65)
	var neighbour: Fighter = _guard(arena)
	GuardBrain.space_partner(partner, arena.hostiles)
	assert_eq(neighbour.pos, AT)
	assert_gte(partner.pos.x, wall.end.x + partner.radius_m)


func test_partner_without_pursuit_holds_position() -> void:
	var arena: CombatArena = _arena()
	arena.guard_map = null
	var partner: Fighter = _guard(arena, 1.65)
	var neighbour: Fighter = _guard(arena)
	GuardBrain.space_partner(partner, arena.hostiles)
	assert_eq(neighbour.pos, AT)
	assert_eq(partner.pos, AT)
