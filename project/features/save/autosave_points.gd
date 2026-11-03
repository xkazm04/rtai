class_name AutosavePoints
extends RefCounted
## The quest package's optional top-level `autosavePoints` (gtai.quest/1): where the designer
## wants the game to autosave. Each point: {id, beat, at: "start"|"end", why}. Validated against
## the package's beats[]; every problem names its point (an unknown beat id is a load-time
## error). The quest's end is always an autosave (SAV-08), declared or not.

const AT_START: String = "start"
const AT_END: String = "end"
const QUEST_END: String = "quest-end"


class Point:
	extends RefCounted
	var id: String = ""
	var beat: String = ""
	var at: String = AT_START
	var why: String = ""


class Result:
	extends RefCounted
	var points: Array[Point] = []
	var errors: Array[String] = []

	func ok() -> bool:
		return errors.is_empty()

	## The point declared at `beat`'s `at` edge, or null.
	func at_edge(beat: String, at: String) -> Point:
		for p: Point in points:
			if p.beat == beat and p.at == at:
				return p
		return null


## Reads `raw["autosavePoints"]` (absent is fine: no declared points) against `raw["beats"]`.
static func read(raw: Dictionary) -> Result:
	var out: Result = Result.new()
	var raw_points: Variant = raw.get("autosavePoints", [])
	if not raw_points is Array:
		out.errors.append("autosavePoints: not an array")
		return out
	var declared: Array = raw_points
	var beat_ids: Dictionary[String, bool] = _beat_ids(raw)
	var seen: Dictionary[String, bool] = {}
	for i: int in declared.size():
		var p: Point = _point(declared[i], i, beat_ids, seen, out)
		if p != null:
			out.points.append(p)
	return out


static func _beat_ids(raw: Dictionary) -> Dictionary[String, bool]:
	var ids: Dictionary[String, bool] = {}
	var raw_beats: Variant = raw.get("beats", [])
	var beats: Array = raw_beats if raw_beats is Array else []
	for b: Variant in beats:
		var beat: Dictionary = b if b is Dictionary else {}
		var id: Variant = beat.get("id")
		if id is String:
			ids[id] = true
	return ids


static func _point(
	v: Variant,
	i: int,
	beat_ids: Dictionary[String, bool],
	seen: Dictionary[String, bool],
	out: Result
) -> Point:
	var at: String = "autosavePoints[%d]" % i
	if not v is Dictionary:
		out.errors.append("%s: not an object" % at)
		return null
	var d: Dictionary = v
	var p: Point = Point.new()
	p.id = str(d.get("id", "")) if d.get("id") is String else ""
	p.beat = str(d.get("beat", "")) if d.get("beat") is String else ""
	p.at = str(d.get("at", "")) if d.get("at") is String else ""
	p.why = str(d.get("why", "")) if d.get("why") is String else ""
	if p.id != "":
		at = "autosavePoints[%d] '%s'" % [i, p.id]
	var before: int = out.errors.size()
	if p.id == "":
		out.errors.append("%s: missing id" % at)
	elif seen.has(p.id):
		out.errors.append("%s: duplicate id" % at)
	seen[p.id] = true
	if not beat_ids.has(p.beat):
		out.errors.append("%s: beat '%s' is not in beats[]" % [at, p.beat])
	if p.at != AT_START and p.at != AT_END:
		out.errors.append("%s: at must be 'start' or 'end', got '%s'" % [at, p.at])
	if p.why.strip_edges() == "":
		out.errors.append("%s: missing why" % at)
	return p if out.errors.size() == before else null


## The declared points of `<root>/<id>/quest.json`, validated; an unreadable file is an error.
static func load_file(id: String, root: String = "res://quests") -> Result:
	var path: String = root.path_join(id).path_join("quest.json")
	var parser: JSON = JSON.new()
	if not FileAccess.file_exists(path) or parser.parse(FileAccess.get_file_as_string(path)) != OK:
		var failed: Result = Result.new()
		failed.errors.append("%s: not readable as JSON" % path)
		return failed
	var doc: Dictionary = {}
	if parser.data is Dictionary:
		doc = parser.data
	return read(doc)
