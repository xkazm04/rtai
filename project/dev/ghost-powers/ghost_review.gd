extends Node
## Capture the arena at native camera scale. The optional trace records ticks, gait and damage.

const KNOWN_FLAGS: PackedStringArray = [
	"--ghost",
	"--ghost-look",
	"--take",
	"--ppm",
	"--view",
	"--clean",
	"--shot",
	"--shot-tick",
	"--ohm-bolt-delay",
	"--film-trace",
	"--film-panel",
	"--apparition"
]
const RUN_TICKS: int = 402
## Camera marks in metres from the starting position, keeping the turn in frame at both zooms.
@export var move_centre: Dictionary[StringName, Vector2]

var _panel: bool = false
var _game: ArenaGame
var _input: GhostReviewInput
var _trace: FileAccess
var _hits: Array[String] = []


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var ghost: StringName = StringName(args.text("--ghost", "tonnage"))
	var take: String = args.text("--take", "move")
	for flag: String in args.values:
		if flag not in KNOWN_FLAGS:
			Log.error("ghost_review", "unknown argument %s" % flag)
			get_tree().quit(2)
			return
	var hit_take: bool = take == "hit" and ghost == &"dent"
	var valid_take: bool = hit_take or take in ["move", "attack", "morph"]
	if not GhostReviewInput.GUARDS.has(ghost) or not valid_take:
		Log.error("ghost_review", "invalid ghost or take")
		get_tree().quit(2)
		return
	Log.info("ghost_review", "%s %s uses %s look" % [ghost, take, GhostLook.of(ghost)])
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_game = ArenaGame.new()
	add_child(_game)
	_input = GhostReviewInput.new(_game.session, ghost, take == "attack", take == "morph")
	_input.dent_hits = hit_take
	_game.session.world.loop().set_input(_input)
	var offset: Vector2 = Vector2(7, 0) if _input.attacking else move_centre[ghost]
	_game.view.focus = GhostReviewInput.MARK + (Vector2.ZERO if _input.morphing else offset)
	if _input.attacking and ghost == &"kerf":
		_game.view.focus = Vector2.INF  # The arena camera follows Kerf's actual blink glide.
	_panel = args.has("--film-panel")
	if _panel:
		_game.cast.ghost_view.hud.hide()
	if args.has("--film-trace"):
		_open_trace(args.text("--film-trace"))
	process_priority = FilmProbe.PRIORITY
	set_process(_trace != null or not _input.attacking)


func _open_trace(path: String) -> void:
	_trace = FileAccess.open(path, FileAccess.WRITE)
	if _trace == null:
		Log.error("ghost_review", "could not open trace")
		get_tree().quit(1)
		return
	var arena: CombatArena = _game.session.stage.arena
	var fields: String = "frame tick form x_m y_m facing_rad atlas_row_col slams ram_hits crushes "
	fields += "jab_hits seizes car_hits blasts blinks slices delay_ticks bolts struck car_bolts "
	fields += "damage_events px_per_m blast_x_m blast_y_m screen_x screen_y"
	if _input.dent_hits:
		fields += " arena_tick hurt_tick held"
	var header: Dictionary = {"schema": "gtai.ghost-review/1", "columns": fields.split(" ")}
	@warning_ignore("return_value_discarded")
	_trace.store_line(JSON.stringify(header))
	@warning_ignore("return_value_discarded")
	arena.kill_landed.connect(_record.bind("killed").unbind(3))
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(_record.bind("wounded").unbind(2))


func _process(_delta: float) -> void:
	var stage: ArenaStage = _game.session.stage
	if _panel:
		var at: Vector2 = stage.arena.rivet.pos
		if _input.attacking and _input.ghost == &"kerf":
			_game.view.focus.x = at.x
		var row: GhostFormDef = stage.pilot.ghosts.forms.table.form(_input.ghost)
		var vm: ViewMode = ViewMode.shared()
		_game.view.focus.y = at.y if vm.is_flat() else at.y - row.size_k * 0.875 / vm.ground_k()
	elif not _input.attacking and _game.px_per_m > 32.0:
		var centre: Vector2 = GhostReviewInput.MARK + move_centre[_input.ghost]
		_game.view.focus.y = lerpf(centre.y, stage.arena.rivet.pos.y, 0.5)
	if _trace != null:
		_trace_frame(stage)


func _trace_frame(stage: ArenaStage) -> void:
	var p: StagePilot = stage.pilot
	var r: Fighter = stage.arena.rivet
	var px: Vector2 = get_viewport().get_canvas_transform() * (r.pos * SimConst.PX_PER_M)
	var row: Array = [Engine.get_process_frames(), _game.session.tick(), p.ghosts.forms.current()]
	row.append_array([r.pos.x, r.pos.y, r.facing.angle(), _gait_cell()])
	row.append_array([p.hauler.form.stomps, p.hauler.ram_hits, p.hauler.cars_crushed])
	row.append_array([p.ghosts.jab.landed, p.dent.seizes, p.dent.strikes, p.dent.blasts])
	row.append_array([p.kerf.blinks, p.kerf.slices])
	row.append_array([p.ohm.cast.delay_ticks, p.ohm.bolts, p.ohm.struck, p.ohm.cars_hit])
	row.append_array([_hits, _game.view.print_stage.camera.zoom.x * SimConst.PX_PER_M])
	row.append_array([p.dent.blast_at.x, p.dent.blast_at.y, px.x, px.y])
	if _input.dent_hits:
		row.append_array([stage.arena.tick, r.hurt_tick, p.dent.car != null])
	@warning_ignore("return_value_discarded")
	_trace.store_line(JSON.stringify(row))
	_hits.clear()


func _gait_cell() -> String:
	var body: Node2D = _game.cast.ghost_view._bodies.get(_input.ghost)
	var drawn: GhostDrawn = body.get(&"drawn")
	var spr: Sprite2D = drawn.sprite()
	if spr == null or not spr.is_visible_in_tree():
		return ""
	return (
		"%s/%d/%d" % [spr.texture.resource_path.get_file(), spr.frame_coords.y, spr.frame_coords.x]
	)


func _exit_tree() -> void:
	if _input != null:
		_game.session.world.loop().set_input(_game.session.live)
	if _trace != null:
		_trace.close()


func _record(f: Fighter, weapon: StringName, event: String) -> void:
	_hits.append("%s %s %d" % [weapon, event, f.id])
