class_name ArenaPropCards
extends RefCounted
## The arena's cover standing up as the city's prop cards under an angled card view (night n8,
## city's REQUEST to view): a cone, a dumpster (cover_high) and a crate row (cover_low, one stack
## per square cell along the box) draw from city's `PropCards.draw_named` with the foot on the
## prop's south edge, instead of the view lab's lifted face + flat top. City owns PropCards; until
## its branch is merged the script is absent and every call returns false (the face draws as
## before). `top`, perspective top_lift and the flat views never reach here. Render only.

const SCRIPT: String = "res://features/city/view/prop_cards.gd"
const TABLE: String = "res://data/tables/city_facades.json"
## Prop kind -> PropCards name. Walls stay architecture (the barrier / ink bar).
const CARD: Dictionary[String, String] = {
	"cone": "traffic_cone", "cover_high": "dumpster", "cover_low": "crate_stack"
}

## The PropCards script, looked up once (null: city not merged).
static var _script: Script = null
static var _looked: bool = false
## The crate stack card's cell width (m), from city's table (city_facades.json props).
static var _crate_w_m: float = 3.2


## Draws prop kind `kind` over ground rect `r` (local px) on `ci` as cards; false = draw as today.
## A crate row's stacks are sized to the row (its cell spans the row's width), never wider than
## the cover the player collides with.
static func draw(ci: CanvasItem, kind: String, r: Rect2) -> bool:
	if not CARD.has(kind):
		return false
	var cards: Object = _cards()
	if cards == null:
		return false
	var name: String = CARD[kind]
	if kind != "cover_low":
		return cards.call("draw_named", ci, name, _foot(r), Ink.PX_PER_M) == true
	var ppm: float = r.size.x / _crate_w_m
	var feet: Array[Vector2] = row_feet(r)
	for i: int in feet.size():
		if cards.call("draw_named", ci, name, feet[i], ppm) != true:
			return false
	return true


## A crate row's card feet on the south edge of each stack: one for an east-west row (the stack
## spans it), one per square cell down a north-south row (drawn north first, south over north).
static func row_feet(r: Rect2) -> Array[Vector2]:
	if r.size.x >= r.size.y:
		return [_foot(r)]
	var n: int = maxi(roundi(r.size.y / maxf(r.size.x, 0.001)), 1)
	var out: Array[Vector2] = []
	for i: int in n:
		out.append(Vector2(r.get_center().x, r.position.y + r.size.y * float(i + 1) / float(n)))
	return out


static func _foot(r: Rect2) -> Vector2:
	return Vector2(r.get_center().x, r.end.y)


static func _cards() -> Object:
	if not _looked:
		_looked = true
		if ResourceLoader.exists(SCRIPT):
			_script = load(SCRIPT) as Script
			_crate_w_m = _cell_w_m("crate_stack", _crate_w_m)
	if _script == null:
		return null
	var got: Variant = _script.call("named")
	return got if got is Object else null


static func _cell_w_m(name: String, fallback: float) -> float:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return fallback
	var d: Dictionary = parser.data
	var props: Dictionary = d.get("props", {})
	var row: Dictionary = props.get(name, {})
	var w: float = row.get("cell_w_m", fallback)
	return w
