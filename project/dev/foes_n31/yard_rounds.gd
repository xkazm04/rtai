extends SceneTree
## n31 foes: the yard patrol's rounds per distance band (dev-only, never shipped). The prologue bot
## on the default dressing, the same scene and 60 Hz loop as scenario_prologue_pilot, stepped until
## wave one is cleared. A round is a ProloguePanic member's EnemyAgent.shot_tick change; its band is
## Rivet's distance from that officer after the tick. One process runs every seed.
## Usage: node tools/dev/run.mjs yard_rounds --out=<absolute.json> [--seeds=7,3,11,21,42]
##   [--foe-moves=legacy]
## A -s script compiles before the autoloads exist, so the game's classes (which name Log and
## friends) are reached by load() and property names only, never as static types here.

const KNOWN_FLAGS: PackedStringArray = ["--out", "--seeds", "--foe-moves"]
const ENTRY: String = "res://boot/prologue/prologue.tscn"
const PILOT: String = "res://dev/bots/prologue_bot.gd"
const ACTIONS: String = "res://features/player/player_actions.gd"
const BUDGET: int = 300 * 60
const DANGER_M: float = 4.0
const GAP_M: float = 8.8


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var values: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("yard_rounds: unknown argument %s" % arg)
			quit(2)
			return
		values[flag] = arg.substr(flag.length() + 1)
	var out: String = _arg(values, "--out", "")
	if not out.is_absolute_path() or out.get_extension() != "json":
		printerr("yard_rounds: needs --out=<absolute.json>")
		quit(2)
		return
	var rows: Array[Dictionary] = []
	for s: String in _arg(values, "--seeds", "7,3,11,21,42").split(","):
		rows.append(_run_seed(s.to_int(), _arg(values, "--foe-moves", "")))
	var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	if file == null:
		printerr("yard_rounds: cannot write %s" % out)
		quit(1)
		return
	var text: String = JSON.stringify({"schema": "gtai.yard-rounds/1", "runs": rows}, "  ")
	if not file.store_string(text + "\n"):
		printerr("yard_rounds: write failed %s" % out)
	file.close()
	quit(0)


func _arg(values: Dictionary[String, String], flag: String, fallback: String) -> String:
	return values[flag] if values.has(flag) else fallback


func _do(target: Object, method: StringName, args: Array = []) -> Variant:
	return target.callv(method, args)


## The property at a "/"-separated path under `target`.
func _at(target: Object, path: String) -> Variant:
	var value: Variant = target
	for key: String in path.split("/"):
		var holder: Object = value
		value = holder.get(key)
	return value


func _launch(seed_value: int, moves: String) -> void:
	var flags: PackedStringArray = ["--seed=%d" % seed_value]
	if not moves.is_empty():
		@warning_ignore("return_value_discarded")
		flags.append("--foe-moves=" + moves)
	@warning_ignore("return_value_discarded")
	_do(root.get_node(^"LaunchArgs"), &"parse", [flags])


func _run_seed(seed_value: int, moves: String) -> Dictionary:
	_launch(seed_value, moves)
	var game: Node = (load(ENTRY) as PackedScene).instantiate()
	root.add_child(game)
	@warning_ignore("return_value_discarded")
	_do(game, &"boot")
	var world: Node = game.get("world")
	world.set_process(false)
	var loop: Object = _do(world, &"loop")
	var encounter: Object = game.get("encounter")
	var pilot: Object = (load(PILOT) as GDScript).new(game.get("stage"), encounter)
	@warning_ignore("return_value_discarded")
	_do(loop, &"set_input", [pilot])
	var context: Object = _do(world, &"context")
	var clock: Object = context.get("clock")
	var bands: Dictionary[String, int] = {"in_4": 0, "mid": 0, "past_gap": 0}
	var seen: Dictionary[int, int] = {}
	var done: int = encounter.get("done_tick")
	var now: int = 0
	while done < 0 and now < BUDGET:
		@warning_ignore("return_value_discarded")
		_do(loop, &"step")
		_count(game, seen, bands)
		done = encounter.get("done_tick")
		now = _do(clock, &"tick")
	var row: Dictionary = {"seed": seed_value, "foe_moves": moves}
	row.merge(bands)
	row["total"] = bands["in_4"] + bands["mid"] + bands["past_gap"]
	row["cleared_tick"] = done
	row["pistol_rounds"] = _at(encounter, "patrol/squad/pistol_rounds")
	var result: Dictionary = _do(game, &"result")
	row["deaths"] = result["deaths"]
	_release(game)
	return row


## As the scenario does after each seed: free the game, the shipped pad, no launch flags.
func _release(game: Node) -> void:
	@warning_ignore("return_value_discarded")
	_do(game, &"release")
	game.free()
	var actions: Object = _do(load(ACTIONS), &"shipped")
	@warning_ignore("return_value_discarded")
	_do(actions, &"install")
	@warning_ignore("return_value_discarded")
	_do(root.get_node(^"LaunchArgs"), &"parse", [PackedStringArray()])


func _count(game: Node, seen: Dictionary[int, int], bands: Dictionary[String, int]) -> void:
	var rivet: Vector2 = _at(game, "stage/arena/rivet/pos")
	var squad: Object = _at(game, "encounter/patrol/squad")
	var minds: Dictionary = squad.get("minds")
	var members: Dictionary = _at(squad, "panic/members")
	for h: Object in members:
		var id: int = h.get("id")
		if not minds.has(id):
			continue
		var mind: Object = minds[id]
		var at: int = _at(mind, "agent/shot_tick")
		var key: int = h.get_instance_id()
		if seen.has(key) and seen[key] != at:
			var pos: Vector2 = h.get("pos")
			var dist: float = pos.distance_to(rivet)
			var band: String = (
				"in_4" if dist < DANGER_M else ("mid" if dist < GAP_M else "past_gap")
			)
			bands[band] += 1
		seen[key] = at
