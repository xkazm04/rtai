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


func _arena() -> CombatArena:
	return CombatArena.new(CombatTuning.shipped(), Events, RngRegistry.new(7).stream(&"combat"))


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
