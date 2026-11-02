class_name RigSelect
extends RefCounted
## LOD 0 selection: the rows that get a full rig, the nearest `limit` people within `radius` of
## the focus (STANDARDS section 20: 16 nearest within 14 m). Rows with the PLAYER kind (Rivet)
## always win a slot. One pass, an insertion list of at most `limit` entries: O(n * limit).


static func nearest(
	feed: RigFeed, focus: Vector2, radius_px: float, limit: int
) -> PackedInt32Array:
	var best: PackedInt32Array = PackedInt32Array()
	var best_d: PackedFloat32Array = PackedFloat32Array()
	var r2: float = radius_px * radius_px
	for i: int in feed.count:
		var d2: float = feed.pos[i].distance_squared_to(focus)
		if feed.kinds[i] == BodyPlan.Kind.RIVET:
			d2 = -1.0
		elif d2 > r2:
			continue
		_insert(best, best_d, i, d2, limit)
	return best


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
