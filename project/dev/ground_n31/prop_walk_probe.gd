extends RefCounted
## n31-21: one walk of Rivet at a prop (see prop_walk.gd). Coordinates are arena metres, a gauntlet
## probe's x is local to its segment. `edge` and `pass_to` are values along the walk's axis.

const Place = preload("res://dev/ground_n31/prop_walk_place.gd")

var id: String = ""
var segment: String = ""
var start: Vector2 = Vector2.ZERO
var dir: Vector2i = Vector2i.ZERO
var edge: float = 0.0
var pass_to: float = INF
var ticks: int = 300
var mode: String = "stop"
var side: String = ""
var gap: float = 3.5
var hint: Rect2 = Rect2()
var has_hint: bool = false
var base: bool = false
var box_edge: float = NAN
var placed: String = "start as given"


func fill(row: Dictionary) -> void:
	id = str(row["id"])
	segment = str(row.get("segment", ""))
	var s: Array = row["start"]
	var d: Array = row["dir"]
	start = Vector2(num(s[0]), num(s[1]))
	dir = Vector2i(roundi(num(d[0])), roundi(num(d[1])))
	edge = num(row.get("edge", 0.0))
	pass_to = num(row.get("pass_to", INF))
	ticks = roundi(num(row.get("ticks", 300)))
	mode = str(row.get("mode", "stop"))
	side = str(row.get("side", ""))
	gap = num(row.get("gap", 3.5))
	var flag: bool = row.get("base", false)
	base = flag
	var h: Array = row.get("hint", [])
	if h.size() == 4:
		hint = Rect2(num(h[0]), num(h[1]), num(h[2]) - num(h[0]), num(h[3]) - num(h[1]))
		has_hint = true
		box_edge = num(row.get("box_edge", 0.0))


## Where this walk starts, in arena metres: a stop probe is placed from the sim's own solid rects
## (see prop_walk_place.gd); `edge` (the drawn art, from the audit) stays, `box_edge` follows.
func place(boxes: Array[Rect2], shift: float, radius: float) -> Vector2:
	if not has_hint:
		return Vector2(shift + start.x, start.y)
	var want: Rect2 = Rect2(hint.position + Vector2(shift, 0.0), hint.size)
	var finder: Place = Place.new(side, dir, gap)
	var at: Vector2 = finder.place(want, boxes, radius)
	placed = finder.note
	box_edge = finder.face - (shift if dir.x != 0 else 0.0)
	return at


static func num(v: Variant) -> float:
	var out: float = v
	return out


## Signed metres from `value` (an x or y along the walk's axis, plus `shift` on x) to `pos`,
## positive once `pos` is past it in the walking direction.
func along(pos: Vector2, shift: float, value: float) -> float:
	if dir.x != 0:
		return (pos.x - (value + shift)) * float(dir.x)
	return (pos.y - value) * float(dir.y)


func result(pos: Vector2, shift: float, walked: float, verdict: String) -> Dictionary:
	return {
		"id": id,
		"verdict": verdict,
		"mode": mode,
		"stop_m": snappedf(-along(pos, shift, edge), 0.001),
		"walked_m": snappedf(walked, 0.001),
		"rivet_m": [snappedf(pos.x - shift, 0.001), snappedf(pos.y, 0.001)],
		"edge": edge,
		"box_edge": box_edge if not is_nan(box_edge) else null,
		"box_m": null if is_nan(box_edge) else snappedf(-along(pos, shift, box_edge), 0.001),
		"placed": placed,
		"dir": [dir.x, dir.y],
	}
