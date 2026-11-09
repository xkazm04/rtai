class_name StreetQuestDeadPush
extends RefCounted
## it22 / n10: keeps quest 1's dead off each other. A body falling within SPACE_M of one already
## lying is pushed off it, measured between the drawn cell centres, relaxed over PUSH_PASSES so
## neighbours on two sides do not cancel, capped at PUSH_MAX_M, and fixed at first sight so the
## earlier dead never move. Dock 9's crossing heaped five into one blob at 64 px/m. View only.

## Drawn bodies are about 2 m across at 64 px/m. Judged on Dock 9 settled (t13900; a body under
## FALL_TICKS old is still sliding into its push, and reads as a stack): 1.9 / 2.2 leaves a hand
## touching, 2.3 / 3.0 throws a body 3 m off its blood. 0 = no push. n11: the bodies drawn at
## StreetDeadPlan.LYING_K need less room, and a 2.4 m push read as a body gliding across the floor.
const SPACE_M: float = 1.5
const PUSH_MAX_M: float = 1.8
const PUSH_PASSES: int = 8
## The search for a clear spot when relaxation leaves an overlap: RINGS circles out to PUSH_MAX_M.
const RINGS: int = 8
const RING_STEPS: int = 16

static var _pushed: Dictionary[int, Vector2] = {}
## Each corpse's cell centre before its push (px): a body is drawn a pelvis along its head from his
## spot, so spots alone call a touching pair apart.
static var _centres: Dictionary[int, Vector2] = {}


## The push of `actor` (cell centre `centre`) off every other body in StreetDeadPlan's memory; a
## body with a stored centre is measured from it, plus its own push. `blocked` (px -> bool, the
## city's solid test; unset = open ground): a pushed body never ends on one.
static func push_of(
	actor: int, centre: Vector2, px_per_m: float, blocked: Callable = Callable()
) -> Vector2:
	if _pushed.has(actor):
		return _pushed[actor]
	var push: Vector2 = Vector2.ZERO
	var others: Array[Vector2] = _others_of(actor)
	for pass_i: int in PUSH_PASSES:
		for o: Vector2 in others:
			push += _shove(centre + push - o, SPACE_M * px_per_m, actor)
	push = push.limit_length(PUSH_MAX_M * px_per_m)
	var walled: bool = push != Vector2.ZERO and blocked.is_valid() and blocked.call(centre + push)
	if walled or not _is_clear(centre + push, others, SPACE_M * px_per_m):
		push = _nearest_clear(centre, others, px_per_m, actor, blocked)
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


## n10: relaxation in a crowd can end on a spot that still overlaps a neighbour (the last shove
## undoes the first), so that body takes the nearest clear spot on growing rings, each body starting
## its rings at its own angle; none clear within PUSH_MAX_M = the spot that clears the nearest most
## (no push at all when every spot is `blocked`).
static func _nearest_clear(
	centre: Vector2, others: Array[Vector2], px_per_m: float, actor: int, blocked: Callable
) -> Vector2:
	var r: float = SPACE_M * px_per_m
	var cap: float = PUSH_MAX_M * px_per_m
	var best: Vector2 = Vector2.ZERO
	var best_gap: float = -1.0
	for ring: int in range(1, RINGS + 1):
		var offset: float = float(actor) * 2.399
		for step_i: int in RING_STEPS:
			var p: Vector2 = (
				Vector2.from_angle(offset + TAU * step_i / RING_STEPS) * cap * ring / RINGS
			)
			if blocked.is_valid() and blocked.call(centre + p):
				continue
			var gap: float = _nearest_gap(centre + p, others)
			if gap >= r:
				return p
			if gap > best_gap:
				best_gap = gap
				best = p
	return best


static func _is_clear(at: Vector2, others: Array[Vector2], r: float) -> bool:
	return _nearest_gap(at, others) >= r


## The distance from `at` to the nearest other body (INF with none).
static func _nearest_gap(at: Vector2, others: Array[Vector2]) -> float:
	var gap: float = INF
	for o: Vector2 in others:
		gap = minf(gap, at.distance_to(o))
	return gap


## The shove owed to a body `off` from a neighbour, to `r` (px); bodies on one spot part along a
## direction fixed by the id.
static func _shove(off: Vector2, r: float, actor: int) -> Vector2:
	var d: float = off.length()
	if d >= r:
		return Vector2.ZERO
	var along: Vector2 = off / d if d > 0.001 else Vector2.from_angle(float(actor) * 2.399)
	return along * (r - d)
