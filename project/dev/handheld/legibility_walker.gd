extends Node
## handheld lane (n9): the runtime legibility walk under a device row (default `deck`). Boots
## quest 1 the way LaunchArgs does on a handheld, walks it on pad events only (title -> A -> a
## stick nudge -> Start = pause), and at each stop runs TextProbe over every visible text Control
## and saves the frame. Also measures each font size the custom draw_string sites use (the HUD,
## the dialogue, the boss bar and taunt, the ghost card, the prompt: reviewed in the LEDGER).
## Writes `<out>/legibility.json` + one PNG per stop. Dev only; never shipped.
## Run through legibility_walk.gd (a SceneTree script cannot name the autoloads at compile time).

## The font sizes the draw_string sites pass (authored px at the 1280x800 base, scaled to the
## window).
const DRAW_SIZES: Dictionary[String, int] = {
	"boss bar count (BossBar 16)": 16,
	"ghost card name / key hint (GhostFormLayout 18)": 18,
	"boss taunt smallest fit (BossTaunt 18)": 18,
	"boss bar name (BossBar 20)": 20,
	"dialogue smallest fit (HudDialogue 20)": 20,
	"unarmed label (HudView 22)": 22,
	"objective prompt (ObjectiveView 24)": 24,
	"weapon / heat / notice (HudView 24)": 24,
	"speaker name (HudView.NAME_SIZE 26)": 26,
	"head line (HudView 30)": 30,
}

var _out: String = ""
var _report: Dictionary = {}


func _ready() -> void:
	_walk.call_deferred()


func _walk() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else OS.get_user_data_dir()
	var device: String = args[1] if args.size() > 1 else "deck"
	var root: Window = get_tree().root
	DeviceProfile.select(device).apply(root)
	PlayerActions.shipped().install()
	var game: Quest1Game = (
		(load("res://boot/quest1.tscn") as PackedScene).instantiate() as Quest1Game
	)
	game.save_path = ""
	game.settings_path = ""
	root.add_child(game)
	game.boot()
	_report["device"] = device
	_report["window"] = [root.size.x, root.size.y]
	await _frames(20)
	_report["draw_sizes"] = _draw_sizes(root.get_final_transform().get_scale().y)
	await _stop("title")
	_pad(JOY_BUTTON_A)
	await _frames(360)
	for v: float in [0.7, 0.0]:
		var m: InputEventJoypadMotion = InputEventJoypadMotion.new()
		m.axis = JOY_AXIS_LEFT_X
		m.axis_value = v
		Input.parse_input_event(m)
		await _frames(4)
	await _frames(30)
	await _stop("quest1")
	_pad(JOY_BUTTON_START)
	await _frames(20)
	await _stop("pause")
	var f: FileAccess = FileAccess.open(_out.path_join("legibility.json"), FileAccess.WRITE)
	var wrote: bool = f.store_string(JSON.stringify(_report, "  ", true))
	f.close()
	Log.info("legibility", "wrote %s (%s)" % [_out.path_join("legibility.json"), wrote])
	get_tree().quit(0)


## Each draw_string size in window px: the authored size x `stretch` (the base-to-window factor).
func _draw_sizes(stretch: float) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for site: String in DRAW_SIZES:
		var row: Dictionary = TextProbe.size_row(ThemeDB.fallback_font, DRAW_SIZES[site] * stretch)
		row["site"] = site
		row["authored_px"] = DRAW_SIZES[site]
		rows.append(row)
	return rows


func _stop(name: String) -> void:
	await RenderingServer.frame_post_draw
	var root: Window = get_tree().root
	var png: String = _out.path_join("legibility-%s.png" % name)
	var err: Error = root.get_texture().get_image().save_png(png)
	var rows: Array[Dictionary] = TextProbe.probe(root)
	_report[name] = rows
	var low: String = "none"
	if not rows.is_empty():
		low = "%s x %.0f px" % [rows[0]["text"], rows[0]["x_px"]]
	Log.info("legibility", "%s: %d text, smallest %s (png %d)" % [name, rows.size(), low, err])


func _pad(b: JoyButton) -> void:
	for down: bool in [true, false]:
		var ev: InputEventJoypadButton = InputEventJoypadButton.new()
		ev.button_index = b
		ev.pressed = down
		Input.parse_input_event(ev)


func _frames(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame
