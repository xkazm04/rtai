class_name DataTable
extends RefCounted
## One JSON table read as data (DAT-02/05, SEC-02: the JSON class, never str_to_var or .tres),
## with typed accessors that record a problem instead of crashing. A loader reads every field it
## needs through num()/integer()/vec()/text()/object(), then checks ok() before it builds.

var raw: Dictionary = {}
var _errors: Array[String] = []
var _name: String = ""


## Reads `path` and checks its `schema` field is `schema_id`.
static func open(path: String, schema_id: String) -> DataTable:
	return parse(FileAccess.get_file_as_string(path), schema_id, path.get_file())


static func parse(json: String, schema_id: String, name: String) -> DataTable:
	var t: DataTable = DataTable.new()
	t._name = name
	var parsed: Variant = JSON.parse_string(json)
	if not parsed is Dictionary:
		t._errors.append("%s: not a JSON object" % name)
		return t
	t.raw = parsed
	if t.raw.get("schema") != schema_id:
		t._errors.append("%s.schema: expected %s" % [name, schema_id])
	return t


func ok() -> bool:
	return _errors.is_empty()


func errors() -> Array[String]:
	return _errors.duplicate()


func num(d: Dictionary, key: String) -> float:
	var v: Variant = d.get(key)
	if v is float:
		return v
	if v is int:
		var i: int = v
		return float(i)
	_errors.append("%s.%s: not a number" % [_name, key])
	return 0.0


func integer(d: Dictionary, key: String) -> int:
	return roundi(num(d, key))


func text(d: Dictionary, key: String) -> String:
	var v: Variant = d.get(key)
	if not v is String:
		_errors.append("%s.%s: not a string" % [_name, key])
		return ""
	return v


func vec(d: Dictionary, key: String) -> Vector2:
	var v: Variant = d.get(key)
	var a: Array = v if v is Array else []
	if a.size() != 2:
		_errors.append("%s.%s: needs [x, y]" % [_name, key])
		return Vector2.ZERO
	return Vector2(num({"x": a[0]}, "x"), num({"y": a[1]}, "y"))


func object(d: Dictionary, key: String) -> Dictionary:
	var v: Variant = d.get(key)
	if not v is Dictionary:
		_errors.append("%s.%s: not an object" % [_name, key])
		return {}
	return v


func array(d: Dictionary, key: String) -> Array:
	var v: Variant = d.get(key)
	if not v is Array:
		_errors.append("%s.%s: not an array" % [_name, key])
		return []
	return v
