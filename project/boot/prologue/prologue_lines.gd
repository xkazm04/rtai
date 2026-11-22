class_name PrologueLines
extends HudFeed
## The stage calls show_line only for spoken rows. The row id is also its translation key.

const TABLE: String = "res://data/tables/prologue_lines.json"
const SCHEMA: String = "gtai.prologue_lines/1"

var shown: Array[String] = []
var beats: Array[int] = []
var events: Array[Dictionary] = []
var subtitle: HudState = HudState.new()
var current: String = ""
var voice: String = ""
var _order: Array[String] = []
var _index: int = 0
var _due: int = 0
var _spoken: Dictionary[String, Dictionary] = {}
var _places: Dictionary[String, String] = {}


func _init() -> void:
	var data: DataTable = DataTable.open(TABLE, SCHEMA)
	for place: Dictionary in data.array(data.raw, "places"):
		var name_key: String = data.text(place, "id")
		_places[data.text(place, "fills")] = _text.resolve(name_key, data.text(place, "t"))
	for row: Dictionary in data.array(data.raw, "rows"):
		if data.text(row, "k") == "line":
			_spoken[data.text(row, "id")] = row
	if not data.ok():
		_spoken.clear()
		Log.error("prologue", str(data.errors()))


func begin(beat: int, tick: int) -> bool:
	_order.clear()
	for id: String in _spoken:
		if _spoken[id]["beat"] == beat:
			_order.append(id)
	_index = 0
	return not _order.is_empty() and show_line(_order[0], tick)


## Hold the last subtitle for its reading time, then leave the scene waiting for the player.
func advance(tick: int, skip: bool) -> void:
	if current.is_empty() or (not skip and tick < _due):
		return
	if skip:
		events.back()["skipped"] = true
		events.back()["skip_tick"] = tick
	_index += 1
	if _index < _order.size():
		@warning_ignore("return_value_discarded")
		show_line(_order[_index], tick)
	else:
		_silence()


## Dale fell. Keep a record of the cut and of every spoken row the player never saw.
func interrupt(tick: int) -> void:
	if not current.is_empty() and tick < _due:
		events.back()["skipped"] = true
		events.back()["skip_tick"] = tick
	for i: int in range(_index + 1, _order.size()):
		var entry: Dictionary = _event(_order[i], tick, false)
		entry["skipped"] = true
		events.append(entry)
	_silence()


func _silence() -> void:
	subtitle.silent()
	current = ""
	voice = ""


func _event(id: String, tick: int, displayed: bool) -> Dictionary:
	return {"id": id, "tick": tick, "shown": displayed, "draft": _spoken[id].get("draft", false)}


func show_line(id: String, tick: int = 0) -> bool:
	if not _spoken.has(id):
		return false
	var row: Dictionary = _spoken[id]
	var beat_number: float = row["beat"]
	var beat: int = roundi(beat_number)
	var speaker: String = row["who"]
	var source: String = row["t"]
	var words: String = _text.resolve(id, source)
	for placeholder: String in _places:
		words = words.replace(placeholder, _places[placeholder])
	var name_en: String = speaker.replace("-", " ").capitalize()
	if speaker == "winnick":
		name_en = "Lieutenant Dale Winnick"
	subtitle.say(_text.resolve(QuestText.cast_key(speaker), name_en), words)
	current = id
	voice = speaker
	var line: QuestLine = QuestLine.new()
	line.text = source
	_due = tick + line.duration_ticks(QuestRules.shipped())
	events.append(_event(id, tick, true))
	shown.append(id)
	if not beats.has(beat):
		beats.append(beat)
	return true


func fill(state: HudState, stage: CollectCallStage, _system: QuestSystem) -> void:
	state.say(subtitle.speaker, subtitle.words)
	state.portrait_key = voice
	if stage != null:
		var weapon: StringName = stage.arena.rivet.weapon
		state.weapon = ""
		if weapon != &"":
			var key: StringName = StringName("WEAPON__%s" % QuestText.symbol(String(weapon)))
			state.weapon = _text.resolve(key, String(weapon).capitalize())
		state.weapon_icon = icon_of(weapon)
		state.ammo = ammo_of(stage.arena, weapon)


func fill_view(view: CollectCallView, stage: CollectCallStage, system: QuestSystem) -> void:
	super.fill_view(view, stage, system)
	view.hud_view.dialogue.modulate = Color("91d9cb") if voice == "ghosts" else Color.WHITE
