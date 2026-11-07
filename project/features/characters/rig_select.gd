class_name RigSelect
extends RefCounted
## LOD 0 selection: the rows that get a full rig, the nearest `limit` people within `radius` of
## the focus (STANDARDS section 20: 16 nearest within 14 m). Rows with the PLAYER kind (Rivet)
## always win a slot. One pass, an insertion list of at most `limit` entries: O(n * limit).
## A fresh corpse (an actor in `pinned`: it died on its full rig less than CORPSE_HOLD_TICKS
## ago) takes a slot past the living `limit` (it ranks after every living row in the radius), so
## the body falling under Rivet's claw keeps its drawn fall instead of dropping to the crowd atlas
## the tick it dies, and no living person loses a rig for it (the arena has no atlas to fall back
## on). Street's REQUEST, city seed 5, actor 3000.

## The hold where a crowd atlas takes the corpse after it (the city): the death sprawl
## (RigClips.DEATH_RAMP_S 0.42 s) and the 1 s death beat after it.
const CORPSE_HOLD_TICKS: int = 90
## A host with no atlas (the arena, quest 1's stage) holds the corpse until it leaves the feed:
## dropped from its rig it would draw nothing at all.
const HOLD_NO_ATLAS: int = 1 << 30
## At most this many fresh corpses are pinned at once (a riot cannot fill LOD 0 with the dead).
const CORPSE_PINS: int = 4


static func nearest(
	feed: RigFeed, focus: Vector2, radius_px: float, limit: int, pinned: Dictionary[int, int] = {}
) -> PackedInt32Array:
	var best: PackedInt32Array = PackedInt32Array()
	var best_d: PackedFloat32Array = PackedFloat32Array()
	var tail: PackedInt32Array = PackedInt32Array()
	var r2: float = radius_px * radius_px
	for i: int in feed.count:
		var d2: float = feed.pos[i].distance_squared_to(focus)
		if feed.kinds[i] == BodyPlan.Kind.RIVET:
			d2 = -1.0
		elif d2 > r2:
			continue
		elif pinned.has(feed.ids[i]):
			@warning_ignore("return_value_discarded")
			tail.append(i)
			continue
		_insert(best, best_d, i, d2, limit)
	best.append_array(tail)
	return best


## Updates `died_at` (actor id -> the tick its rigged row was first seen DEAD) for the actors in
## `rigged` and returns the pinned set: those dead for fewer than `hold` ticks (at most
## CORPSE_PINS, the latest deaths first). Actors no longer rigged or no longer dead are dropped.
static func fresh_dead(
	feed: RigFeed,
	rigged: Dictionary[int, CutRig],
	died_at: Dictionary[int, int],
	tick: int,
	hold: int = CORPSE_HOLD_TICKS,
) -> Dictionary[int, int]:
	var seen: Dictionary[int, int] = {}
	for actor: int in rigged:
		var i: int = feed.ids.find(actor)
		if i >= 0 and i < feed.count and feed.has_flag(i, RigFeed.Flag.DEAD):
			seen[actor] = died_at.get(actor, tick)
	died_at.assign(seen)
	var out: Dictionary[int, int] = {}
	for actor: int in seen:
		if tick - seen[actor] < hold:
			out[actor] = seen[actor]
	while out.size() > CORPSE_PINS:
		var oldest: int = -1
		for actor: int in out:
			if oldest < 0 or out[actor] < out[oldest]:
				oldest = actor
		@warning_ignore("return_value_discarded")
		out.erase(oldest)
	return out


static func _insert(
	best: PackedInt32Array, best_d: PackedFloat32Array, i: int, d2: float, limit: int
) -> void:
	var n: int = best.size()
	if n >= limit and d2 >= best_d[n - 1]:
		return
	var at: int = n
	while at > 0 and best_d[at - 1] > d2:
		at -= 1
	@warning_ignore_start("return_value_discarded")
	best.insert(at, i)
	best_d.insert(at, d2)
	if best.size() > limit:
		best.resize(limit)
		best_d.resize(limit)
	@warning_ignore_restore("return_value_discarded")
