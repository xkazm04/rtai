extends GutTest

const GOOD: String = """{"schema": "gtai.arena-station/1", "doc": "t", "lane": "probe",
"stations": [{"id": "probe", "name": "Probe", "area": "pit", "measures": ["hits"],
"props": [{"kind": "cover_low", "at": [1, 2], "size": [2, 1]}],
"spawns": [{"id": "d", "kind": "target", "at": [3, 4], "motion": "strafe",
"speed_mps": 2, "span_m": 4}],
"tuning": [{"key": "combat.weapons.gloria.cooldown_s", "min": 0.1, "max": 1, "step": 0.05}]}]}"""


func test_shipped_stations_load_range_and_course() -> void:
	var s: ArenaStations = ArenaStations.shipped()
	assert_eq(s.errors.size(), 0)
	assert_not_null(s.by_id("range"))
	assert_not_null(s.by_id("course"))
	assert_eq(s.by_id("range").lane, "arena")


func test_a_lane_file_adds_a_station() -> void:
	var s: ArenaStations = ArenaStations.new()
	s.add_text(GOOD, "probe.json")
	var p: ArenaStation = s.by_id("probe")
	assert_not_null(p)
	assert_eq(p.spawns[0].at, Vector2(3, 4))
	assert_eq(p.knobs[0].key, "combat.weapons.gloria.cooldown_s")
	assert_eq(s.in_area("pit").size(), 1)


func test_a_broken_file_is_skipped_not_fatal() -> void:
	var s: ArenaStations = ArenaStations.new()
	s.add_text(GOOD.replace("gtai.arena-station/1", "gtai.wrong/1"), "bad.json")
	assert_eq(s.stations.size(), 0)
	assert_gt(s.errors.size(), 0)


func test_strafe_dummy_stays_inside_its_span() -> void:
	var t: ArenaTargets.Target = ArenaTargets.Target.new()
	var sp: ArenaStation.Spawn = ArenaStation.Spawn.new()
	sp.motion = "strafe"
	sp.speed_mps = 2.0
	sp.span_m = 4.0
	t.spawn = sp
	t.home = Vector2(10, 0)
	for tick: int in range(0, 600, 7):
		var p: Vector2 = ArenaTargets.position(t, tick)
		assert_almost_eq(p.x, 10.0, 0.001)
		assert_true(absf(p.y) <= 2.0001)
