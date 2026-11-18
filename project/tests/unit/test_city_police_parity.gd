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


## Heat 2 on CityRoadMap: two dispatched cars (east and west), an undispatched one, foot cops;
## the cars park, crews get out, then heat 0 sends everyone on. Bit for bit, every tick.
func test_the_car_ladder_is_bit_exact_native_vs_reference() -> void:
	if not CitySimNative.available():
		pending("no native library in this build")
		return
	var ref: CitySimBackend = CitySimRef.new()
	var nat: CitySimBackend = CitySimNative.new()
	var tune: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4, 2.0, 12.0]
	for sim: CitySimBackend in [ref, nat]:
		CityRoadMap.paint(sim)
		sim.set_police(tune)
		assert_gte(CityRoadMap.dispatch_car(sim, 262.0), 0)
		var west: Array = [SimConst.K_PCAR, 380.0, CityRoadMap.LANE_W, -1.0, 0.0, 8]
		west.append_array([SimConst.F_PROMOTED | SimConst.F_ENGAGED, 17.0, CityRoadMap.LANE_W, 2])
		assert_gte(sim.spawn(PackedFloat64Array(west)), 0)
		var idle: Array = [SimConst.K_PCAR, 300.0, CityRoadMap.LANE_E, 1.0, 0.0, 8, 1, 17.0]
		assert_gte(sim.spawn(PackedFloat64Array(idle + [CityRoadMap.LANE_E, 0])), 0)
		for k: int in 4:
			assert_gte(CityWallMap.spawn_cop(sim, Vector2(280.5 + 12.0 * k, 300.5)), 0)
		sim.set_heat(2, 340.5, 317.5)
	var cops_max: int = 0
	for t: int in 1200:
		if t == 900:
			for sim: CitySimBackend in [ref, nat]:
				sim.set_heat(0, 340.5, 317.5)
		for sim: CitySimBackend in [ref, nat]:
			sim.step(SimClock.TICK_DT, 320.0, 320.0, 270.5, 290.5)
		if ref.snapshot() != nat.snapshot():
			fail_test("car ladder diverged at tick %d" % t)
			return
		cops_max = maxi(cops_max, ref.get_counters()[SimConst.CN_COPS])
	gut.p("car ladder parity: 1200 ticks bit for bit, up to %d cops (4 foot + crews)" % cops_max)
	assert_eq(cops_max, 8, "both dispatched cars unloaded their crews")


## Heat 3 on CityRoadMap.paint_cross: a dispatched car unloads a riot / SWAT squad, a roadblock of
## two parked cruisers stands past the junction, a westbound car brakes behind it; then heat 0
## lifts it all. Bit for bit, every tick, the art variants too.
func test_the_heat_3_squad_and_roadblock_are_bit_exact_native_vs_reference() -> void:
	if not CitySimNative.available():
		pending("no native library in this build")
		return
	var ref: CitySimBackend = CitySimRef.new()
	var nat: CitySimBackend = CitySimNative.new()
	var tune: PackedFloat64Array = [
		0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4, 2.0, 12.0, 4.0, 4.0, 6.0, 8.0
	]
	for sim: CitySimBackend in [ref, nat]:
		CityRoadMap.paint_cross(sim)
		sim.set_police(tune)
		sim.set_heat(3, 340.5, 317.5)
		assert_gte(CityRoadMap.dispatch_car(sim, 262.0), 0)
		var rb: CityRoadblock = CityRoadblock.new()
		rb.delay_ticks = 0
		rb.ahead_m = Vector2(10.0, 90.0)
		@warning_ignore("return_value_discarded")
		rb.step(sim, 0, 3, Vector2(250.0, 322.0))
		@warning_ignore("return_value_discarded")
		rb.step(sim, 1, 3, Vector2(254.0, 322.0))
		assert_eq(rb.placed, 2)
		var car: Array = [SimConst.K_CAR, 330.0, CityRoadMap.LANE_W, -1.0, 0.0, 0, 0, 12.0]
		assert_gte(sim.spawn(PackedFloat64Array(car + [CityRoadMap.LANE_W, 2])), 0)
	var cops_max: int = 0
	for t: int in 1200:
		if t == 900:
			for sim: CitySimBackend in [ref, nat]:
				sim.set_heat(0, 340.5, 317.5)
		for sim: CitySimBackend in [ref, nat]:
			sim.step(SimClock.TICK_DT, 320.0, 320.0, 270.5, 290.5)
		if ref.snapshot() != nat.snapshot() or ref.get_variants() != nat.get_variants():
			fail_test("heat 3 ladder diverged at tick %d" % t)
			return
		cops_max = maxi(cops_max, ref.get_counters()[SimConst.CN_COPS])
	gut.p("heat 3 parity: 1200 ticks bit for bit, up to %d cops (the squad)" % cops_max)
	assert_eq(cops_max, 4, "the dispatched car unloaded a squad of 4")
