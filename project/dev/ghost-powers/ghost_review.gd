extends Node
## Captures the production arena at one physical screen pixel per camera pixel.
## Use --fixed-fps 60 and --write-movie. The trace maps movie frames to sim ticks,
## including hit-stop, actually displayed gait cells and actual damage events.

const KNOWN_FLAGS: PackedStringArray = [
	"--ghost", "--take", "--ppm", "--view", "--clean", "--ohm-bolt-delay", "--film-trace"
]
const RUN_TICKS: int = 370
## Camera marks in metres from the starting position, keeping the turn in frame at both zooms.
const MOVE_CENTRE: Dictionary[StringName, Vector2] = {
	&"tonnage": Vector2(3.4, 2),
	&"dent": Vector2(5.6, 3),
	&"kerf": Vector2(11.4, 5),
	&"ohm": Vector2(3.6, 2)
}

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
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	_game = ArenaGame.new()
	add_child(_game)
	_input = GhostReviewInput.new(_game.session, ghost, take == "attack")
	_game.session.world.loop().set_input(_input)
	_game.view.focus = (
		GhostReviewInput.MARK + (Vector2(7, 0) if _input.attacking else MOVE_CENTRE[ghost])
	)
	if _input.attacking and ghost == &"kerf":
		_game.view.focus = Vector2.INF  # The arena camera follows Kerf's actual blink glide.
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
	if not _input.attacking and _game.px_per_m > 32.0:
		var centre: Vector2 = GhostReviewInput.MARK + MOVE_CENTRE[_input.ghost]
		_game.view.focus.y = lerpf(centre.y, stage.arena.rivet.pos.y, 0.5)
	if _trace != null:
		_trace_frame(stage)


func _trace_frame(stage: ArenaStage) -> void:
	var p: StagePilot = stage.pilot
	var cell: String = _gait_cell(stage)
	var r: Fighter = stage.arena.rivet
	var px: Vector2 = get_viewport().get_canvas_transform() * (r.pos * SimConst.PX_PER_M)
	var row: Array = [
		Engine.get_process_frames(),
		_game.session.tick(),
		p.ghosts.forms.current(),
		r.pos.x,
		r.pos.y,
		r.facing.angle(),
		cell,
		p.hauler.form.stomps,
		p.hauler.ram_hits,
		p.hauler.cars_crushed,
		p.ghosts.jab.landed,
		p.dent.seizes,
		p.dent.strikes,
		p.dent.blasts,
		p.kerf.blinks,
		p.kerf.slices,
		p.ohm.cast.delay_ticks,
		p.ohm.bolts,
		p.ohm.struck,
		p.ohm.cars_hit,
		_hits,
		_game.view.print_stage.camera.zoom.x * SimConst.PX_PER_M,
		p.dent.blast_at.x,
		p.dent.blast_at.y,
		px.x,
		px.y
	]
	@warning_ignore("return_value_discarded")
	_trace.store_line(JSON.stringify(row))
	_hits.clear()


func _gait_cell(stage: ArenaStage) -> String:
	if stage.tick == GhostReviewInput.START or (_sprites.is_empty() and ViewMode.shared().cards):
		_sprites = _game.cast.ghost_view.find_children("ghost_drawn", "Sprite2D", true, false)
	for n: Sprite2D in _sprites:
		if n.is_visible_in_tree():
			return (
				"%s/%d/%d"
				% [n.texture.resource_path.get_file(), n.frame_coords.y, n.frame_coords.x]
			)
	return ""


func _trace_header() -> void:
	var fields: String = "frame tick form x_m y_m facing_rad atlas_row_col slams ram_hits crushes "
	fields += "jab_hits seizes car_hits blasts blinks slices delay_ticks bolts struck car_bolts "
	fields += "damage_events px_per_m blast_x_m blast_y_m screen_x screen_y"
	@warning_ignore("return_value_discarded")
	_trace.store_line(
		JSON.stringify({"schema": "gtai.ghost-review/1", "columns": fields.split(" ")})
	)


func _exit_tree() -> void:
	if _input != null:
		_game.session.world.loop().set_input(_game.session.live)
	if _trace != null:
		_trace.close()


func _kill(f: Fighter, weapon: StringName, _dir: Vector2, _at: Vector2, _kind: StringName) -> void:
	_hits.append("%s killed %d" % [weapon, f.id])


func _wound(f: Fighter, weapon: StringName) -> void:
	_hits.append("%s wounded %d" % [weapon, f.id])
