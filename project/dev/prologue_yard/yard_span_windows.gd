extends Node
## Run the bot pilot headless on arched_line for chosen seeds and list the tick runs where the
## span shadow is at half strength or more, with Rivet's mean feet.
## godot --headless --path project res://dev/prologue_yard/yard_span_windows.tscn -- \
##   --seeds=7,3,11,21,42 --out=<abs txt>

const KNOWN_FLAGS: PackedStringArray = ["--seeds", "--out"]
const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")
const PILOT: GDScript = preload("res://dev/bots/prologue_bot.gd")
const BUDGET: int = 300 * SimClock.TICK_RATE
const MIN_STRENGTH: float = 0.5


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	for key: String in args.values:
		if key not in KNOWN_FLAGS:
			Log.error("yard-span-windows", "unknown option " + key)
			get_tree().quit(2)
			return
	var out: String = args.text("--out")
	if not out.is_absolute_path() or not args.has("--seeds"):
		Log.error("yard-span-windows", "expected --seeds and an absolute --out")
		get_tree().quit(2)
		return
	var lines: PackedStringArray = []
	for seed_text: String in args.text("--seeds").split(","):
		LaunchArgs.parse(["--seed=" + seed_text, "--yard-dressing=arched_line"])
		lines += _run(seed_text.to_int())
	var file: FileAccess = FileAccess.open(out, FileAccess.WRITE)
	var ok: bool = file != null and file.store_string("\n".join(lines) + "\n")
	get_tree().quit(0 if ok else 2)


func _run(seed_value: int) -> PackedStringArray:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child(game)
	game.boot()
	game.world.set_process(false)
	var loop: SimLoop = game.world.loop()
	var pilot: InputSource = PILOT.new(game.stage, game.encounter)
	loop.set_input(pilot)
	# Headless boots no view, so build the shadow node the view would (never in the tree).
	var plan: PrologueYard = game.stage.plan as PrologueYard
	var out: PackedStringArray = []
	var pieces: Array[PrologueYard.Wreck] = PrologueSpanShadow.spans(plan)
	if plan.dressing.span_shadow.is_empty() or pieces.is_empty():
		out += PackedStringArray(["seed %d: no span shadow row or spans" % seed_value])
	else:
		var node: PrologueSpanShadow = PrologueSpanShadow.build(
			plan.dressing.span_shadow, pieces, PrologueYardPaint.new()
		)
		out += _scan(game, loop, node, seed_value)
		node.free()
	game.release()
	game.free()
	return out


func _scan(
	game: PrologueGame, loop: SimLoop, node: PrologueSpanShadow, seed_value: int
) -> PackedStringArray:
	var out: PackedStringArray = []
	var first: int = -1
	var sum: Vector2 = Vector2.ZERO
	var count: int = 0
	var tick: int = 0
	while game.encounter.street.end_tick < 0 and tick < BUDGET:
		loop.step()
		tick = game.stage.tick
		var feet: Vector2 = game.stage.arena.rivet.pos
		node.step(tick, feet)
		if node.strength() >= MIN_STRENGTH:
			if first < 0:
				first = tick
				sum = Vector2.ZERO
				count = 0
			sum += feet
			count += 1
		elif first >= 0:
			out += PackedStringArray([_row(seed_value, first, tick - 1, sum / float(count))])
			first = -1
	if first >= 0:
		out += PackedStringArray([_row(seed_value, first, tick, sum / float(count))])
	out += PackedStringArray(["seed %d: ended at tick %d" % [seed_value, tick]])
	return out


func _row(seed_value: int, first: int, last: int, mean: Vector2) -> String:
	var secs: float = float(last - first + 1) / float(SimClock.TICK_RATE)
	return (
		"seed %d ticks %d..%d (%.2f s) mean feet %.2f,%.2f"
		% [seed_value, first, last, secs, mean.x, mean.y]
	)
