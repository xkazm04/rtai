extends GutTest
## n18 police item 7: CityHeat asks "does a live foot cop see this point?" every tick. It used to
## copy the whole sim snapshot and walk it; the sim answers it now (CitySimBackend.cop_sees, native
## flow.cpp and CitySimFlow op for op). The old snapshot walk stays here as the oracle: native,
## reference and oracle agree at every tick of a heat run on CityWallMap, over a grid of points.

const CAM: Vector2 = Vector2(290.0, 300.0)
const TUNE: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 4.0, 3.0, 1.4]
const RADII: Array[float] = [4.0, 12.0, 30.0]


func test_the_sim_answers_like_the_snapshot_walk_on_both_backends() -> void:
	var sims: Array[CitySimBackend] = [CitySimRef.new()]
	if CitySimNative.available():
		sims.append(CitySimNative.new())
	for sim: CitySimBackend in sims:
		CityWallMap.paint(sim, true)
		sim.set_police(TUNE)
		for k: int in 5:
			assert_gte(CityWallMap.spawn_cop(sim, Vector2(276.5 + 5.0 * k, 296.5)), 0)
		sim.set_heat(1, 306.5, 300.5)
	var asked: int = 0
	var seen: int = 0
	for t: int in 600:
		for sim: CitySimBackend in sims:
			sim.step(SimClock.TICK_DT, CAM.x, CAM.y, 306.5, 300.5)
		if t % 20 != 0:
			continue
		for p: Vector2 in _points():
			for r: float in RADII:
				var want: bool = _snapshot_walk(sims[0], p, r)
				for sim: CitySimBackend in sims:
					assert_eq(sim.cop_sees(p.x, p.y, r), want, "t %d at %s r %.0f" % [t, p, r])
				asked += 1
				seen += 1 if want else 0
	gut.p("cop_sees: %d questions, %d seen, %d backends" % [asked, seen, sims.size()])
	assert_gt(seen, 0, "some points were seen")
	assert_lt(seen, asked, "some were not (the wall or the radius)")


func test_nobody_sees_without_cops() -> void:
	var sim: CitySimBackend = CitySimRef.new()
	CityWallMap.paint(sim, true)
	assert_false(sim.cop_sees(290.5, 300.5, 50.0), "an empty map sees nothing")


func _points() -> Array[Vector2]:
	var out: Array[Vector2] = []
	for gx: int in range(270, 316, 6):
		for gy: int in range(284, 332, 8):
			out.append(Vector2(gx + 0.5, gy + 0.5))
	return out


## The pre-item-7 CityHeat.cop_sees, verbatim but for the call into the sim.
func _snapshot_walk(sim: CitySimBackend, at: Vector2, r: float) -> bool:
	var snap: PackedFloat64Array = sim.snapshot()
	var r2: float = r * r
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[k + 1]) != SimConst.K_COP or int(snap[k + 2]) == SimConst.M_DEAD:
			continue
		var dx: float = at.x - snap[k + 4]
		var dy: float = at.y - snap[k + 5]
		if dx * dx + dy * dy <= r2 and sim.sight(snap[k + 4], snap[k + 5], at.x, at.y):
			return true
	return false
