extends Node
## Headless microbenchmark of the real guard approach in the shipped city arena. Stage collision
## still runs after each tick. Its unchanged cost is outside the timed section.

const KNOWN_FLAGS: PackedStringArray = ["--out"]
const COUNT: int = 400
const TICKS: int = 360


func _ready() -> void:
	var rows: Array[Dictionary] = []
	for round_index: int in 3:
		for wall: bool in [false, true]:
			for arm: int in 2:
				var world: World = World.new()
				var stage: ArenaStage = _street(world)
				var routed: bool = (round_index + arm) % 2 == 1
				rows.append(_measure(stage, wall, routed))
				world.free()
	var result: Dictionary = {"actors": COUNT, "ticks": TICKS, "timing": "CONTENDED", "rows": rows}
	var out: String = ArenaArgs.parse().text("--out")
	var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if f == null:
		Log.error("guard_cost", "could not open output " + out)
		get_tree().quit(1)
		return
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(result, "  ") + "\n")
	f.close()
	get_tree().quit()


func _street(world: World) -> ArenaStage:
	var plan: ArenaPlan = ArenaPlan.shipped()
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	var stage: ArenaStage = ArenaStage.new(ArenaPlan.shipped(plan.city_base), stations)
	stage.cells = StageCells.shipped()
	world.start(Events, Data, 20261109)
	world.add_system(stage)
	return stage


func _measure(stage: ArenaStage, wall: bool, routed: bool) -> Dictionary:
	var arena: CombatArena = stage.arena
	var base: Vector2 = stage.plan.base
	var target: Vector2 = base + (Vector2(12, 11) if wall else Vector2(20, 0))
	arena.hostiles.clear()
	for i: int in COUNT:
		var spread: Vector2 = Vector2((i % 20) * 0.12, (i / 20) * 0.05)
		var start: Vector2 = base + spread + (Vector2(10, 3) if wall else Vector2.ZERO)
		var g: Fighter = arena.spawn_guard(start)
		g.pos = start
		if not routed:
			g.pursuit = null
	var times: Array[int] = []
	var total_us: int = 0
	var peak: int = 0
	var initial: int = arena.guard_map.searches
	for tick: int in TICKS:
		var searches: int = arena.guard_map.searches
		var start_us: int = Time.get_ticks_usec()
		for g: Fighter in arena.hostiles:
			@warning_ignore("return_value_discarded")
			GuardBrain.approach(g, target, arena.tuning)
		var elapsed: int = Time.get_ticks_usec() - start_us
		total_us += elapsed
		times.append(elapsed)
		peak = maxi(peak, arena.guard_map.searches - searches)
		stage._collide_hostiles()
	times.sort()
	return {
		"wall": wall,
		"routes": routed,
		"searches": arena.guard_map.searches - initial,
		"peak_searches_in_tick": peak,
		"us_per_guard_tick": float(total_us) / (COUNT * TICKS),
		"batch_p99_us": times[ceili(TICKS * 0.99) - 1],
		"batch_max_us": times.back()
	}
