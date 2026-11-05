extends RefCounted
## Dev-only: checks quest 1's ghost_cars (collect_call_city.json) against the city's walk cells: a
## car (three 1 m circles along its 4.6 m length, nose east) must overlap no building, prop, kerb
## or baked parked car. Prints each spot and every clear y row near it; exits 1 on a blocked spot.
## Run through res://dev/ghost-powers/ghost_cars_fit.gd.


func run() -> int:
	var layout: StageLayout = StageLayout.shipped(true)
	var cells: StageCells = StageCells.shipped()
	var pts: Array[Vector2] = layout.extent()
	for p: Vector2 in layout.ghost_cars:
		pts.append(p)
	@warning_ignore("return_value_discarded")
	cells.prewarm(pts)
	var bad: int = 0
	for p: Vector2 in layout.ghost_cars:
		var ok: bool = _fits(cells, p)
		bad += 0 if ok else 1
		var rows: PackedStringArray = PackedStringArray()
		for i: int in range(-16, 17):
			var q: Vector2 = p + Vector2(0.0, i * 0.5)
			if _fits(cells, q):
				@warning_ignore("return_value_discarded")
				rows.push_back("%.1f" % q.y)
		Log.info("fit", "car %s %s; clear y here: %s" % [p, "ok" if ok else "BLOCKED", rows])
	Log.info("fit", "rivet_start %s" % layout.rivet_start)
	return 1 if bad > 0 else 0


func _fits(cells: StageCells, p: Vector2) -> bool:
	for dx: float in [-1.4, 0.0, 1.4]:
		if not cells.clear(p + Vector2(dx, 0.0), 1.0):
			return false
	return true
