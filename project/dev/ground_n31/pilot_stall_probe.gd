extends Node
## n31-23: the prologue pilot (as scenario_prologue_pilot runs it: boot, the bot as input, no
## render) with a position log every 30 ticks: Rivet, every live foe, and the solid box nearest
## Rivet (index into arena.walls.boxes, kind, gap from his edge). --seed=<n> (default 7),
## --result=<abs dir> gets pilot_ticks.jsonl and walls.json.

const KNOWN_FLAGS: PackedStringArray = ["--result", "--seed"]
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const EVERY: int = 30
const BUDGET: int = 300 * SimClock.TICK_RATE

var _log: FileAccess


func _ready() -> void:
	var out: String = LaunchArgs.value("--result")
	var seed_text: String = LaunchArgs.value("--seed")
	if out.is_empty():
		Log.error("pilot-stall", "use --result=<abs dir>")
		get_tree().quit(2)
		return
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(out)
	LaunchArgs.parse(["--seed=" + ("7" if seed_text.is_empty() else seed_text)])
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child(game)
	game.boot()
	game.world.set_process(false)
	var loop: SimLoop = game.world.loop()
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	loop.set_input(pilot)
	_walls(game.stage.arena.walls, out.path_join("walls.json"))
	_log = FileAccess.open(out.path_join("pilot_ticks.jsonl"), FileAccess.WRITE)
	while game.encounter.street.end_tick < 0 and game.world.context().clock.tick() < BUDGET:
		loop.step()
		if game.stage.tick % EVERY == 0:
			_write(game)
	var result: Dictionary = game.result()
	var sha: String = (JSON.stringify(result, "  ", true) + "\n").sha256_text()
	Log.info(
		"pilot-stall", "end ticks %s ended %s sha %s" % [result["ticks"], result["ended"], sha]
	)
	_log.close()
	get_tree().quit(0)


func _walls(walls: ArenaWalls, path: String) -> void:
	var rows: Array[Dictionary] = []
	for i: int in walls.boxes.size():
		var box: Rect2 = walls.boxes[i]
		rows.append(
			{
				"i": i,
				"kind": walls.kinds[i],
				"rect": [box.position.x, box.position.y, box.size.x, box.size.y]
			}
		)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	file.store_string(JSON.stringify(rows))
	file.close()


func _write(game: PrologueGame) -> void:
	var arena: CombatArena = game.stage.arena
	var rivet: Fighter = arena.rivet
	var foes: Array[Array] = []
	for h: Fighter in arena.hostiles:
		if h.alive():
			foes.append(
				[h.id, str(h.archetype), snappedf(h.pos.x, 0.01), snappedf(h.pos.y, 0.01), h.hp]
			)
	var row: Dictionary = {
		"t": game.stage.tick,
		"ph": game.encounter.phase,
		"st": game.encounter.street.phase,
		"r": [snappedf(rivet.pos.x, 0.001), snappedf(rivet.pos.y, 0.001)],
		"hp": rivet.hp,
		"near": _nearest(arena.walls, rivet.pos),
		"foes": foes,
	}
	@warning_ignore("return_value_discarded")
	_log.store_line(JSON.stringify(row))


func _nearest(walls: ArenaWalls, at: Vector2) -> Array:
	var best: int = -1
	var gap: float = INF
	for i: int in walls.boxes.size():
		var box: Rect2 = walls.boxes[i]
		var d: float = (at.clamp(box.position, box.end) - at).length()
		if d < gap:
			gap = d
			best = i
	return [best, snappedf(gap, 0.001)]
