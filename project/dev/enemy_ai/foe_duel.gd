extends SceneTree
## node tools/dev/run.mjs foe_duel --enemy=rocket_trooper --seeds=20 --out=<absolute.json>

const KNOWN_FLAGS: PackedStringArray = ["--enemy", "--seeds", "--out", "--player", "--foe-mix"]
const PROFILES: Array[String] = ["perfect", "average", "novice"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var path: String = args.text("--out")
	var seeds: String = args.text("--seeds", "20")
	var profile: String = args.text("--player")
	if args.has("--player") and profile not in PROFILES:
		printerr("foe_duel: --player must be perfect, average or novice")
		quit(2)
		return
	var known: bool = args.values.keys().all(func(key: String) -> bool: return key in KNOWN_FLAGS)
	if not known or not seeds.is_valid_int() or seeds.to_int() < 1 or not path.is_absolute_path():
		printerr("foe_duel needs --enemy=<id> --seeds=<positive integer> --out=<absolute.json>")
		quit(2)
		return
	# Load after autoloads initialize, as for fight_probe.
	var trial: GDScript = load("res://dev/enemy_ai/foe_duel_trial.gd")
	var runner: Object = trial.new()
	var enemy: StringName = runner.get("enemy")
	if enemy == &"" or not runner.call("knows", enemy):
		printerr("foe_duel: unknown enemy ", enemy)
		quit(2)
		return
	_measure(runner, enemy, seeds.to_int(), args)


func _measure(runner: Object, enemy: StringName, seeds: int, args: ArenaArgs) -> void:
	var profile: String = args.text("--player")
	var profiles: Dictionary = {}
	for profile_name: String in PROFILES:
		if profile.is_empty() or profile == profile_name:
			profiles[profile_name] = _profile(runner, enemy, seeds, profile_name)
	var out: Dictionary = {
		"schema": "gtai.foe-duel/2", "enemy": enemy, "tick_hz": 60, "profiles": profiles
	}
	if args.has("--foe-mix"):
		var formation: GDScript = load("res://dev/enemy_ai/foe_duel_formation.gd")
		var mixed: Dictionary = formation.call("run", args.text("--foe-mix"))
		if mixed.is_empty():
			printerr("foe_duel: formation needs at least two known foes")
			quit(2)
			return
		out.formation = mixed
	_write(args.text("--out"), out)


func _write(path: String, out: Dictionary) -> void:
	if DirAccess.make_dir_recursive_absolute(path.get_base_dir()) != OK:
		quit(1)
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null or not file.store_string(JSON.stringify(out, "  ") + "\n"):
		printerr("foe_duel: could not write ", path)
		quit(1)
		return
	quit(0)


func _profile(runner: Object, enemy: StringName, seeds: int, profile: String) -> Dictionary:
	var runs: Array[Dictionary] = []
	var hurt: int = 0
	var damage: float = 0.0
	var dealt: float = 0.0
	var rear: float = 0.0
	var recover: float = 0.0
	var kills: Array[int] = []
	for i: int in seeds:
		var row: Dictionary = runner.call("run", enemy, i + 1, profile)
		runs.append(row)
		var lost: float = row.damage_to_rivet
		hurt += int(lost > 0.0)
		damage += lost
		var actual: float = row.damage_to_enemy
		var behind: float = row.rear_damage
		dealt += actual
		rear += behind
		var during_recover: float = row.recover_damage
		recover += during_recover
		if row.enemy_killed_tick != null:
			kills.append(row.enemy_killed_tick)
	kills.sort()
	var median: Variant = null
	if not kills.is_empty():
		median = 0.5 * (kills[(kills.size() - 1) / 2] + kills[kills.size() / 2])
	return {
		"runs": runs,
		"hurt_share": float(hurt) / seeds,
		"mean_damage": damage / seeds,
		"enemy_killed_share": float(kills.size()) / seeds,
		"median_kill_tick": median,
		"rear_damage_share": rear / dealt if dealt > 0.0 else null,
		"recover_damage_share": recover / dealt if dealt > 0.0 else null
	}
