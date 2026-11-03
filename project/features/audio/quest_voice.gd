class_name QuestVoice
extends Node
## Plays a quest line's voice when the line player puts the line on screen. The audio path is the
## line's own `audio` field in the quest package (res://quests/<id>/quest.json), read straight from
## the file: the package parser keeps only what the sim needs. A line without `audio` stays silent.
## Render-side: it watches `runner.lines.current`, it never advances the quest.

const QUEST_FILE: String = "res://quests/%s/quest.json"

var played: Array[String] = []
var _service: AudioService
var _system: QuestSystem
var _audio: Dictionary[String, String] = {}
var _current: String = ""


## `quest_id` is the package folder under res://quests/.
func bind(service: AudioService, system: QuestSystem, quest_id: String = "collect-call") -> void:
	_service = service
	_system = system
	_audio = audio_fields(QUEST_FILE % quest_id)


static func audio_fields(path: String) -> Dictionary[String, String]:
	var out: Dictionary[String, String] = {}
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return out
	var doc: Dictionary = parser.data
	for line: Dictionary in doc.get("lines", []):
		var audio: Variant = line.get("audio", null)
		if audio is String and audio != "":
			out[str(line["id"])] = audio
	return out


func _process(_delta: float) -> void:
	if _system == null or _system.runner == null:
		return
	var line: QuestLine = _system.runner.lines.current
	var id: String = line.id if line != null else ""
	if id == _current:
		return
	_current = id
	if id == "" or not _audio.has(id):
		return
	var stream: AudioStream = (
		load(_audio[id]) as AudioStream if ResourceLoader.exists(_audio[id]) else null
	)
	if _service.voice.speak(id, stream):
		played.append(id)
