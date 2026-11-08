class_name StainCover
extends RefCounted
## How much of a corpse soak shows under the living (CorpseStains): 0 while a walker stands on
## the body, 1 once every walker is CorpseStains.CLEAR_M away.


## The soak's alpha at `at` (px) under the walkers `by_x` (px, sorted: Vector2 order, x first):
## only those within CLEAR_M in x (+1 px for the float32 edge) are measured (perf L23: the riot's
## ~15 soaks x ~260 rows were ~70 us a frame). minf is order-free, so the answer is exact.
static func cover(at: Vector2, by_x: PackedVector2Array) -> float:
	var a: float = 1.0
	var reach: float = CorpseStains.CLEAR_M * SimConst.PX_PER_M
	var clear2: float = pow(reach, 2.0)
	for k: int in range(by_x.bsearch(Vector2(at.x - reach - 1.0, -INF)), by_x.size()):
		var w: Vector2 = by_x[k]
		if w.x > at.x + reach + 1.0:
			break
		if at.distance_squared_to(w) < clear2:
			var m: float = at.distance_to(w) / SimConst.PX_PER_M
			a = minf(a, smoothstep(CorpseStains.COVER_M, CorpseStains.CLEAR_M, m))
	return a
