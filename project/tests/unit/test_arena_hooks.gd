extends GutTest
## A station's `script` names an ArenaHook a lane ships in its own folder; the arena stage builds
## it, steps it every tick and folds its state and telemetry in. A bad path is dropped, logged.

const HOOK: String = "res://features/arena/arena_tick_hook.gd"
const HOOKED: String = """{"schema": "gtai.arena-station/1", "doc": "t", "lane": "enemy-ai",
"stations": [{"id": "probe_hook", "name": "Probe hook", "area": "pit", "doc": "hook only",
"script": "%s"}]}"""


func test_a_hook_only_station_loads_without_lists() -> void:
	var s: ArenaStations = ArenaStations.new()
	s.add_text(HOOKED % HOOK, "enemy-ai.json")
	assert_eq(s.errors.size(), 0)
	var p: ArenaStation = s.by_id("probe_hook")
	assert_not_null(p)
	assert_eq(p.script_path, HOOK)
	assert_eq(p.lane, "enemy-ai")
	assert_eq(p.spawns.size(), 0)


func test_make_builds_the_named_hook() -> void:
	var s: ArenaStations = ArenaStations.new()
	s.add_text(HOOKED % HOOK, "enemy-ai.json")
	var hook: ArenaHook = ArenaHook.make(s.by_id("probe_hook"))
	assert_true(hook is ArenaTickHook)
	assert_eq(hook.station.id, "probe_hook")


func test_bad_hook_paths_are_dropped() -> void:
	for path: String in [
		"res://tests/unit/test_arena_hooks.gd",
		"res://features/arena/missing_hook.gd",
		"res://features/arena/arena_plan.gd",
	]:
		var st: ArenaStation = ArenaStation.new()
		st.id = "bad"
		st.script_path = path
		assert_null(ArenaHook.make(st), path)


func test_the_stage_steps_and_reports_its_hooks() -> void:
	var stations: ArenaStations = ArenaStations.shipped()
	stations.add_text(HOOKED % HOOK, "zz-probe.json")
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var world: World = World.new()
	world.start(bus, data, 7)
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(), stations)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	world.add_system(stage)
	for i: int in 30:
		world.loop().step()
	var hook: ArenaTickHook = null
	for h: ArenaHook in stage.hooks:  # shipped stations may carry hooks too (lane brutality)
		if h is ArenaTickHook:
			hook = h as ArenaTickHook
	assert_not_null(hook)
	assert_true(hook.set_up)
	assert_eq(hook.ticks, 30)
	var tel: Dictionary = stage.telemetry_dict()
	var extra: Dictionary = tel.get("probe_hook", {})
	var ticks: int = extra.get("ticks", -1)
	assert_eq(ticks, 30)
	world.free()
	bus.free()
	data.free()


func test_metal_dummies_are_the_arenas_metal() -> void:
	# the arena's own file only: other lanes' station files (metal dummies, pit enemies) ship beside it
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	var metal: String = """{"schema": "gtai.arena-station/1", "doc": "t", "lane": "probe",
"stations": [{"id": "metal_line", "name": "Metal", "area": "hub", "spawns": [
{"id": "m1", "kind": "metal", "at": [2, 3], "motion": "static", "speed_mps": 0, "span_m": 0}]}]}"""
	stations.add_text(metal, "zz-metal.json")
	assert_eq(stations.errors.size(), 0)
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	var world: World = World.new()
	world.start(bus, data, 7)
	var plan: ArenaPlan = ArenaPlan.shipped()
	var stage: ArenaStage = ArenaStage.new(plan, stations)
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	world.add_system(stage)
	world.loop().step()
	assert_eq(stage.arena.metal.size(), 1)
	assert_eq(stage.arena.metal[0], plan.base + Vector2(2, 3))
	world.free()
	bus.free()
	data.free()
