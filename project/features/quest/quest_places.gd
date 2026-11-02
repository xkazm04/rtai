class_name QuestPlaces
extends RefCounted
## The words a quest package names places and things with, resolved to the world
## (gtai.questMarkers/1, the spike's markers table). A beat's `location` is a marker, an
## enter-vehicle `target` a vehicle tag, a kill/escort `target` an actor tag. Positions are metres.
## The world supplies this table (QuestWorld.places()); the quest never invents a position.

const SCHEMA: String = "gtai.questMarkers/1"


class Marker:
	extends RefCounted
	var at: Vector2 = Vector2.ZERO
	var radius_m: float = 2.0
	## Where the job's payphone stands when this marker is a quest's first location.
	var phone: Vector2 = Vector2.ZERO


class Actor:
	extends RefCounted
	var at: Vector2 = Vector2.ZERO
	var kind: StringName = &"cop"
	var ally: bool = false
	var hp: float = 1.0


var markers: Dictionary[String, Marker] = {}
var vehicles: Dictionary[String, Vector2] = {}
var vehicle_headings: Dictionary[String, float] = {}
var actors: Dictionary[String, Actor] = {}
var _errors: Array[String] = []


static func from_json_text(text: String) -> QuestPlaces:
	var places: QuestPlaces = QuestPlaces.new()
	var raw: Dictionary = QuestJson.parse_object(text)
	if raw.get("schema") != SCHEMA:
		places._errors.append("places.schema: expected %s (or not a JSON object)" % SCHEMA)
		return places
	places._read_markers(raw.get("markers"))
	places._read_vehicles(raw.get("vehicles"))
	places._read_actors(raw.get("actors"))
	return places


func errors() -> Array[String]:
	return _errors.duplicate()


func ok() -> bool:
	return _errors.is_empty()


func _read_markers(raw: Variant) -> void:
	for tag: String in _rows(raw, "markers"):
		var row: Dictionary = _row(raw, tag)
		var m: Marker = Marker.new()
		m.at = _vec(row.get("at"), "markers.%s.at" % tag)
		m.radius_m = _num(row.get("r", 2.0), "markers.%s.r" % tag)
		m.phone = _vec(row.get("phone", row.get("at")), "markers.%s.phone" % tag)
		markers[tag] = m


func _read_vehicles(raw: Variant) -> void:
	for tag: String in _rows(raw, "vehicles"):
		var row: Dictionary = _row(raw, tag)
		vehicles[tag] = _vec(row.get("at"), "vehicles.%s.at" % tag)
		vehicle_headings[tag] = _num(row.get("heading", 0.0), "vehicles.%s.heading" % tag)


func _read_actors(raw: Variant) -> void:
	for tag: String in _rows(raw, "actors"):
		var row: Dictionary = _row(raw, tag)
		var a: Actor = Actor.new()
		a.at = _vec(row.get("at"), "actors.%s.at" % tag)
		a.kind = StringName(str(row.get("kind", "cop")))
		a.ally = row.get("side", "hostile") == "ally"
		a.hp = _num(row.get("hp", 1.0), "actors.%s.hp" % tag)
		actors[tag] = a


## The tags of a section whose every row is an object, in sorted order.
func _rows(raw: Variant, section: String) -> Array[String]:
	var tags: Array[String] = []
	if not raw is Dictionary:
		_errors.append("places.%s: missing or not an object" % section)
		return tags
	var d: Dictionary = raw
	for key: Variant in d.keys():
		if key is String and d[key] is Dictionary:
			tags.append(str(key))
		else:
			_errors.append("places.%s.%s: not an object" % [section, key])
	tags.sort()
	return tags


func _row(raw: Variant, tag: String) -> Dictionary:
	var section: Dictionary = raw
	var row: Dictionary = section[tag]
	return row


func _vec(raw: Variant, at: String) -> Vector2:
	if not QuestJson.is_vec(raw):
		_errors.append("places.%s: needs [x, y] in metres" % at)
	return QuestJson.vec(raw)


func _num(raw: Variant, at: String) -> float:
	if not QuestJson.is_num(raw):
		_errors.append("places.%s: not a number" % at)
	return QuestJson.num(raw, 0.0)
