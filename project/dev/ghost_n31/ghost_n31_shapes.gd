class_name GhostN31Shapes
extends RefCounted
## n31 measure (dev only): foe cluster shapes sampled from gauntlet play. A shape is N foe
## offsets from their centroid plus Rivet's offset from it, at a moment the deploy bot would
## drop Tonnage. Stored as shapes.json beside this script.

const SIZES: Array[int] = [4, 8, 12]
const SCHEMA: String = "gtai.ghost-n31-shapes/1"


static func centroid(points: Array[Vector2]) -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	for p: Vector2 in points:
		sum += p
	return sum / maxf(1.0, points.size())


## Indices of the tightest n points: around each point its n nearest (itself included), the
## set with the smallest summed distance wins. Empty when there are fewer than n points.
static func densest(points: Array[Vector2], n: int) -> Array[int]:
	var best: Array[int] = []
	var low: float = INF
	if n < 1 or points.size() < n:
		return best
	for i: int in points.size():
		var order: Array[int] = []
		for j: int in points.size():
			order.append(j)
		var from: Vector2 = points[i]
		order.sort_custom(
			func(a: int, b: int) -> bool:
				return from.distance_squared_to(points[a]) < from.distance_squared_to(points[b])
		)
		var pick: Array[int] = order.slice(0, n)
		var total: float = 0.0
		for k: int in pick:
			total += from.distance_to(points[k])
		if total < low:
			low = total
			best = pick
	return best


## One shape row: offsets of the picked points and of Rivet from their centroid, rounded to cm.
static func shape(points: Array[Vector2], picked: Array[int], rivet: Vector2) -> Dictionary:
	var chosen: Array[Vector2] = []
	for i: int in picked:
		chosen.append(points[i])
	var mid: Vector2 = centroid(chosen)
	var foes: Array = []
	for p: Vector2 in chosen:
		foes.append([snappedf(p.x - mid.x, 0.01), snappedf(p.y - mid.y, 0.01)])
	var back: Vector2 = rivet - mid
	return {"foes": foes, "rivet": [snappedf(back.x, 0.01), snappedf(back.y, 0.01)]}


## size -> Array of {"foes": Array[Vector2], "rivet": Vector2}; empty on any malformed row.
static func parse(text: String) -> Dictionary:
	var out: Dictionary = {}
	var raw: Variant = JSON.parse_string(text)
	var root: Dictionary = raw if raw is Dictionary else {}
	if root.get("schema", "") != SCHEMA:
		return {}
	var sizes: Dictionary = root.get("sizes", {})
	for key: String in sizes:
		var rows: Array = []
		for row: Dictionary in sizes[key]:
			var foes: Array[Vector2] = []
			for p: Array in row.get("foes", []):
				foes.append(_vec(p))
			var r: Array = row.get("rivet", [])
			if foes.size() != key.to_int() or r.size() != 2:
				return {}
			rows.append({"foes": foes, "rivet": _vec(r), "seed": row.get("seed", 0)})
		out[key.to_int()] = rows
	return out


static func _vec(pair: Array) -> Vector2:
	var x: float = pair[0]
	var y: float = pair[1]
	return Vector2(x, y)


## Up to k rows spread evenly over the list (first and last kept).
static func spread(rows: Array, k: int) -> Array:
	if rows.size() <= k:
		return rows.duplicate()
	var out: Array = []
	for i: int in k:
		out.append(rows[roundi(float(i) * (rows.size() - 1) / maxf(1.0, k - 1))])
	return out
