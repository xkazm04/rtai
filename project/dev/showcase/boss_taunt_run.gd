extends Node
## n8-hud (run by boss_taunt.gd, dev only): a boss's taunt over the live fight, in the form
## GTAI_TAUNT_FORM names (strip = BossTaunt under the boss bar, box = the quest dialogue box with
## the boss's PortraitBook face; default BossTaunt.FORM). Words from boss_taunt_lines.json
## (illustrative, never shipped). Render only: counts drawn frames, never touches the sim.

## The drawn frame the game scene is opened on (the project's main scene has loaded by then).
const OPEN_FRAME: int = 3
const LINES: String = "res://dev/showcase/boss_taunt_lines.json"

## The drawn frame of the first line (0 = 150) and how many frames each line stays (0 = 240).
var at_frame: int = 0
var hold_frames: int = 0
## The scene to run under the taunt (set by boss_taunt.gd), opened on OPEN_FRAME.
var game_scene: String = ""
## &"strip" or &"box" (empty = BossTaunt.FORM).
var form: StringName = &""
var _state: HudState = HudState.new()
var _box: HudDialogue = HudDialogue.new()
var _strip: BossTaunt = null
var _faces: PortraitBook = PortraitBook.new()
var _lines: Array = []
var _frame: int = 0


func _ready() -> void:
	at_frame = at_frame if at_frame > 0 else 150
	hold_frames = hold_frames if hold_frames > 0 else 240
	form = form if form != &"" else BossTaunt.FORM
	var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(LINES))
	if doc is Dictionary:
		var d: Dictionary = doc
		var rows: Variant = d.get("lines", [])
		if rows is Array:
			_lines = rows
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = RenderLayers.canvas(&"hud") + 1
	add_child(layer)
	_box.state = _state
	_box.art = HudArt.new()
	layer.add_child(_box)


func _process(_delta: float) -> void:
	_frame += 1
	if _frame == OPEN_FRAME and game_scene != "":
		var err: Error = get_tree().change_scene_to_file(game_scene)
		Log.info("dev", "boss_taunt: open %s -> %d, form %s" % [game_scene, err, form])
	var i: int = (_frame - at_frame) / hold_frames if _frame >= at_frame else -1
	var row: Dictionary = {}
	if i >= 0 and i < _lines.size() and _lines[i] is Dictionary:
		row = _lines[i]
	if form == &"strip":
		_say_strip(str(row.get("text", "")))
	else:
		_say_box(row)


func _say_strip(text: String) -> void:
	if _strip == null and text != "":
		var bar: BossBar = _find_bar(get_tree().root)
		if bar != null:
			_strip = BossTaunt.new()
			bar.get_parent().add_child(_strip)
	if _strip != null:
		_strip.words = text


func _say_box(row: Dictionary) -> void:
	if row.is_empty():
		_state.silent()
		return
	var boss: String = str(row.get("boss", ""))
	_state.say(str(row.get("name", "")), str(row.get("text", "")))
	_state.full_words = _state.words
	_state.portrait = _faces.face(boss, "")
	_state.portrait_device = _faces.is_device(boss)
	_state.portrait_key = boss


static func _find_bar(n: Node) -> BossBar:
	if n is BossBar:
		return n
	for c: Node in n.get_children():
		var b: BossBar = _find_bar(c)
		if b != null:
			return b
	return null
