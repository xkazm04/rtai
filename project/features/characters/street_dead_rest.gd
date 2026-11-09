class_name StreetDeadRest
extends Node2D
## n10 world: a near corpse's rig goes back to the pool after its hold (RigSelect.CORPSE_HOLD_TICKS)
## and the baked crowd used to take the body over: at its sim point, not where the plan pose lay (a
## pelvis and a push away), in another pose, with no shadow or near side, a visible pop 1.5 s after
## every death. This keeps the plan pose's sprites where they lay until the corpse leaves the feed
## (the sim's despawn, or past the feed radius); the city skips its atlas cell (ids()). View only.
## ENABLED false = the swap (before).

const ENABLED: bool = true
## The kept bodies at most: past it the oldest goes back to the atlas.
const CAP: int = 48
## The sprites a lying body is made of, under its card, bottom first.
const PARTS: Array[String] = [
	StreetDeadHeading.SHADOW_NODE, StreetDeadHeading.SIDE_NODE, StreetDeadPlan.NODE
]

var _kept: Dictionary[int, Array] = {}


## Keeps `rig`'s plan pose as it comes off its rig, settled at the end of its fall. Nothing for a
## body not lying yet (no plan pose: the atlas draws its fall) or no longer a dead row of `feed`.
func adopt(rig: CutRig, feed: RigFeed) -> void:
	var card: Sprite2D = rig.head_card
	if not ENABLED or card == null or card.get_node_or_null(StreetDeadPlan.NODE) == null:
		return
	var i: int = feed.ids.find(rig.actor_id)
	if i < 0 or i >= feed.count or not feed.has_flag(i, RigFeed.Flag.DEAD):
		return
	StreetDeadPlan.draw(rig, card, StreetWalkerCards.row_of(rig), card.global_scale.x, 1.0)
	keep(rig.actor_id, card)


## Moves the lying sprites off `card` to this layer, where they lie, and restores the card.
func keep(actor: int, card: Sprite2D) -> void:
	if _kept.size() >= CAP:
		var oldest: int = _kept.keys()[0]
		drop(oldest)
	var parts: Array = []
	for part: String in PARTS:
		var sprite: Node2D = card.get_node_or_null(part) as Node2D
		if sprite != null:
			sprite.reparent(self)
			parts.append(sprite)
	_kept[actor] = parts
	card.self_modulate.a = 1.0
	card.remove_meta(StreetDeadPlan.FREE)


## `chosen` (feed rows) without the bodies kept here: one kept body never takes a rig again (a new
## rig has no blow to read, so the body would turn on it).
func free_of(chosen: PackedInt32Array, feed: RigFeed) -> PackedInt32Array:
	if _kept.is_empty():
		return chosen
	var out: PackedInt32Array = PackedInt32Array()
	for i: int in chosen:
		if not _kept.has(feed.ids[i]):
			@warning_ignore("return_value_discarded")
			out.append(i)
	return out


## Lets go of the bodies whose row left `feed` or got up.
func sync(feed: RigFeed) -> void:
	if _kept.is_empty():
		return
	var dead: Dictionary[int, bool] = {}
	for i: int in feed.count:
		if feed.has_flag(i, RigFeed.Flag.DEAD):
			dead[feed.ids[i]] = true
	for actor: int in _kept.keys():
		if not dead.has(actor):
			drop(actor)


## Removes a kept body's sprites.
func drop(actor: int) -> void:
	for part: Node2D in _kept.get(actor, []):
		remove_child(part)
		part.queue_free()
	@warning_ignore("return_value_discarded")
	_kept.erase(actor)


## The kept bodies' actor ids (the city's rig slots: their atlas cells stay undrawn).
func ids() -> PackedInt32Array:
	return PackedInt32Array(_kept.keys())
