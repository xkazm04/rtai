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
	"--film-panel"
]
const RUN_TICKS: int = 370
## Camera marks in metres from the starting position, keeping the turn in frame at both zooms.
const MOVE_CENTRE: Dictionary[StringName, Vector2] = {
	&"tonnage": Vector2(3.4, 2),
	&"dent": Vector2(5.6, 3),
	&"kerf": Vector2(11.4, 5),
	&"ohm": Vector2(3.6, 2)
}

var _panel: bool = false
var _game: ArenaGame
var _input: GhostReviewInput
var _trace: FileAccess
var _sprites: Array[Node] = []
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
	if not GhostReviewInput.GUARDS.has(ghost) or take not in ["move", "attack"]:
		Log.error("ghost_review", "invalid ghost or take")
		get_tree().quit(2)
		return
	Log.info("ghost_review", "%s %s uses %s look" % [ghost, take, GhostLook.of(ghost)])
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_game = ArenaGame.new()
	add_child(_game)
	_input = GhostReviewInput.new(_game.session, ghost, take == "attack")
	_game.session.world.loop().set_input(_input)
	var offset: Vector2 = Vector2(7, 0) if _input.attacking else MOVE_CENTRE[ghost]
	_game.view.focus = GhostReviewInput.MARK + offset
	if _input.attacking and ghost == &"kerf":
		_game.view.focus = Vector2.INF  # The arena camera follows Kerf's actual blink glide.
	_panel = args.has("--film-panel")
	if _panel:
		_game.cast.ghost_view.hud.hide()
	if args.has("--film-trace"):
		_trace = FileAccess.open(args.text("--film-trace"), FileAccess.WRITE)
		if _trace == null:
			Log.error("ghost_review", "could not open trace")
			get_tree().quit(1)
			return
		var arena: CombatArena = _game.session.stage.arena
		_trace_header()
		@warning_ignore("return_value_discarded")
		arena.kill_landed.connect(_kill)
		@warning_ignore("return_value_discarded")
		arena.wounded.connect(_wound)
	process_priority = FilmProbe.PRIORITY
	set_process(_trace != null or not _input.attacking)


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
		var centre: Vector2 = GhostReviewInput.MARK + MOVE_CENTRE[_input.ghost]
		_game.view.focus.y = lerpf(centre.y, stage.arena.rivet.pos.y, 0.5)
	if _trace != null:
		_trace_frame(stage)


func _trace_frame(stage: ArenaStage) -> void:
	var p: StagePilot = stage.pilot
	var r: Fighter = stage.arena.rivet
	var px: Vector2 = get_viewport().get_canvas_transform() * (r.pos * SimConst.PX_PER_M)
	var row: Array = [Engine.get_process_frames(), _game.session.tick(), p.ghosts.forms.current()]
	row.append_array([r.pos.x, r.pos.y, r.facing.angle(), _gait_cell(stage)])
	row.append_array([p.hauler.form.stomps, p.hauler.ram_hits, p.hauler.cars_crushed])
	row.append_array([p.ghosts.jab.landed, p.dent.seizes, p.dent.strikes, p.dent.blasts])
	row.append_array([p.kerf.blinks, p.kerf.slices])
	row.append_array([p.ohm.cast.delay_ticks, p.ohm.bolts, p.ohm.struck, p.ohm.cars_hit])
	row.append_array([_hits, _game.view.print_stage.camera.zoom.x * SimConst.PX_PER_M])
	row.append_array([p.dent.blast_at.x, p.dent.blast_at.y, px.x, px.y])
	@warning_ignore("return_value_discarded")
	_trace.store_line(JSON.stringify(row))
	_hits.clear()


func _gait_cell(stage: ArenaStage) -> String:
	if stage.tick == GhostReviewInput.START or (_sprites.is_empty() and ViewMode.shared().cards):
		_sprites = _game.cast.ghost_view.find_children("ghost_drawn", "Sprite2D", true, false)
	for n: Sprite2D in _sprites:
		if n.is_visible_in_tree():
			var atlas: String = n.texture.resource_path.get_file()
			return "%s/%d/%d" % [atlas, n.frame_coords.y, n.frame_coords.x]
	return ""


func _trace_header() -> void:
	var fields: String = "frame tick form x_m y_m facing_rad atlas_row_col slams ram_hits crushes "
	fields += "jab_hits seizes car_hits blasts blinks slices delay_ticks bolts struck car_bolts "
	fields += "damage_events px_per_m blast_x_m blast_y_m screen_x screen_y"
	var header: Dictionary = {"schema": "gtai.ghost-review/1", "columns": fields.split(" ")}
	@warning_ignore("return_value_discarded")
	_trace.store_line(JSON.stringify(header))


func _exit_tree() -> void:
	if _input != null:
		_game.session.world.loop().set_input(_game.session.live)
	if _trace != null:
		_trace.close()


func _kill(f: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName) -> void:
	_hits.append("%s killed %d" % [weapon, f.id])


func _wound(f: Fighter, weapon: StringName) -> void:
	_hits.append("%s wounded %d" % [weapon, f.id])
