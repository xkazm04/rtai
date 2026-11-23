class_name PrologueGame
extends Node
## Prologue composition root, also used by the dev scene. The pilot always uses wheel controls.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--result", "--seed"]
const FIXED_FPS: int = 60
const TABLE: String = "res://data/tables/prologue_stage.json"
const SCHEMA: String = "gtai.prologue_stage/1"

var world: World
var stage: ArenaStage
var bodies: PrologueBodies
var live: LiveInput
var lines: PrologueLines
var encounter: PrologueEncounter
var result_path: String
var with_view: bool = true
var _seed: int


func _ready() -> void:
	boot()


func boot() -> void:
	if world != null:
		return
	var problem: String = _read_args()
	if problem != "":
		Log.error("prologue", problem)
		get_tree().quit(2)
		return
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
	if not lines.begin(1, 0):
		Log.error("prologue", "missing opening line")
		get_tree().quit(1)
		return
	encounter = PrologueEncounter.new(lines, stage, data)
	@warning_ignore("return_value_discarded")
	encounter.finished.connect(_finished)
	@warning_ignore("return_value_discarded")
	encounter.end_card_reached.connect(_save_result)
	@warning_ignore("return_value_discarded")
	encounter.opening_restarted.connect(bodies.restore_opening)
	stage.hooks.append(encounter)
	if LaunchArgs.has("--bot"):
		_attach_bot()
	if with_view and DisplayServer.get_name() != "headless":
		_open_view(plan)


func _read_args() -> String:
	result_path = LaunchArgs.value("--result")
	var seed_arg: String = LaunchArgs.value("--seed")
	if LaunchArgs.has("--seed") and not seed_arg.is_valid_int():
		return "invalid seed %s" % seed_arg
	if LaunchArgs.has("--result") and not result_path.is_absolute_path():
		return "result path must be absolute"
	_seed = seed_arg.to_int() if seed_arg != "" else World.DEFAULT_SEED
	return ""


func _open(plan: PrologueYard, data: DataTable) -> void:
	world = World.new()
	world.start(Events, Data, _seed)
	var options: ArenaArgs = ArenaArgs.new()
	options.values["--enemy-brain"] = "squad"
	stage = PrologueStage.new(plan, plan.stations, options)
	var actions: PlayerActions = PlayerActions.shipped(true)
	actions.install()
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts = null
	var phone: Dictionary = data.object(data.raw, "payphone")
	stage.layout.phones[data.text(phone, "id")] = data.vec(phone, "at")
	world.add_system(stage)
	stage.arena.squad_ai = PrologueSquad.new(stage.arena.guard_map)
	_equip_squad(data)
	bodies = PrologueBodies.place(stage, data, world.context())
	stage.arena.rivet.weapon = &""
	stage.pilot.carry = RivetWheel.carry_for(stage.arena)
	live = PadAimAssist.wired(LiveInput.new(actions), stage.get.bind(&"arena"))
	world.loop().set_input(live)
	add_child(world)


func _attach_bot() -> void:
	if OS.is_debug_build() or OS.has_feature("devtools"):
		var script: GDScript = load("res://dev/bots/prologue_bot.gd") as GDScript
		if script != null and script.can_instantiate():
			var source: InputSource = script.new(stage, encounter)
			world.loop().set_input(source)
			return
	Log.error("prologue", "--bot requires the dev prologue pilot")
	get_tree().quit(2)


## The warden carries the local catch pole. Mulroney uses his shared roster weapon.
func _equip_squad(data: DataTable) -> void:
	var roster: EnemyRoster = stage.arena.squad_ai.pit.roster
	for row: Dictionary in data.array(data.raw, "weapons"):
		var foe: EnemyRoster.Archetype = roster.archetype(StringName(data.text(row, "archetype")))
		var weapon_id: StringName = StringName(data.text(row, "id"))
		foe.weapon = EnemyRoster.Weapon.from_row(data, weapon_id, row)


func _open_view(plan: PrologueYard) -> void:
	var view: PrologueView = PrologueView.new()
	view.encounter = encounter
	view.live = live
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
	var cards: ArenaWaveCards = ArenaWaveCards.attach(rigs.rigs, stage.arena.hostiles)
	var props: PrologueProps = PrologueProps.new()
	props.patrol = encounter.patrol
	props.rigs = rigs.rigs
	props.cards = cards
	props.z_index = rigs.rigs.z_index + 60
	view.print_stage.actor_layer().add_child(props)
	bodies.attach_view(view)
	PrologueCommandView.new().attach(view, stage, props.dress_boss, _seed)
	live.viewport = get_viewport()
	live.origin_px = view.rivet_screen
	live.px_per_m = func() -> float: return view.px_per_m


func _input(event: InputEvent) -> void:
	if live != null:
		live.note_event(event)


func show_line(id: String) -> bool:
	return lines.show_line(id)


func _finished() -> void:
	world.set_process(false)
	if LaunchArgs.has("--bot") or not result_path.is_empty():
		get_tree().quit()


func _exit_tree() -> void:
	release()
	_save_result()


## The synchronous scenario boots before SceneTree enters its root. Release the same
## stage hooks there as on a normal scene exit (the corpse hook retains its stage).
func release() -> void:
	if live != null:
		live.cursor_px = Callable()
	if stage != null:
		stage.hooks.clear()


func _save_result() -> void:
	if encounter == null or result_path.is_empty():
		return
	var err: Error = DirAccess.make_dir_recursive_absolute(result_path.get_base_dir())
	var file: FileAccess = FileAccess.open(result_path, FileAccess.WRITE) if err == OK else null
	if file == null or not file.store_string(JSON.stringify(result(), "  ", true) + "\n"):
		Log.error("prologue", "cannot write result to %s" % result_path)
		get_tree().quit(1)


func result() -> Dictionary:
	return PrologueRunResult.collect(stage, encounter, _seed, world.context().clock.tick())
