extends GutTest
## n18 police: the heat ladder bit for bit, native CitySim vs the GDScript reference (NAT-06).
## The parity gate (tools/tests/run_parity.mjs) runs at heat -1, so this run walks the ladder
## itself: heat 0 (walking), 1 (investigate, search, release), Rivet seen nearby (sight, fire),
## 3 then 2 then 0, on CityWallMap with eight cops and peds, every snapshot compared.

const CAM: Vector2 = Vector2(290.0, 300.0)
const TUNE: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 4.0, 3.0, 1.4]
## [from tick, level, last-seen x, y, Rivet x, y]
const PLAN: Array[Array] = [
	[0, 0, 0.0, 0.0, 320.5, 290.5],
	[60, 1, 288.5, 330.5, 320.5, 290.5],
	[700, 1, 285.5, 300.5, 286.5, 306.5],
	[900, 3, 296.5, 280.5, 296.5, 280.5],
	[1100, 2, 296.5, 280.5, 330.5, 280.5],
	[1300, 0, 296.5, 280.5, 330.5, 280.5],
]
const TICKS: int = 1500


func test_the_heat_ladder_is_bit_exact_native_vs_reference() -> void:
	if not CitySimNative.available():
		pending("no native library in this build")
		return
	var ref: CitySimBackend = CitySimRef.new()
	var nat: CitySimBackend = CitySimNative.new()
	for sim: CitySimBackend in [ref, nat]:
		CityWallMap.paint(sim, true)
		sim.set_police(TUNE)
		_populate(sim)
	var row: int = 0
	var engaged_max: int = 0
	for t: int in TICKS:
		var r: PackedFloat64Array = PackedFloat64Array(PLAN[mini(row, PLAN.size() - 1)])
		if row < PLAN.size() and int(r[0]) == t:
			for sim: CitySimBackend in [ref, nat]:
				sim.set_heat(int(r[1]), r[2], r[3])
			row += 1
		var at: PackedFloat64Array = PackedFloat64Array(PLAN[row - 1])
		for sim: CitySimBackend in [ref, nat]:
			sim.step(SimClock.TICK_DT, CAM.x, CAM.y, at[4], at[5])
		var a: PackedFloat64Array = ref.snapshot()
		var b: PackedFloat64Array = nat.snapshot()
		if a != b:
			fail_test("diverged at tick %d (%d vs %d floats)" % [t, a.size(), b.size()])
			return
		var ea: int = ref.flow_stats()[SimConst.FS_ENGAGED]
		assert_eq(ea, nat.flow_stats()[SimConst.FS_ENGAGED], "engaged count at tick %d" % t)
		engaged_max = maxi(engaged_max, ea)
	gut.p("heat ladder parity: %d ticks bit for bit, up to %d cops engaged" % [TICKS, engaged_max])
	assert_eq(engaged_max, 6, "heat 3 engaged every cop (the run reached the top rung)")


func _populate(sim: CitySimBackend) -> void:
	for k: int in 6:
		assert_gte(CityWallMap.spawn_cop(sim, Vector2(262.5 + 6.0 * k, 290.5)), 0)
	for k: int in 6:
		var spec: Array = [SimConst.K_PED, 270.5 + 3.0 * k, 310.5, 1.0, 0.0, 1, 0, 1.3, 0.0, 0]
		assert_gte(sim.spawn(PackedFloat64Array(spec)), 0)
