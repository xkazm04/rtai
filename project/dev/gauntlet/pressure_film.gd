extends Node
## Capture one 60 Hz take with --take, --seed, --ppm and --out=<native frame directory>.
## --still=N captures just tick N. A headless run prints the same take's measured result.

const KNOWN_FLAGS: PackedStringArray = ["--take", "--seed", "--ppm", "--out", "--still"]
const FRAME: Vector2i = Vector2i(1920, 1080)
const TITLES: Dictionary[String, String] = {
	"guard": "Guard against three rifles",
	"blade": "Plasma sword / timed bat",
	"stand": "Stand still",
	"circle": "Circle",
	"dash": "Circle and dash",
	"rockets": "Two launchers"
}

var shot: PressureTake = PressureTake.new()
var ppm: int
var out_dir: String
var still: int
var _drawing: bool = false
var _view: GauntletView
@onready var title: Label = %Title
@onready var numbers: Label = %Numbers
@onready var hp: ProgressBar = %HP


func _ready() -> void:
	var args: ArenaArgs = ArenaArgs.parse()
	var id: String = args.text("--take", "guard")
	ppm = int(args.number("--ppm", 32))
	still = int(args.number("--still", 0))
	out_dir = args.text("--out")
	var seed_value: int = int(args.number("--seed", 1))
	if id not in PressureTake.TAKES or ppm not in [32, 64] or not shot.open(id, seed_value):
		_fail("Unknown take, unsupported scale or wave lacks both patrol and rocket trooper.")
		return
	if DisplayServer.get_name() == "headless":
		while shot.tick < shot.length:
			shot.advance()
		_finish()
		return
	if still < 0 or still > shot.length or not out_dir.is_absolute_path():
		_fail("Expected an absolute --out directory and an in-range --still tick.")
		return
	if DirAccess.make_dir_recursive_absolute(out_dir) != OK:
		_fail("Could not open " + out_dir)
		return
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = FRAME
	ViewMode.select("tilt70")
	_open_view()
	title.text = tr(TITLES[id])
	process_priority = -1000


func _open_view() -> void:
	var s: GauntletSession = shot.session
	_view = GauntletView.new(s.street)
	_view.px_per_m = ppm
	_view.focus = shot.mark + Vector2(4, 0)
	_view.bind(s.stage, CollectCallWorld.new(s.stage), null)
	add_child(_view)
	_view.hud_view.hide()
	var cast: ArenaRigs = ArenaRigs.new()
	add_child(cast)
	@warning_ignore("return_value_discarded")
	cast.attach(s.stage, _view, s.world.context())
	cast.ghost_view.hud.hide()
	($Caption as CanvasLayer).layer = RenderLayers.canvas(&"hud") + 1


func _process(_delta: float) -> void:
	if _drawing:
		return
	_drawing = true
	shot.advance()
	_caption()
	await RenderingServer.frame_post_draw
	if still == 0 or still == shot.tick:
		if not _save():
			_fail("Capture failed the resolution, pitch, scale or image-write check.")
			return
	if shot.tick == shot.length or shot.tick == still:
		_finish()
	else:
		_drawing = false


func _caption() -> void:
	hp.max_value = shot.arena.rivet.max_hp
	hp.value = shot.arena.rivet.hp
	var detail: String
	match shot.take:
		"guard", "blade":
			detail = (
				tr("Passed %d    Returned %d    Kills %d")
				% [shot.rifles.passed, shot.rifles.returned, shot.arena.kills]
			)
		"rockets":
			detail = tr("Rivet / amber     Trooper / ice blue")
		_:
			detail = (
				tr("Wave %d    Rifle hits %d    Dashes %d")
				% [PressureTake.WAVE, shot.contacts, shot.session.pilot.motion.dashes]
			)
	numbers.text = tr("HP %.1f     ") % hp.value + detail


func _save() -> bool:
	var frame: Image = get_viewport().get_texture().get_image()
	var transform_px: Transform2D = _view.fx_view.get_screen_transform()
	var scale_px: float = transform_px.x.length() * Ink.PX_PER_M
	if frame == null or frame.get_size() != FRAME or not is_equal_approx(scale_px, ppm):
		return false
	if not is_equal_approx(ViewMode.shared().pitch_deg, 70.0):
		return false
	if still > 0:
		return frame.save_png(out_dir.path_join("still.png")) == OK
	return frame.save_jpg(out_dir.path_join("%04d.jpg" % shot.tick), 0.97) == OK


func _finish() -> void:
	set_process(false)
	Log.info("pressure-film", JSON.stringify(shot.summary()))
	get_tree().quit()


func _fail(why: String) -> void:
	set_process(false)
	Log.error("pressure-film", why)
	get_tree().quit(1)


func _exit_tree() -> void:
	if shot.session != null:
		shot.session.close()
