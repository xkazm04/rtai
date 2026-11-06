class_name ArenaPropCards
extends RefCounted
## The arena's cover standing up as the city's prop cards under an angled card view (night n8,
## city's REQUEST to view): a cone, a dumpster (cover_high) and a crate row (cover_low, one stack
## per square cell along the box) draw from city's `PropCards.draw_named` with the foot on the
## prop's south edge, instead of the view lab's lifted face + flat top. City owns PropCards; until
## its branch is merged the script is absent and every call returns false (the face draws as
## before). `top`, perspective top_lift and the flat views never reach here. Render only.

const SCRIPT: String = "res://features/city/view/prop_cards.gd"
## Prop kind -> PropCards name. Walls stay architecture (the barrier / ink bar).
const CARD: Dictionary[String, String] = {
	"cone": "traffic_cone", "cover_high": "dumpster", "cover_low": "crate_stack"
}

## The PropCards script, looked up once (null: city not merged).
static var _script: Script = null
static var _looked: bool = false


## Draws prop kind `kind` over ground rect `r` (local px) on `ci` as cards; false = draw as today.
static func draw(ci: CanvasItem, kind: String, r: Rect2) -> bool:
	if not CARD.has(kind):
		return false
	var cards: Object = _cards()
	if cards == null:
		return false
	var name: String = CARD[kind]
	if kind != "cover_low":
		return cards.call("draw_named", ci, name, _foot(r), Ink.PX_PER_M) == true
	var feet: Array[Vector2] = row_feet(r)
	for i: int in feet.size():
		if cards.call("draw_named", ci, name, feet[i], Ink.PX_PER_M) != true:
			return false
	return true


## A crate row's card feet: one per square cell along the box's long side, on its south edge,
## drawn north first (a north-south row overlaps south over north).
static func row_feet(r: Rect2) -> Array[Vector2]:
	var side: float = minf(r.size.x, r.size.y)
	var n: int = maxi(roundi(maxf(r.size.x, r.size.y) / maxf(side, 0.001)), 1)
	var out: Array[Vector2] = []
	for i: int in n:
		if r.size.x >= r.size.y:
			out.append(Vector2(r.position.x + r.size.x * (float(i) + 0.5) / float(n), r.end.y))
		else:
			out.append(Vector2(r.get_center().x, r.position.y + r.size.y * float(i + 1) / float(n)))
	return out


static func _foot(r: Rect2) -> Vector2:
	return Vector2(r.get_center().x, r.end.y)


static func _cards() -> Object:
	if not _looked:
		_looked = true
		if ResourceLoader.exists(SCRIPT):
			_script = load(SCRIPT) as Script
	if _script == null:
		return null
	var got: Variant = _script.call("named")
	return got if got is Object else null
