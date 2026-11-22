class_name PrologueGame
extends Node
## Prologue composition root, also used by the dev scene. The pilot always uses wheel controls.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--result", "--seed"]
const FIXED_FPS: int = 60
const TABLE: String = "res://data/tables/prologue_stage.json"
const SCHEMA: String = "gtai.prologue_stage/1"


class WalkPilot:
	extends InputSource

	func sample(tick: int) -> TickInput:
		return TickInput.new(0, TickInput.AXIS_MAX if tick < SimClock.TICK_RATE else 0, 0)


var world: World
var stage: ArenaStage
var live: LiveInput
var lines: PrologueLines
var _result_path: String
var _seed: int


func _ready() -> void:
	_result_path = LaunchArgs.value("--result")
	var seed_arg: String = LaunchArgs.value("--seed")
	if LaunchArgs.has("--seed") and not seed_arg.is_valid_int():
		Log.error("prologue", "invalid seed %s" % seed_arg)
		get_tree().quit(2)
		return
	if LaunchArgs.has("--result") and not _result_path.is_absolute_path():
		Log.error("prologue", "result path must be absolute")
		get_tree().quit(2)
		return
	_seed = seed_arg.to_int() if seed_arg != "" else World.DEFAULT_SEED
	var data: DataTable = DataTable.open(TABLE, SCHEMA)
	var plan: PrologueYard = PrologueYard.from_stage(data)
	var beats: Array = data.array(data.raw, "beats")
	if not data.ok() or beats.is_empty():
		Log.error("prologue", str(data.errors()))
		get_tree().quit(1)
		return
	_open(plan, data)
	if not data.ok():
		Log.error("prologue", str(data.errors()))
		get_tree().quit(1)
		return
	lines = PrologueLines.new()
	var opening: Dictionary = beats[0]
	if not show_line(data.text(opening, "first_line")):
		Log.error("prologue", "missing opening line")
		get_tree().quit(1)
		return
	if DisplayServer.get_name() != "headless":
		_open_view(plan)


func _open(plan: PrologueYard, data: DataTable) -> void:
	world = World.new()
	world.start(Events, Data, _seed)
	var options: ArenaArgs = ArenaArgs.new()
	options.values["--enemy-brain"] = "squad"
	stage = ArenaStage.new(plan, plan.stations, options)
	var actions: PlayerActions = PlayerActions.shipped(true)
	actions.install()
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts.forms.apply_locks([])
	world.add_system(stage)
	_equip_squad(data)
	stage.arena.rivet.weapon = &""
	live = PadAimAssist.wired(LiveInput.new(actions), stage.get.bind(&"arena"))
	var input: InputSource = live
	if LaunchArgs.has("--bot"):
		input = WalkPilot.new()
	world.loop().set_input(input)
	add_child(world)


## These two weapons belong to this encounter. The common enemy table uses its existing
## ranged/melee profiles so every other loader can still resolve its weapon references.
func _equip_squad(data: DataTable) -> void:
	var roster: EnemyRoster = stage.arena.squad_ai.pit.roster
	for row: Dictionary in data.array(data.raw, "weapons"):
		var foe: EnemyRoster.Archetype = roster.archetype(StringName(data.text(row, "archetype")))
		var weapon_id: StringName = StringName(data.text(row, "id"))
		foe.weapon = EnemyRoster.Weapon.from_row(data, weapon_id, row)


func _open_view(plan: PrologueYard) -> void:
	var view: CollectCallView = CollectCallView.new()
	var floor_view: PrologueFloor = PrologueFloor.new()
	floor_view.plan = plan
	view.stage_view.free()
	view.stage_view = floor_view
	view.hud_feed = lines
	view.px_per_m = 32.0
	view.bind(stage, CollectCallWorld.new(stage), null)
	add_child(view)
	var rigs: ArenaRigs = ArenaRigs.new()
	add_child(rigs)
	@warning_ignore("return_value_discarded")
	rigs.attach(stage, view, world.context())
	live.viewport = get_viewport()
	live.origin_px = func() -> Vector2: return get_viewport().get_visible_rect().size * 0.5
	live.px_per_m = func() -> float: return view.px_per_m


func _input(event: InputEvent) -> void:
	if live != null:
		live.note_event(event)


func show_line(id: String) -> bool:
	return lines.show_line(id)


func _exit_tree() -> void:
	if live != null:
		live.cursor_px = Callable()
	if stage != null:
		stage.hooks.clear()
	if lines == null or _result_path.is_empty():
		return
	var result: Dictionary = {
		"schema": "gtai.prologue-run/1",
		"seed": _seed,
		"lines_shown": lines.shown,
		"beats_reached": lines.beats,
		"ticks": world.context().clock.tick(),
	}
	var err: Error = DirAccess.make_dir_recursive_absolute(_result_path.get_base_dir())
	var file: FileAccess = FileAccess.open(_result_path, FileAccess.WRITE) if err == OK else null
	if file == null or not file.store_string(JSON.stringify(result, "  ", true) + "\n"):
		Log.error("prologue", "cannot write result to %s" % _result_path)
		get_tree().quit(1)
