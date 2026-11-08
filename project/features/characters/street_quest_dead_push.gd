class_name StreetQuestDeadPush
extends RefCounted
## it22 / n10: keeps quest 1's dead off each other. A body falling within SPACE_M of one already
## lying is pushed off it, measured between the drawn cell centres, relaxed over PUSH_PASSES so
## neighbours on two sides do not cancel, capped at PUSH_MAX_M, and fixed at first sight so the
## earlier dead never move. Dock 9's crossing heaped five into one blob at 64 px/m. View only.

## Drawn bodies are about 2 m across at 64 px/m. Filmed at Dock 9's crossing: 1.9 / 2.2 leaves one
## touching pair and no stack; 2.1 / 3.0 and 2.3 / 2.4 stack two bodies. 0 = no push.
const SPACE_M: float = 1.9
const PUSH_MAX_M: float = 2.2
const PUSH_PASSES: int = 8

static var _pushed: Dictionary[int, Vector2] = {}
## Each corpse's cell centre before its push (px): a body is drawn a pelvis along its head from his
## spot, so spots alone call a touching pair apart.
static var _centres: Dictionary[int, Vector2] = {}


## The push of `actor` (cell centre `centre`) off every other body in StreetDeadPlan's memory; a
## body with a stored centre is measured from it, plus its own push.
static func push_of(actor: int, centre: Vector2, px_per_m: float) -> Vector2:
	if _pushed.has(actor):
		return _pushed[actor]
	var push: Vector2 = Vector2.ZERO
	var others: Array[Vector2] = _others_of(actor)
	for pass_i: int in PUSH_PASSES:
		for o: Vector2 in others:
			push += _shove(centre + push - o, SPACE_M * px_per_m, actor)
	push = push.limit_length(PUSH_MAX_M * px_per_m)
	if _pushed.size() >= StreetDeadPlan.MEMORY:
		reset()
	_pushed[actor] = push
	_centres[actor] = centre
	return push


## Forgets every push (tests; a new scene starts from no dead).
static func reset() -> void:
	_pushed.clear()
	_centres.clear()


## Where every other corpse lies now (px): its stored centre (its spot when it has none) + its push.
static func _others_of(actor: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for key: int in StreetDeadPlan._lying:
		if key != actor:
			var v: Vector3 = StreetDeadPlan._lying[key]
			out.append(_centres.get(key, Vector2(v.x, v.y)) + _pushed.get(key, Vector2.ZERO))
	return out


## The shove owed to a body `off` from a neighbour, to `r` (px); bodies on one spot part along a
## direction fixed by the id.
static func _shove(off: Vector2, r: float, actor: int) -> Vector2:
	var d: float = off.length()
	if d >= r:
		return Vector2.ZERO
	var along: Vector2 = off / d if d > 0.001 else Vector2.from_angle(float(actor) * 2.399)
	return along * (r - d)
