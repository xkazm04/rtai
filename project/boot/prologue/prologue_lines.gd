class_name PrologueLines
extends HudFeed
## The stage calls show_line only for spoken rows. The row id is also its translation key.

const TABLE: String = "res://data/tables/prologue_lines.json"
const SCHEMA: String = "gtai.prologue_lines/1"
const INTERRUPT_TICKS: int = 26
const QUIET_TICKS: int = SimClock.TICK_RATE

var shown: Array[String] = []
var beats: Array[int] = []
var events: Array[Dictionary] = []
var subtitle: HudState = HudState.new()
var current: String = ""
var voice: String = ""
var owner_calls: Array[String] = []
var _order: Array[String] = []
var _index: int = 0
var _due: int = 0
var _resume: int = -1
var _spoken: Dictionary[String, Dictionary] = {}
var _places: Dictionary[String, String] = {}
var _place_ids: Dictionary[String, String] = {}


func _init() -> void:
	var data: DataTable = DataTable.open(TABLE, SCHEMA)
	for place: Dictionary in data.array(data.raw, "places"):
		var name_key: String = data.text(place, "id")
		owner_calls.append(name_key)
		_place_ids[data.text(place, "fills")] = name_key
		_places[data.text(place, "fills")] = _text.resolve(name_key, data.text(place, "t"))
	for row: Dictionary in data.array(data.raw, "rows"):
		if data.text(row, "k") == "line":
			_spoken[data.text(row, "id")] = row
			if row.get("draft", false):
				owner_calls.append(data.text(row, "id"))
	if not data.ok():
		_spoken.clear()
		Log.error("prologue", str(data.errors()))


func begin(beat: int, tick: int) -> bool:
	_resume = -1
	_order.clear()
	for id: String in _spoken:
		if _spoken[id]["beat"] == beat:
			_order.append(id)
	_index = 0
	return not _order.is_empty() and show_line(_order[0], tick)


## Play only the rows between two stage directions. Player input opens the next segment.
func segment(first: String, last: String, tick: int) -> void:
	var ids: Array[String] = _spoken.keys()
	_order = ids.slice(ids.find(first), ids.find(last) + 1)
	_index = 0
	_resume = -1
	@warning_ignore("return_value_discarded")
	show_line(first, tick)


func busy() -> bool:
	return current != "" or _resume >= 0


func stop_segment() -> void:
	_resume = -1
	_order.clear()
	_silence()


func place_name(placeholder: String) -> String:
	return _places[placeholder]


## Hold the last subtitle for its reading time, then leave the scene waiting for the player.
func advance(tick: int, skip: bool) -> void:
	if _resume >= 0:
		if tick >= _resume:
			_resume = -1
			@warning_ignore("return_value_discarded")
			show_line(_order[_index], tick)
		return
	if current.is_empty() or (not skip and tick < _due):
		return
	if skip:
		events.back()["skipped"] = true
		events.back()["skip_tick"] = tick
	_index += 1
	if _index < _order.size():
		if _spoken[_order[_index]].get("cue", "") == "a beat later, suddenly quiet":
			_silence()
			_resume = tick + QUIET_TICKS
			return
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


func reading_ticks(id: String) -> int:
	var line: QuestLine = QuestLine.new()
	line.text = _spoken[id]["t"]
	return line.duration_ticks(QuestRules.shipped())


func show_line(id: String, tick: int = 0, repeated_order: bool = false) -> bool:
	if not _spoken.has(id):
		return false
	var row: Dictionary = _spoken[id]
	var beat_number: float = row["beat"]
	var beat: int = roundi(beat_number)
	var speaker: String = row["who"]
	var source: String = row["t"]
	var words: String = _text.resolve(id, source)
	var entry: Dictionary = _event(id, tick, true)
	for placeholder: String in _places:
		if source.contains(placeholder):
			words = words.replace(placeholder, place_name(placeholder))
			entry.merge(
				{"draft": true, "draft_place": true, "place_id": _place_ids[placeholder]}, true
			)
			entry["text"] = words
	var name_en: String = speaker.replace("-", " ").capitalize()
	if speaker == "winnick":
		name_en = "Lieutenant Dale Winnick"
	var label: String = _text.resolve(QuestText.cast_key(speaker), name_en)
	if id == "b3_l11_fax_location":
		label = _text.resolve(&"PROLOGUE__RADIO_SPEAKER", "%s · Radio") % label
	subtitle.say(label, words)
	current = id
	voice = speaker
	_due = tick + reading_ticks(id)
	# Battle records each recurring tell in orders. Keep the authored dialogue history intact.
	if repeated_order:
		return true
	if _index + 1 < _order.size() and _spoken[_order[_index + 1]].get("cue", "") == "interrupting":
		_due = mini(_due, tick + INTERRUPT_TICKS)
	events.append(entry)
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
