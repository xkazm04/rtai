extends Node
## n18 police item 7: what living police cost per tick in the sandbox city. The real World +
## CitySystem (native when built) + CityHeat, no view, headless; at tick HEAT_AT the heat is forced
## at A as a witnessed kill does (heat_clip's plan), Rivet goes 60 m off; from FROM on every tick's
## sim step (CitySystem.stats_us[2]) and CityHeat step (CityHeat.cost_us) are recorded.
## --police=pre: the pre-n18 sim police (set_heat -1, the same patrol). Writes <out>.json:
## mean / p50 / p99 / max us per tick for both, the cop and car counts at the end.
## Usage: godot --headless --path project --fixed-fps 60 res://dev/sim/heat_cost.tscn --
##   --out=<abs path, no ext> [--police=living|pre] [--level=3] [--ticks=1800] [--peds=270]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--police", "--level", "--ticks", "--peds"]
const MASTER_SEED: int = 18
const A: Vector2 = CitySystem.START
const B: Vector2 = CitySystem.START + Vector2(4.0, 60.0)
const HEAT_AT: int = 180
const FROM: int = 600

var _out: String = ""
var _living: bool = true
var _level: int = 3
var _ticks: int = 1800
var _peds: int = 270
var _world: World = null
var _city: CitySystem = null
var _heat: CityHeat = null
var _sim: PackedInt64Array = PackedInt64Array()
var _pol: PackedInt64Array = PackedInt64Array()
var _last_sim: int = 0
var _last_pol: int = 0


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	_city = CitySystem.new(true)
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = A
	_city.target = A
	_city.spawner.targets = CityTargets.street(_peds, 120, 10)
	_heat = CityHeat.new(_city)
	_world.add_system(_heat)
	_heat.tune.living = _living
	add_child(_world)


func _process(_delta: float) -> void:
	var tick: int = _world.context().clock.tick()
	if tick == HEAT_AT:
		_heat.last_seen = A
		_heat.ever_seen = true
		_heat.meter.set_level(_level)
		_city.target = B
	if tick > FROM:
		@warning_ignore("return_value_discarded")
		_sim.append(_city.stats_us[2] - _last_sim)
		@warning_ignore("return_value_discarded")
		_pol.append(_heat.cost_us - _last_pol)
	_last_sim = _city.stats_us[2]
	_last_pol = _heat.cost_us
	if tick >= FROM + _ticks:
		_finish()


func _finish() -> void:
	var c: PackedInt32Array = _city.sim.get_counters()
	var out: Dictionary = {
		"schema": "gtai.heat-cost/1",
		"police": "living" if _living else "pre",
		"level": _level,
		"peds_target": _peds,
		"ticks": _sim.size(),
		"backend": "native" if _city.sim is CitySimNative else "reference",
		"sim_us": _stats(_sim),
		"heat_us": _stats(_pol),
		"cops": c[SimConst.CN_COPS],
		"engaged": _city.sim.flow_stats()[SimConst.FS_ENGAGED],
	}
	var f: FileAccess = FileAccess.open(_out + ".json", FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify(out, " "))
	Log.info("heat_cost", JSON.stringify(out))
	set_process(false)
	get_tree().quit(0 if ok else 1)


static func _stats(a: PackedInt64Array) -> Dictionary:
	var s: PackedInt64Array = a.duplicate()
	s.sort()
	var n: int = s.size()
	var sum: int = 0
	for v: int in s:
		sum += v
	if n == 0:
		return {}
	return {
		"mean": float(sum) / float(n),
		"p50": s[n / 2],
		"p99": s[mini(n - 1, n * 99 / 100)],
		"max": s[n - 1],
	}


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		var v: String = arg.substr(flag.length() + 1)
		match flag:
			"--out":
				_out = v
			"--police":
				_living = v != "pre"
			"--level":
				_level = clampi(v.to_int(), 0, 3)
			"--ticks":
				_ticks = maxi(60, v.to_int())
			"--peds":
				_peds = maxi(0, v.to_int())
			_:
				printerr("heat_cost: unknown argument %s" % arg)
				return false
	if _out == "":
		printerr("heat_cost: needs --out=<abs path, no ext>")
		return false
	return true
