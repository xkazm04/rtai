class_name QuestJson
extends RefCounted
## Typed reads of parsed JSON for the quest loaders (DAT-05: JSON numbers arrive as floats;
## cast them). JSON is parsed with the JSON class only, never str_to_var (SEC-02).


## The parsed object, or an empty Dictionary when the text is not a JSON object.
static func parse_object(text: String) -> Dictionary:
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return {}
	var out: Dictionary = json.data
	return out


static func is_num(value: Variant) -> bool:
	return value is float or value is int


static func num(value: Variant, fallback: float) -> float:
	if not is_num(value):
		return fallback
	var number: float = value
	return number


static func is_text(value: Variant) -> bool:
	return value is String and value != ""


## True when the value is [x, y] (two numbers).
static func is_vec(value: Variant) -> bool:
	if not value is Array:
		return false
	var a: Array = value
	return a.size() == 2 and is_num(a[0]) and is_num(a[1])


## [x, y] in metres -> Vector2 (zero when malformed: check is_vec first).
static func vec(value: Variant) -> Vector2:
	if not is_vec(value):
		return Vector2.ZERO
	var a: Array = value
	return Vector2(num(a[0], 0.0), num(a[1], 0.0))


## Each item as a String (str() of anything else); empty when it is not an array.
static func strings(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if value is Array:
		var a: Array = value
		for item: Variant in a:
			out.append(str(item))
	return out
