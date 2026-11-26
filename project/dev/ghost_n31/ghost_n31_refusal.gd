extends Node
## n31 ghost 26 (dev only): the refusal cue on the REAL GhostFormHud, inked with the gauntlet's
## meter shader (GauntletView.style_ghost_meter's lines; that view needs a street). All four ghosts
## unlocked, Tonnage cooling. The cue is fed the way GhostFormHud.sync feeds it
## (GhostRefusalCue.notice: refusals, refused_form, last_refusal == cooldown), not by a real
## GhostDeploy: tick 20 a cooldown refusal on Tonnage, tick 60 a no-target refusal on Kerf. The HUD
## region is saved at press -1, +1, +2, +4, +8, +17 of each. --no-cue never counts the refusal.
## Flags: --out=<abs dir> (cells <form>_<m|p><n>.png), --no-cue (the before).

const KNOWN_FLAGS: PackedStringArray = ["--out", "--no-cue"]
const RUN_TICKS: int = 90
const PRESSES: Dictionary[StringName, int] = {&"tonnage": 20, &"kerf": 60}
const OFFSETS: Array[int] = [-1, 1, 2, 4, 8, 17]
const FORMS: Array[StringName] = [&"tonnage", &"ohm", &"dent", &"kerf"]
const CROP: Vector2i = Vector2i(420, 220)

var _hud: GhostFormHud
var _tick: int = -1
var _refusals: int = 0
var _form: StringName = &""
var _out: String = ""
var _cue: bool = true


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg == "--no-cue":
			_cue = false
	get_window().position = Vector2i(0, 1440)  # the secondary screen, never the main display
	_hud = GhostFormHud.new()
	add_child(_hud)
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	for id: StringName in FORMS:
		_hud.order.append(id)
		_hud.names[id] = String(id).capitalize()
		_hud.locked[id] = false
		_hud.number_hints[id] = str(FORMS.find(id) + 1)
	_hud.cooling[&"tonnage"] = 0.6
	_hud.current = GhostForms.BASE
	_hud.selected = &"tonnage"
	var ink: ShaderMaterial = ShaderMaterial.new()
	ink.shader = preload("res://features/gauntlet/gauntlet_meter.gdshader")
	var l: GhostFormLayout = _hud.layout
	ink.set_shader_parameter(&"meter_band_px", l.margin + l.card_h - l.bar_y + 6.0)
	_hud.material = ink
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_grab)


func _process(_delta: float) -> void:
	_tick += 1
	for id: StringName in PRESSES:
		if _tick == PRESSES[id] and _cue:
			_refusals += 1
			_form = id
	_hud.cue.notice(_refusals, _form, _form == &"tonnage")
	_hud.queue_redraw()
	if _tick >= PRESSES[&"kerf"] + 20:
		Log.info("dev", "ghost_n31_refusal done cue=%s out=%s" % [_cue, _out])
		get_tree().quit(0)


func _grab() -> void:
	if _out == "":
		return
	for id: StringName in PRESSES:
		var d: int = _tick - PRESSES[id]
		if not OFFSETS.has(d):
			continue
		var img: Image = get_viewport().get_texture().get_image()
		var h: int = img.get_height()
		var cell: Image = img.get_region(Rect2i(0, h - CROP.y, CROP.x, CROP.y))
		var file: String = "%s_%s%d.png" % [id, "m" if d < 0 else "p", absi(d)]
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(_out)
		@warning_ignore("return_value_discarded")
		cell.save_png(_out.path_join(file))
