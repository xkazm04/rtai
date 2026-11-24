extends Node
## Headless, stationary pistol contacts. Each round starts against a fresh guard or timed slash.
## Run with node tools/dev/run.mjs deflect_share -- --out=<absolute directory> [--rounds=1000].

const KNOWN_FLAGS: PackedStringArray = ["--out", "--rounds"]
const SEED: int = 90210
const DISTANCES: Array[int] = [4, 6, 8, 12, 20]
const SPREADS: Array[int] = [12, 20]

var _gun: EnemyWeapon = EnemyRoster.shipped().weapons[&"pistol"]
var _blade: MeleeTable = MeleeTable.weapon(&"plasma_sword")
var _meter: GuardTuning = GuardTuning.load_table()
var _n: int


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var directory: String = args.text("--out")
	var count: String = args.text("--rounds", "1000")
	if not directory.is_absolute_path() or not count.is_valid_int() or count.to_int() < 300:
		Log.error("deflect-share", "Expected --out=<absolute directory> and at least 300 rounds")
		get_tree().quit(2)
		return
	_n = count.to_int()
	var rows: Array[Dictionary] = []
	for distance: int in DISTANCES:
		for spread: int in SPREADS:
			for mode: String in ["guard", "bat"]:
				var row: Dictionary = _measure(distance, spread, mode)
				if row.is_empty():
					get_tree().quit(1)
					return
				rows.append(row)
	get_tree().quit(0 if _save(directory, rows) else 1)


func _measure(distance: int, spread: int, mode: String) -> Dictionary:
	var reg: RngRegistry = RngRegistry.new(SEED)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), Events, reg.stream(&"combat"))
	DeflectRule.bind(arena, reg)
	DeflectRule.of(arena).spread_deg = spread
	var foe: Fighter = arena.spawn_guard(Vector2.RIGHT * distance)
	foe.pos = Vector2.RIGHT * distance
	foe.facing = Vector2.LEFT
	arena.rivet.facing = Vector2.RIGHT
	# Accumulate real HP deltas without killing either participant or invoking repair.
	foe.hp = float(_n + 1)
	arena.rivet.hp = _gun.damage * float(_n + 1)
	var passed: int = 0
	var hits: int = 0
	for i: int in _n:
		var before: Vector2 = Vector2(arena.rivet.hp, foe.hp)
		var s: Shot = FoeAttacks.round_from(foe, _gun)
		arena.shots.append(s)
		_flight(arena, s, mode)
		var through: bool = arena.rivet.hp < before.x
		if (
			not arena.shots.is_empty()
			or s.from_rivet == through
			or s.has_meta(PlayerDeflect.PASSED) != through
		):
			Log.error(
				"deflect-share", "Unresolved pistol round %d at %d m (%s)" % [i, distance, mode]
			)
			return {}
		passed += int(through)
		hits += int(foe.hp < before.y)
	return _row(mode, distance, spread, passed, hits)


func _row(mode: String, distance: int, spread: int, passed: int, hits: int) -> Dictionary:
	var back: int = _n - passed
	return {
		"mode": mode,
		"distance_m": distance,
		"spread_deg": spread,
		"rounds": _n,
		"passed": passed,
		"returned": back,
		"shooter_hits": hits,
		"pass_share": float(passed) / _n,
		"return_share": float(back) / _n,
		"shooter_share_of_returns": float(hits) / back if back > 0 else null,
	}


func _flight(arena: CombatArena, s: Shot, mode: String) -> void:
	var blade: PlayerMelee
	if mode == "guard":
		arena.guard = PlayerGuard.new(_meter)
		arena.guard.step(true, true)
	else:
		blade = PlayerMelee.new(_blade)
	# Start winding up so the first active tick meets the round at the outer edge of bat reach.
	var stride: float = s.vel.length() * SimClock.TICK_DT
	var contact_tick: int = ceili((s.pos.x - _blade.deflect_m) / stride)
	var press_tick: int = contact_tick - _blade.hits[0].windup + 1
	for t: int in 240:
		arena.tick += 1
		if blade != null:
			@warning_ignore("return_value_discarded")
			blade.step(arena, t == press_tick, Vector2.RIGHT)
		ArenaProjectiles.step_shots(arena)
		if arena.shots.is_empty():
			return


func _save(directory: String, rows: Array[Dictionary]) -> bool:
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return false
	var report: Dictionary = {
		"schema": "gtai.deflect-share/1",
		"seed": SEED,
		"rounds_per_cell": _n,
		"weapon": "pistol",
		"shooter_radius_m": CombatTuning.shipped().human.radius_m,
		"trials": rows,
	}
	return (
		_write(directory.path_join("share.json"), JSON.stringify(report, "  ", true, true) + "\n")
		and _write(directory.path_join("share.md"), _markdown(rows))
	)


func _markdown(rows: Array[Dictionary]) -> String:
	var header: Array[String] = ["Distance (m)"]
	for r: Dictionary in rows:
		if r.distance_m == DISTANCES[0]:
			var mode: String = "Guard" if r.mode == "guard" else "Plasma bat"
			header.append("%s %d°" % [mode, r.spread_deg])
	var lines: Array[String] = [
		"Seed %d restarts for each cell of %d aimed pistol rounds." % [SEED, _n],
		"Each cell shows shooter hits / returned rounds at the stated centre-to-centre distance.",
		"",
		"| %s |" % " | ".join(header),
		"|" + "---:|".repeat(header.size()),
	]
	for distance: int in DISTANCES:
		var cells: Array[String] = [str(distance)]
		for r: Dictionary in rows:
			if r.distance_m == distance:
				var share: String = "n/a"
				if r.returned > 0:
					share = "%.1f%%" % (r.shooter_share_of_returns * 100)
				cells.append("%d/%d (%s)" % [r.shooter_hits, r.returned, share])
		lines.append("| %s |" % " | ".join(cells))
	return "\n".join(lines) + "\n"


func _write(path: String, contents: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(contents):
		Log.error("deflect-share", "Could not write %s" % path)
		return false
	file.close()
	return true
