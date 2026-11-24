extends Node
## Run the real bot pilot headless for chosen dressings and seeds, the way the pilot scenario does,
## and write one row each: ticks, deaths, lowest health, stuck marks, result bytes.
## godot --headless --path project res://dev/prologue_yard/yard_pilot_rows.tscn -- \
##   --dressings=line_fire,raised_line --seeds=7,3,11,21,42 --out=<abs json>

const KNOWN_FLAGS: PackedStringArray = ["--dressings", "--seeds", "--out"]
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const Watch = preload("res://dev/prologue_yard/yard_motion_watch.gd")
const BUDGET: int = 300 * SimClock.TICK_RATE


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			Log.error("yard-pilot-rows", "unknown option " + key)
			get_tree().quit(2)
			return
	var out: String = args.text("--out")
	if not out.is_absolute_path() or not args.has("--dressings") or not args.has("--seeds"):
		Log.error("yard-pilot-rows", "expected --dressings, --seeds and an absolute --out")
		get_tree().quit(2)
		return
	var rows: Array[Dictionary] = []
	for dressing: String in args.text("--dressings").split(","):
		for seed_text: String in args.text("--seeds").split(","):
			LaunchArgs.parse(["--seed=" + seed_text, "--yard-dressing=" + dressing])
			rows.append(_run(seed_text.to_int(), dressing))
	var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	var ok: bool = (
		file != null and file.store_string(JSON.stringify({"runs": rows}, "  ", true) + "\n")
	)
	get_tree().quit(0 if ok else 2)


func _run(seed_value: int, dressing: String) -> Dictionary:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child(game)
	game.boot()
	game.world.set_process(false)
	var loop: SimLoop = game.world.loop()
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	loop.set_input(pilot)
	var watch: Watch = Watch.new()
	watch.sample(game)
	var lowest: float = game.stage.arena.rivet.hp
	while game.encounter.street.end_tick < 0 and game.world.context().clock.tick() < BUDGET:
		loop.step()
		lowest = minf(lowest, game.stage.arena.rivet.hp)
		watch.sample(game)
	var result: Dictionary = game.result()
	var row: Dictionary = {
		"dressing": dressing,
		"seed": seed_value,
		"ended": result["ended"],
		"ticks": result["ticks"],
		"deaths": result["deaths"],
		"min_hp": lowest,
		"stuck": watch.stuck,
		"sha256": (JSON.stringify(result, "  ", true) + "\n").sha256_text(),
	}
	Log.info("yard-pilot-rows", JSON.stringify(row))
	game.release()
	game.free()
	return row
