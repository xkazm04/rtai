extends SceneTree
## features/bodies cost: the native sim stepping a 300-person riot (the bench's riot targets)
## with Rivet's body sprinting circles through it, against the same run with the body off.
## Headless, CPU only; the numbers are per sim step (ms). Usage:
##   godot --headless --path project -s res://dev/bench/bodies_cost.gd -- --out=<file.json>

const RIOT: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const STEPS: int = 1800


func _initialize() -> void:
	var out: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.substr(6)
	var off: Dictionary = _run(false)
	var on: Dictionary = _run(true)
	var r: Dictionary = {
		"backend": off["backend"], "body_off": off, "body_on": on, "label": "CONTENDED"
	}
	printerr("bodies_cost: %s" % JSON.stringify(r))
	if out != "":
		var f: FileAccess = FileAccess.open(out, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(JSON.stringify(r, "  ") + "\n")
			f.close()
	quit(0)


func _run(body_on: bool) -> Dictionary:
	var sim: CitySimBackend = CitySimNative.best()
	sim.init(11)
	sim.set_radii(80.0, 160.0, 14.0)
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	var res: CityResidency = CityResidency.new(ChunkSource.new(gen), sim, SimConst.CITY_CHUNKS)
	res.update(RIOT)
	var sp: CitySpawner = CitySpawner.new(sim, res, RngRegistry.new(11).stream(&"city_spawn"))
	sp.targets = CityTargets.riot(300, 100)
	sp.riot_c = RIOT
	@warning_ignore("return_value_discarded")
	sp.tick(RIOT, true)
	var body: RivetBody = RivetBody.new(BodyTable.load_default(), RIOT + Vector2(6, 0))
	body.on = body_on
	var ms: PackedFloat64Array = PackedFloat64Array()
	var knocks: int = 0
	for st: int in STEPS:
		var a: float = st * SimClock.TICK_DT * 0.8
		sim.set_body(body.spec(RIOT + Vector2(cos(a), sin(a)) * 6.0))
		var t0: int = Time.get_ticks_usec()
		sim.step(SimClock.TICK_DT, RIOT.x, RIOT.y, body.pos.x, body.pos.y)
		@warning_ignore("return_value_discarded")
		ms.append((Time.get_ticks_usec() - t0) / 1000.0)
		body.take(sim.body_result())
		@warning_ignore("integer_division")
		knocks += body.knocks.size() / SimConst.BR_STRIDE
		@warning_ignore("return_value_discarded")
		sp.tick(RIOT, false)
	ms.sort()
	return {
		"backend": String(sim.backend_name()),
		"p50_ms": ms[STEPS / 2],
		"p99_ms": ms[int(STEPS * 0.99)],
		"max_ms": ms[STEPS - 1],
		"knockdowns": knocks,
		"tier_a": sim.get_counters()[SimConst.CN_TIER_A],
	}
