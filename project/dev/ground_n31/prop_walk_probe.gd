extends RefCounted
## n31-21: one walk of Rivet at a prop (see prop_walk.gd). Coordinates are arena metres, a gauntlet
## probe's x is local to its segment. `edge` and `pass_to` are values along the walk's axis.

var id: String = ""
var segment: String = ""
var start: Vector2 = Vector2.ZERO
var dir: Vector2i = Vector2i.ZERO
var edge: float = 0.0
var pass_to: float = INF
var ticks: int = 300
var mode: String = "stop"


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
		"dir": [dir.x, dir.y],
	}
