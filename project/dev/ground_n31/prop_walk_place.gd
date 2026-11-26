extends RefCounted
## n31-24: where a prop walk starts, from the solid rects the sim itself uses (arena walls),
## not from the dressing table. The prop is the solid nearest the dressing box (within 2 m)
## plus every solid touching it (legs, supports), which walk and stop as one. The lane runs
## through the centre of the member a walker meets first, slid sideways until a circle of
## Rivet's radius reaches it clear of every other solid. `note` says what was used.

var note: String = ""
var face: float = NAN
var _side: String
var _dir: Vector2i
var _gap: float
var _blocker: String = ""


func _init(side: String, dir: Vector2i, gap: float) -> void:
	_side = side
	_dir = dir
	_gap = gap


## The start in arena metres; sets `face` (the first face he meets, along the walk's axis, in the
## coordinates of `want`) and `note`.
func place(want: Rect2, boxes: Array[Rect2], radius: float) -> Vector2:
	var pick: int = -1
	var best: float = 2.0
	for i: int in boxes.size():
		var d: float = (boxes[i].get_center() - want.get_center()).length()
		if d <= best:
			best = d
			pick = i
	var box: Rect2 = want if pick < 0 else boxes[pick]
	note = "dressing box, no solid within 2 m"
	if pick >= 0:
		note = "own rect #%d, centre %.2f m from the dressing box" % [pick, best]
	var group: Array[Rect2] = [box]
	var others: Array[Rect2] = []
	_split(boxes, box, group, others)
	if group.size() > 1:
		note += ", joined by %d touching solids (legs, supports)" % (group.size() - 1)
	var at: Vector2 = _lane(group, others, radius)
	face = _first_face(group, at, radius)
	return at


func _split(boxes: Array[Rect2], box: Rect2, group: Array[Rect2], others: Array[Rect2]) -> void:
	var rest: Array[Rect2] = []
	for b: Rect2 in boxes:
		if b != box:
			rest.append(b)
	var grew: bool = true
	while grew:
		grew = false
		for b: Rect2 in rest.duplicate():
			for g: Rect2 in group:
				if (
					g.grow(0.05).intersects(b)
					and b.get_center().distance_to(box.get_center()) < 3.5
				):
					group.append(b)
					rest.erase(b)
					grew = true
					break
	others.append_array(rest)


func _first_face(group: Array[Rect2], at: Vector2, radius: float) -> float:
	var faces: Array[float] = []
	for g: Rect2 in group:
		var lo: float = g.position.y if _dir.x != 0 else g.position.x
		var hi: float = g.end.y if _dir.x != 0 else g.end.x
		var lane: float = at.y if _dir.x != 0 else at.x
		if lane > lo - radius and lane < hi + radius:
			faces.append(_face(g))
	if faces.is_empty():
		return _face(group[0])
	return faces.min() if _side == "W" or _side == "N" else faces.max()


func _face(g: Rect2) -> float:
	match _side:
		"W":
			return g.position.x
		"E":
			return g.end.x
		"N":
			return g.position.y
	return g.end.y


func _lane(group: Array[Rect2], others: Array[Rect2], radius: float) -> Vector2:
	var union: Rect2 = group[0]
	var lead: Rect2 = group[0]
	for g: Rect2 in group:
		union = union.merge(g)
		if _face(g) == _face(lead) or _beyond(g, lead):
			lead = g
	var c: Vector2 = lead.get_center()
	var span: float = (lead.size.y if _dir.x != 0 else lead.size.x) * 0.5 - 0.2
	var slide: float = 0.0
	while slide <= maxf(span, 0.0):
		for turn: float in [1.0, -1.0]:
			var from: Vector2 = _start_at(union, c, slide * turn)
			if _clear(from, others, radius):
				if slide > 0.0:
					note += "; lane slid %.1f m (a solid in the way: %s)" % [slide * turn, _blocker]
				return from
		slide += 0.4
	note += "; NO clear lane, started on the centre line"
	return _start_at(union, c, 0.0)


func _beyond(g: Rect2, lead: Rect2) -> bool:
	if _side == "W" or _side == "N":
		return _face(g) < _face(lead)
	return _face(g) > _face(lead)


func _start_at(box: Rect2, c: Vector2, off: float) -> Vector2:
	match _side:
		"W":
			return Vector2(box.position.x - _gap, c.y + off)
		"E":
			return Vector2(box.end.x + _gap, c.y + off)
		"N":
			return Vector2(c.x + off, box.position.y - _gap)
	return Vector2(c.x + off, box.end.y + _gap)


func _clear(from: Vector2, others: Array[Rect2], radius: float) -> bool:
	var to: Vector2 = from + Vector2(_dir) * (_gap + 0.1)
	var steps: int = ceili(from.distance_to(to) / 0.1)
	for k: int in steps + 1:
		var p: Vector2 = from.lerp(to, float(k) / float(steps))
		for o: Rect2 in others:
			if p.distance_to(p.clamp(o.position, o.end)) < radius + 0.02:
				_blocker = str(o)
				return false
	return true
