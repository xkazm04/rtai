class_name PortraitBook
extends RefCounted
## Who is speaking, as a face (n8-hud; data/tables/portraits.json): a speaker's bust, the mood
## bust on the lines the table names, or the device a voice-only caller speaks through (Don Fax
## and Patch: the payphone). A speaker with no row has no face (the box shows the name alone);
## only owner-approved looks get a row. Art loads once per path; a missing file is no face.

const TABLE: String = "res://data/tables/portraits.json"
const SCHEMA: String = "gtai.portraits/1"

var _art: Dictionary[String, String] = {}
var _mood_art: Dictionary[String, String] = {}
var _mood_lines: Dictionary[String, PackedStringArray] = {}
var _device: Dictionary[String, bool] = {}
var _tex: Dictionary[String, Texture2D] = {}


func _init(path: String = TABLE) -> void:
	var t: DataTable = DataTable.open(path, SCHEMA)
	for row: Variant in t.array(t.raw, "speakers"):
		var r: Dictionary = row if row is Dictionary else {}
		var id: String = t.text(r, "id")
		_art[id] = t.text(r, "art")
		_mood_art[id] = t.text(r, "mood_art")
		_device[id] = t.text(r, "kind") == "device"
		var lines: PackedStringArray = []
		for v: Variant in t.array(r, "mood_lines"):
			@warning_ignore("return_value_discarded")
			lines.append(str(v))
		_mood_lines[id] = lines
	if not t.ok():
		Log.error("hud", str(t.errors()))


func has(speaker: String) -> bool:
	return _art.has(speaker)


func is_device(speaker: String) -> bool:
	return _device.get(speaker, false)


## The face for `speaker` saying line `line_id`: the mood bust when the table names the line,
## else the neutral bust (or the device); null when the speaker has no row.
func face(speaker: String, line_id: String = "") -> Texture2D:
	if not _art.has(speaker):
		return null
	var mood: String = _mood_art.get(speaker, "")
	var named: PackedStringArray = _mood_lines.get(speaker, PackedStringArray())
	if mood != "" and named.has(line_id):
		return _load(mood)
	return _load(_art[speaker])


func _load(path: String) -> Texture2D:
	if _tex.has(path):
		return _tex[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		Log.warn("hud", "no portrait art at %s" % path)
	_tex[path] = tex
	return tex
