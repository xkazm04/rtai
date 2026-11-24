extends Node
## Capture one 60 Hz take with --take, --seed, --ppm and --out=<native frame directory>.
## --still=N captures just tick N. A headless run prints the same take's measured result.

const KNOWN_FLAGS: PackedStringArray = [
	"--take", "--seed", "--ppm", "--out", "--still", "--half", "--cadence"
]
const FRAME: Vector2i = Vector2i(1920, 1080)
const TITLES: Dictionary[String, String] = {
	"guard": "Guard against three rifles",
	"blade": "Plasma sword / timed bat",
	"stand": "Stand still",
	"circle": "Circle",
	"dash": "Circle and dash",
	"rockets": "Two launchers",
	"pair_circle": "Two troopers: circle",
	"pair_dash": "Two troopers: circle + dash",
	"guard6": "Guard at 6 m",
	"blade6": "Plasma sword at 6 m",
	"blade6_spaced": "Plasma sword, rounds spaced"
}

var shot: PressureTake = PressureTake.new()
var ppm: int
var out_dir: String
var still: int
var cadence: bool = false
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
	cadence = args.has("--cadence")
	if args.has("--half"):
		($Caption/Panel as Panel).position.x += 480.0


func _open_view() -> void:
	var s: GauntletSession = shot.session
	_view = GauntletView.new(s.street)
	_view.px_per_m = ppm
	_view.focus = _focus()
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
	if shot.take.begins_with("pair") and still > 0:
		_view.focus = _focus()
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


func _focus() -> Vector2:
	if shot.take.begins_with("pair"):
		if still == 0:
			return shot.pair.centre
		return (shot.pair.centre + shot.arena.rivet.pos) * 0.5
	return shot.mark + Vector2(3 if _near() else 4, 0)


func _near() -> bool:
	return shot.take.ends_with("6") or shot.take.ends_with("spaced")


func _caption() -> void:
	hp.max_value = shot.arena.rivet.max_hp
	hp.value = shot.arena.rivet.hp
	var near: bool = _near()
	hp.visible = not near
	numbers.text = ("" if near else tr("HP %.1f     ") % hp.value) + _detail()


func _detail() -> String:
	var rifles: PressureRifles = shot.rifles
	match shot.take:
		"guard", "blade":
			return (
				tr("Passed %d    Returned %d    Kills %d")
				% [rifles.passed, rifles.returned, shot.arena.kills]
			)
		"guard6", "blade6", "blade6_spaced":
			if cadence or shot.take == "blade6_spaced":
				return _cadence_detail()
			var curve: int = 24 if shot.take == "guard6" else 31
			var share: float = 100.0 * rifles.struck / maxf(rifles.returned, 1.0)
			return (
				tr(
					"Fired %d    Returned %d    Passed %d\nHit a shooter %d    Share %.0f%%    Curve %d%%"
				)
				% [rifles.fired, rifles.returned, rifles.passed, rifles.struck, share, curve]
			)
		"pair_circle", "pair_dash":
			var end: String = tr("Down at %.1f s") % (shot.pair.death_tick / 60.0)
			if shot.pair.death_tick == 0:
				end = tr("Dashes %d") % shot.session.pilot.motion.dashes
			var pair: PressurePair = shot.pair
			return (
				tr("Rockets %d    Direct %d    Splash %d    HP lost %.0f\n%s")
				% [pair.launches, pair.direct, pair.splash, pair.hp_lost, end]
			)
		"rockets":
			return tr("Rivet / amber     Trooper / ice blue")
	return (
		tr("Wave %d    Rifle hits %d    Dashes %d")
		% [PressureTake.WAVE, shot.contacts, shot.session.pilot.motion.dashes]
	)


func _cadence_detail() -> String:
	var rifles: PressureRifles = shot.rifles
	var back: float = 100.0 * rifles.returned / maxf(rifles.fired, 1.0)
	return (
		tr("Fired %d  Returned %d  Passed %d  Hit a shooter %d  Turned back %d%%")
		% [rifles.fired, rifles.returned, rifles.passed, rifles.struck, roundi(back)]
	)


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
