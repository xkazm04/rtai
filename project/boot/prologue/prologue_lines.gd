class_name PrologueLines
extends HudFeed
## The stage calls show_line only for spoken rows. The row id is also its translation key.

const TABLE: String = "res://data/tables/prologue_lines.json"
const SCHEMA: String = "gtai.prologue_lines/1"

var shown: Array[String] = []
var beats: Array[int] = []
var subtitle: HudState = HudState.new()
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


func show_line(id: String) -> bool:
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
	subtitle.say(_text.resolve(QuestText.cast_key(speaker), speaker), words)
	shown.append(id)
	if not beats.has(beat):
		beats.append(beat)
	return true


func fill(state: HudState, _stage: CollectCallStage, _system: QuestSystem) -> void:
	state.say(subtitle.speaker, subtitle.words)
